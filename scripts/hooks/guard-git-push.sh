#!/usr/bin/env bash
# guard-git-push.sh — PreToolCall hook
# Blocks git push to main/master unless Architect persona with QA_APPROVED.
#
# Called by Claude Code before Bash tool calls.
# Receives tool call info via stdin as JSON.
#
# Exit 0 = allow, Exit 2 = block with message on stderr

set -euo pipefail

INPUT="$(cat)"

COMMAND="$(echo "$INPUT" | python3 -c "
import sys, json
data = json.load(sys.stdin)
print(data.get('tool_input', {}).get('command', ''))
" 2>/dev/null || echo "")"

# Only care about git push commands
if ! echo "$COMMAND" | grep -qE '^\s*git\s+push'; then
  exit 0
fi

# Block force push always
if echo "$COMMAND" | grep -qE '\-\-force|\-f'; then
  echo "BLOCKED: Force push is not allowed. Use regular push only." >&2
  exit 2
fi

# Block push to main/master
if echo "$COMMAND" | grep -qE '\s+(origin\s+)?(main|master)\s*$|\s+(origin\s+)?(main|master)\s'; then
  PERSONA="${ACTIVE_PERSONA:-unknown}"
  if [[ "$PERSONA" != "architect" ]]; then
    echo "BLOCKED: Only the Architect persona may push to main/master. Active persona: ${PERSONA}" >&2
    exit 2
  fi
fi

exit 0
