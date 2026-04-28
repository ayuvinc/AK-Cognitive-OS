# Session 27 — v4 Phase 3: Signal Engine

**Date:** 2026-04-28
**Status:** COMPLETE

---

## Tasks Completed

### TASK-011 — signal_engine.py + signals/ scaffold
- **Branch:** feature/TASK-011-signal-engine (merged to main)
- **Status:** QA_APPROVED → merged
- **Files:**
  - `validators/signal_engine.py` — 6-detector signal engine with validate() + generate() modes
  - `signals/active.json` — scaffold (live: contains SIG-001 LESSON_RECURRENCE LOW)
  - `signals/history/.gitkeep`
  - `project-template/signals/active.json` — scaffold
  - `project-template/signals/history/.gitkeep`
- **Outcome:** Signal engine auto-discovered by runner.py, exits 0 always, detectors handle sparse data gracefully. SIG-001 fires immediately on real project data (HOOK tag 6x in lessons.md).

### TASK-012 — auto-signal-check.sh hook + settings wiring
- **Branch:** feature/TASK-012-signal-check-hook (merged to main)
- **Status:** QA_APPROVED → merged
- **Files:**
  - `scripts/hooks/auto-signal-check.sh` — UserPromptSubmit hook, advisory, exit 0 always
  - `.claude/settings.json` — UserPromptSubmit hook wired (auto-persona-detect.sh → auto-signal-check.sh → guard-boundary-flags.sh)
  - `project-template/.claude/settings.json` — same wiring
- **Outcome:** 13/13 AC pass, 9 failure modes all exit 0. Hook surfaces HIGH signals only; MEDIUM/LOW suppressed. No content field access, no eval, no dynamic shell exec.

---

## Phase 3 Summary

v4 Phase 3 (Signal Engine) is complete. The system can now:
1. Detect 6 pattern types across memory/index.json, risk-register.md, and lessons.md
2. Write structured signals to signals/active.json (upsert by signal_type + affected_area)
3. Surface HIGH severity signals on every user prompt via UserPromptSubmit hook

Phase 4 (Framework Integration) is next: bootstrap v4 scaffold, remediate --v4-upgrade, validate-framework.sh v4, .ak-cogos-version bump to 4.0.0.

---

## Key Design Decisions

- Signal detectors read memory/index.json (Phase 2 actual output), not feedback/summary.json (architecture doc divergence — Phase 2 stored to index.json, not a separate feedback/ dir)
- Hook safety contract: no set -e, no set -u, every command uses `|| true`, wrapped in function called with `|| true`, single `exit 0` at end — mathematically cannot exit non-zero
- Evidence array capped at 10 entries; content field never accessed; field values truncated before print
