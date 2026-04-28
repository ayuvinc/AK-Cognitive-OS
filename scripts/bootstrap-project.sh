#!/usr/bin/env bash
set -euo pipefail

[[ -n "${BASH_VERSION:-}" ]] || { echo "ERROR: Run with bash: bash scripts/bootstrap-project.sh"; exit 1; }

# bootstrap-project.sh
# Usage: bootstrap-project.sh <target_project_path> [--force] [--non-interactive]
#
# Copies the AK-Cognitive-OS project template into an existing project directory.
# Creates tasks/, releases/, docs/, .claude/commands/, and framework/ directories.
# Installs personas, skills, review contracts, templates, schemas, and planning doc templates.
# Runs an interactive intake interview to pre-fill CLAUDE.md and planning doc stubs.
# Pass --force to overwrite files that already exist.
# Pass --non-interactive to skip interview and create blank templates.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
FRAMEWORK_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
VERSION="4.0.0"

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
  mkdir -p "$TARGET_DIR" || { echo "ERROR: Could not create target directory: $TARGET_DIR"; exit 1; }
  echo "[ok] Created target directory: $TARGET_DIR"
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
PROJECT_TIER="Standard"
RISK_LEVEL=""
COMPLIANCE_REQS=""
AI_FEATURES=""
AUDIT_LOG_PATH="releases/audit-log.md"

# Discovery conversation fields (v2.0)
PRIMARY_USER=""
USER_PROBLEM=""
DELIVERY_TARGET=""
SUCCESS_METRIC=""

if [[ "$INTERACTIVE" == true ]]; then
  echo "=========================================="
  echo "  Project Intake Interview"
  echo "=========================================="
  echo ""
  echo "Answer a few questions to pre-fill your CLAUDE.md and planning docs."
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

  # Tier selection — determines which enforcement gates are active
  while true; do
    read -rp "  Project tier [MVP/Standard/High-Risk]? [default: Standard]: " input
    if [[ -z "$input" ]]; then
      PROJECT_TIER="Standard"
      break
    elif [[ "$input" =~ ^(MVP|Standard|High-Risk)$ ]]; then
      PROJECT_TIER="$input"
      break
    else
      echo "  ERROR: Invalid tier '${input}'. Must be MVP, Standard, or High-Risk."
    fi
  done

  read -rp "  Risk level (low/medium/high/regulated): " input
  [[ -n "$input" ]] && RISK_LEVEL="$input"

  read -rp "  Compliance needed (comma-separated, or none): " input
  [[ -n "$input" ]] && COMPLIANCE_REQS="$input"

  read -rp "  AI features? (yes/no): " input
  [[ -n "$input" ]] && AI_FEATURES="$input"

  read -rp "  Audit log path [default: releases/audit-log.md]: " input
  [[ -n "$input" ]] && AUDIT_LOG_PATH="$input"

  echo ""
  echo "--- Discovery Questions (for planning docs) ---"
  echo ""

  read -rp "  Who is the primary user? " input
  [[ -n "$input" ]] && PRIMARY_USER="$input"

  read -rp "  What problem does this solve for them? " input
  [[ -n "$input" ]] && USER_PROBLEM="$input"

  read -rp "  Delivery target (demo/pilot/production): " input
  [[ -n "$input" ]] && DELIVERY_TARGET="$input"

  read -rp "  What defines success? (one measurable outcome): " input
  [[ -n "$input" ]] && SUCCESS_METRIC="$input"

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
mkdir -p "${TARGET_DIR}/docs/lld"
mkdir -p "${TARGET_DIR}/.claude/commands"
mkdir -p "${TARGET_DIR}/framework/interop"
mkdir -p "${TARGET_DIR}/framework/codex-core/runbooks"
mkdir -p "${TARGET_DIR}/framework/codex-core/validators"
mkdir -p "${TARGET_DIR}/framework/templates"
mkdir -p "${TARGET_DIR}/framework/schemas"
mkdir -p "${TARGET_DIR}/framework/governance"
echo "  [ok] tasks/"
echo "  [ok] releases/"
echo "  [ok] docs/ (planning artifacts + lld/)"
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
  # Apply tier — replaces the default 'Tier: Standard' from the template with the user-selected value
  # The tier value is a literal string (never executed), matched at line start to avoid false positives
  sed -i.bak "s|^Tier: Standard|Tier: ${PROJECT_TIER}|" "${TARGET_DIR}/CLAUDE.md"
  rm -f "${TARGET_DIR}/CLAUDE.md.bak"

  # Append intake summary if risk level was provided (idempotent — skip if already present)
  if [[ -n "$RISK_LEVEL" ]] && ! grep -q "## Intake Summary" "${TARGET_DIR}/CLAUDE.md" 2>/dev/null; then
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
# Copy planning doc templates (docs/)
# ---------------------------------------------------------------------------

TEMPLATE_DOCS_DIR="${TEMPLATE_DIR}/docs"

if [[ -d "$TEMPLATE_DOCS_DIR" ]]; then
  echo "Copying planning doc templates..."
  for src_file in "${TEMPLATE_DOCS_DIR}"/*.md; do
    if [[ -f "$src_file" ]]; then
      dst_file="${TARGET_DIR}/docs/$(basename "$src_file")"
      copy_file "$src_file" "$dst_file"
    fi
  done
  # Copy lld/ subdirectory
  if [[ -d "${TEMPLATE_DOCS_DIR}/lld" ]]; then
    for src_file in "${TEMPLATE_DOCS_DIR}/lld"/*.md; do
      if [[ -f "$src_file" ]]; then
        dst_file="${TARGET_DIR}/docs/lld/$(basename "$src_file")"
        copy_file "$src_file" "$dst_file"
      fi
    done
  fi
  echo ""
else
  echo "  [warn] project-template/docs/ not found -- skipping planning doc copy"
fi

# ---------------------------------------------------------------------------
# Auto-fill planning doc stubs from discovery answers (v2.0)
# All bootstrap-generated content defaults to Status: draft, Source: mixed
# ---------------------------------------------------------------------------

if [[ "$INTERACTIVE" == true ]]; then
  TODAY="$(date +%Y-%m-%d)"

  # Auto-fill problem-definition.md
  if [[ -n "$PRIMARY_USER" || -n "$USER_PROBLEM" ]] && [[ -f "${TARGET_DIR}/docs/problem-definition.md" ]]; then
    echo "Auto-filling planning doc stubs (Status: draft)..."
    sed -i.bak "s|Last confirmed with user: YYYY-MM-DD|Last confirmed with user: ${TODAY}|" "${TARGET_DIR}/docs/problem-definition.md"
    sed -i.bak "s|Source: (user-confirmed | ai-inferred | code-observed | mixed)|Source: mixed|" "${TARGET_DIR}/docs/problem-definition.md"
    if [[ -n "$PRIMARY_USER" ]]; then
      sed -i.bak "s|Who is the main person using this product? What is their role, context, and technical level?|${PRIMARY_USER}|" "${TARGET_DIR}/docs/problem-definition.md"
    fi
    if [[ -n "$USER_PROBLEM" ]]; then
      sed -i.bak "s|What specific problem does the user face today?.*|${USER_PROBLEM}|" "${TARGET_DIR}/docs/problem-definition.md"
    fi
    rm -f "${TARGET_DIR}/docs/problem-definition.md.bak"
    echo "  [ok] docs/problem-definition.md stub filled (Status: draft)"
  fi

  # Auto-fill scope-brief.md
  if [[ -n "$DELIVERY_TARGET" || -n "$SUCCESS_METRIC" ]] && [[ -f "${TARGET_DIR}/docs/scope-brief.md" ]]; then
    sed -i.bak "s|Last confirmed with user: YYYY-MM-DD|Last confirmed with user: ${TODAY}|" "${TARGET_DIR}/docs/scope-brief.md"
    sed -i.bak "s|Source: (user-confirmed | ai-inferred | code-observed | mixed)|Source: mixed|" "${TARGET_DIR}/docs/scope-brief.md"
    if [[ -n "$DELIVERY_TARGET" ]]; then
      sed -i.bak "s|Target | demo / pilot / production|Target | ${DELIVERY_TARGET}|" "${TARGET_DIR}/docs/scope-brief.md"
    fi
    if [[ -n "$SUCCESS_METRIC" ]]; then
      sed -i.bak "s|Success metric | |Success metric | ${SUCCESS_METRIC}|" "${TARGET_DIR}/docs/scope-brief.md"
    fi
    rm -f "${TARGET_DIR}/docs/scope-brief.md.bak"
    echo "  [ok] docs/scope-brief.md stub filled (Status: draft)"
  fi

  echo ""
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
    # Skip sub-persona directories — installed separately as optional add-ons
    [[ "$persona_name" =~ ^(researcher|compliance)- ]] && continue

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
    # Skip optional skills — use --optional flag to include them
    [[ "$skill_name" == "optional" ]] && continue

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
# Install Claude Code native integration (settings, hooks, ignore, memory)
# ---------------------------------------------------------------------------

echo "Installing Claude Code native integration..."

# .claude/settings.json
SETTINGS_SRC="${TEMPLATE_DIR}/.claude/settings.json"
if [[ -f "$SETTINGS_SRC" ]]; then
  copy_file "$SETTINGS_SRC" "${TARGET_DIR}/.claude/settings.json"
  # Fix MCP server paths: template uses relative placeholders; resolve to absolute at bootstrap time
  # so MCP startup is not dependent on the cwd from which Claude Code is launched.
  # LOCK_FILE is passed as sys.argv[1] — safe even if TARGET_DIR contains special characters.
  if [[ -f "${TARGET_DIR}/.claude/settings.json" ]]; then
    # Add enableAllProjectMcpServers: true so Claude Code auto-connects .mcp.json servers
    # without prompting the user on every session start.
    python3 -c "
import json, sys
path = sys.argv[1]
with open(path) as f:
    d = json.load(f)
d['enableAllProjectMcpServers'] = True
with open(path, 'w') as f:
    json.dump(d, f, indent=2)
" "${TARGET_DIR}/.claude/settings.json"
    echo "  [ok] enableAllProjectMcpServers set to true"
  fi

  # Generate .mcp.json — Claude Code reads MCP server definitions from here, not settings.json.
  # Absolute paths stamped at bootstrap time so startup is not cwd-dependent.
  PYTHON3_BIN="$(command -v python3 2>/dev/null || echo "python3")"
  cat > "${TARGET_DIR}/.mcp.json" <<MCPEOF
{
  "mcpServers": {
    "ak-state-machine": {
      "type": "stdio",
      "command": "${PYTHON3_BIN}",
      "args": ["${TARGET_DIR}/mcp-servers/state_machine_server.py"],
      "env": {"PROJECT_ROOT": "${TARGET_DIR}"}
    },
    "ak-audit-log": {
      "type": "stdio",
      "command": "${PYTHON3_BIN}",
      "args": ["${TARGET_DIR}/mcp-servers/audit_log_server.py"],
      "env": {"PROJECT_ROOT": "${TARGET_DIR}", "AUDIT_LOG_PATH": "tasks/audit-log.md"}
    },
    "ak-memory": {
      "type": "stdio",
      "command": "${PYTHON3_BIN}",
      "args": ["${TARGET_DIR}/mcp-servers/memory_server.py"],
      "env": {"PROJECT_ROOT": "${TARGET_DIR}"}
    }
  }
}
MCPEOF
  echo "  [ok] .mcp.json created (python3: ${PYTHON3_BIN})"
fi

# .claude/settings.local.json.example
SETTINGS_LOCAL_SRC="${TEMPLATE_DIR}/.claude/settings.local.json.example"
if [[ -f "$SETTINGS_LOCAL_SRC" ]]; then
  copy_file "$SETTINGS_LOCAL_SRC" "${TARGET_DIR}/.claude/settings.local.json.example"
fi

# .claudeignore
CLAUDEIGNORE_SRC="${TEMPLATE_DIR}/.claudeignore"
if [[ -f "$CLAUDEIGNORE_SRC" ]]; then
  copy_file "$CLAUDEIGNORE_SRC" "${TARGET_DIR}/.claudeignore"
fi

# memory/MEMORY.md + v4 additions (index.json, sessions/, decisions/, outcomes/)
mkdir -p "${TARGET_DIR}/memory/sessions" \
         "${TARGET_DIR}/memory/decisions" \
         "${TARGET_DIR}/memory/outcomes"
MEMORY_SRC="${TEMPLATE_DIR}/memory/MEMORY.md"
if [[ -f "$MEMORY_SRC" ]]; then
  copy_file "$MEMORY_SRC" "${TARGET_DIR}/memory/MEMORY.md"
  # Apply intake answers to MEMORY.md if interactive
  if [[ "$INTERACTIVE" == true && -f "${TARGET_DIR}/memory/MEMORY.md" ]]; then
    sed -i.bak "s|\[PROJECT_NAME\]|${PROJECT_NAME}|g" "${TARGET_DIR}/memory/MEMORY.md"
    sed -i.bak "s|\[STACK\]|${TECH_STACK}|g" "${TARGET_DIR}/memory/MEMORY.md"
    sed -i.bak "s|\[AK_COGOS_VERSION\]|${VERSION}|g" "${TARGET_DIR}/memory/MEMORY.md"
    rm -f "${TARGET_DIR}/memory/MEMORY.md.bak"
  fi
fi
MEMORY_INDEX_SRC="${TEMPLATE_DIR}/memory/index.json"
if [[ -f "$MEMORY_INDEX_SRC" ]]; then
  copy_file "$MEMORY_INDEX_SRC" "${TARGET_DIR}/memory/index.json"
fi
echo "  [ok] memory/ v4 scaffold (index.json + sessions/ decisions/ outcomes/)"

# ANTI-SYCOPHANCY.md
ANTI_SRC="${FRAMEWORK_DIR}/ANTI-SYCOPHANCY.md"
if [[ -f "$ANTI_SRC" ]]; then
  copy_file "$ANTI_SRC" "${TARGET_DIR}/ANTI-SYCOPHANCY.md"
fi

echo ""

# ---------------------------------------------------------------------------
# Install hook scripts
# ---------------------------------------------------------------------------

echo "Installing enforcement hook scripts..."
HOOKS_SRC="${FRAMEWORK_DIR}/scripts/hooks"
mkdir -p "${TARGET_DIR}/scripts/hooks"

if [[ -d "$HOOKS_SRC" ]]; then
  for hook_file in "${HOOKS_SRC}"/*.sh; do
    [[ -f "$hook_file" ]] || continue
    dst_hook="${TARGET_DIR}/scripts/hooks/$(basename "$hook_file")"
    copy_file "$hook_file" "$dst_hook"
    chmod +x "$dst_hook" 2>/dev/null || true
  done
fi

echo ""

# ---------------------------------------------------------------------------
# Install MCP server scripts and dependencies
# ---------------------------------------------------------------------------

echo "Installing MCP servers..."
MCP_SRC="${FRAMEWORK_DIR}/mcp-servers"
mkdir -p "${TARGET_DIR}/mcp-servers"

if [[ -d "$MCP_SRC" ]]; then
  for mcp_file in "${MCP_SRC}"/*.py "${MCP_SRC}/requirements.txt"; do
    [[ -f "$mcp_file" ]] || continue
    copy_file "$mcp_file" "${TARGET_DIR}/mcp-servers/$(basename "$mcp_file")"
  done
  echo "  [ok] mcp-servers/ installed"
else
  echo "  [warn] mcp-servers/ not found in framework source -- skipping"
fi

# Install MCP Python dependency (mcp package required for state_machine_server.py and audit_log_server.py)
# Non-fatal: some environments use conda/venv with different pip paths.
if [[ -f "${TARGET_DIR}/mcp-servers/requirements.txt" ]]; then
  echo "  [*] Installing MCP server dependencies (pip3 install mcp>=1.0.0)..."
  if pip3 install -r "${TARGET_DIR}/mcp-servers/requirements.txt" --quiet 2>/dev/null; then
    echo "  [ok] MCP dependencies installed"
  else
    echo ""
    echo "  ============================================================"
    echo "  WARN: pip3 install failed for mcp-servers/requirements.txt"
    echo "  MCP servers will not work until the package is installed."
    echo "  Remediation: pip3 install mcp>=1.0.0"
    echo "  ============================================================"
    echo ""
  fi

  # Verify the mcp package is importable regardless of whether pip succeeded above
  if python3 -c "import mcp" 2>/dev/null; then
    echo "  [ok] mcp package verified importable"
  else
    echo ""
    echo "  ============================================================"
    echo "  WARN: mcp package is not importable after install attempt."
    echo "  session-open and session-close will use the file-write fallback"
    echo "  path until MCP is available."
    echo "  Remediation: pip3 install mcp>=1.0.0"
    echo "  ============================================================"
    echo ""
  fi
fi

echo ""

# ---------------------------------------------------------------------------
# Install v4 cognitive layer scaffolds (signals/, feedback/, validators/)
# ---------------------------------------------------------------------------

echo "Installing v4 cognitive layer scaffolds..."

# signals/ — signal engine output (active signals + history)
SIGNALS_SRC="${TEMPLATE_DIR}/signals"
if [[ -d "$SIGNALS_SRC" ]]; then
  mkdir -p "${TARGET_DIR}/signals/history"
  copy_file "${SIGNALS_SRC}/active.json" "${TARGET_DIR}/signals/active.json"
  echo "  [ok] signals/ scaffold (active.json + history/)"
else
  echo "  [warn] project-template/signals/ not found -- skipping signals scaffold"
fi

# feedback/ — feedback loop storage (qa, risk, velocity, codex records)
mkdir -p "${TARGET_DIR}/feedback/qa" \
         "${TARGET_DIR}/feedback/risk" \
         "${TARGET_DIR}/feedback/velocity" \
         "${TARGET_DIR}/feedback/codex"
FEEDBACK_SUMMARY="${TARGET_DIR}/feedback/summary.json"
if [[ ! -f "$FEEDBACK_SUMMARY" ]] || [[ "$FORCE" == true ]]; then
  printf '{"feedback": [], "total_entries": 0}\n' > "$FEEDBACK_SUMMARY"
  echo "  [create]    feedback/summary.json"
else
  echo "  [skip]      feedback/summary.json  (exists -- pass --force to overwrite)"
fi
echo "  [ok] feedback/ subdirs (qa/ risk/ velocity/ codex/)"

# validators/ — Python cognitive layer validators (memory, feedback, signal_engine)
VALIDATORS_SRC="${FRAMEWORK_DIR}/validators"
mkdir -p "${TARGET_DIR}/validators"
if [[ -d "$VALIDATORS_SRC" ]]; then
  for v_file in memory.py feedback.py signal_engine.py base.py; do
    if [[ -f "${VALIDATORS_SRC}/${v_file}" ]]; then
      copy_file "${VALIDATORS_SRC}/${v_file}" "${TARGET_DIR}/validators/${v_file}"
    else
      echo "  [warn] ${v_file} not found in framework validators/ -- skipping"
    fi
  done
  echo "  [ok] validators/ (memory.py feedback.py signal_engine.py base.py)"
else
  echo "  [warn] framework validators/ not found -- skipping validators copy"
fi

echo ""

# Add session lock file to .gitignore (created by session-open/close fallback path)
if [[ -f "${TARGET_DIR}/.gitignore" ]]; then
  if ! grep -q 'session-transition-lock' "${TARGET_DIR}/.gitignore" 2>/dev/null; then
    echo "" >> "${TARGET_DIR}/.gitignore"
    echo "# Session lock files (session-open/session-close fallback path)" >> "${TARGET_DIR}/.gitignore"
    echo "tasks/.session-transition-lock" >> "${TARGET_DIR}/.gitignore"
    echo "  [update]    .gitignore — added session lock file exclusion"
  fi
fi

echo ""

# ---------------------------------------------------------------------------
# Install sub-persona commands (researcher-*, compliance-*)
# Skipped by default — these are domain-specific add-ons, not part of the core 22.
# To install sub-personas: copy from personas/researcher/sub-personas/ or
# personas/compliance/sub-personas/ manually after bootstrap.
# ---------------------------------------------------------------------------

SUB_COUNT=0
echo "  [skip] sub-persona commands (researcher-*, compliance-*) — domain-specific, install manually if needed"
echo ""

# ---------------------------------------------------------------------------
# Add .claude/settings.local.json to .gitignore
# ---------------------------------------------------------------------------

GITIGNORE="${TARGET_DIR}/.gitignore"
if [[ -f "$GITIGNORE" ]]; then
  if ! grep -q 'settings.local.json' "$GITIGNORE" 2>/dev/null; then
    echo "" >> "$GITIGNORE"
    echo "# Claude Code local settings (personal overrides, not committed)" >> "$GITIGNORE"
    echo ".claude/settings.local.json" >> "$GITIGNORE"
    echo "  [update]    .gitignore — added settings.local.json exclusion"
  fi
else
  cat > "$GITIGNORE" <<'GITIGNORE_CONTENT'
# Claude Code local settings (personal overrides, not committed)
.claude/settings.local.json

# Environment
.env
.env.*
!.env.example
GITIGNORE_CONTENT
  echo "  [create]    .gitignore"
fi

echo ""

# ---------------------------------------------------------------------------
# Write version stamp
# ---------------------------------------------------------------------------

echo "${VERSION}" > "${TARGET_DIR}/.ak-cogos-version"
echo "  [create]    .ak-cogos-version (v${VERSION})"
echo ""

# ---------------------------------------------------------------------------
# Post-bootstrap validation
# ---------------------------------------------------------------------------

echo "Running post-bootstrap validation..."
VALIDATION_PASS=true

# Check critical files exist
for required in \
  "CLAUDE.md" \
  ".claude/commands/architect.md" \
  ".claude/settings.json" \
  ".claudeignore" \
  "memory/MEMORY.md" \
  "tasks/todo.md" \
  "tasks/ba-logic.md" \
  "tasks/ux-specs.md" \
  "tasks/lessons.md" \
  "tasks/next-action.md" \
  "channel.md" \
  "ANTI-SYCOPHANCY.md" \
  "scripts/hooks/guard-session-state.sh" \
  "scripts/hooks/guard-persona-boundaries.sh" \
  "scripts/hooks/guard-git-push.sh" \
  "signals/active.json" \
  "feedback/summary.json" \
  "validators/signal_engine.py"; do
  if [[ ! -f "${TARGET_DIR}/${required}" ]]; then
    echo "  [WARN] Missing: ${required}"
    VALIDATION_PASS=false
  fi
done

# Count commands installed
CMD_COUNT=$(find "${TARGET_DIR}/.claude/commands" -name '*.md' 2>/dev/null | wc -l)

if [[ "$VALIDATION_PASS" == true ]]; then
  echo "  [PASS] All critical files present"
else
  echo "  [WARN] Some files missing — check output above"
fi

echo ""

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------

TOTAL=$((INSTALLED + SKILL_COUNT + SUB_COUNT))
echo "=========================================="
echo "  Bootstrap complete!"
echo "=========================================="
echo ""
echo "  Slash commands:     ${CMD_COUNT} (${INSTALLED} personas + ${SUB_COUNT} sub-personas + ${SKILL_COUNT} skills)"
echo "  Hook scripts:       $(find "${TARGET_DIR}/scripts/hooks" -name '*.sh' 2>/dev/null | wc -l)"
echo "  Settings:           .claude/settings.json (hooks + permissions configured)"
echo "  Context filter:     .claudeignore"
echo "  Memory:             memory/MEMORY.md"
echo "  Framework version:  v${VERSION}"
echo ""
echo "IMPORTANT: Do not start building until planning docs are confirmed."
echo ""
echo "Next steps:"
if [[ "$INTERACTIVE" == false ]]; then
  echo "  1. Open ${TARGET_DIR}/CLAUDE.md and replace all [PLACEHOLDER] values."
else
  echo "  1. Review ${TARGET_DIR}/CLAUDE.md — intake answers have been applied."
fi
echo "  2. Review .claude/settings.json — adjust permissions for your stack."
echo "  3. Open a Claude Code session from your project root:"
echo "       cd ${TARGET_DIR} && claude"
echo "  4. Run discovery conversation to confirm problem + scope:"
echo "       /ba → confirm docs/problem-definition.md + docs/scope-brief.md"
echo "  5. Run HLD conversation → confirm docs/hld.md:"
echo "       /architect → draft and confirm HLD"
echo "  6. Create LLDs for first features → docs/lld/<feature>.md"
echo "  7. Derive tasks into tasks/todo.md"
echo "  8. Begin build"
echo ""
echo "Planning docs created (Status: draft):"
echo "  docs/problem-definition.md  docs/scope-brief.md"
echo "  docs/hld.md                 docs/assumptions.md"
echo "  docs/decision-log.md        docs/release-truth.md"
echo "  docs/traceability-matrix.md docs/current-state.md"
echo "  docs/lld/README.md          docs/lld/feature-template.md"
echo ""
echo "Claude Code native integration:"
echo "  .claude/settings.json       — hooks + permissions active"
echo "  .claudeignore               — context window optimized"
echo "  memory/MEMORY.md            — persistent project memory"
echo "  scripts/hooks/              — enforcement scripts installed"
echo "  ANTI-SYCOPHANCY.md          — standing instruction active"
echo ""
