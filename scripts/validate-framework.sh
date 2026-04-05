#!/usr/bin/env bash
set -euo pipefail

[[ -n "${BASH_VERSION:-}" ]] || { echo "ERROR: Run with bash: bash scripts/validate-framework.sh"; exit 1; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail() {
  echo "[FAIL] $1"
  exit 1
}

# Hard-fail if required framework dirs are missing (catches wrong ROOT silently)
[[ -d "$ROOT/personas" ]] || fail "personas/ not found under ROOT=$ROOT — wrong directory?"
[[ -d "$ROOT/skills" ]]   || fail "skills/ not found under ROOT=$ROOT — wrong directory?"
[[ -d "$ROOT/schemas" ]]  || fail "schemas/ not found under ROOT=$ROOT — wrong directory?"

echo "[INFO] Running framework validation in $ROOT"

# 1) All agent files must include BOUNDARY_FLAG
while IFS= read -r f; do
  grep -q 'BOUNDARY_FLAG' "$f" || fail "Missing BOUNDARY_FLAG: $f"
done < <(find "$ROOT/personas" "$ROOT/skills" -type f \( -name 'claude-command.md' -o -name 'codex-prompt.md' \) | sort)

echo "[OK] BOUNDARY_FLAG present in all agent files"

# 2) All claude-command.md and codex-prompt.md YAML must include 10 envelope keys
ROOT="$ROOT" python3 - <<'PY'
from pathlib import Path
import os, re, sys
root=Path(os.environ["ROOT"])
req=['run_id','agent','origin','status','timestamp_utc','summary','failures','warnings','artifacts_written','next_action']
files=sorted(list(root.glob('personas/**/claude-command.md'))+list(root.glob('skills/**/claude-command.md'))+list(root.glob('personas/**/codex-prompt.md'))+list(root.glob('skills/**/codex-prompt.md')))

def blocks(text):
    out=[]; ls=text.splitlines(); i=0
    while i<len(ls):
        if ls[i].strip().startswith('```yaml'):
            s=i+1; j=i+1
            while j<len(ls) and not ls[j].strip().startswith('```'):
                j+=1
            out.append('\n'.join(ls[s:j])); i=j
        i+=1
    return out

for f in files:
    t=f.read_text(encoding='utf-8')
    bs=blocks(t)
    if not bs:
        print(f"[FAIL] No YAML block: {f}")
        sys.exit(1)
    b=bs[-1] if f.name=='claude-command.md' else bs[0]
    miss=[k for k in req if re.search(rf'^\s*{k}\s*:',b,re.M) is None]
    if miss:
        print(f"[FAIL] Missing envelope fields in {f}: {miss}")
        sys.exit(1)
print("[OK] Envelope fields present in all agent YAML blocks")
PY

# 3) Schema headers
while IFS= read -r f; do
  grep -q 'validation: markdown-contract-only | machine-validated' "$f" || fail "Missing schema validation header: $f"
done < <(find "$ROOT/schemas" -type f -name '*.md' | sort)

echo "[OK] Schema headers verified"

# 4) All SKILL.md files must have valid YAML frontmatter: name, description, tools
ROOT="$ROOT" python3 - <<'PY'
from pathlib import Path
import os, sys
root = Path(os.environ["ROOT"])
required = ["name", "description", "tools"]
files = sorted(list(root.glob("personas/**/SKILL.md")) + list(root.glob("skills/**/SKILL.md")))

for f in files:
    lines = f.read_text(encoding="utf-8").splitlines()
    # Must start with ---
    if not lines or lines[0].strip() != "---":
        print(f"[FAIL] Missing YAML frontmatter (no opening ---): {f}")
        sys.exit(1)
    # Find closing ---
    end = next((i for i in range(1, len(lines)) if lines[i].strip() == "---"), None)
    if end is None:
        print(f"[FAIL] Unclosed YAML frontmatter (no closing ---): {f}")
        sys.exit(1)
    frontmatter = "\n".join(lines[1:end])
    missing = [k for k in required if not any(line.startswith(f"{k}:") for line in lines[1:end])]
    if missing:
        print(f"[FAIL] SKILL.md missing frontmatter fields {missing}: {f}")
        sys.exit(1)

print(f"[OK] SKILL.md frontmatter valid in all {len(files)} files")
PY

# 5) State machine consistency: session-open expects CLOSED, session-close expects OPEN
SESSION_OPEN="${ROOT}/skills/session-open/claude-command.md"
SESSION_CLOSE="${ROOT}/skills/session-close/claude-command.md"

if [[ -f "$SESSION_OPEN" ]]; then
  # session-open must check for CLOSED (precondition to open)
  if grep -q 'CLOSED' "$SESSION_OPEN"; then
    echo "[OK] session-open references CLOSED state (correct precondition)"
  else
    fail "session-open does not reference CLOSED state — state machine contract violation (see schemas/state-machine.md)"
  fi
  # session-open must NOT require Status == OPEN as a precondition before execution (the v1.0-v1.1 bug)
  # Note: it IS valid to check Status == OPEN *after* writing (post-write validation)
  # The bug pattern is: "BLOCKED immediately if ... Status ≠ OPEN" appearing before any write step
  if grep -qE 'BLOCKED immediately.*Status ≠ OPEN|BLOCKED immediately.*Status != OPEN' "$SESSION_OPEN" 2>/dev/null; then
    fail "session-open still requires Status == OPEN as precondition — this is the locked-door bug"
  fi
fi

if [[ -f "$SESSION_CLOSE" ]]; then
  # session-close must check for OPEN (precondition to close)
  if grep -q 'OPEN' "$SESSION_CLOSE"; then
    echo "[OK] session-close references OPEN state (correct precondition)"
  else
    fail "session-close does not reference OPEN state — state machine contract violation (see schemas/state-machine.md)"
  fi
fi

# 6) Planning doc templates must exist in project-template/docs/
TEMPLATE_DOCS="${ROOT}/project-template/docs"
REQUIRED_TEMPLATES=(
  "problem-definition.md"
  "scope-brief.md"
  "hld.md"
  "assumptions.md"
  "decision-log.md"
  "release-truth.md"
  "traceability-matrix.md"
  "current-state.md"
  "lld/README.md"
  "lld/feature-template.md"
)

for tmpl in "${REQUIRED_TEMPLATES[@]}"; do
  [[ -f "${TEMPLATE_DOCS}/${tmpl}" ]] || fail "Missing planning doc template: project-template/docs/${tmpl}"
done

echo "[OK] All 10 planning doc templates present"

# 7) Planning doc templates must have metadata headers (Status: field)
for tmpl in "${REQUIRED_TEMPLATES[@]}"; do
  tmpl_file="${TEMPLATE_DOCS}/${tmpl}"
  # Skip README.md — it doesn't need a metadata header
  [[ "$(basename "$tmpl_file")" == "README.md" ]] && continue
  grep -q '^Status:' "$tmpl_file" || fail "Missing Status: metadata header in project-template/docs/${tmpl}"
done

echo "[OK] Metadata headers present in planning doc templates"

# 8) Guides 11 and 12 must exist
[[ -f "${ROOT}/guides/11-conversation-first-planning.md" ]] || fail "Missing guide: guides/11-conversation-first-planning.md"
[[ -f "${ROOT}/guides/12-mid-build-recovery.md" ]] || fail "Missing guide: guides/12-mid-build-recovery.md"

echo "[OK] Planning guides present (11, 12)"

# 9) Validator suite exists
[[ -f "${ROOT}/validators/runner.py" ]] || fail "Missing validators/runner.py"
[[ -f "${ROOT}/validators/base.py" ]] || fail "Missing validators/base.py"

echo "[OK] Validator suite present"

# 10) Plugin manifest: settings path exists
PLUGIN_JSON="${ROOT}/.claude-plugin/plugin.json"
if [[ -f "$PLUGIN_JSON" ]]; then
  PLUGIN_SETTINGS="$(python3 -c "
import json
with open('${PLUGIN_JSON}') as f:
    d = json.load(f)
print(d.get('settings', ''))
" 2>/dev/null || echo "")"
  if [[ -n "$PLUGIN_SETTINGS" ]]; then
    [[ -f "${ROOT}/${PLUGIN_SETTINGS}" ]] || fail "Plugin manifest settings path does not exist: ${PLUGIN_SETTINGS} (declared in .claude-plugin/plugin.json)"
    echo "[OK] Plugin manifest settings path exists: ${PLUGIN_SETTINGS}"
  fi

  # 11) Plugin manifest: all command files exist
  MISSING_CMDS=0
  while IFS= read -r cmd_file; do
    [[ -z "$cmd_file" ]] && continue
    if [[ ! -f "${ROOT}/${cmd_file}" ]]; then
      echo "[FAIL] Plugin command file missing: ${cmd_file}"
      MISSING_CMDS=$((MISSING_CMDS + 1))
    fi
  done < <(python3 -c "
import json
with open('${PLUGIN_JSON}') as f:
    d = json.load(f)
for cmd in d.get('commands', []):
    print(cmd.get('file', ''))
" 2>/dev/null || echo "")
  [[ $MISSING_CMDS -eq 0 ]] || exit 1
  echo "[OK] All plugin command files exist"
fi

# 12) package.json files list includes .claude-plugin/ and .claude/
PACKAGE_JSON="${ROOT}/package.json"
if [[ -f "$PACKAGE_JSON" ]]; then
  python3 - <<PY || fail "package.json files list is missing .claude-plugin/ or .claude/ — run npm pack will omit native Claude Code assets"
import json, sys
with open('${PACKAGE_JSON}') as f:
    d = json.load(f)
files = d.get('files', [])
missing = []
if not any('.claude-plugin' in entry for entry in files):
    missing.append('.claude-plugin/')
if not any(entry.strip('/') == '.claude' for entry in files):
    missing.append('.claude/')
if missing:
    print(f"[FAIL] package.json files missing: {missing}")
    sys.exit(1)
PY
  echo "[OK] package.json files includes .claude-plugin/ and .claude/"
fi

# 13) Hook scripts referenced in .claude/settings.json all exist
SETTINGS_JSON="${ROOT}/.claude/settings.json"
if [[ -f "$SETTINGS_JSON" ]]; then
  MISSING_HOOKS=0
  while IFS= read -r hook_cmd; do
    [[ -z "$hook_cmd" ]] && continue
    hook_script="$(echo "$hook_cmd" | grep -oE 'scripts/hooks/[^ ]+\.sh' || echo "")"
    [[ -z "$hook_script" ]] && continue
    if [[ ! -f "${ROOT}/${hook_script}" ]]; then
      echo "[FAIL] Hook script missing: ${hook_script}"
      MISSING_HOOKS=$((MISSING_HOOKS + 1))
    fi
  done < <(python3 -c "
import json
with open('${SETTINGS_JSON}') as f:
    d = json.load(f)
hooks = d.get('hooks', {})
for event_hooks in hooks.values():
    for h in event_hooks:
        print(h.get('command', ''))
" 2>/dev/null || echo "")
  [[ $MISSING_HOOKS -eq 0 ]] || exit 1
  echo "[OK] All hook scripts referenced in .claude/settings.json exist"
fi

# 14) Bootstrap smoke check: project-template/ required files present
for req_tmpl in \
  "project-template/.claude/settings.json" \
  "project-template/.claudeignore" \
  "project-template/memory/MEMORY.md" \
  "project-template/tasks/next-action.md"; do
  [[ -f "${ROOT}/${req_tmpl}" ]] || fail "Missing required bootstrap template: ${req_tmpl}"
done

echo "[OK] project-template/ bootstrap files present"

# 15) MCP server files must exist
MCP_FILES=(
  "mcp-servers/state_machine_server.py"
  "mcp-servers/audit_log_server.py"
  "mcp-servers/requirements.txt"
)
for mcp_file in "${MCP_FILES[@]}"; do
  [[ -f "${ROOT}/${mcp_file}" ]] || fail "Missing MCP server file: ${mcp_file}"
done

echo "[OK] MCP server files present (state_machine_server.py, audit_log_server.py, requirements.txt)"

# 16) Context budgets: every persona card must have ## Context Budget + 3 subsections
ROOT="$ROOT" python3 - <<'PY'
from pathlib import Path
import os, sys

root = Path(os.environ["ROOT"])
persona_cards = sorted(root.glob("personas/*/claude-command.md"))

REQUIRED_BUDGET_HEADER = "## Context Budget"
REQUIRED_SUBSECTIONS = ["Always load", "Load on demand", "Never load"]

for f in persona_cards:
    text = f.read_text(encoding="utf-8")
    if REQUIRED_BUDGET_HEADER not in text:
        print(f"[FAIL] Missing '## Context Budget' section in {f}")
        sys.exit(1)
    missing_sub = [s for s in REQUIRED_SUBSECTIONS if s not in text]
    if missing_sub:
        print(f"[FAIL] Missing Context Budget subsections {missing_sub} in {f}")
        sys.exit(1)

print(f"[OK] Context Budget sections present in all {len(persona_cards)} persona cards")
PY

# 17) Tier field present in project-template/CLAUDE.md (STEP-43)
TEMPLATE_CLAUDE="${ROOT}/project-template/CLAUDE.md"
if [[ -f "$TEMPLATE_CLAUDE" ]]; then
  grep -qE '^Tier:' "$TEMPLATE_CLAUDE" || fail "project-template/CLAUDE.md is missing Tier: field — add 'Tier: Standard' (see framework/governance/operating-tiers.md)"
  echo "[OK] project-template/CLAUDE.md has Tier: field"
else
  fail "project-template/CLAUDE.md not found"
fi

# 18) guard-planning-artifacts.sh wired in project-template/.claude/settings.json (STEP-43)
TEMPLATE_SETTINGS="${ROOT}/project-template/.claude/settings.json"
if [[ -f "$TEMPLATE_SETTINGS" ]]; then
  grep -q 'guard-planning-artifacts.sh' "$TEMPLATE_SETTINGS" || fail "project-template/.claude/settings.json does not reference guard-planning-artifacts.sh — hook is missing from PreToolUse block (see STEP-31)"
  echo "[OK] guard-planning-artifacts.sh wired in project-template/.claude/settings.json"
else
  fail "project-template/.claude/settings.json not found"
fi

# 19) Artifact-map consistency check — all non-CREATED-ON-DEMAND paths exist in project-template/ (STEP-44)
MISSING_ARTIFACTS="$(ROOT="$ROOT" python3 - <<'PYEOF'
import sys, os
root = os.environ.get('ROOT', '.')
missing = []
try:
    with open(os.path.join(root, 'framework/governance/artifact-map.md')) as f:
        in_inventory = False
        for line in f:
            stripped = line.strip()
            if '## Artifact Inventory' in stripped:
                in_inventory = True
                continue
            if in_inventory and stripped.startswith('##'):
                break
            if not in_inventory or not stripped.startswith('|'):
                continue
            cols = [c.strip() for c in stripped.split('|')]
            if len(cols) < 4:
                continue
            name = cols[1]
            path = cols[2]
            if not name or not path or name.startswith('Artifact') or path.startswith('-') or path.startswith('Path'):
                continue
            if 'CREATED-ON-DEMAND' in path or '*' in path:
                continue
            check = os.path.join(root, 'project-template', path)
            if not os.path.exists(check):
                missing.append(f'{name} (expected: project-template/{path})')
except Exception as e:
    print(f'ERROR reading artifact-map.md: {e}', file=sys.stderr)
for m in missing:
    print(m)
PYEOF
)"
if [[ -n "$MISSING_ARTIFACTS" ]]; then
  echo "[FAIL] Artifacts missing from project-template/:"
  echo "$MISSING_ARTIFACTS" | while IFS= read -r line; do echo "       - ${line}"; done
  exit 1
fi
echo "[OK] All artifact-map.md paths present in project-template/"

# 20) Governance completeness check — governance docs and guides all present (STEP-45)
GOV_DOCS=("artifact-map.md" "artifact-ownership.md" "change-policy.md" "default-workflows.md" \
          "delivery-lifecycle.md" "metrics-tracker.md" "operating-tiers.md" "release-policy.md" \
          "role-design-rules.md" "role-taxonomy.md" "stage-gates.md" "versioning-policy.md")
GOV_MISSING=""
for doc in "${GOV_DOCS[@]}"; do
  [[ -f "${ROOT}/framework/governance/${doc}" ]] || GOV_MISSING="${GOV_MISSING} ${doc}"
done
if [[ -n "$GOV_MISSING" ]]; then
  fail "Governance docs missing from framework/governance/:${GOV_MISSING}"
fi
echo "[OK] All 12 governance docs present in framework/governance/"

GUIDE_MISSING=""
for i in $(seq -w 0 14); do
  ls "${ROOT}/guides/${i}-"*.md 2>/dev/null | grep -q . || GUIDE_MISSING="${GUIDE_MISSING} ${i}"
done
if [[ -n "$GUIDE_MISSING" ]]; then
  fail "Guides missing from guides/ (numeric prefix):${GUIDE_MISSING}"
fi
echo "[OK] All 15 guides present in guides/ (00-14)"

# 21) Semantic lint: placeholder tokens, role_class, format classes, extra_fields
ROOT="$ROOT" bash "${ROOT}/scripts/validate-contracts.sh"

echo "[PASS] Framework validation complete (20 structural checks + semantic lint)"
