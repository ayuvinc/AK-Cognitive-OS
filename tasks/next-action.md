# Next Action Dispatch

NEXT_PERSONA: Architect
TASK:         v4 Phase 2 — Feedback Loop decomposition
CONTEXT:      Session 25 complete. v4 Phase 1 (Memory Foundation) merged to main.
              All 6 tasks QA_APPROVED. releases/session-25.md written.

              Phase 2 scope (BACKLOG-001):
                - Feedback schemas: define feedback entry structure (task_id, type,
                  signal, severity, source_persona, session, timestamp)
                - qa-run write: after each QA verdict, write feedback entry via
                  mcp__ak-memory__write(type="outcome", ...)
                - risk-manager write: after risk assessment, write to memory
                - feedback.py validator: validate feedback entries in index.json
                  (auto-discovered by runner.py, same pattern as memory.py)

              Before Phase 2 decomposition:
                - Verify Phase 1 is working in production: open a session and confirm
                  ak-memory MCP server starts, mcp__ak-memory__summary loads on session-open
                - Check memory/index.json has first real entry after a session-close
                - Confirm guard-memory-loaded.sh flag file is written on session-open

COMMAND:      /session-open → /architect for Phase 2 decomposition
SESSION_STATUS: CLOSED
NEXT_FOCUS:   Validate Phase 1 in production, then decompose Phase 2
BLOCKERS:     none — Phase 1 fully merged and validated
