# Next Action Dispatch

NEXT_PERSONA: Junior Dev
TASK:         TASK-015 — validate-framework.sh v4 checks
CONTEXT:      TASK-014 QA_APPROVED and merged to main (2026-04-28).
              TASK-015 is now the active task. AC is in tasks/todo.md.

              Key constraints from Architect:
                - All new v4 checks are advisory WARN only — validate-framework.sh
                  must still exit 0 in all cases (no v4 check causes non-zero exit)
                - Required-file checklist additions: 4 files
                - Step 15b extension: run feedback.py + signal_engine.py in validate mode
                  with "[WARN] (v4-advisory)" prefix on output
                - Step 15c: grep-based bootstrap completeness check
                - Summary section must report v4 check count separately
                - Existing checks (steps 1–15a) must be regression-free

              Branch to create: feature/TASK-015-validate-framework-v4-checks
              Target file: scripts/validate-framework.sh

COMMAND:      /junior-dev
BLOCKERS:     none
