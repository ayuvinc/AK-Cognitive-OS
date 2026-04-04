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
#   5. Creates docs/ directory with planning doc templates (skips existing)
#   6. Writes .ak-cogos-version
#   7. Detects mid-build state and prints recovery guidance
#   8. Reports warnings for anything it can't auto-fix

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
VERSION="2.0.0"

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
# 5. Create docs/ with planning doc templates
# ---------------------------------------------------------------------------

echo "--- Step 5: Planning doc templates (docs/) ---"

TEMPLATE_DOCS_DIR="${FRAMEWORK_DIR}/project-template/docs"

if [[ "$DRY_RUN" == false ]]; then
  mkdir -p "${TARGET_DIR}/docs/lld"
fi

if [[ -d "$TEMPLATE_DOCS_DIR" ]]; then
  for src_file in "${TEMPLATE_DOCS_DIR}"/*.md; do
    [[ -f "$src_file" ]] || continue
    safe_copy "$src_file" "${TARGET_DIR}/docs/$(basename "$src_file")"
  done
  # Copy lld/ subdirectory
  if [[ -d "${TEMPLATE_DOCS_DIR}/lld" ]]; then
    for src_file in "${TEMPLATE_DOCS_DIR}/lld"/*.md; do
      [[ -f "$src_file" ]] || continue
      safe_copy "$src_file" "${TARGET_DIR}/docs/lld/$(basename "$src_file")"
    done
  fi
else
  echo "  [warn] project-template/docs/ not found in framework — skipping"
  WARNINGS+=("Framework missing project-template/docs/")
fi

echo ""

# ---------------------------------------------------------------------------
# 6. Claude Code native integration (settings, hooks, ignore, memory)
# ---------------------------------------------------------------------------

echo "--- Step 6: Claude Code native integration ---"

TEMPLATE_DIR="${FRAMEWORK_DIR}/project-template"

# .claude/settings.json
SETTINGS_SRC="${TEMPLATE_DIR}/.claude/settings.json"
if [[ -f "$SETTINGS_SRC" ]]; then
  if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "${TARGET_DIR}/.claude"
  fi
  safe_copy "$SETTINGS_SRC" "${TARGET_DIR}/.claude/settings.json"
fi

# .claude/settings.local.json.example
SETTINGS_LOCAL_SRC="${TEMPLATE_DIR}/.claude/settings.local.json.example"
if [[ -f "$SETTINGS_LOCAL_SRC" ]]; then
  safe_copy "$SETTINGS_LOCAL_SRC" "${TARGET_DIR}/.claude/settings.local.json.example"
fi

# .claudeignore
CLAUDEIGNORE_SRC="${TEMPLATE_DIR}/.claudeignore"
if [[ -f "$CLAUDEIGNORE_SRC" ]]; then
  safe_copy "$CLAUDEIGNORE_SRC" "${TARGET_DIR}/.claudeignore"
fi

# memory/MEMORY.md
MEMORY_SRC="${TEMPLATE_DIR}/memory/MEMORY.md"
if [[ -f "$MEMORY_SRC" ]]; then
  if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "${TARGET_DIR}/memory"
  fi
  safe_copy "$MEMORY_SRC" "${TARGET_DIR}/memory/MEMORY.md"
fi

# ANTI-SYCOPHANCY.md
ANTI_SRC="${FRAMEWORK_DIR}/ANTI-SYCOPHANCY.md"
if [[ -f "$ANTI_SRC" ]]; then
  safe_copy "$ANTI_SRC" "${TARGET_DIR}/ANTI-SYCOPHANCY.md"
fi

echo ""

# ---------------------------------------------------------------------------
# 7. Install enforcement hook scripts
# ---------------------------------------------------------------------------

echo "--- Step 7: Enforcement hook scripts ---"

HOOKS_SRC="${FRAMEWORK_DIR}/scripts/hooks"
if [[ -d "$HOOKS_SRC" ]]; then
  if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "${TARGET_DIR}/scripts/hooks"
  fi
  for hook_file in "${HOOKS_SRC}"/*.sh; do
    [[ -f "$hook_file" ]] || continue
    dst_hook="${TARGET_DIR}/scripts/hooks/$(basename "$hook_file")"
    safe_copy "$hook_file" "$dst_hook"
    if [[ "$DRY_RUN" == false ]]; then
      chmod +x "$dst_hook" 2>/dev/null || true
    fi
  done
fi

echo ""

# ---------------------------------------------------------------------------
# 8. Install MCP servers
# ---------------------------------------------------------------------------

echo "--- Step 8: MCP servers ---"

MCP_SRC="${FRAMEWORK_DIR}/mcp-servers"
if [[ -d "$MCP_SRC" ]]; then
  if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "${TARGET_DIR}/mcp-servers"
  fi
  for mcp_file in "${MCP_SRC}"/*; do
    [[ -f "$mcp_file" ]] || continue
    safe_copy "$mcp_file" "${TARGET_DIR}/mcp-servers/$(basename "$mcp_file")"
  done
else
  echo "  [warn] mcp-servers/ not found in framework — skipping"
  WARNINGS+=("Framework missing mcp-servers/")
fi

echo ""

# ---------------------------------------------------------------------------
# 9. Install sub-persona commands (researcher-*, compliance-*)
# ---------------------------------------------------------------------------

echo "--- Step 8: Sub-persona commands ---"

SUB_COUNT=0

# Researcher sub-personas
RESEARCHER_SUBS="${FRAMEWORK_DIR}/personas/researcher/sub-personas"
if [[ -d "$RESEARCHER_SUBS" ]]; then
  for sub_file in "${RESEARCHER_SUBS}"/*.md; do
    [[ -f "$sub_file" ]] || continue
    sub_name="researcher-$(basename "$sub_file" .md)"
    dst_file="${COMMANDS_DIR}/${sub_name}.md"
    safe_copy "$sub_file" "$dst_file"
    SUB_COUNT=$((SUB_COUNT + 1))
  done
fi

# Compliance sub-personas
COMPLIANCE_SUBS="${FRAMEWORK_DIR}/personas/compliance/sub-personas"
if [[ -d "$COMPLIANCE_SUBS" ]]; then
  for sub_file in "${COMPLIANCE_SUBS}"/*.md; do
    [[ -f "$sub_file" ]] || continue
    [[ -d "$sub_file" ]] && continue
    sub_name="compliance-$(basename "$sub_file" .md)"
    dst_file="${COMMANDS_DIR}/${sub_name}.md"
    safe_copy "$sub_file" "$dst_file"
    SUB_COUNT=$((SUB_COUNT + 1))
  done
fi

echo "  [ok] ${SUB_COUNT} sub-persona(s) processed"
echo ""

# ---------------------------------------------------------------------------
# 10. Update .gitignore
# ---------------------------------------------------------------------------

echo "--- Step 10: .gitignore update ---"

GITIGNORE="${TARGET_DIR}/.gitignore"
if [[ -f "$GITIGNORE" ]]; then
  if ! grep -q 'settings.local.json' "$GITIGNORE" 2>/dev/null; then
    if [[ "$DRY_RUN" == true ]]; then
      echo "  [would add] .claude/settings.local.json to .gitignore"
    else
      echo "" >> "$GITIGNORE"
      echo "# Claude Code local settings (personal overrides, not committed)" >> "$GITIGNORE"
      echo ".claude/settings.local.json" >> "$GITIGNORE"
      echo "  [update] .gitignore — added settings.local.json exclusion"
    fi
    CHANGES=$((CHANGES + 1))
  else
    echo "  [ok] .gitignore already excludes settings.local.json"
  fi
else
  echo "  [warn] No .gitignore found — settings.local.json may be committed accidentally"
  WARNINGS+=("No .gitignore found")
fi

echo ""

# ---------------------------------------------------------------------------
# 11. Write .ak-cogos-version
# ---------------------------------------------------------------------------

echo "--- Step 11: Version stamp ---"

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

CMD_COUNT=$(find "${TARGET_DIR}/.claude/commands" -name '*.md' 2>/dev/null | wc -l)
HOOK_COUNT=$(find "${TARGET_DIR}/scripts/hooks" -name '*.sh' 2>/dev/null | wc -l)

MCP_COUNT=$(find "${TARGET_DIR}/mcp-servers" -type f 2>/dev/null | wc -l)

echo "  Changes: ${CHANGES}"
echo ""
echo "  Slash commands:   ${CMD_COUNT}"
echo "  Hook scripts:     ${HOOK_COUNT}"
echo "  MCP servers:      ${MCP_COUNT} file(s)"
echo "  Settings:         $([ -f "${TARGET_DIR}/.claude/settings.json" ] && echo 'installed' || echo 'MISSING')"
echo "  Context filter:   $([ -f "${TARGET_DIR}/.claudeignore" ] && echo 'installed' || echo 'MISSING')"
echo "  Memory:           $([ -f "${TARGET_DIR}/memory/MEMORY.md" ] && echo 'installed' || echo 'MISSING')"

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

echo ""
echo "Claude Code native integration checklist:"
echo "  $([ -f "${TARGET_DIR}/.claude/settings.json" ] && echo '[x]' || echo '[ ]') .claude/settings.json — hooks + permissions"
echo "  $([ -f "${TARGET_DIR}/.claudeignore" ] && echo '[x]' || echo '[ ]') .claudeignore — context window optimization"
echo "  $([ -f "${TARGET_DIR}/memory/MEMORY.md" ] && echo '[x]' || echo '[ ]') memory/MEMORY.md — persistent project memory"
echo "  $([ -d "${TARGET_DIR}/scripts/hooks" ] && echo '[x]' || echo '[ ]') scripts/hooks/ — enforcement hook scripts"
echo "  $([ -f "${TARGET_DIR}/ANTI-SYCOPHANCY.md" ] && echo '[x]' || echo '[ ]') ANTI-SYCOPHANCY.md — standing instruction"
echo "  $([ -d "${TARGET_DIR}/mcp-servers" ] && echo '[x]' || echo '[ ]') mcp-servers/ — state machine + audit log MCP servers"
echo ""

# ---------------------------------------------------------------------------
# Mid-build detection
# ---------------------------------------------------------------------------

TODO_CHECK="${TARGET_DIR}/tasks/todo.md"
if [[ -f "$TODO_CHECK" ]]; then
  # Check for non-ARCHIVED tasks (indicates active project).
  # Covers all known task formats across projects:
  #   canonical:  ## [TASK-001] or ### TASK-001
  #   checkbox:   - [ ] TASK-001 or - [x] TASK-001
  #   AKR-style:  #### AKR-01 —
  #   phase-based: ### Phase N or ### Sprint-N
  #   pending section: ## PENDING TASKS
  ACTIVE_TASKS="$(grep -cE '^##+ \[?TASK-[0-9]+\]?|^\- \[[ x]\] TASK-[0-9]+|^#### [A-Z]+-[0-9]+|^### (Phase|Sprint)[- ][0-9]|^## PENDING TASKS' "$TODO_CHECK" 2>/dev/null || true)"
  if [[ "$ACTIVE_TASKS" -gt 0 ]]; then
    echo ""
    echo "=========================================="
    echo "  Mid-Build Recovery Recommended"
    echo "=========================================="
    echo ""
    echo "This project has ${ACTIVE_TASKS} active task(s) but may be missing planning docs."
    echo "Recommended: Run mid-build recovery flow."
    echo "See: guides/12-mid-build-recovery.md"
    echo ""
    echo "Quick start:"
    echo "  ~/AK-Cognitive-OS/scripts/new-session.sh <session_id> <sprint_id> architect --mode recovery"
  fi
fi
