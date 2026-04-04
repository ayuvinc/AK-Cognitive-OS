#!/usr/bin/env bash
# auto-audit-log.sh — PostToolCall hook (Notification)
# Auto-appends audit entries after skill execution completes.
#
# Called after any slash command completes.
# Looks for output envelope fields in the tool result and appends to audit log.
#
# This is a best-effort hook — it will not block on failure.

set -euo pipefail

INPUT="$(cat)"

# Extract output from tool result
RESULT="$(echo "$INPUT" | python3 -c "
import sys, json, re
from datetime import datetime, timezone

data = json.load(sys.stdin)
output = data.get('tool_result', data.get('stdout', ''))
if not isinstance(output, str):
    output = json.dumps(output)

# Look for envelope fields
run_id = ''
agent = ''
status = ''
summary = ''

for line in output.splitlines():
    line = line.strip()
    if line.startswith('run_id:'):
        run_id = line.split(':', 1)[1].strip().strip('\"')
    elif line.startswith('agent:'):
        agent = line.split(':', 1)[1].strip().strip('\"')
    elif line.startswith('status:'):
        status = line.split(':', 1)[1].strip().strip('\"')
    elif line.startswith('summary:'):
        summary = line.split(':', 1)[1].strip().strip('\"')

if run_id and agent and status:
    ts = datetime.now(timezone.utc).strftime('%Y-%m-%dT%H:%M:%SZ')
    print(f'| {ts} | {agent} | {status} | {run_id} | {summary} |')
" 2>/dev/null || echo "")"

if [[ -z "$RESULT" ]]; then
  exit 0
fi

# Find audit log path
AUDIT_LOG=""
for candidate in "tasks/audit-log.md" "releases/audit-log.md"; do
  if [[ -f "$candidate" ]]; then
    AUDIT_LOG="$candidate"
    break
  fi
done

if [[ -z "$AUDIT_LOG" ]]; then
  exit 0
fi

echo "$RESULT" >> "$AUDIT_LOG"
exit 0
