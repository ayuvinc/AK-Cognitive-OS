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

echo "[PASS] Framework validation complete"
