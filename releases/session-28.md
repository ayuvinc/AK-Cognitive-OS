# Session 28 Release Archive

Session: 28
Date: 2026-04-28
Architect: AK Cognitive OS

---

## TASK-013 — bootstrap-project.sh v4 scaffold additions
Status:    QA_APPROVED → merged to main
Branch:    feature/TASK-013-bootstrap-v4-scaffold
Commits:   39751e3 (impl), 8525887 (AC-11 fix)
Merge:     main (--no-ff)

Summary:
  Extended bootstrap-project.sh so every newly bootstrapped project gets
  the full v4 cognitive layer scaffold: signals/, feedback/, validators/,
  ak-memory in .mcp.json, memory v4 subdirs (index.json + sessions/
  decisions/ outcomes/), and VERSION bumped to 4.0.0.

Files changed:
  - scripts/bootstrap-project.sh (VERSION bump, v4 scaffold steps, validation)
  - project-template/.claude/settings.json (ak-memory permissions + mcpServers)
  - project-template/memory/index.json (new scaffold)
  - project-template/memory/sessions|decisions|outcomes/.gitkeep (new dirs)

AC result: 17/17 PASS (1 QA_REJECTED cycle on AC-11 — fixed same session)
QA_REJECTED reason: post-bootstrap validation block was not naming v4 files
Fix: added explicit echo in validation block

---

## TASK-014 — remediate-project.sh --v4-upgrade flag
Status:    QA_APPROVED → merged to main
Branch:    feature/TASK-014-remediate-v4-upgrade
Commits:   6c717cf (impl + Step 8b hardening), 1f2c2f7 (qa-run), 1403f40 (QA verdict)
Merge:     main (--no-ff)

Summary:
  Added --v4-upgrade flag to scripts/remediate-project.sh. Upgrades any existing
  v3 project to the v4 cognitive layer without overwriting existing files
  (safe_copy semantics throughout). Applied to all 6 downstream projects.

  Steps installed by --v4-upgrade:
    v4-1: signals/ scaffold (active.json + history/)
    v4-2: feedback/ scaffold (summary.json + qa/ risk/ velocity/ codex/)
    v4-3: memory/ v4 additions (index.json + sessions/ decisions/ outcomes/)
    v4-4: validators/ copy (memory.py, feedback.py, signal_engine.py, base.py)
    v4-5: ak-memory JSON merge into .mcp.json
    v4-6: ak-memory permissions JSON merge into .claude/settings.json
    v4-7: mcp importability check (WARN only, never blocks)

  Side-effect fix: Step 8b hardened — malformed settings.json no longer
  causes set -e crash in base remediation.

  Downstream projects upgraded (6/6):
    mission-control, policybrain, Transplant-workflow, forensic-ai,
    Pharma-Base, Project-Dig

Files changed:
  - scripts/remediate-project.sh (v4_upgrade() function + call site + Step 8b fix)

AC result: 15/15 PASS (first pass, no QA_REJECTED cycles)

---

## TASK-015 — validate-framework.sh v4 checks
Status:    QA_APPROVED → merged to main
Branch:    feature/TASK-015-validate-framework-v4-checks
Commits:   b06d55e (impl), e14ee69 (qa-run), 5c05165 (QA verdict)
Merge:     main (--no-ff)

Summary:
  Extended validate-framework.sh step 15b with advisory v4 cognitive layer
  checks and added step 15c (bootstrap completeness grep). All new checks
  are WARN-only; script always exits 0.

  Changes:
    - v4 required-file checklist (4 files): project-template/signals/active.json,
      validators/feedback.py, signal_engine.py, base.py
    - Step 15b extended: runs memory.py, feedback.py, signal_engine.py in validate
      mode; output prefixed with [WARN] (v4-advisory); guarded by `|| true`
    - Step 15c: greps bootstrap-project.sh for 'signals/' and 'feedback/' keywords
    - Final summary: "v4 checks: 9" appended to PASS line

Files changed:
  - scripts/validate-framework.sh

AC result: 10/10 PASS (first pass, no QA_REJECTED cycles)

---

## TASK-016 — .ak-cogos-version bump to 4.0.0
Status:    QA_APPROVED → merged to main
Branch:    feature/TASK-016-version-bump-4.0.0
Commits:   2e22ef5 (impl + QA inline)
Merge:     main (--no-ff)

Summary:
  Bumped .ak-cogos-version from 3.0.0 → 4.0.0.
  validate-framework.sh exits 0 after bump.
  bootstrap-project.sh VERSION="4.0.0" consistent.

AC result: 3/3 PASS (inline QA, no separate QA_REJECTED cycle)

---

## Phase 4 Complete — v4.0.0

All four tasks merged to main:
  TASK-013: bootstrap-project.sh v4 scaffold
  TASK-014: remediate-project.sh --v4-upgrade (applied to 6 downstream projects)
  TASK-015: validate-framework.sh v4 checks
  TASK-016: .ak-cogos-version → 4.0.0

AK Cognitive OS is now at v4.0.0.
