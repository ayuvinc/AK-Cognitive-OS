#!/usr/bin/env bash
set -euo pipefail

[[ -n "${BASH_VERSION:-}" ]] || { echo "ERROR: Run with bash: bash scripts/bootstrap-project.sh"; exit 1; }

# bootstrap-project.sh
# Usage: bootstrap-project.sh <target_project_path> [--force] [--non-interactive]
#
# Copies the AK-Cognitive-OS project template into an existing project directory.
# Creates tasks/, releases/, .claude/commands/, and framework/ directories.
# Installs personas, skills, review contracts, templates, and schemas.
# Runs an interactive intake interview to pre-fill CLAUDE.md (skip with --non-interactive).
# Pass --force to overwrite files that already exist.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
VERSION="1.2.0"

# ---------------------------------------------------------------------------
# Argument validation
# ---------------------------------------------------------------------------

if [[ $# -lt 1 ]]; then
  echo "ERROR: Missing required argument."
  echo "Usage: $(basename "$0") <target_project_path> [--force] [--non-interactive]"
  exit 1
fi

TARGET_DIR="$1"
shift
FORCE=false
INTERACTIVE=true

while [[ $# -gt 0 ]]; do
  case "$1" in
    --force) FORCE=true ;;
    --non-interactive) INTERACTIVE=false ;;
    *) echo "WARNING: Unknown argument: $1" ;;
  esac
  shift
done

# ---------------------------------------------------------------------------
# Validate target directory
# ---------------------------------------------------------------------------

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "ERROR: Target directory does not exist: $TARGET_DIR"
  echo "Create the directory first, then re-run this script."
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"
echo "=========================================="
echo "  AK-Cognitive-OS Project Bootstrap v${VERSION}"
echo "=========================================="
echo ""
echo "Target project:    $TARGET_DIR"
echo "Framework source:  $FRAMEWORK_DIR"
echo "Force overwrite:   $FORCE"
echo "Interactive mode:  $INTERACTIVE"
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
      echo "  [skip]      $(basename "$dst")  (exists -- pass --force to overwrite)"
    fi
  else
    echo "  [create]    $(basename "$dst")"
    cp "$src" "$dst"
  fi
}

# ---------------------------------------------------------------------------
# Interactive intake interview
# ---------------------------------------------------------------------------

PROJECT_NAME="[PROJECT_NAME]"
OWNER_NAME="[OWNER_NAME]"
PRODUCT_DESC="[One line: what this product does]"
TECH_STACK="[Framework], [Language], [DB], [Auth], [AI SDK if applicable]"
RISK_LEVEL=""
COMPLIANCE_REQS=""
AI_FEATURES=""
AUDIT_LOG_PATH="releases/audit-log.md"

if [[ "$INTERACTIVE" == true ]]; then
  echo "=========================================="
  echo "  Project Intake Interview"
  echo "=========================================="
  echo ""
  echo "Answer a few questions to pre-fill your CLAUDE.md."
  echo "(Press Enter to skip any question and fill in later.)"
  echo ""

  read -rp "  Project name: " input
  [[ -n "$input" ]] && PROJECT_NAME="$input"

  read -rp "  Owner name (product manager): " input
  [[ -n "$input" ]] && OWNER_NAME="$input"

  read -rp "  What does this product do (one line): " input
  [[ -n "$input" ]] && PRODUCT_DESC="$input"

  read -rp "  Tech stack [e.g. React, Node, PostgreSQL]: " input
  [[ -n "$input" ]] && TECH_STACK="$input"

  read -rp "  Risk level (low/medium/high/regulated): " input
  [[ -n "$input" ]] && RISK_LEVEL="$input"

  read -rp "  Compliance needed (comma-separated, or none): " input
  [[ -n "$input" ]] && COMPLIANCE_REQS="$input"

  read -rp "  AI features? (yes/no): " input
  [[ -n "$input" ]] && AI_FEATURES="$input"

  read -rp "  Audit log path [default: releases/audit-log.md]: " input
  [[ -n "$input" ]] && AUDIT_LOG_PATH="$input"

  echo ""
fi

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
# Create target directories
# ---------------------------------------------------------------------------

echo "Creating directories..."
mkdir -p "${TARGET_DIR}/tasks"
mkdir -p "${TARGET_DIR}/releases"
mkdir -p "${TARGET_DIR}/.claude/commands"
mkdir -p "${TARGET_DIR}/framework/interop"
mkdir -p "${TARGET_DIR}/framework/codex-core/runbooks"
mkdir -p "${TARGET_DIR}/framework/codex-core/validators"
mkdir -p "${TARGET_DIR}/framework/templates"
mkdir -p "${TARGET_DIR}/framework/schemas"
mkdir -p "${TARGET_DIR}/framework/governance"
echo "  [ok] tasks/"
echo "  [ok] releases/"
echo "  [ok] .claude/commands/"
echo "  [ok] framework/ (interop, codex-core, templates, schemas, governance)"
echo ""

# ---------------------------------------------------------------------------
# Copy root template files
# ---------------------------------------------------------------------------

echo "Copying template files..."
for src_file in "${TEMPLATE_DIR}/CLAUDE.md" "${TEMPLATE_DIR}/CLAUDE_START.md" "${TEMPLATE_DIR}/CODEX_START.md" "${TEMPLATE_DIR}/channel.md" "${TEMPLATE_DIR}/framework-improvements.md"; do
  if [[ -f "$src_file" ]]; then
    dst_file="${TARGET_DIR}/$(basename "$src_file")"
    copy_file "$src_file" "$dst_file"
  else
    echo "  [warn] Source file not found, skipping: $(basename "$src_file")"
  fi
done
echo ""

# ---------------------------------------------------------------------------
# Apply intake answers to CLAUDE.md
# ---------------------------------------------------------------------------

if [[ "$INTERACTIVE" == true && -f "${TARGET_DIR}/CLAUDE.md" ]]; then
  echo "Applying intake answers to CLAUDE.md..."
  sed -i.bak "s|\[PROJECT_NAME\]|${PROJECT_NAME}|g" "${TARGET_DIR}/CLAUDE.md"
  sed -i.bak "s|\[One line: what this product does\]|${PRODUCT_DESC}|g" "${TARGET_DIR}/CLAUDE.md"
  sed -i.bak "s|\[Framework\], \[Language\], \[DB\], \[Auth\], \[AI SDK if applicable\]|${TECH_STACK}|g" "${TARGET_DIR}/CLAUDE.md"
  sed -i.bak "s|\[OWNER_NAME\]|${OWNER_NAME}|g" "${TARGET_DIR}/CLAUDE.md"
  sed -i.bak "s|\[OWNER\]|${OWNER_NAME}|g" "${TARGET_DIR}/CLAUDE.md"
  sed -i.bak "s|\[AUDIT_LOG_PATH\]|${AUDIT_LOG_PATH}|g" "${TARGET_DIR}/CLAUDE.md"
  rm -f "${TARGET_DIR}/CLAUDE.md.bak"

  # Append intake summary if risk level was provided
  if [[ -n "$RISK_LEVEL" ]]; then
    cat >> "${TARGET_DIR}/CLAUDE.md" <<EOF

---

## Intake Summary

- **Risk level:** ${RISK_LEVEL}
- **Compliance:** ${COMPLIANCE_REQS:-none}
- **AI features:** ${AI_FEATURES:-no}
- **Generated by:** AK-Cognitive-OS bootstrap v${VERSION}
EOF
  fi

  echo "  [ok] CLAUDE.md placeholders replaced"
  echo ""
fi

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

AUDIT_FILE="${TARGET_DIR}/${AUDIT_LOG_PATH}"

if [[ ! -f "$AUDIT_FILE" ]]; then
  mkdir -p "$(dirname "$AUDIT_FILE")"
  touch "$AUDIT_FILE"
  echo "  [create]    ${AUDIT_LOG_PATH}"
else
  echo "  [skip]      ${AUDIT_LOG_PATH}  (already exists)"
fi
echo ""

# ---------------------------------------------------------------------------
# Install persona commands into .claude/commands/
# ---------------------------------------------------------------------------

PERSONAS_DIR="${FRAMEWORK_DIR}/personas"
INSTALLED=0

if [[ -d "$PERSONAS_DIR" ]]; then
  echo "Installing persona commands..."
  for persona_dir in "${PERSONAS_DIR}"/*/; do
    persona_name="$(basename "$persona_dir")"
    [[ "$persona_name" == "_template" ]] && continue

    src_file="${persona_dir}claude-command.md"
    dst_file="${TARGET_DIR}/.claude/commands/${persona_name}.md"

    if [[ -f "$src_file" ]]; then
      copy_file "$src_file" "$dst_file"
      INSTALLED=$((INSTALLED + 1))
    fi
  done
  echo "  [ok] ${INSTALLED} persona command(s)"
  echo ""
fi

# ---------------------------------------------------------------------------
# Install skill commands into .claude/commands/
# ---------------------------------------------------------------------------

SKILLS_DIR="${FRAMEWORK_DIR}/skills"
SKILL_COUNT=0

if [[ -d "$SKILLS_DIR" ]]; then
  echo "Installing skill commands..."
  for skill_dir in "${SKILLS_DIR}"/*/; do
    skill_name="$(basename "$skill_dir")"
    [[ "$skill_name" == "_template" ]] && continue

    src_file="${skill_dir}claude-command.md"
    dst_file="${TARGET_DIR}/.claude/commands/${skill_name}.md"

    if [[ -f "$src_file" ]]; then
      copy_file "$src_file" "$dst_file"
      SKILL_COUNT=$((SKILL_COUNT + 1))
    fi
  done
  echo "  [ok] ${SKILL_COUNT} skill command(s)"
  echo ""
fi

# ---------------------------------------------------------------------------
# Copy review contracts (framework/interop/)
# ---------------------------------------------------------------------------

echo "Copying review contracts..."

INTEROP_SRC="${FRAMEWORK_DIR}/framework/interop"
if [[ -d "$INTEROP_SRC" ]]; then
  for src_file in "${INTEROP_SRC}"/*.md; do
    [[ -f "$src_file" ]] || continue
    copy_file "$src_file" "${TARGET_DIR}/framework/interop/$(basename "$src_file")"
  done
fi

CODEX_SRC="${FRAMEWORK_DIR}/framework/codex-core"
if [[ -d "$CODEX_SRC" ]]; then
  for src_file in "${CODEX_SRC}"/*.md; do
    [[ -f "$src_file" ]] || continue
    copy_file "$src_file" "${TARGET_DIR}/framework/codex-core/$(basename "$src_file")"
  done
  # Copy runbooks
  if [[ -d "${CODEX_SRC}/runbooks" ]]; then
    for src_file in "${CODEX_SRC}/runbooks"/*.md; do
      [[ -f "$src_file" ]] || continue
      copy_file "$src_file" "${TARGET_DIR}/framework/codex-core/runbooks/$(basename "$src_file")"
    done
  fi
  # Copy validators
  if [[ -d "${CODEX_SRC}/validators" ]]; then
    for src_file in "${CODEX_SRC}/validators"/*.md; do
      [[ -f "$src_file" ]] || continue
      copy_file "$src_file" "${TARGET_DIR}/framework/codex-core/validators/$(basename "$src_file")"
    done
  fi
fi

GOVERNANCE_SRC="${FRAMEWORK_DIR}/framework/governance"
if [[ -d "$GOVERNANCE_SRC" ]]; then
  for src_file in "${GOVERNANCE_SRC}"/*.md; do
    [[ -f "$src_file" ]] || continue
    copy_file "$src_file" "${TARGET_DIR}/framework/governance/$(basename "$src_file")"
  done
fi

echo ""

# ---------------------------------------------------------------------------
# Copy reference templates (framework/templates/)
# ---------------------------------------------------------------------------

echo "Copying reference templates..."

TEMPLATES_SRC="${FRAMEWORK_DIR}/framework/templates"
if [[ -d "$TEMPLATES_SRC" ]]; then
  for src_file in "${TEMPLATES_SRC}"/*.md; do
    [[ -f "$src_file" ]] || continue
    copy_file "$src_file" "${TARGET_DIR}/framework/templates/$(basename "$src_file")"
  done
fi

echo ""

# ---------------------------------------------------------------------------
# Copy schemas
# ---------------------------------------------------------------------------

echo "Copying schemas..."

SCHEMAS_SRC="${FRAMEWORK_DIR}/schemas"
if [[ -d "$SCHEMAS_SRC" ]]; then
  for src_file in "${SCHEMAS_SRC}"/*.md; do
    [[ -f "$src_file" ]] || continue
    copy_file "$src_file" "${TARGET_DIR}/framework/schemas/$(basename "$src_file")"
  done
fi

echo ""

# ---------------------------------------------------------------------------
# Copy dual-stack architecture doc
# ---------------------------------------------------------------------------

if [[ -f "${FRAMEWORK_DIR}/framework/dual-stack-architecture.md" ]]; then
  copy_file "${FRAMEWORK_DIR}/framework/dual-stack-architecture.md" "${TARGET_DIR}/framework/dual-stack-architecture.md"
fi

# ---------------------------------------------------------------------------
# Write version stamp
# ---------------------------------------------------------------------------

echo "${VERSION}" > "${TARGET_DIR}/.ak-cogos-version"
echo "  [create]    .ak-cogos-version (v${VERSION})"
echo ""

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

TOTAL=$((INSTALLED + SKILL_COUNT))
echo "=========================================="
echo "  Bootstrap complete!"
echo "=========================================="
echo ""
echo "  Commands installed: ${TOTAL} (${INSTALLED} personas + ${SKILL_COUNT} skills)"
echo "  Framework version:  v${VERSION}"
echo ""
echo "Next steps:"
if [[ "$INTERACTIVE" == false ]]; then
  echo "  1. Open ${TARGET_DIR}/CLAUDE.md and replace all [PLACEHOLDER] values."
else
  echo "  1. Review ${TARGET_DIR}/CLAUDE.md — intake answers have been applied."
fi
echo "  2. Open a Claude Code session from your project root:"
echo "       cd ${TARGET_DIR} && claude"
echo "  3. Ask Claude to act as BA and run /ba to confirm business logic."
echo ""
