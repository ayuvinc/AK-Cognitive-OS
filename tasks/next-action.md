# Next Action Dispatch

NEXT_PERSONA: architect
TASK:         Begin transplant-workflow sprint — open session in Transplant-workflow project
CONTEXT:      Session 19 hook/MCP fix sprint complete. All downstream projects have working hooks
              and MCP servers. Transplant-workflow is ready to receive a session.

              Before opening Transplant-workflow session:
                1. Review Transplant-workflow/tasks/next-action.md for expected persona + task
                2. Confirm Transplant-workflow session-open.md / session-close.md contract — these
                   diverge from AK-Cognitive-OS source (S-012 customizations). Do NOT overwrite
                   without AK approval (see RISK-004 in tasks/risk-register.md).
                3. Open session in Transplant-workflow using /session-open

              Open items to carry forward:
                - forensic-ai SESSION STATE still has code fences (session 010 OPEN — defer to close)
                - Transplant-workflow session contracts need AK review before any overwrite (RISK-004)
                - RISK-003 and RISK-004 still OPEN in tasks/risk-register.md

COMMAND:      /session-open (in Transplant-workflow project)
SESSION_STATUS: OPEN (AK-Cognitive-OS session 19 — close when transplant-workflow work begins)
NEXT_FOCUS:    Transplant-workflow sprint delivery
BLOCKERS:      none
