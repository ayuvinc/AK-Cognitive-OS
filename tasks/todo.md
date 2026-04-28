## SESSION STATE
Status:         OPEN
Active task:    none
Active persona: Architect
Blocking issue: none
Last updated:   2026-04-28T06:35:19Z — state transition by MCP server
---

## Active Tasks

---

<!-- TASK-007 QA_APPROVED — merged to main 2026-04-28 — archived to releases/session-26.md at close -->

---

<!-- TASK-008 QA_APPROVED — merged to main 2026-04-28 — archived to releases/session-26.md at close -->

---

<!-- TASK-009 QA_APPROVED — merged to main 2026-04-28 — archived to releases/session-26.md at close -->

---

### TASK-010 — feedback.py Validator
Status:       READY_FOR_REVIEW
Persona:      Junior Dev
Branch:       feature/TASK-010-feedback-validator
Depends:      TASK-007
Files:        validators/feedback.py (new)
Description:  Create validators/feedback.py — validates type-specific required fields for
              feedback entries in memory/index.json. Auto-discovered by runner.py (same
              validate(project_root) → ValidatorResult interface as memory.py). WARN severity
              only in v4.0 (exits 0 via runner). No project-template mirror needed (bootstrap
              does not copy validators/).
Constraints:
  - If index.json missing or has 0 entries: return PASS immediately (no warn)
  - For type="outcome" entries: WARN if task_id empty, outcome missing/not in VALID_OUTCOMES,
    persona empty
  - For type="decision" entries: WARN if task_id empty, persona empty
  - Import VALID_OUTCOMES from a local constant — do not hardcode values inline
  - Never read or log the content field value (structural keys only)
  - Expose validate(project_root: Path) → ValidatorResult; support direct execution via main()
  - Exit 0 in all cases; runner.py maps WARN → exit 0
Security:     Reads index.json; never logs content field; exits 0 — no blocking path.
Acceptance Criteria:
  #### AC — TASK-010
  - [ ] validators/feedback.py exists and exposes validate(project_root: Path) → ValidatorResult
  - [ ] Auto-discovered by validators/runner.py: runner output includes "[PASS] feedback" or
        "[WARN] feedback: ..." (confirm by running python3 validators/runner.py .)
  - [ ] Direct execution supported: python3 validators/feedback.py [project_root] exits 0 and
        prints [PASS] or [WARN] line(s) — never errors or exits non-zero
  - [ ] index.json missing → PASS (no warn emitted)
  - [ ] index.json present, entries=[] → PASS (no warn emitted)
  - [ ] type="outcome" entry with all required fields (task_id, persona, valid outcome) → PASS
  - [ ] type="outcome" entry with empty task_id → WARN mentioning entry_id
  - [ ] type="outcome" entry with outcome value not in VALID_OUTCOMES → WARN mentioning entry_id
  - [ ] type="outcome" entry with empty persona → WARN mentioning entry_id
  - [ ] type="decision" entry with all required fields (task_id, persona) → PASS
  - [ ] type="decision" entry with empty task_id → WARN mentioning entry_id
  - [ ] type="decision" entry with empty persona → WARN mentioning entry_id
  - [ ] Entries of other types (lesson, task_history, audit_event, decision unrelated) → not
        flagged; PASS unless other entries fail
  - [ ] VALID_OUTCOMES defined as a module-level constant (not inline literal set); value matches
        memory_server.py: {"PASS", "FAIL", "PARTIAL", "DEFERRED"}
  - [ ] Code review: content field is never read into a variable that appears in any log/warn
        output (structural keys only accessed)

---

## Backlog

### BACKLOG-001 — v4 Cognitive Layer (full initiative)
Status:       IN PLANNING — Phase 1 COMPLETE (merged 2026-04-28)
Architecture: docs/v4-architecture.md
Decision:     AK approved 2026-04-28: hand-rolled storage + ak-memory MCP server,
              per-project memory scope, per session-close compaction. Beads/Dolt rejected.
Phase 1:      COMPLETE — TASK-001–006 merged to main (releases/session-25.md)
Phase 2:      Feedback Loop — decompose next session
              (feedback schemas, qa-run write, risk-manager write, feedback.py validator)
Phase 3:      Signal Engine — decompose after Phase 2 proven
              (signal_engine.py, 6 detectors, auto-signal-check.sh hook)
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
