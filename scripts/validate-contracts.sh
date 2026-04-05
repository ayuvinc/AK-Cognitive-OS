#!/usr/bin/env bash
# ============================================================
# validate-contracts.sh — Semantic Lint Layer (SL-1 through SL-4)
# Called by validate-framework.sh after structural checks complete.
# Usage: ROOT=/path/to/repo bash scripts/validate-contracts.sh
# ============================================================
#
# WHAT EACH CHECK TESTS:
#
# SL-1 (placeholder scan):
#   Scans .claude/commands/*.md for tokens matching \[[A-Z][A-Z_]{2,}\] that
#   are NOT in the exempt list. These patterns indicate unresolved template
#   stubs that should have been filled in before a command file was committed.
#   Exempt tokens are intentional output labels or canonical path references.
#
# SL-2 (role_class field):
#   Verifies every SKILL.md in personas/ and skills/ contains a role_class:
#   field in its YAML frontmatter. role_class was added in Session 5 (TASK-001)
#   to encode the 5-class taxonomy. This check prevents role_class from being
#   silently dropped in future edits.
#
# SL-3 (format class + required sections):
#   Verifies .claude/commands/*.md files carry the correct format class
#   declaration (## FORMAT: <class>) and meet the structural minimum for that
#   class:
#     - persona-card (implicit default, no FORMAT line required):
#         must have "## WHO YOU ARE" + a "HANDOFF" section
#     - role-card:  must have "## FORMAT: role-card"
#     - reference-doc: must have "## FORMAT: reference-doc"
#   A file with no ## FORMAT: declaration is treated as an implicit persona-card.
#
# SL-4 (extra_fields warning — non-blocking):
#   Warns if a persona-card file's handoff block is missing an extra_fields
#   declaration. All compliant persona-card files must either list their extra
#   fields (extra_fields: [field1, field2]) or explicitly declare none
#   (extra_fields: none). This prevents silent schema drift.
#
# ──────────────────────────────────────────────────────────────────────────────
# EXEMPT TOKEN LIST (SL-1):
#
#   AUDIT_LOG_PATH — canonical path placeholder; actual path varies per project.
#                    Referenced by agents as a symbolic key that project CLAUDE.md
#                    overrides. It is NOT a forgotten stub — projects that use
#                    the default path (tasks/audit-log.md) work without replacing it.
#
#   SCAFFOLD       — intentional output label in architect.md plan templates.
#                    Marks placeholder sections the architect fills at planning
#                    time when generating a new feature scaffold document.
#
#   UNVERIFIED     — intentional output label in researcher-news.md templates.
#                    Marks AI-generated news summaries requiring human verification
#                    before they are used as source material.
#
# HOW TO ADD A NEW EXEMPTION:
#   1. Confirm the token is intentional (output label, canonical path, etc.)
#      and NOT a forgotten template stub. Check git blame for context.
#   2. Add the token name (without [ ] brackets) to the EXEMPT_TOKENS set
#      in the Python block below (search for "EXEMPT_TOKENS =").
#   3. Add an entry to the EXEMPT TOKEN LIST section above explaining:
#      what the token is, where it appears, and why it is exempt.
# ============================================================

set -euo pipefail
ROOT="${ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

[[ -d "$ROOT/.claude/commands" ]] || {
  echo "[FAIL] SL: .claude/commands/ not found under ROOT=$ROOT"
  exit 1
}

ROOT="$ROOT" python3 - <<'PY'
import os, re, sys
from pathlib import Path

root = Path(os.environ["ROOT"])
fail_count = 0
warn_count = 0

def emit_fail(msg):
    global fail_count
    print(f"[FAIL] SL: {msg}")
    fail_count += 1

def emit_warn(msg):
    global warn_count
    print(f"[WARN] SL: {msg}")
    warn_count += 1

# ── SL-1: Placeholder token scan ─────────────────────────────────────────────
# Tokens in [UPPER_CASE] form that are intentional labels, not unresolved stubs.
EXEMPT_TOKENS = {
    "AUDIT_LOG_PATH",  # canonical path placeholder; projects override via CLAUDE.md
    "SCAFFOLD",        # intentional output label in architect.md templates
    "UNVERIFIED",      # intentional output label in researcher-news.md templates
    "NNN",             # task/risk number pattern label (TASK-[NNN], RISK-[NNN])
    "VERDICT",         # codex-read verdict routing label
}
placeholder_re = re.compile(r'\[([A-Z][A-Z_]{2,})\]')

for f in sorted(root.glob(".claude/commands/*.md")):
    text = f.read_text(encoding="utf-8")
    tokens = {m.group(1) for m in placeholder_re.finditer(text)} - EXEMPT_TOKENS
    for token in sorted(tokens):
        emit_fail(f"Unresolved placeholder [{token}] in {f.name}")

# ── SL-2: role_class field in SKILL.md ───────────────────────────────────────
skill_files = sorted(
    list(root.glob("personas/**/SKILL.md")) +
    list(root.glob("skills/**/SKILL.md"))
)
for f in skill_files:
    lines = f.read_text(encoding="utf-8").splitlines()
    if not lines or lines[0].strip() != "---":
        continue  # malformed frontmatter caught by check #4 in validate-framework.sh
    end = next((i for i in range(1, len(lines)) if lines[i].strip() == "---"), None)
    if end is None:
        continue  # malformed — caught upstream
    fm_lines = lines[1:end]
    if not any(line.startswith("role_class:") for line in fm_lines):
        emit_fail(f"SKILL.md missing role_class field: {f}")

# ── SL-3: Format class declarations and required sections ────────────────────
FORMAT_RE = re.compile(r"^## FORMAT:\s*(.+)$", re.MULTILINE)

for f in sorted(root.glob(".claude/commands/*.md")):
    text = f.read_text(encoding="utf-8")
    fmt_match = FORMAT_RE.search(text)
    fmt_class = fmt_match.group(1).strip() if fmt_match else None

    if fmt_class in ("role-card", "reference-doc"):
        # Minimum: the FORMAT declaration itself — already present by definition
        pass
    else:
        # Implicit or explicit persona-card: must have WHO YOU ARE + HANDOFF
        missing = []
        if "## WHO YOU ARE" not in text:
            missing.append("## WHO YOU ARE")
        if "HANDOFF" not in text:
            missing.append("HANDOFF section")
        if missing:
            emit_fail(
                f"persona-card {f.name} missing required sections: {', '.join(missing)}"
            )

# ── SL-4: extra_fields warning for persona-cards (non-blocking) ───────────────
for f in sorted(root.glob(".claude/commands/*.md")):
    text = f.read_text(encoding="utf-8")
    fmt_match = FORMAT_RE.search(text)
    fmt_class = fmt_match.group(1).strip() if fmt_match else None

    # Only warn for persona-card files (role-card and reference-doc are exempt)
    if fmt_class in ("role-card", "reference-doc"):
        continue

    if "extra_fields:" not in text:
        emit_warn(
            f"persona-card {f.name} HANDOFF block missing extra_fields declaration "
            f"(add 'extra_fields: none' if there are none)"
        )

# ── Summary ──────────────────────────────────────────────────────────────────
if fail_count > 0:
    print(f"[FAIL] Semantic lint: {fail_count} failure(s), {warn_count} warning(s)")
    sys.exit(1)
elif warn_count > 0:
    print(f"[OK] Semantic lint: 0 failures, {warn_count} warning(s) (non-blocking)")
else:
    print("[OK] Semantic lint: all checks passed (0 failures, 0 warnings)")
PY
