## SESSION STATE
Status:         CLOSED
Active task:    none
Active persona: none
Blocking issue: none
Last updated:   2026-04-05T13:40:00Z — Session 13 close — Phase 10 + STEP-43 delivered (41/76)

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
- Dependencies: TASK-033 (role-taxonomy.md must exist ✅)
- Security model: N/A — validator reads files, no execution, no auth, no PII
- Architecture constraints:
    - governance.py MUST use Python 3.8+ stdlib only (no third-party packages)
    - governance.py MUST expose validate(project_dir: Path) -> ValidatorResult
    - governance.py is auto-discovered by validators/runner.py — no wiring needed
    - guard-git-push.sh addition: run ONLY when pushing to main/master (inside existing main-check block)
    - guard-git-push.sh: governance FAIL blocks push (exit 2), WARN allows push with message
    - session-integrity-check.sh addition: advisory only (no exit 2) — warn, never block
    - governance.py must handle missing files gracefully (WARN not FAIL if governance/ docs absent)
- Acceptance criteria: (QA to fill in Session 14 before build begins)
