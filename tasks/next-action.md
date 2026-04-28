# Next Action Dispatch

NEXT_PERSONA: Junior Dev
TASK:         TASK-011 — signal_engine.py + signals/ scaffold
CONTEXT:      Session 27 — Architect has decomposed v4 Phase 3 (Signal Engine) into 2 tasks.
              Both tasks have full acceptance criteria. AK approval required before build starts.

              Tasks in scope:
                TASK-011 — signal_engine.py (validators/signal_engine.py + signals/ scaffold)
                TASK-012 — auto-signal-check.sh hook + settings wiring (depends on TASK-011)

              Key design decisions (do not re-open):
                - Signal engine reads memory/index.json (not feedback/summary.json — Phase 2 used memory layer)
                - 6 detectors: DEBT_ACCUMULATION, LESSON_RECURRENCE, FAILURE_PATTERN,
                  RISK_HOTSPOT, VELOCITY_DROP, COVERAGE_GAP
                - Sparse data = no signal emitted (not a WARN — normal for young memory store)
                - All signals advisory (exit 0) in v4.0
                - auto-signal-check.sh runs generate mode then surfaces HIGH signals only
                - CRITICAL: TASK-012 must commit hook script and settings wiring in same commit

              Build order: TASK-011 first (no deps), then TASK-012 (depends on TASK-011).

COMMAND:      /junior-dev TASK-011
SESSION_STATUS: OPEN
NEXT_FOCUS:   Junior Dev builds TASK-011 → TASK-012 → session-close
BLOCKERS:     none — AK approval required before Junior Dev starts
