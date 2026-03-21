#!/usr/bin/env bash
set -euo pipefail

# new-session.sh
# Usage: new-session.sh <session_id> <sprint_id> <persona>
#
# Validates the project is bootstrapped, checks current SESSION STATE, and
# prints the ready-to-paste /session-open command block. Also appends a
# timestamped entry to channel.md.
#
# Valid personas: architect ba ux junior-dev qa researcher compliance

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Argument validation
# ---------------------------------------------------------------------------

if [[ $# -ne 3 ]]; then
  echo "ERROR: Exactly 3 arguments required."
  echo "Usage: $(basename "$0") <session_id> <sprint_id> <persona>"
  echo ""
  echo "Example: $(basename "$0") 4 2 architect"
  exit 1
fi

SESSION_ID="$1"
SPRINT_ID="$2"
PERSONA="$3"

# ---------------------------------------------------------------------------
# Validate persona
# ---------------------------------------------------------------------------

VALID_PERSONAS="architect ba ux junior-dev qa researcher compliance"

persona_valid=false
for p in $VALID_PERSONAS; do
  if [[ "$PERSONA" == "$p" ]]; then
    persona_valid=true
    break
  fi
done

if [[ "$persona_valid" == false ]]; then
  echo "ERROR: Unknown persona '${PERSONA}'."
  echo "Valid personas: ${VALID_PERSONAS}"
  exit 1
fi

# ---------------------------------------------------------------------------
# Prechecks: required project files
# ---------------------------------------------------------------------------

REQUIRED_FILES=(
  "CLAUDE.md"
  "tasks/todo.md"
  "channel.md"
  "releases/audit-log.md"
)

missing=false
for f in "${REQUIRED_FILES[@]}"; do
  if [[ ! -f "$f" ]]; then
    echo "ERROR: Required file not found: $f"
    missing=true
  fi
done

if [[ "$missing" == true ]]; then
  echo ""
  echo "Project not bootstrapped. Run scripts/bootstrap-project.sh first."
  exit 1
fi

# ---------------------------------------------------------------------------
# Read SESSION STATE from tasks/todo.md
# ---------------------------------------------------------------------------

TODO_FILE="tasks/todo.md"
CURRENT_STATUS="UNKNOWN"

# Extract the Status line from the SESSION STATE block
if grep -q "^Status:" "$TODO_FILE" 2>/dev/null; then
  CURRENT_STATUS="$(grep "^Status:" "$TODO_FILE" | head -1 | awk '{print $2}')"
fi

if [[ "$CURRENT_STATUS" == "OPEN" ]]; then
  echo "WARNING: SESSION STATE in tasks/todo.md is currently OPEN."
  echo "         A session may already be in progress."
  echo "         If this is stale, manually set Status to CLOSED in tasks/todo.md"
  echo "         before opening a new session."
  echo ""
fi

# ---------------------------------------------------------------------------
# Print ready-to-paste /session-open command block
# ---------------------------------------------------------------------------

TIMESTAMP="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

echo "----------------------------------------------------------------------"
echo "Session ready. Paste the block below into your Claude Code session:"
echo "----------------------------------------------------------------------"
echo ""
echo "/session-open"
echo "session_id:  ${SESSION_ID}"
echo "sprint_id:   ${SPRINT_ID}"
echo "persona:     ${PERSONA}"
echo "timestamp:   ${TIMESTAMP}"
echo ""
echo "----------------------------------------------------------------------"

# ---------------------------------------------------------------------------
# Append entry to channel.md
# ---------------------------------------------------------------------------

CHANNEL_FILE="channel.md"

{
  echo ""
  echo "## [${TIMESTAMP}] new-session.sh invoked"
  echo ""
  echo "- session_id:  ${SESSION_ID}"
  echo "- sprint_id:   ${SPRINT_ID}"
  echo "- persona:     ${PERSONA}"
  echo "- status_at_invoke: ${CURRENT_STATUS}"
  echo ""
} >> "$CHANNEL_FILE"

echo "Entry appended to channel.md."
