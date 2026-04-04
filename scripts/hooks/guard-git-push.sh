#!/usr/bin/env bash
# guard-git-push.sh — PreToolCall hook
# Blocks git push to main/master unless Architect persona with QA_APPROVED task in tasks/todo.md.
# If tasks/todo.md does not exist (new project), QA_APPROVED check is skipped.
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

# Helper: check if command targets main/master (branch name or refspec syntax)
targets_main() {
  echo "$1" | grep -qE '\s+(origin\s+)?(main|master)\s*$|\s+(origin\s+)?(main|master)\s' && return 0
  echo "$1" | grep -qE ':(main|master)(\s|$)' && return 0
  return 1
}

# Block push to main/master
if targets_main "$COMMAND"; then
  PERSONA="${ACTIVE_PERSONA:-unknown}"

  # Check persona first
  if [[ "$PERSONA" != "architect" ]]; then
    echo "BLOCKED: Only the Architect persona may push to main/master. Active persona: ${PERSONA}" >&2
    exit 2
  fi

  # Check QA_APPROVED exists in tasks/todo.md (skip if file doesn't exist — new project)
  if [[ -f "tasks/todo.md" ]]; then
    if ! grep -q "QA_APPROVED" "tasks/todo.md" 2>/dev/null; then
      echo "BLOCKED: No QA_APPROVED tasks found in tasks/todo.md. Get QA sign-off before pushing to main." >&2
      exit 2
    fi
  fi
fi

exit 0
