## SESSION STATE
Status:         OPEN
Active task:    none
Active persona: Architect
Blocking issue: none
Last updated:   2026-04-28T15:35:12Z — state transition by MCP server
---

## Active Tasks

---

<!-- TASK-013 QA_APPROVED — merged to main 2026-04-28 — archived to releases/session-28.md -->

---

<!-- TASK-014 QA_APPROVED — merged to main 2026-04-28 — archived to releases/session-28.md -->

---

### TASK-015 — validate-framework.sh v4 checks
Status:       QA_APPROVED
Owner:        Junior Dev
Branch:       feature/TASK-015-validate-framework-v4-checks
Session:      28
Priority:     MEDIUM — framework self-certification; needed before version bump

Description:
  Extend scripts/validate-framework.sh to verify the v4 cognitive layer is structurally
  present. Currently only step 15b checks validators/memory.py.

  Changes required in scripts/validate-framework.sh:
  1. Extend the required-file checklist to include:
       "project-template/signals/active.json"
       "validators/feedback.py"
       "validators/signal_engine.py"
       "validators/base.py"
  2. Extend step 15b to also run validators/feedback.py and validators/signal_engine.py
     in validate mode against the framework root (advisory WARN prefix, same pattern as memory).
  3. Add step 15c — v4 bootstrap completeness check:
     grep-based check that bootstrap-project.sh contains "signals/" and "feedback/" scaffold
     steps. WARN if absent.
  4. Update final summary to report v4 check count.

Security model:
  Auth:         Read-only — validates local files only; no network, no user input
  Data bounds:  Framework source files only
  PII/PHI:      None
  Audit:        Output to stdout; CI/operator reads it
  Abuse surface: No external input — all paths derived from SCRIPT_DIR/ROOT

Acceptance Criteria:
  Required-file checklist additions:
  [ ] AC-1:  validate-framework.sh reports [OK] (or [WARN] if missing) for
             "project-template/signals/active.json" in the required-file checklist section
  [ ] AC-2:  validate-framework.sh reports [OK] (or [WARN] if missing) for each of:
             "validators/feedback.py", "validators/signal_engine.py", "validators/base.py"

  Step 15b extension:
  [ ] AC-3:  After TASK-013 merged, step 15b runs validators/feedback.py in validate mode
             against ROOT and surfaces output with "[WARN] (v4-advisory)" prefix
  [ ] AC-4:  After TASK-013 merged, step 15b runs validators/signal_engine.py in validate mode
             against ROOT and surfaces output with "[WARN] (v4-advisory)" prefix
  [ ] AC-5:  If validators/feedback.py or signal_engine.py exit non-zero in validate mode,
             output is shown as WARN — validate-framework.sh still exits 0 (advisory only)

  Step 15c — bootstrap completeness check:
  [ ] AC-6:  Step 15c greps bootstrap-project.sh for the string "signals/" and reports
             [OK] if found, [WARN] if absent
  [ ] AC-7:  Step 15c greps bootstrap-project.sh for the string "feedback/" and reports
             [OK] if found, [WARN] if absent

  Summary and regression:
  [ ] AC-8:  Final summary section of validate-framework.sh reports v4 check count
             (e.g. "v4 checks: 6") separately from total check count
  [ ] AC-9:  All existing validate-framework.sh checks (steps 1–15a) pass with unchanged
             output after TASK-015 changes — no regression in existing check behaviour
  [ ] AC-10: validate-framework.sh exits 0 in all cases — v4 checks are advisory WARN only

Dependencies: Can be written independently; best run after TASK-013 merged so checked files exist

---

### TASK-016 — .ak-cogos-version bump to 4.0.0
Status:       PENDING
Owner:        Junior Dev
Branch:       feature/TASK-016-version-bump-4.0.0
Session:      28
Priority:     LOW — cosmetic gate; must be last

Description:
  Bump the root framework version file once TASK-013, 014, 015 are all QA_APPROVED and merged.

  Changes:
  1. .ak-cogos-version: "3.0.0" → "4.0.0"
  Note: bootstrap-project.sh VERSION is bumped in TASK-013; this task only touches .ak-cogos-version

Security model: N/A — single static text file, no execution path

Acceptance Criteria:
  [ ] AC-1: cat .ak-cogos-version returns exactly "4.0.0" — no trailing spaces, no extra lines
  [ ] AC-2: scripts/validate-framework.sh exits 0 after bump (full PASS — no new WARNs introduced)
  [ ] AC-3: scripts/bootstrap-project.sh VERSION variable also reads "4.0.0"
            (this is set in TASK-013, verified here to confirm consistency between the two sources)

Dependencies: TASK-013, TASK-014, TASK-015 all QA_APPROVED and merged to main

---

<!-- TASK-011 QA_APPROVED — merged to main 2026-04-28 — archived to releases/session-27.md at close -->

---

<!-- TASK-012 QA_APPROVED — merged to main 2026-04-28 — archived to releases/session-27.md at close -->

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
Phase 3:      COMPLETE — TASK-011–012 merged to main (releases/session-27.md)
Phase 4:      IN PROGRESS — TASK-013–016 decomposed (Session 28), PENDING QA criteria
Note:         BA waived — internal framework feature, no domain logic. AK PM approval
              2026-04-28 is sufficient authority for all phases.

---

## Archive

<!-- Completed tasks moved here by Architect at sprint close -->
<!-- Session 25 tasks archived to releases/session-25.md -->
<!-- TASK-001 through TASK-006: v4 Phase 1 Memory Foundation — all QA_APPROVED, merged 2026-04-28 -->
