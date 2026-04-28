#!/usr/bin/env bash
# guard-memory-loaded.sh — PreToolUse enforcement hook
#
# v4.0: Advisory only — exits 0 in all cases, emits WARN if memory was not
# loaded this session. Exit 2 (blocking) promoted in v4.1 after one full cycle.
#
# Checks for flag file tasks/.memory-loaded-session-{N} where N is the current
# session number read from SESSION STATE in tasks/todo.md.
# Flag is written by session-open after a successful mcp__ak-memory__summary call.

set -euo pipefail

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
TODO_FILE="${PROJECT_ROOT}/tasks/todo.md"

# Extract session number from SESSION STATE "Last updated" field.
# Looks for patterns like "Session 25" in the Last updated line.
SESSION_NUM=""
if [[ -f "$TODO_FILE" ]]; then
  SESSION_NUM=$(grep -m1 'Last updated:' "$TODO_FILE" | grep -oE 'Session [0-9]+' | grep -oE '[0-9]+' | head -1 || true)
fi

# MCP primary path writes "state transition by MCP server" with no Session N — fall back to
# the audit log where every session-open run_id is "session-open-{N}-...".
AUDIT_LOG="${PROJECT_ROOT}/tasks/audit-log.md"
if [[ -z "$SESSION_NUM" ]] && [[ -f "$AUDIT_LOG" ]]; then
  SESSION_NUM=$(grep -oE 'session-open-[0-9]+' "$AUDIT_LOG" | tail -1 | grep -oE '[0-9]+' || true)
fi

if [[ -z "$SESSION_NUM" ]]; then
  # Cannot determine session number — warn but do not block
  printf '[MEMORY-GATE] WARN: could not determine session number from SESSION STATE — skipping memory check\n' >&2
  exit 0
fi

FLAG_FILE="${PROJECT_ROOT}/tasks/.memory-loaded-session-${SESSION_NUM}"

if [[ -f "$FLAG_FILE" ]]; then
  exit 0
fi

# Flag missing — memory was not loaded this session
printf '[MEMORY-GATE] WARN: memory not loaded this session (no flag: tasks/.memory-loaded-session-%s)\n' "$SESSION_NUM" >&2
printf '[MEMORY-GATE] Run mcp__ak-memory__summary before high-impact actions to load session memory.\n' >&2
printf '[MEMORY-GATE] v4.0: this is advisory only — action will proceed.\n' >&2

# v4.0: exit 0 (advisory). Change to exit 2 in v4.1 to enforce.
exit 0
