# Next Action Dispatch

NEXT_PERSONA: Junior Dev
TASK:         TASK-023 first (session-close contract fix), then TASK-016, TASK-018, TASK-019 in parallel
CONTEXT:      Session 7 closed as planning session — 8 tasks deferred (TASK-016..023).
              TASK-023 is P0: fixes session-close contract to support PLANNING_SESSION mode.
              After TASK-023 merged, build v3.0 Alpha in dependency order:
                Parallel (no deps): TASK-016, TASK-018, TASK-019
                After TASK-016: TASK-017
                After TASK-016 + 017: TASK-021
                After TASK-019: TASK-020
                After all above merged: TASK-022
              QA AC already written for TASK-016..022. QA must fill AC for TASK-023 before build.
COMMAND:      /qa (for TASK-023 AC) → /junior-dev

SESSION_STATUS: CLOSED
NEXT_FOCUS:    Session 8 — QA fills TASK-023 AC → Junior Dev builds all 8 tasks
BLOCKERS:      none
TASK_QUEUE:    TASK-023, TASK-016, TASK-017, TASK-018, TASK-019, TASK-020, TASK-021, TASK-022
