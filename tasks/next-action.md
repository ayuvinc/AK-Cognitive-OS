# Next Action Dispatch

NEXT_PERSONA: QA
TASK:         QA sign-off for TASK-001 through TASK-006 (all READY_FOR_REVIEW)
CONTEXT:      Session 25 closed — all 6 v4 Phase 1 tasks implemented, marked READY_FOR_REVIEW.
              Feature branches:
                - feature/TASK-001-remediate-mcp-fix      (2699e62)
                - feature/TASK-002-ak-memory-mcp-server   (3d3b13d)
                - feature/TASK-003-session-memory-contracts (a8155ef — also covers TASK-004, TASK-005)
                - feature/TASK-006-memory-validator        (ea59c11)

              Codex review: AK has the Codex prompt (provided end of Session 25).
              Run Codex on all 4 branches before QA review.
              Any CRITICAL Codex finding blocks QA_APPROVED.

              NOTE: ak-memory MCP server (TASK-002) is newly wired in .mcp.json.
              On next session-open, memory summary call will attempt for the first time.
              If it fails: fallback path (read memory/MEMORY.md directly) is the expected
              first-run behavior — not a bug.

COMMAND:      /qa to review Codex findings against AC and issue QA_APPROVED or QA_REJECTED
              Then /architect to merge all QA_APPROVED branches to main.
SESSION_STATUS: CLOSED
NEXT_FOCUS:   QA → Architect merge → Phase 2 planning (Feedback Loop)
BLOCKERS:     Codex review must run first. AK holds the prompt.
