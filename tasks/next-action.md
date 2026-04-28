# Next Action Dispatch

NEXT_PERSONA: QA
TASK:         Fill AC for TASK-001, TASK-002, TASK-003, TASK-004, TASK-005, TASK-006
CONTEXT:      Session 25 — Architect decomposed v4 Phase 1 (Memory Foundation):
                - TASK-001: remediate-project.sh MCP fix (pre-existing, ships first)
                - TASK-002: ak-memory MCP server + memory/ scaffold
                - TASK-003: session-open/close contract updates (call ak-memory)
                - TASK-004: PostToolUse compaction re-injection hook
                - TASK-005: PreToolUse enforcement hook (memory-loaded gate)
                - TASK-006: memory.py validator + runner.py update

              Architecture decisions (AK approved 2026-04-28):
                - Hand-rolled JSON/Markdown storage — no Dolt/beads
                - Per-project memory scope
                - Per session-close compaction (automatic)
                - ak-memory MCP server: 3 tools (write/query/summary)
                - All new hooks advisory (exit 0) in v4.0

              After QA fills AC:
                - TASK-001 → Junior Dev (ships first, independent of v4)
                - TASK-002 → Junior Dev (v4 start, no dependencies)
                - TASK-003–006 → Junior Dev (in dependency order)

              BA must log BL-002 (v4 business logic) before Phase 2 decomposition.

COMMAND:      /qa to fill acceptance criteria for all 6 tasks
SESSION_STATUS: OPEN
NEXT_FOCUS:   QA → Junior Dev → back to Architect for Phase 2 planning
BLOCKERS:     none
