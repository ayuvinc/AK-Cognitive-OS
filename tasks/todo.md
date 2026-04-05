## SESSION STATE
Status:         OPEN
Active task:    none
Active persona: Architect
Blocking issue: none
Last updated:   2026-04-05T13:15:00Z — Session 13 — Phase 10 merged, TASK-038 written

---

## TASK-038 — Governance validator + hook wiring
- Status: PENDING
- Step: Phase 10.5 (governance enforcement)
- Owner: Junior Dev
- Description: Make Phase 10 governance rules machine-enforceable.
  Three deliverables in one task:
  1. validators/governance.py — 8 checks against Phase 10 docs and command set
  2. scripts/hooks/guard-git-push.sh — add governance validator call as hard gate on main push
  3. scripts/hooks/session-integrity-check.sh — add governance check as Advisory check 4 (warning)
- Deliverables:
    validators/governance.py (new file)
    scripts/hooks/guard-git-push.sh (edit — add governance check before final exit 0)
    scripts/hooks/session-integrity-check.sh (edit — add Advisory check 4)
- Dependencies: TASK-033 (role-taxonomy.md must exist)
- Security model: N/A — validator reads files, no execution, no auth, no PII
- Architecture constraints:
    - governance.py MUST use Python 3.8+ stdlib only (no third-party packages)
    - governance.py MUST expose validate(project_dir: Path) -> ValidatorResult
    - governance.py is auto-discovered by validators/runner.py — no wiring needed
    - guard-git-push.sh addition: run ONLY when pushing to main/master (inside existing main-check block)
    - guard-git-push.sh: governance FAIL blocks push (exit 2), WARN allows push with message
    - session-integrity-check.sh addition: advisory only (no exit 2) — warn, never block
    - governance.py must handle missing files gracefully (WARN not FAIL if governance/ docs absent)
- Acceptance criteria:
  - AC-1: scripts/validate-framework.sh is edited (not a new file); no other files changed
  - AC-2: bash scripts/validate-framework.sh exits 0 on current framework (both new checks pass today)
  - AC-3: New check 1 — grep for ^Tier: in project-template/CLAUDE.md; if absent outputs [FAIL] line and exits non-zero
  - AC-4: New check 2 — grep for guard-planning-artifacts.sh in project-template/.claude/settings.json; if absent outputs [FAIL] line and exits non-zero
  - AC-5: Both new [FAIL] lines are visible in validate-framework.sh output alongside existing [OK] lines (consistent format)
  - AC-6: All pre-existing checks still pass — no regressions (exit 0, same [OK] count as before)

---

## TASK-039 — validate-framework.sh tier consistency check (STEP-43)
- Status: READY_FOR_REVIEW
- Step: STEP-43 (Phase 12)
- Owner: Junior Dev
- Description: Add 2 checks to scripts/validate-framework.sh:
  1. project-template/CLAUDE.md contains a Tier: field
  2. guard-planning-artifacts.sh appears in project-template/.claude/settings.json PreToolUse block
  Both checks emit [FAIL] and exit 1 on failure. Both conditions pass today.
- Deliverable: scripts/validate-framework.sh (edit only)
- Dependencies: STEP-34 (Tier field exists ✅), STEP-31 (hook wired ✅)
- Security model: N/A — bash read-only checks
- Acceptance criteria:
  - AC-1: scripts/validate-framework.sh is edited (not a new file); no other files changed
  - AC-2: bash scripts/validate-framework.sh exits 0 on current framework (both new checks pass today)
  - AC-3: New check 1 — grep for ^Tier: in project-template/CLAUDE.md; if absent outputs [FAIL] line and exits non-zero
  - AC-4: New check 2 — grep for guard-planning-artifacts.sh in project-template/.claude/settings.json; if absent outputs [FAIL] line and exits non-zero
  - AC-5: Both new [FAIL] lines are visible in validate-framework.sh output alongside existing [OK] lines (consistent format)
  - AC-6: All pre-existing checks still pass — no regressions (exit 0, same [OK] count as before)
