# Next Action Dispatch

NEXT_PERSONA: junior-dev
TASK:         Build TASK-FIX-001, TASK-FIX-002, TASK-FIX-003, TASK-FIX-004 in parallel; TASK-FIX-005 last
CONTEXT:      All risks reviewed and accepted by AK. Build is unblocked.

              Execution order:
                PARALLEL: TASK-FIX-001, TASK-FIX-002, TASK-FIX-003, TASK-FIX-004
                (no dependencies between them — build all four before starting TASK-FIX-005)
                LAST: TASK-FIX-005 (blocked on 001+002+003 completing)

              Key constraints per task:
                TASK-FIX-001:
                  - guard-session-state.sh: lock file check with 30-min stale expiry
                  - session-open.md: add fallback path (MCP fail -> WARN -> lock -> edit -> unlock)
                  - session-close.md: same fallback at step 10-11
                  - bash trap ERR EXIT in both skills to delete lock file on any exit
                  - Lock file NOT committed (.gitignore tasks/.session-transition-lock)

                TASK-FIX-002:
                  - guard-git-push.sh only — read Active persona from tasks/todo.md SESSION STATE
                  - Use python3 same regex as state_machine_server.py
                  - Active persona = "none" -> BLOCK with "no active session"
                  - No changes to session-open.md or session-close.md

                TASK-FIX-003:
                  - Create project-template/mcp-servers/requirements.txt (mcp>=1.0.0)
                  - bootstrap-project.sh: add pip3 install step (non-fatal) + import verification
                  - WARN block on failure must include exact command: pip3 install mcp>=1.0.0

                TASK-FIX-004:
                  - project-template/tasks/todo.md only — remove backtick fences, no value changes
                  - Do NOT touch forensic-ai or Transplant-workflow

                TASK-FIX-005:
                  - Diff before copy on every file — stop and flag to AK if meaningful divergence
                  - Do NOT touch forensic-ai/tasks/todo.md
                  - Transplant-workflow session contracts: diff first, flag to AK before overwriting
                  - Commit in each project after sync

COMMAND:      /junior-dev
SESSION_STATUS: OPEN
NEXT_FOCUS:    Hook env-var fix — build phase
BLOCKERS:      none (RISK-001 accepted by AK)
