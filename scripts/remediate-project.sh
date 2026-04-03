#!/usr/bin/env bash
set -euo pipefail

[[ -n "${BASH_VERSION:-}" ]] || { echo "ERROR: Run with bash: bash scripts/remediate-project.sh"; exit 1; }

# remediate-project.sh
# Usage: remediate-project.sh <target_project_path> [--dry-run] [--force]
#
# Brings an existing AK-Cognitive-OS project up to the current standard.
# Safe to run multiple times — checks before acting, skips what already exists.
#
# What it does:
#   1. Ensures tasks/todo.md has a SESSION STATE block (adds if missing)
#   2. Installs persona commands into .claude/commands/ (skips existing)
#   3. Installs skill commands into .claude/commands/ (skips existing)
#   4. Creates framework/ directory with contracts, templates, schemas
#   5. Writes .ak-cogos-version
#   6. Reports warnings for anything it can't auto-fix

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
VERSION="1.2.0"

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

if [[ $# -lt 1 ]]; then
  echo "ERROR: Missing required argument."
  echo "Usage: $(basename "$0") <target_project_path> [--dry-run] [--force]"
  exit 1
fi

TARGET_DIR="$1"
shift
DRY_RUN=false
FORCE=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --force) FORCE=true ;;
    *) echo "WARNING: Unknown argument: $1" ;;
  esac
  shift
done

if [[ ! -d "$TARGET_DIR" ]]; then
  echo "ERROR: Target directory does not exist: $TARGET_DIR"
  exit 1
fi

TARGET_DIR="$(cd "$TARGET_DIR" && pwd)"

echo "=========================================="
echo "  AK-Cognitive-OS Project Remediation"
echo "=========================================="
echo ""
echo "Target:    $TARGET_DIR"
echo "Framework: $FRAMEWORK_DIR"
echo "Dry run:   $DRY_RUN"
echo "Force:     $FORCE"
echo ""

WARNINGS=()
CHANGES=0

# ---------------------------------------------------------------------------
# Helper: copy a file with dry-run and force support
# ---------------------------------------------------------------------------

safe_copy() {
  local src="$1"
  local dst="$2"

  if [[ -f "$dst" ]]; then
    if [[ "$FORCE" == true ]]; then
      if [[ "$DRY_RUN" == true ]]; then
        echo "  [would overwrite] $(basename "$dst")"
      else
        echo "  [overwrite] $(basename "$dst")"
        cp "$src" "$dst"
      fi
      CHANGES=$((CHANGES + 1))
    else
      return 0  # skip silently
    fi
  else
    if [[ "$DRY_RUN" == true ]]; then
      echo "  [would create] $(basename "$dst")"
    else
      echo "  [create] $(basename "$dst")"
      cp "$src" "$dst"
    fi
    CHANGES=$((CHANGES + 1))
  fi
}

# ---------------------------------------------------------------------------
# 1. Ensure tasks/todo.md has SESSION STATE block
# ---------------------------------------------------------------------------

echo "--- Step 1: SESSION STATE in tasks/todo.md ---"

TODO_FILE="${TARGET_DIR}/tasks/todo.md"

if [[ ! -f "$TODO_FILE" ]]; then
  echo "  [warn] tasks/todo.md does not exist — cannot add SESSION STATE"
  WARNINGS+=("tasks/todo.md missing entirely")
elif grep -q '## SESSION STATE' "$TODO_FILE" 2>/dev/null; then
  echo "  [ok] SESSION STATE block already exists"

  # Check for OPEN state (warning only)
  if grep -q 'Status:.*OPEN' "$TODO_FILE" 2>/dev/null; then
    echo "  [warn] Session appears to be OPEN — verify this is intentional"
    WARNINGS+=("Session left OPEN in tasks/todo.md")
  fi
else
  echo "  [fix] Adding SESSION STATE block to tasks/todo.md"

  if [[ "$DRY_RUN" == true ]]; then
    echo "  [would prepend] SESSION STATE block"
  else
    # Read existing content
    EXISTING="$(cat "$TODO_FILE")"

    # Check if file starts with a heading
    if [[ "$EXISTING" =~ ^#\  ]]; then
      # Extract first line (heading) and rest
      FIRST_LINE="$(head -1 "$TODO_FILE")"
      REST="$(tail -n +2 "$TODO_FILE")"

      cat > "$TODO_FILE" <<EOF
${FIRST_LINE}

## SESSION STATE

\`\`\`
Status:         CLOSED
Active task:    none
Active persona: none
Blocking issue: none
Last updated:   — (added by remediation script)
\`\`\`

---
${REST}
EOF
    else
      # Prepend to file
      cat > "$TODO_FILE" <<EOF
## SESSION STATE

\`\`\`
Status:         CLOSED
Active task:    none
Active persona: none
Blocking issue: none
Last updated:   — (added by remediation script)
\`\`\`

---

${EXISTING}
EOF
    fi
  fi
  CHANGES=$((CHANGES + 1))
fi

echo ""

# ---------------------------------------------------------------------------
# 2. Install persona commands
# ---------------------------------------------------------------------------

echo "--- Step 2: Persona commands in .claude/commands/ ---"

COMMANDS_DIR="${TARGET_DIR}/.claude/commands"
if [[ "$DRY_RUN" == false ]]; then
  mkdir -p "$COMMANDS_DIR"
fi

PERSONAS_DIR="${FRAMEWORK_DIR}/personas"
PERSONA_COUNT=0

if [[ -d "$PERSONAS_DIR" ]]; then
  for persona_dir in "${PERSONAS_DIR}"/*/; do
    persona_name="$(basename "$persona_dir")"
    [[ "$persona_name" == "_template" ]] && continue

    src_file="${persona_dir}claude-command.md"
    dst_file="${COMMANDS_DIR}/${persona_name}.md"

    if [[ -f "$src_file" ]]; then
      safe_copy "$src_file" "$dst_file"
      PERSONA_COUNT=$((PERSONA_COUNT + 1))
    fi
  done
fi

echo "  [ok] ${PERSONA_COUNT} persona(s) processed"
echo ""

# ---------------------------------------------------------------------------
# 3. Install skill commands
# ---------------------------------------------------------------------------

echo "--- Step 3: Skill commands in .claude/commands/ ---"

SKILLS_DIR="${FRAMEWORK_DIR}/skills"
SKILL_COUNT=0

if [[ -d "$SKILLS_DIR" ]]; then
  for skill_dir in "${SKILLS_DIR}"/*/; do
    skill_name="$(basename "$skill_dir")"
    [[ "$skill_name" == "_template" ]] && continue

    src_file="${skill_dir}claude-command.md"
    dst_file="${COMMANDS_DIR}/${skill_name}.md"

    if [[ -f "$src_file" ]]; then
      safe_copy "$src_file" "$dst_file"
      SKILL_COUNT=$((SKILL_COUNT + 1))
    fi
  done
fi

echo "  [ok] ${SKILL_COUNT} skill(s) processed"
echo ""

# ---------------------------------------------------------------------------
# 4. Create framework/ directory with contracts, templates, schemas
# ---------------------------------------------------------------------------

echo "--- Step 4: Framework directory ---"

if [[ "$DRY_RUN" == false ]]; then
  mkdir -p "${TARGET_DIR}/framework/interop"
  mkdir -p "${TARGET_DIR}/framework/codex-core/runbooks"
  mkdir -p "${TARGET_DIR}/framework/codex-core/validators"
  mkdir -p "${TARGET_DIR}/framework/templates"
  mkdir -p "${TARGET_DIR}/framework/schemas"
  mkdir -p "${TARGET_DIR}/framework/governance"
fi

# Interop contracts
INTEROP_SRC="${FRAMEWORK_DIR}/framework/interop"
if [[ -d "$INTEROP_SRC" ]]; then
  for src_file in "${INTEROP_SRC}"/*.md; do
    [[ -f "$src_file" ]] || continue
    safe_copy "$src_file" "${TARGET_DIR}/framework/interop/$(basename "$src_file")"
  done
fi

# Codex-core
CODEX_SRC="${FRAMEWORK_DIR}/framework/codex-core"
if [[ -d "$CODEX_SRC" ]]; then
  for src_file in "${CODEX_SRC}"/*.md; do
    [[ -f "$src_file" ]] || continue
    safe_copy "$src_file" "${TARGET_DIR}/framework/codex-core/$(basename "$src_file")"
  done
  if [[ -d "${CODEX_SRC}/runbooks" ]]; then
    for src_file in "${CODEX_SRC}/runbooks"/*.md; do
      [[ -f "$src_file" ]] || continue
      safe_copy "$src_file" "${TARGET_DIR}/framework/codex-core/runbooks/$(basename "$src_file")"
    done
  fi
  if [[ -d "${CODEX_SRC}/validators" ]]; then
    for src_file in "${CODEX_SRC}/validators"/*.md; do
      [[ -f "$src_file" ]] || continue
      safe_copy "$src_file" "${TARGET_DIR}/framework/codex-core/validators/$(basename "$src_file")"
    done
  fi
fi

# Governance
GOVERNANCE_SRC="${FRAMEWORK_DIR}/framework/governance"
if [[ -d "$GOVERNANCE_SRC" ]]; then
  for src_file in "${GOVERNANCE_SRC}"/*.md; do
    [[ -f "$src_file" ]] || continue
    safe_copy "$src_file" "${TARGET_DIR}/framework/governance/$(basename "$src_file")"
  done
fi

# Templates
TEMPLATES_SRC="${FRAMEWORK_DIR}/framework/templates"
if [[ -d "$TEMPLATES_SRC" ]]; then
  for src_file in "${TEMPLATES_SRC}"/*.md; do
    [[ -f "$src_file" ]] || continue
    safe_copy "$src_file" "${TARGET_DIR}/framework/templates/$(basename "$src_file")"
  done
fi

# Schemas
SCHEMAS_SRC="${FRAMEWORK_DIR}/schemas"
if [[ -d "$SCHEMAS_SRC" ]]; then
  for src_file in "${SCHEMAS_SRC}"/*.md; do
    [[ -f "$src_file" ]] || continue
    safe_copy "$src_file" "${TARGET_DIR}/framework/schemas/$(basename "$src_file")"
  done
fi

# Dual-stack architecture doc
if [[ -f "${FRAMEWORK_DIR}/framework/dual-stack-architecture.md" ]]; then
  safe_copy "${FRAMEWORK_DIR}/framework/dual-stack-architecture.md" "${TARGET_DIR}/framework/dual-stack-architecture.md"
fi

echo ""

# ---------------------------------------------------------------------------
# 5. Write .ak-cogos-version
# ---------------------------------------------------------------------------

echo "--- Step 5: Version stamp ---"

VERSION_FILE="${TARGET_DIR}/.ak-cogos-version"

if [[ -f "$VERSION_FILE" ]]; then
  CURRENT_VERSION="$(cat "$VERSION_FILE")"
  if [[ "$CURRENT_VERSION" == "$VERSION" ]]; then
    echo "  [ok] Already at v${VERSION}"
  else
    if [[ "$DRY_RUN" == true ]]; then
      echo "  [would update] v${CURRENT_VERSION} → v${VERSION}"
    else
      echo "${VERSION}" > "$VERSION_FILE"
      echo "  [update] v${CURRENT_VERSION} → v${VERSION}"
    fi
    CHANGES=$((CHANGES + 1))
  fi
else
  if [[ "$DRY_RUN" == true ]]; then
    echo "  [would create] .ak-cogos-version (v${VERSION})"
  else
    echo "${VERSION}" > "$VERSION_FILE"
    echo "  [create] .ak-cogos-version (v${VERSION})"
  fi
  CHANGES=$((CHANGES + 1))
fi

echo ""

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo "=========================================="
echo "  Remediation Summary"
echo "=========================================="
echo ""

if [[ "$DRY_RUN" == true ]]; then
  echo "  Mode:    DRY RUN (no changes made)"
else
  echo "  Mode:    LIVE"
fi
echo "  Changes: ${CHANGES}"

if [[ ${#WARNINGS[@]} -gt 0 ]]; then
  echo ""
  echo "  Warnings:"
  for w in "${WARNINGS[@]}"; do
    echo "    - $w"
  done
fi

echo ""

if [[ "$DRY_RUN" == true && $CHANGES -gt 0 ]]; then
  echo "Run without --dry-run to apply these changes."
fi
