#!/usr/bin/env bash
# session-integrity-check.sh — Stop hook (runs when Claude Code session ends)
# Warns if SESSION STATE is still OPEN when the user exits.
#
# This is advisory — prints warning to stderr, does not block exit.

set -euo pipefail

TODO_FILE="tasks/todo.md"

if [[ ! -f "$TODO_FILE" ]]; then
  exit 0
fi

# Check if session is still OPEN
if ! grep -q 'Status:.*OPEN' "$TODO_FILE" 2>/dev/null; then
  exit 0
fi

# Gather context for a useful warning

# 1. Next persona from tasks/next-action.md
NEXT_PERSONA=""
if [[ -f "tasks/next-action.md" ]]; then
  NEXT_PERSONA="$(python3 -c "
import sys
try:
    with open('tasks/next-action.md', 'r') as f:
        for line in f:
            line = line.strip()
            if line.lower().startswith('next_persona:'):
                val = line.split(':', 1)[1].strip().strip('\"').strip(\"'\")
                if val and val.lower() not in ('none', '[persona]'):
                    print(val)
                    break
except Exception:
    pass
" 2>/dev/null || echo "")"
fi

# 2. Open task count (PENDING or IN_PROGRESS) from tasks/todo.md
OPEN_TASKS="$(python3 -c "
import re
try:
    with open('tasks/todo.md', 'r') as f:
        content = f.read()
    matches = re.findall(r'^\- Status:\s+(PENDING|IN_PROGRESS)', content, re.MULTILINE)
    print(len(matches))
except Exception:
    print(0)
" 2>/dev/null || echo "0")"

echo "" >&2
echo "================================================================" >&2
echo "  WARNING: Session is still OPEN!" >&2
echo "================================================================" >&2
echo "" >&2
echo "  You are exiting without running /session-close." >&2
echo "  This means:" >&2
echo "    - SESSION STATE remains OPEN in tasks/todo.md" >&2
echo "    - tasks/next-action.md will not be updated" >&2
echo "    - Audit log will be missing SESSION_CLOSED entry" >&2
echo "    - Next session may start with stale context" >&2
echo "" >&2
if [[ -n "$NEXT_PERSONA" ]]; then
  echo "  Next persona: ${NEXT_PERSONA}" >&2
fi
echo "  Open tasks: ${OPEN_TASKS}" >&2
echo "" >&2
echo "  To fix: Re-open Claude Code and run /session-close" >&2
echo "================================================================" >&2

exit 0
