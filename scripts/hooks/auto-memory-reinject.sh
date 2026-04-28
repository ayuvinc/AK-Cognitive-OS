#!/usr/bin/env bash
# auto-memory-reinject.sh — PostToolUse hook, matcher: "compact"
#
# Fires after every Claude Code compaction event. Re-emits the last 20 lines
# of memory/MEMORY.md as a WARN block so the memory digest re-enters context
# immediately after compaction clears it.
#
# Advisory only — exits 0 in all cases. Never blocks.
# CLAUDE.md (system prompt) survives compaction; this hook covers mid-session
# memory that lives in conversation history and does not.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
MEMORY_FILE="${PROJECT_ROOT}/memory/MEMORY.md"

if [[ ! -f "$MEMORY_FILE" ]]; then
  exit 0
fi

LINES=$(tail -n 20 "$MEMORY_FILE" 2>/dev/null) || exit 0

if [[ -z "$LINES" ]]; then
  exit 0
fi

# Print the digest as a WARN block so it lands visibly in the next turn.
# Using printf to avoid any shell expansion of file content.
printf '\n[MEMORY-REINJECT] Compaction detected — re-surfacing memory digest:\n'
printf '%s\n' "$LINES"
printf '[/MEMORY-REINJECT]\n\n'

exit 0
