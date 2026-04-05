# Next Action Dispatch

NEXT_PERSONA: qa
TASK:         Write acceptance criteria for TASK-038 (governance validator + hook wiring)
CONTEXT:      Session 13 complete. 41/76 plan steps done.
              Delivered this session:
                TASK-032 gate cleared (STEP-35)
                TASK-033..037: Phase 10 governance policies (39/39 AC)
                TASK-039: validate-framework.sh tier checks STEP-43 (6/6 AC)
                Archived to: releases/session-13.md

              TASK-038 held (PENDING, no AC yet):
                validators/governance.py — 8 governance checks (plugin auto-discovered)
                guard-git-push.sh — governance FAIL = hard block on main push
                session-integrity-check.sh — governance WARN at session close

              Key constraints QA must enforce for TASK-038:
                - governance.py: Python 3.8+ stdlib only
                - governance.py: validate(project_dir) -> ValidatorResult interface
                - guard-git-push.sh: only fires inside existing main-push block
                - session-integrity-check.sh: advisory only, no exit 2

COMMAND:      /qa
SESSION_STATUS: CLOSED
NEXT_FOCUS:    Session 14 — TASK-038 QA AC → Junior Dev → qa-run → merge → continue Phase 12
BLOCKERS:      none
PLAN_FILE:     tasks/framework-upgrade-plan.md
