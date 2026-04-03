#!/usr/bin/env bash
set -euo pipefail

[[ -n "${BASH_VERSION:-}" ]] || { echo "ERROR: Run with bash: bash scripts/new-session.sh"; exit 1; }

# new-session.sh
# Usage: new-session.sh <session_id> <sprint_id> <persona> [--mode greenfield|recovery]
#
# Validates the project is bootstrapped, checks current SESSION STATE, and
# prints the ready-to-paste /session-open command block. Also appends a
# timestamped entry to channel.md.
#
# Modes:
#   greenfield (default) — checks planning docs exist and are confirmed
#   recovery             — guides user to create current-state.md first
#
# Valid personas: architect ba ux junior-dev qa researcher compliance

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ---------------------------------------------------------------------------
# Argument validation
# ---------------------------------------------------------------------------

if [[ $# -lt 3 ]]; then
  echo "ERROR: At least 3 arguments required."
  echo "Usage: $(basename "$0") <session_id> <sprint_id> <persona> [--mode greenfield|recovery]"
  echo ""
  echo "Example: $(basename "$0") 4 2 architect"
  echo "Example: $(basename "$0") 4 2 architect --mode recovery"
  exit 1
fi

SESSION_ID="$1"
SPRINT_ID="$2"
PERSONA="$3"
shift 3

# Parse optional --mode flag
SESSION_MODE="greenfield"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --mode)
      shift
      if [[ $# -gt 0 && ("$1" == "greenfield" || "$1" == "recovery") ]]; then
        SESSION_MODE="$1"
      else
        echo "ERROR: --mode requires 'greenfield' or 'recovery'"
        exit 1
      fi
      ;;
    *) echo "WARNING: Unknown argument: $1" ;;
  esac
  shift
done

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
# Planning doc checks (mode-dependent)
# ---------------------------------------------------------------------------

if [[ "$SESSION_MODE" == "greenfield" ]]; then
  echo "Mode: greenfield"
  echo ""

  # Check problem-definition.md
  if [[ ! -f "docs/problem-definition.md" ]]; then
    echo "WARNING: docs/problem-definition.md not found."
    echo "         Run discovery conversation first. See guides/11-conversation-first-planning.md"
  else
    pd_status="$(grep '^Status:' docs/problem-definition.md 2>/dev/null | head -1 | awk '{print $2}' || true)"
    if [[ "$pd_status" != "confirmed" ]]; then
      echo "WARNING: docs/problem-definition.md has Status: ${pd_status:-unknown} (not confirmed)"
    fi
  fi

  # Check scope-brief.md
  if [[ ! -f "docs/scope-brief.md" ]]; then
    echo "WARNING: docs/scope-brief.md not found."
    echo "         Run discovery conversation first. See guides/11-conversation-first-planning.md"
  else
    sb_status="$(grep '^Status:' docs/scope-brief.md 2>/dev/null | head -1 | awk '{print $2}' || true)"
    if [[ "$sb_status" != "confirmed" ]]; then
      echo "WARNING: docs/scope-brief.md has Status: ${sb_status:-unknown} (not confirmed)"
    fi
  fi

  # Check hld.md (info level, not critical)
  if [[ ! -f "docs/hld.md" ]]; then
    echo "INFO:    docs/hld.md not found — recommended before multi-feature work."
  fi

  echo ""

elif [[ "$SESSION_MODE" == "recovery" ]]; then
  echo "Mode: mid-build recovery"
  echo ""

  if [[ ! -f "docs/current-state.md" ]]; then
    echo "WARNING: docs/current-state.md not found."
    echo "         Run recovery conversation first. See guides/12-mid-build-recovery.md"
    echo ""
    echo "Recovery conversation — 7 questions to ask:"
    echo "  1. What is this project supposed to achieve?"
    echo "  2. Who is the real user?"
    echo "  3. What is already built and working?"
    echo "  4. What is only planned or partially done?"
    echo "  5. What feels unclear or drifting?"
    echo "  6. What matters most right now?"
    echo "  7. What should be cut?"
  else
    cs_status="$(grep '^Status:' docs/current-state.md 2>/dev/null | head -1 | awk '{print $2}' || true)"
    echo "INFO:    docs/current-state.md exists (Status: ${cs_status:-unknown})"
  fi

  echo ""
fi

# Run Python validator in warn-only mode if available
FRAMEWORK_DIR_CHECK="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
if [[ -f "${FRAMEWORK_DIR_CHECK}/validators/runner.py" ]]; then
  echo "Running validators (warn-only)..."
  python3 "${FRAMEWORK_DIR_CHECK}/validators/runner.py" "$(pwd)" --warn-only --only planning_docs,session_state 2>/dev/null || true
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
