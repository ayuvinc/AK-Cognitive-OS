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

### TASK-008 — qa-run Feedback Write
Status:       READY_FOR_REVIEW
Persona:      Junior Dev
Branch:       feature/TASK-008-qa-run-write
Depends:      TASK-007
Files:        skills/qa-run/claude-command.md (modify)
Description:  Add mcp__ak-memory__write call to qa-run contract, executed after each QA verdict
              is determined (QA_APPROVED or QA_REJECTED), before HANDOFF output. Write must
              never block the verdict — failure path emits WARN only. Add memory_written:
              true|false to extra_fields in HANDOFF envelope.
Constraints:
  - type="outcome", outcome per TASK-007 schema (PASS|FAIL), tags=["qa","verdict"]
  - persona="QA", session=<session_id>, task_id=<task under review>
  - content: one-line verdict summary ≤500 chars (e.g. "TASK-042 QA_APPROVED — all 6 ACs pass")
  - On write failure: add entry to warnings[], set memory_written=false, continue
  - If mcp__ak-memory__write tool unavailable: same WARN path, do not block
Security:     content field contains task IDs and verdict codes only — no PII. Write capped
              at 500 chars by memory_server.py.
Acceptance Criteria:
  #### AC — TASK-008
  - [ ] mcp__ak-memory__write step present in skills/qa-run/claude-command.md ON ACTIVATION
        or TASK EXECUTION section, positioned after verdict determination, before HANDOFF output
  - [ ] Write call specifies: type="outcome", tags=["qa","verdict"], persona="QA";
        outcome="PASS" for QA_APPROVED verdict, outcome="FAIL" for QA_REJECTED verdict
  - [ ] Write call includes session=<session_id> and task_id=<task under review>
  - [ ] content described as one-line verdict summary ≤500 chars
  - [ ] On write failure: warnings[] entry added, memory_written=false in extra_fields,
        verdict and HANDOFF proceed normally (no status change to FAIL or BLOCKED)
  - [ ] If mcp__ak-memory__write unavailable: same WARN path — no block on verdict
  - [ ] memory_written: true|false present in extra_fields block of HANDOFF section
  - [ ] Both QA_APPROVED and QA_REJECTED paths have write steps (not just one branch)

---

### TASK-009 — risk-manager Feedback Write
Status:       READY_FOR_REVIEW
Persona:      Junior Dev
Branch:       feature/TASK-009-risk-manager-write
Depends:      TASK-007
Files:        personas/risk-manager/claude-command.md (modify)
Description:  Add mcp__ak-memory__write call to risk-manager persona contract, executed after
              step 7 (S0/S1 surfacing), before HANDOFF. Write must never block the assessment.
Constraints:
  - type="decision", outcome per TASK-007 schema (PASS|PARTIAL|FAIL), tags=["risk","assessment"]
  - persona="risk-manager", session=<session_id>
  - task_id: primary TASK-ID under assessment, or "cross-cutting" if multi-task run
  - content: "N risks reviewed, N new, S0: N open, S1: N open" — ≤500 chars
  - On write failure: add entry to warnings[], continue without blocking
Security:     content contains only counts and IDs — no risk description text or PII.
Acceptance Criteria:
  #### AC — TASK-009
  - [ ] mcp__ak-memory__write step present in personas/risk-manager/claude-command.md ON
        ACTIVATION sequence, positioned after step 7 (S0/S1 surfacing), before HANDOFF
  - [ ] Write call specifies: type="decision", tags=["risk","assessment"], persona="risk-manager"
  - [ ] Outcome mapping documented: no S0/S1 open → PASS, S1 open → PARTIAL, S0 open → FAIL
  - [ ] content pattern specified: "N risks reviewed, N new, S0: N open, S1: N open" (≤500 chars)
  - [ ] task_id: primary TASK-ID for single-task run; "cross-cutting" for multi-task run
  - [ ] On write failure: warnings[] entry added, assessment output proceeds normally (no block)
  - [ ] If mcp__ak-memory__write unavailable: same WARN path — no block on assessment
  - [ ] memory_written: true|false present in extra_fields block of HANDOFF section

---

### TASK-010 — feedback.py Validator
Status:       IN_PROGRESS
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
