# Next Action Dispatch

NEXT_PERSONA: Junior Dev (Transplant-workflow)
TASK:         TASK-320 — fix ACCENT_CLASSES type in DashboardPage.tsx (revision 3)
CONTEXT:      Session 21 (ad-hoc maintenance) completed:
                - auto-codex-read.sh deadlock fixed permanently (flag-file pattern)
                - set-codex-read-flag.sh created and wired in all projects
                - Fix propagated to: policybrain, Transplant-workflow, forensic-ai,
                  Pharma-Base, mission-control
                - TASK-320 revision 2 Codex FAIL processed → REVISION_NEEDED

              TASK-320 fix required (one line):
                File: src/client/pages/DashboardPage.tsx
                Change: ACCENT_CLASSES type from Record<string, {iconBg, iconText}>
                        to Record<StatCardProps['accentColor'], {iconBg, iconText}>
                Q2 + Q3 were PASS — no other changes needed.

              After fix: run /codex-prep for revision 3.

COMMAND:      /junior-dev (in Transplant-workflow project)
SESSION_STATUS: CLOSED
NEXT_FOCUS:    Transplant-workflow TASK-320 revision 3
BLOCKERS:      none
