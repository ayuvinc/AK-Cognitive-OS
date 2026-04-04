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
if grep -q 'Status:.*OPEN' "$TODO_FILE" 2>/dev/null; then
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
  echo "  To fix: Re-open Claude Code and run /session-close" >&2
  echo "================================================================" >&2
fi

exit 0
