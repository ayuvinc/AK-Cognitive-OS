#!/usr/bin/env bash
set -euo pipefail

[[ -n "${BASH_VERSION:-}" ]] || { echo "ERROR: Run with bash: bash scripts/remediate-project.sh"; exit 1; }

# remediate-project.sh
# Usage: remediate-project.sh <target_project_path> [--dry-run] [--force] [--audit-only]
#
# Brings an existing AK-Cognitive-OS project up to v3.0 standard.
# Safe to run multiple times — checks before acting, skips what already exists.
#
# What it does:
#   1.  Ensures tasks/todo.md has a SESSION STATE block
#   1b. Checks CLAUDE.md for Tier: field (advisory)
#   2.  Installs exactly 20 commands into .claude/commands/ (explicit deploy list)
#   3.  Removes 17 retired command files from .claude/commands/ (if present)
#   4.  Creates framework/ directory with contracts, templates, schemas
#   5.  Creates docs/ directory with planning doc templates
#   6.  Installs Claude Code native integration (settings, hooks, ignore, memory)
#   7.  Installs enforcement hook scripts
#   8.  Installs MCP servers
#   9.  Creates tasks/codex-review.md placeholder (if missing)
#  10.  Creates memory/teaching-log.md placeholder (if missing)
#  11.  Updates .gitignore
#  12.  Writes .ak-cogos-version
#  13.  Creates tasks/design-system.md placeholder (if missing)

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
VERSION="3.0.0"

# ---------------------------------------------------------------------------
# Explicit deploy list — exactly 20 commands deployed to every project
# Format: "source_subdir|target_filename"
# ---------------------------------------------------------------------------

DEPLOY_COMMANDS=(
  # Session
  "skills/session-open|session-open.md"
  "skills/session-close|session-close.md"
  "skills/compact-session|compact-session.md"
  # Personas
  "personas/architect|architect.md"
  "personas/ba|ba.md"
  "personas/junior-dev|junior-dev.md"
  "personas/qa|qa.md"
  "personas/ux|ux.md"
  "personas/designer|designer.md"
  # Quality
  "skills/qa-run|qa-run.md"
  "skills/security-sweep|security-sweep.md"
  "personas/compliance|compliance.md"
  # Research
  "personas/researcher|researcher.md"
  # Codex
  "skills/codex-prep|codex-prep.md"
  "skills/codex-read|codex-read.md"
  # Intelligence
  "skills/teach-me|teach-me.md"
  "skills/lessons-extractor|lessons-extractor.md"
  "personas/risk-manager|risk-manager.md"
  # Utility
  "skills/audit-log|audit-log.md"
  "skills/check-channel|check-channel.md"
)

# ---------------------------------------------------------------------------
# Retired commands — deleted from target projects (keep in source only)
# ---------------------------------------------------------------------------

RETIRED_COMMANDS=(
  "researcher-business.md"
  "researcher-technical.md"
  "researcher-legal.md"
  "researcher-policy.md"
  "researcher-news.md"
  "review-packet.md"
  "codex-intake-check.md"
  "codex-creator.md"
  "codex-delta-verify.md"
  "framework-delta-log.md"
  "handoff-validator.md"
  "sprint-packager.md"
  "regression-guard.md"
  "compliance-data-privacy.md"
  "compliance-data-security.md"
  "compliance-phi-handler.md"
  "compliance-pii-handler.md"
)

# ---------------------------------------------------------------------------
# Argument parsing
# ---------------------------------------------------------------------------

if [[ $# -lt 1 ]]; then
  echo "ERROR: Missing required argument."
  echo "Usage: $(basename "$0") <target_project_path> [--dry-run] [--force] [--audit-only]"
  exit 1
fi

TARGET_DIR="$1"
shift
DRY_RUN=false
FORCE=false
AUDIT_ONLY=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --dry-run) DRY_RUN=true ;;
    --force) FORCE=true ;;
    --audit-only) AUDIT_ONLY=true; DRY_RUN=true ;;
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
echo "  Target version: v${VERSION}"
echo "=========================================="
echo ""
echo "Target:    $TARGET_DIR"
echo "Framework: $FRAMEWORK_DIR"
if [[ "$AUDIT_ONLY" == true ]]; then
  echo "Mode:      AUDIT ONLY"
else
  echo "Dry run:   $DRY_RUN"
fi
echo "Force:     $FORCE"
echo ""

WARNINGS=()
CHANGES=0

# ---------------------------------------------------------------------------
# Helper: copy a framework file (commands, hooks, settings, MCP)
#   --force applies here: overwrites existing files when set
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
      return 0  # skip silently without --force
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
# Helper: copy a project-owned file (docs, planning artifacts)
#   --force is IGNORED here — these are never overwritten by remediation
# ---------------------------------------------------------------------------

safe_copy_project() {
  local src="$1"
  local dst="$2"

  if [[ -f "$dst" ]]; then
    return 0  # always skip — project file, never overwrite
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo "  [would create] $(basename "$dst")"
  else
    echo "  [create] $(basename "$dst")"
    cp "$src" "$dst"
  fi
  CHANGES=$((CHANGES + 1))
}

# ---------------------------------------------------------------------------
# Helper: create a placeholder file (only if missing, never overwrite)
# ---------------------------------------------------------------------------

create_placeholder() {
  local dst="$1"
  local content="$2"

  if [[ -f "$dst" ]]; then
    echo "  [ok] $(basename "$dst") exists"
    return 0
  fi

  if [[ "$DRY_RUN" == true ]]; then
    echo "  [would create] $(basename "$dst")"
  else
    echo "  [create] $(basename "$dst")"
    printf '%s\n' "$content" > "$dst"
  fi
  CHANGES=$((CHANGES + 1))
}

# ---------------------------------------------------------------------------
# 1. Ensure tasks/todo.md has SESSION STATE block
# ---------------------------------------------------------------------------

echo "--- Step 1: SESSION STATE check (read-only diagnostic) ---"
echo "  [note] tasks/todo.md is a project file — remediation never modifies it"

TODO_FILE="${TARGET_DIR}/tasks/todo.md"

if [[ ! -f "$TODO_FILE" ]]; then
  echo "  [warn] tasks/todo.md does not exist"
  WARNINGS+=("tasks/todo.md missing — create manually before opening a session")
elif grep -q '## SESSION STATE' "$TODO_FILE" 2>/dev/null; then
  echo "  [ok] SESSION STATE block present"
  if grep -q 'Status:.*OPEN' "$TODO_FILE" 2>/dev/null; then
    echo "  [warn] Session is OPEN — verify this is intentional before remediating"
    WARNINGS+=("Session left OPEN in tasks/todo.md — verify before proceeding")
  fi
else
  echo "  [warn] SESSION STATE block missing from tasks/todo.md"
  echo "         Run /session-open to create it, or add manually"
  WARNINGS+=("tasks/todo.md missing SESSION STATE block — run /session-open to fix")
fi

echo ""

# ---------------------------------------------------------------------------
# 1b. Tier field check (advisory — reads CLAUDE.md, never modifies it)
# ---------------------------------------------------------------------------

echo "--- Step 1b: Tier field check (read-only advisory) ---"

CLAUDE_MD="${TARGET_DIR}/CLAUDE.md"

if [[ ! -f "$CLAUDE_MD" ]]; then
  echo "  [warn] CLAUDE.md not found — Tier field cannot be checked"
  WARNINGS+=("CLAUDE.md not found — Tier field cannot be checked; create CLAUDE.md before opening a session")
elif grep -qE '^Tier:' "$CLAUDE_MD" 2>/dev/null; then
  TIER_VALUE="$(grep -E '^Tier:' "$CLAUDE_MD" | head -1 | sed 's/^Tier:[[:space:]]*//')"
  echo "  [ok] Tier field found: ${TIER_VALUE}"
else
  echo "  [warn] CLAUDE.md is missing Tier: field"
  echo "         Add 'Tier: Standard' before opening a session"
  echo "         See: framework/governance/operating-tiers.md"
  WARNINGS+=("CLAUDE.md is missing Tier: field — add 'Tier: Standard' before opening a session (see framework/governance/operating-tiers.md)")
fi

echo ""

# ---------------------------------------------------------------------------
# 2. Install exactly 20 commands from explicit deploy list
# ---------------------------------------------------------------------------

echo "--- Step 2: Install 20 commands into .claude/commands/ ---"

COMMANDS_DIR="${TARGET_DIR}/.claude/commands"
if [[ "$DRY_RUN" == false ]]; then
  mkdir -p "$COMMANDS_DIR"
fi

DEPLOY_COUNT=0
MISSING_SRC=()

for entry in "${DEPLOY_COMMANDS[@]}"; do
  src_subdir="${entry%%|*}"
  dst_name="${entry##*|}"
  src_file="${FRAMEWORK_DIR}/${src_subdir}/claude-command.md"
  dst_file="${COMMANDS_DIR}/${dst_name}"

  if [[ -f "$src_file" ]]; then
    safe_copy "$src_file" "$dst_file"
    DEPLOY_COUNT=$((DEPLOY_COUNT + 1))
  else
    echo "  [MISSING SRC] ${src_file} — cannot deploy ${dst_name}"
    MISSING_SRC+=("$src_file")
    WARNINGS+=("Source missing: ${src_subdir}/claude-command.md")
  fi
done

echo "  [ok] ${DEPLOY_COUNT}/20 command(s) processed"

if [[ ${#MISSING_SRC[@]} -gt 0 ]]; then
  echo "  [WARN] ${#MISSING_SRC[@]} source file(s) missing — check personas/ and skills/"
fi

echo ""

# ---------------------------------------------------------------------------
# 3. Remove retired commands from .claude/commands/
# ---------------------------------------------------------------------------

echo "--- Step 3: Remove retired commands ---"

RETIRED_COUNT=0

for fname in "${RETIRED_COMMANDS[@]}"; do
  target_file="${COMMANDS_DIR}/${fname}"
  if [[ -f "$target_file" ]]; then
    if [[ "$DRY_RUN" == true ]]; then
      echo "  [would delete] ${fname}"
    else
      echo "  [delete] ${fname}"
      rm "$target_file"
    fi
    RETIRED_COUNT=$((RETIRED_COUNT + 1))
    CHANGES=$((CHANGES + 1))
  fi
done

if [[ "$RETIRED_COUNT" -eq 0 ]]; then
  echo "  [ok] No retired commands found"
else
  echo "  [ok] ${RETIRED_COUNT} retired command(s) removed"
fi

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

INTEROP_SRC="${FRAMEWORK_DIR}/framework/interop"
if [[ -d "$INTEROP_SRC" ]]; then
  for src_file in "${INTEROP_SRC}"/*.md; do
    [[ -f "$src_file" ]] || continue
    safe_copy "$src_file" "${TARGET_DIR}/framework/interop/$(basename "$src_file")"
  done
fi

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

GOVERNANCE_SRC="${FRAMEWORK_DIR}/framework/governance"
if [[ -d "$GOVERNANCE_SRC" ]]; then
  for src_file in "${GOVERNANCE_SRC}"/*.md; do
    [[ -f "$src_file" ]] || continue
    safe_copy "$src_file" "${TARGET_DIR}/framework/governance/$(basename "$src_file")"
  done
fi

TEMPLATES_SRC="${FRAMEWORK_DIR}/framework/templates"
if [[ -d "$TEMPLATES_SRC" ]]; then
  for src_file in "${TEMPLATES_SRC}"/*.md; do
    [[ -f "$src_file" ]] || continue
    safe_copy "$src_file" "${TARGET_DIR}/framework/templates/$(basename "$src_file")"
  done
fi

SCHEMAS_SRC="${FRAMEWORK_DIR}/schemas"
if [[ -d "$SCHEMAS_SRC" ]]; then
  for src_file in "${SCHEMAS_SRC}"/*.md; do
    [[ -f "$src_file" ]] || continue
    safe_copy "$src_file" "${TARGET_DIR}/framework/schemas/$(basename "$src_file")"
  done
fi

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

echo "  [note] docs/ are project-owned files — only created if missing, never overwritten"

if [[ -d "$TEMPLATE_DOCS_DIR" ]]; then
  for src_file in "${TEMPLATE_DOCS_DIR}"/*.md; do
    [[ -f "$src_file" ]] || continue
    safe_copy_project "$src_file" "${TARGET_DIR}/docs/$(basename "$src_file")"
  done
  if [[ -d "${TEMPLATE_DOCS_DIR}/lld" ]]; then
    for src_file in "${TEMPLATE_DOCS_DIR}/lld"/*.md; do
      [[ -f "$src_file" ]] || continue
      safe_copy_project "$src_file" "${TARGET_DIR}/docs/lld/$(basename "$src_file")"
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

SETTINGS_SRC="${TEMPLATE_DIR}/.claude/settings.json"
if [[ -f "$SETTINGS_SRC" ]]; then
  if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "${TARGET_DIR}/.claude"
  fi
  safe_copy "$SETTINGS_SRC" "${TARGET_DIR}/.claude/settings.json"
fi

SETTINGS_LOCAL_SRC="${TEMPLATE_DIR}/.claude/settings.local.json.example"
if [[ -f "$SETTINGS_LOCAL_SRC" ]]; then
  safe_copy "$SETTINGS_LOCAL_SRC" "${TARGET_DIR}/.claude/settings.local.json.example"
fi

CLAUDEIGNORE_SRC="${TEMPLATE_DIR}/.claudeignore"
if [[ -f "$CLAUDEIGNORE_SRC" ]]; then
  safe_copy "$CLAUDEIGNORE_SRC" "${TARGET_DIR}/.claudeignore"
fi

MEMORY_SRC="${TEMPLATE_DIR}/memory/MEMORY.md"
if [[ -f "$MEMORY_SRC" ]]; then
  if [[ "$DRY_RUN" == false ]]; then
    mkdir -p "${TARGET_DIR}/memory"
  fi
  safe_copy "$MEMORY_SRC" "${TARGET_DIR}/memory/MEMORY.md"
fi

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
# 9. Create tasks/codex-review.md placeholder
# ---------------------------------------------------------------------------

echo "--- Step 9: tasks/codex-review.md placeholder ---"

if [[ "$DRY_RUN" == false ]]; then
  mkdir -p "${TARGET_DIR}/tasks"
fi

CODEX_REVIEW_PLACEHOLDER='# Codex Review
# This file is written by /codex-prep and read by /codex-read.
# It is overwritten each review cycle. Do not edit manually.
#
# Status: EMPTY — no review pending
'

create_placeholder "${TARGET_DIR}/tasks/codex-review.md" "$CODEX_REVIEW_PLACEHOLDER"

echo ""

# ---------------------------------------------------------------------------
# 10. Create memory/teaching-log.md placeholder
# ---------------------------------------------------------------------------

echo "--- Step 10: memory/teaching-log.md placeholder ---"

if [[ "$DRY_RUN" == false ]]; then
  mkdir -p "${TARGET_DIR}/memory"
fi

TEACHING_LOG_PLACEHOLDER='# Teaching Log
# Written by /teach-me when a new task starts.
# Each entry: task ID, plain-language brief, timestamp.
# Read by AK to understand what was built and why.
'

create_placeholder "${TARGET_DIR}/memory/teaching-log.md" "$TEACHING_LOG_PLACEHOLDER"

echo ""

# ---------------------------------------------------------------------------
# 11. Update .gitignore
# ---------------------------------------------------------------------------

echo "--- Step 11: .gitignore update ---"

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

# Also ensure flag files are gitignored
if [[ -f "$GITIGNORE" ]]; then
  if ! grep -q '\.teach-me-required' "$GITIGNORE" 2>/dev/null; then
    if [[ "$DRY_RUN" == true ]]; then
      echo "  [would add] hook flag files to .gitignore"
    else
      echo "" >> "$GITIGNORE"
      echo "# AK-Cognitive-OS hook flag files (runtime state, not committed)" >> "$GITIGNORE"
      echo ".teach-me-required" >> "$GITIGNORE"
      echo ".codex-prep-required" >> "$GITIGNORE"
      echo "  [update] .gitignore — added hook flag file exclusions"
    fi
    CHANGES=$((CHANGES + 1))
  fi
fi

echo ""

# ---------------------------------------------------------------------------
# 12. Write .ak-cogos-version
# ---------------------------------------------------------------------------

echo "--- Step 12: Version stamp ---"

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
# 13. Create tasks/design-system.md placeholder
# ---------------------------------------------------------------------------

echo "--- Step 13: tasks/design-system.md placeholder ---"

if [[ "$DRY_RUN" == false ]]; then
  mkdir -p "${TARGET_DIR}/tasks"
fi

DESIGN_SYSTEM_SRC="${FRAMEWORK_DIR}/project-template/tasks/design-system.md"

if [[ -f "$DESIGN_SYSTEM_SRC" ]]; then
  safe_copy_project "$DESIGN_SYSTEM_SRC" "${TARGET_DIR}/tasks/design-system.md"
else
  echo "  [warn] project-template/tasks/design-system.md not found in framework — skipping"
  WARNINGS+=("Framework missing project-template/tasks/design-system.md")
fi

echo ""

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

echo "=========================================="
echo "  Remediation Summary"
echo "=========================================="
echo ""

if [[ "$AUDIT_ONLY" == true ]]; then
  echo "  Mode:    AUDIT ONLY (no changes made)"
elif [[ "$DRY_RUN" == true ]]; then
  echo "  Mode:    DRY RUN (no changes made)"
else
  echo "  Mode:    LIVE"
fi

CMD_COUNT=$(find "${TARGET_DIR}/.claude/commands" -name '*.md' 2>/dev/null | wc -l | tr -d ' ') || CMD_COUNT=0
HOOK_COUNT=$(find "${TARGET_DIR}/scripts/hooks" -name '*.sh' 2>/dev/null | wc -l | tr -d ' ') || HOOK_COUNT=0
MCP_COUNT=$(find "${TARGET_DIR}/mcp-servers" -type f 2>/dev/null | wc -l | tr -d ' ') || MCP_COUNT=0

echo "  Changes: ${CHANGES}"
echo ""
echo "  Slash commands:   ${CMD_COUNT} (target: 20)"
echo "  Hook scripts:     ${HOOK_COUNT}"
echo "  MCP servers:      ${MCP_COUNT} file(s)"
echo "  Settings:         $([ -f "${TARGET_DIR}/.claude/settings.json" ] && echo 'installed' || echo 'MISSING')"
echo "  Context filter:   $([ -f "${TARGET_DIR}/.claudeignore" ] && echo 'installed' || echo 'MISSING')"
echo "  Memory:           $([ -f "${TARGET_DIR}/memory/MEMORY.md" ] && echo 'installed' || echo 'MISSING')"
echo "  Codex review:     $([ -f "${TARGET_DIR}/tasks/codex-review.md" ] && echo 'installed' || echo 'MISSING')"
echo "  Teaching log:     $([ -f "${TARGET_DIR}/memory/teaching-log.md" ] && echo 'installed' || echo 'MISSING')"
echo "  Design system:    $([ -f "${TARGET_DIR}/tasks/design-system.md" ] && echo 'installed' || echo 'MISSING')"
echo "  Version:          $([ -f "${TARGET_DIR}/.ak-cogos-version" ] && cat "${TARGET_DIR}/.ak-cogos-version" || echo 'MISSING')"

if [[ "$CMD_COUNT" -ne 20 && "$DRY_RUN" == false ]]; then
  echo ""
  echo "  [WARN] Expected exactly 20 commands, found ${CMD_COUNT}"
  echo "         Run 'ls ${TARGET_DIR}/.claude/commands/' to investigate"
  WARNINGS+=("Command count mismatch: expected 20, got ${CMD_COUNT}")
fi

if [[ ${#WARNINGS[@]} -gt 0 ]]; then
  echo ""
  echo "  Warnings:"
  for w in "${WARNINGS[@]}"; do
    echo "    - $w"
  done
fi

echo ""

if [[ "$AUDIT_ONLY" == true ]]; then
  echo "AUDIT COMPLETE — review warnings before running live."
  echo "Run without --audit-only (and without --dry-run) to apply changes."
  echo "Add --force to overwrite existing files."
elif [[ "$DRY_RUN" == true && $CHANGES -gt 0 ]]; then
  echo "Run without --dry-run to apply these changes."
  echo "Add --force to overwrite existing files."
fi

echo ""
echo "Claude Code native integration checklist:"
echo "  $([ -f "${TARGET_DIR}/.claude/settings.json" ] && echo '[x]' || echo '[ ]') .claude/settings.json — hooks + permissions"
echo "  $([ -f "${TARGET_DIR}/.claudeignore" ] && echo '[x]' || echo '[ ]') .claudeignore — context window optimization"
echo "  $([ -f "${TARGET_DIR}/memory/MEMORY.md" ] && echo '[x]' || echo '[ ]') memory/MEMORY.md — persistent project memory"
echo "  $([ -d "${TARGET_DIR}/scripts/hooks" ] && echo '[x]' || echo '[ ]') scripts/hooks/ — enforcement hook scripts"
echo "  $([ -f "${TARGET_DIR}/ANTI-SYCOPHANCY.md" ] && echo '[x]' || echo '[ ]') ANTI-SYCOPHANCY.md — standing instruction"
echo "  $([ -d "${TARGET_DIR}/mcp-servers" ] && echo '[x]' || echo '[ ]') mcp-servers/ — state machine + audit log MCP servers"
echo "  $([ -f "${TARGET_DIR}/tasks/codex-review.md" ] && echo '[x]' || echo '[ ]') tasks/codex-review.md — Codex review file"
echo "  $([ -f "${TARGET_DIR}/memory/teaching-log.md" ] && echo '[x]' || echo '[ ]') memory/teaching-log.md — teaching log"
echo "  $([ -f "${TARGET_DIR}/tasks/design-system.md" ] && echo '[x]' || echo '[ ]') tasks/design-system.md — design system placeholder"
echo ""

# ---------------------------------------------------------------------------
# Mid-build detection
# ---------------------------------------------------------------------------

TODO_CHECK="${TARGET_DIR}/tasks/todo.md"
if [[ -f "$TODO_CHECK" ]]; then
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
  fi
fi
