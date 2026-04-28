## SESSION STATE
Status:         OPEN
Active task:    none
Active persona: Architect
Blocking issue: none
Last updated:   2026-04-28T08:02:36Z — state transition by MCP server
---

## Active Tasks

---

### TASK-011 — signal_engine.py + signals/ scaffold
Status:       PENDING
Persona:      Junior Dev
Branch:       feature/TASK-011-signal-engine
Depends:      TASK-007 (memory feedback entries exist)
Files:
  validators/signal_engine.py (new)
  signals/active.json (new scaffold)
  signals/history/.gitkeep (new)
  project-template/signals/active.json (new scaffold)
  project-template/signals/history/.gitkeep (new)
Description:  Create validators/signal_engine.py — implements the v4 Signal Engine with two modes:
              (1) Validate mode: auto-discovered by runner.py, validates signals/active.json schema.
              (2) Generate mode: runs 6 detectors against current inputs, writes to signals/active.json.

              Input sources (Phase 2 implementation used memory/index.json — not feedback/summary.json):
                memory/index.json       — outcome, decision, task_history entries
                tasks/risk-register.md  — unresolved risk tracking
                tasks/lessons.md        — lesson recurrence detection

              6 detectors:
                DEBT_ACCUMULATION  — S1+ risk in risk-register.md OPEN with identified date > 14 days ago
                LESSON_RECURRENCE  — tag appearing 3+ times in tasks/lessons.md
                FAILURE_PATTERN    — same persona with 3+ type="outcome" outcome="FAIL" in memory/index.json
                RISK_HOTSPOT       — 3+ FAIL outcomes/decisions concentrated in same session range in memory
                VELOCITY_DROP      — 2+ consecutive task_history entries with outcome="DEFERRED" in memory
                COVERAGE_GAP       — ≥5 task_history entries in memory but 0 type="outcome" entries

              Also create signals/ scaffold:
                signals/active.json: {"signals": [], "generated_at": null, "schema_version": "4.0"}
                project-template/signals/active.json: same placeholder

Constraints:
  - validate(project_root: Path) → ValidatorResult — auto-discovered by runner.py
  - generate mode invoked as: python3 validators/signal_engine.py --generate [project_root]
  - Exit 0 always in both modes — advisory in v4.0
  - Creates signals/ and signals/history/ if not present
  - All detectors handle sparse data gracefully — no signal emitted if below threshold (normal for young memory)
  - Upsert by signal_type + affected_area — re-running does not duplicate signals
  - Evidence array capped at 10 entries per signal
  - content field from memory entries is NEVER read or echoed in any signal or log output
  - signal schema per entry: signal_id, signal_type, severity, evidence, affected_area,
    recommended_action, persona_to_notify, auto_escalate, status, generated_at
  - VALID_SIGNAL_TYPES = {RISK_HOTSPOT, FAILURE_PATTERN, VELOCITY_DROP, DEBT_ACCUMULATION,
    COVERAGE_GAP, LESSON_RECURRENCE} as module-level constant
  - VALID_SEVERITIES = {HIGH, MEDIUM, LOW} as module-level constant
Security:     Reads local files only; no network; no shell exec from file content;
              content field never accessed; evidence capped; exits 0 always.
Acceptance Criteria:
  #### AC — TASK-011
  - [ ] validators/signal_engine.py exists and exposes validate(project_root: Path) → ValidatorResult
  - [ ] Auto-discovered by runner.py: output includes "[PASS] signal_engine" or "[WARN] signal_engine: ..."
  - [ ] validate mode: signals/active.json missing → PASS immediately (no warn)
  - [ ] validate mode: signals array empty → PASS
  - [ ] validate mode: signal missing required field → WARN mentioning signal_id
  - [ ] validate mode: signal_type not in VALID_SIGNAL_TYPES → WARN mentioning signal_id
  - [ ] validate mode: severity not in VALID_SEVERITIES → WARN mentioning signal_id
  - [ ] validate mode: evidence array empty on active signal → WARN mentioning signal_id
  - [ ] generate mode: python3 validators/signal_engine.py --generate . exits 0
  - [ ] generate mode: creates signals/ and signals/history/ if not present
  - [ ] generate mode: writes valid signals/active.json (valid JSON, signals array, generated_at, schema_version)
  - [ ] generate mode: DEBT_ACCUMULATION fires when S1+ OPEN risk identified > 14 days ago
  - [ ] generate mode: LESSON_RECURRENCE fires when a tag appears 3+ times in lessons.md
  - [ ] generate mode: FAILURE_PATTERN fires when same persona has 3+ FAIL outcome entries in memory
  - [ ] generate mode: RISK_HOTSPOT fires when 3+ FAIL entries concentrated in same session range
  - [ ] generate mode: VELOCITY_DROP fires when 2+ consecutive DEFERRED task_history entries
  - [ ] generate mode: COVERAGE_GAP fires when ≥5 task_history entries but 0 outcome entries
  - [ ] All detectors: sparse data (below threshold) → no signal emitted, no WARN
  - [ ] Upsert: re-running generate does not duplicate existing signals
  - [ ] VALID_SIGNAL_TYPES and VALID_SEVERITIES defined as module-level constants (not inline)
  - [ ] content field from memory entries never read into any variable used in output
  - [ ] signals/active.json scaffold committed: {"signals": [], "generated_at": null, "schema_version": "4.0"}
  - [ ] project-template/signals/active.json scaffold committed with same content
  - [ ] Direct execution: python3 validators/signal_engine.py . exits 0

---

### TASK-012 — auto-signal-check.sh hook + settings wiring
Status:       PENDING
Persona:      Junior Dev
Branch:       feature/TASK-012-signal-check-hook
Depends:      TASK-011
Files:
  scripts/hooks/auto-signal-check.sh (new)
  .claude/settings.json (modified — add UserPromptSubmit hook)
  project-template/.claude/settings.json (modified — add UserPromptSubmit hook)
Description:  Create scripts/hooks/auto-signal-check.sh — advisory UserPromptSubmit hook that runs
              the signal engine in generate mode, reads signals/active.json, and surfaces any HIGH
              severity signals as stdout messages to the active persona. Non-blocking: exit 0 always.
              Wire into both settings files.

              Hook sequence:
                1. Check validators/signal_engine.py exists — if not, exit 0 silently
                2. Check signals/ directory exists — if not, exit 0 silently
                3. Run: python3 validators/signal_engine.py --generate . (regenerate signals)
                   On any error from generate mode: continue (do not abort hook)
                4. Read signals/active.json with python3 (no eval, no shell exec from JSON content)
                5. For each signal with severity="HIGH" and status="ACTIVE": print one warning line
                6. MEDIUM and LOW signals: suppressed entirely
                7. Exit 0

              Output format (stdout, one line per HIGH signal):
                [SIGNAL] RISK_HOTSPOT (HIGH) — <affected_area>: <recommended_action>

Constraints:
  - Exit 0 always — never blocks Claude's response
  - signals/ missing or signals/active.json missing → exit 0 silently (no output)
  - validators/signal_engine.py missing → exit 0 silently
  - Parse signals/active.json with python3 only — no eval, no jq, no dynamic shell exec
  - Only HIGH signals surface — MEDIUM/LOW suppressed
  - Output must contain only: signal_type, affected_area, recommended_action from signal schema
  - Neither signal content fields nor memory entry content fields ever echoed to stdout
  - Wired AFTER auto-persona-detect.sh in UserPromptSubmit in both settings files
  - CRITICAL: hook script must be committed in same task as settings wiring (CI checks existence)
Security:     Reads signals/active.json only; stdout output contains signal schema fields only
              (no raw content, no PII); exit 0 on any error; no network calls.
Acceptance Criteria:
  #### AC — TASK-012
  - [ ] scripts/hooks/auto-signal-check.sh exists and exits 0 in all cases
  - [ ] signals/ directory missing → exit 0 silently (no output, no non-zero exit)
  - [ ] signals/active.json missing → exit 0 silently
  - [ ] validators/signal_engine.py missing → exit 0 silently
  - [ ] signals/active.json with no HIGH signals → exit 0 silently (no output)
  - [ ] signals/active.json with HIGH signal → stdout line mentioning signal_type, affected_area, recommended_action
  - [ ] MEDIUM signal present → suppressed (no stdout output for it)
  - [ ] LOW signal present → suppressed
  - [ ] signals/active.json with malformed JSON → exit 0 silently (no crash, no non-zero exit)
  - [ ] Hook wired in .claude/settings.json UserPromptSubmit after auto-persona-detect.sh
  - [ ] Hook wired in project-template/.claude/settings.json UserPromptSubmit after auto-persona-detect.sh
  - [ ] validate-framework.sh passes: "All hook scripts referenced in settings.json exist"
  - [ ] Output contains only signal_type, affected_area, recommended_action — no content field values

---

<!-- TASK-007 QA_APPROVED — merged to main 2026-04-28 — archived to releases/session-26.md at close -->

---

<!-- TASK-008 QA_APPROVED — merged to main 2026-04-28 — archived to releases/session-26.md at close -->

---

<!-- TASK-009 QA_APPROVED — merged to main 2026-04-28 — archived to releases/session-26.md at close -->

---

<!-- TASK-010 QA_APPROVED — merged to main 2026-04-28 — archived to releases/session-26.md at close -->

---

## Backlog

### BACKLOG-001 — v4 Cognitive Layer (full initiative)
Status:       IN PLANNING — Phase 1 COMPLETE (merged 2026-04-28)
Architecture: docs/v4-architecture.md
Decision:     AK approved 2026-04-28: hand-rolled storage + ak-memory MCP server,
              per-project memory scope, per session-close compaction. Beads/Dolt rejected.
Phase 1:      COMPLETE — TASK-001–006 merged to main (releases/session-25.md)
Phase 2:      COMPLETE — TASK-007–010 merged to main (releases/session-26.md)
Phase 3:      IN PLANNING — TASK-011–012 decomposed (Session 27)
Phase 4:      Framework Integration — decompose after Phase 3 proven
              (bootstrap v4 scaffold, remediate --v4-upgrade, validate-framework.sh v4,
               .ak-cogos-version bump to 4.0.0)
Note:         BA waived — internal framework feature, no domain logic. AK PM approval
              2026-04-28 is sufficient authority for all phases.

---

## Archive

<!-- Completed tasks moved here by Architect at sprint close -->
<!-- Session 25 tasks archived to releases/session-25.md -->
<!-- TASK-001 through TASK-006: v4 Phase 1 Memory Foundation — all QA_APPROVED, merged 2026-04-28 -->
