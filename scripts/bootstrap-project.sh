#!/usr/bin/env bash
set -euo pipefail

[[ -n "${BASH_VERSION:-}" ]] || { echo "ERROR: Run with bash: bash scripts/bootstrap-project.sh"; exit 1; }

# bootstrap-project.sh
# Usage: bootstrap-project.sh <target_project_path> [--force]
#
# Copies the AK-Cognitive-OS project template into an existing project directory.
# Creates tasks/ and releases/ directories and seeds them from project-template/.
# Pass --force to overwrite files that already exist.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

# ---------------------------------------------------------------------------
# Argument validation
# ---------------------------------------------------------------------------

if [[ $# -lt 1 ]]; then
  echo "ERROR: Missing required argument."
  echo "Usage: $(basename "$0") <target_project_path> [--force]"
  exit 1
fi

TARGET_DIR="$1"
FORCE=false

if [[ $# -ge 2 && "$2" == "--force" ]]; then
  FORCE=true
fi

# ---------------------------------------------------------------------------
# Validate target directory
# ---------------------------------------------------------------------------

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "ERROR: Target directory does not exist: $TARGET_DIR"
  echo "Create the directory first, then re-run this script."
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
echo "Bootstrapping project at: $TARGET_DIR"
echo "Framework directory:       $FRAMEWORK_DIR"
echo "Force overwrite:           $FORCE"
echo ""

# ---------------------------------------------------------------------------
# Helper: copy a file, respecting --force
# ---------------------------------------------------------------------------

copy_file() {
  local src="$1"
  local dst="$2"

  if [[ -f "$dst" ]]; then
    if [[ "$FORCE" == true ]]; then
      echo "  [overwrite] $dst"
      cp "$src" "$dst"
    else
      echo "  [skip]      $dst  (already exists -- pass --force to overwrite)"
    fi
  else
    echo "  [create]    $dst"
    cp "$src" "$dst"
  fi
}

# ---------------------------------------------------------------------------
# Create target directories
# ---------------------------------------------------------------------------

echo "Creating directories..."
mkdir -p "${TARGET_DIR}/tasks"
mkdir -p "${TARGET_DIR}/releases"
echo "  [ok] tasks/"
echo "  [ok] releases/"
echo ""

# ---------------------------------------------------------------------------
# Validate source template exists
# ---------------------------------------------------------------------------

TEMPLATE_DIR="${FRAMEWORK_DIR}/project-template"

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  echo "ERROR: project-template/ not found at expected location: $TEMPLATE_DIR"
  echo "Ensure this script is run from within the AK-Cognitive-OS repository."
  exit 1
fi

# ---------------------------------------------------------------------------
# Copy root template files
# ---------------------------------------------------------------------------

echo "Copying template files..."
for src_file in "${TEMPLATE_DIR}/CLAUDE.md" "${TEMPLATE_DIR}/channel.md" "${TEMPLATE_DIR}/framework-improvements.md"; do
  if [[ -f "$src_file" ]]; then
    dst_file="${TARGET_DIR}/$(basename "$src_file")"
    copy_file "$src_file" "$dst_file"
  else
    echo "  [warn] Source file not found, skipping: $src_file"
  fi
done
echo ""

# ---------------------------------------------------------------------------
# Copy tasks/ template files
# ---------------------------------------------------------------------------

TEMPLATE_TASKS_DIR="${TEMPLATE_DIR}/tasks"

if [[ -d "$TEMPLATE_TASKS_DIR" ]]; then
  echo "Copying tasks/ template files..."
  for src_file in "${TEMPLATE_TASKS_DIR}"/*.md; do
    if [[ -f "$src_file" ]]; then
      dst_file="${TARGET_DIR}/tasks/$(basename "$src_file")"
      copy_file "$src_file" "$dst_file"
    fi
  done
  echo ""
else
  echo "  [warn] project-template/tasks/ not found -- skipping tasks copy"
fi

# ---------------------------------------------------------------------------
# Create releases/audit-log.md if missing
# ---------------------------------------------------------------------------

AUDIT_LOG="${TARGET_DIR}/releases/audit-log.md"

if [[ ! -f "$AUDIT_LOG" ]]; then
  touch "$AUDIT_LOG"
  echo "  [create]    releases/audit-log.md"
else
  echo "  [skip]      releases/audit-log.md  (already exists)"
fi
echo ""

# ---------------------------------------------------------------------------
# Next steps
# ---------------------------------------------------------------------------

echo "Bootstrap complete."
echo ""
echo "Next steps:"
echo "  1. Open ${TARGET_DIR}/CLAUDE.md and replace all [PLACEHOLDER] values"
echo "     (start with [OWNER_NAME] and [PROJECT_NAME])."
echo "  2. Run scripts/install-claude-commands.sh to install persona and skill"
echo "     commands into ~/.claude/commands/."
echo "  3. Open a Claude Code session from your project root:"
echo "     cd ${TARGET_DIR} && claude"
echo "  4. Ask Claude to act as BA and run /ba to confirm business logic before"
echo "     Architect writes any tasks."
