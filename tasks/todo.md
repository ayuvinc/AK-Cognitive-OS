## SESSION STATE
Status:         OPEN
Active task:    none
Active persona: Architect
Blocking issue: none
Last updated:   2026-04-28T15:35:12Z — state transition by MCP server
---

## Active Tasks

---

### TASK-013 — bootstrap-project.sh v4 scaffold additions
Status:       READY_FOR_REVIEW
Owner:        Junior Dev
Branch:       feature/TASK-013-bootstrap-v4-scaffold
Session:      28
Priority:     HIGH — Phase 4 gate; downstream projects cannot be upgraded until bootstrap is v4-complete

Description:
  Extend bootstrap-project.sh so every newly bootstrapped project gets the full v4 cognitive
  layer scaffold out of the box. Currently bootstrap creates memory/MEMORY.md and copies hooks
  (including auto-signal-check.sh) but does NOT create signals/, feedback/, or copy the Python
  validators. ak-memory is also missing from the generated .mcp.json.

  Changes required in scripts/bootstrap-project.sh:
  1. Copy project-template/signals/ → target/signals/ (active.json + history/)
  2. Create target/feedback/ scaffold: summary.json ({"feedback": [], "total_entries": 0}),
     subdirs qa/ risk/ velocity/ codex/
  3. Copy validators/memory.py, validators/feedback.py, validators/signal_engine.py, validators/base.py
     → target/validators/ (create dir if absent)
  4. Add ak-memory entry to the generated .mcp.json block (alongside ak-state-machine, ak-audit-log)
  5. Add mcp__ak-memory__write/query/summary to the permissions block in settings.json template
     (if not already present — check project-template/.claude/settings.json)
  6. Add memory/index.json scaffold + sessions/ decisions/ outcomes/ dirs to project-template/memory/
     and copy them to target
  7. Bump VERSION variable from "3.1.0" → "4.0.0"

  Also add to post-bootstrap validation checklist:
  - signals/active.json present
  - feedback/ dir with summary.json present
  - validators/signal_engine.py present

Security model:
  Auth:         Local filesystem only — script accepts one path arg; validate it is non-empty
                and not a root/system path before any mkdir/copy
  Data bounds:  No user data read or written — scaffold files are static JSON/Markdown placeholders
  PII/PHI:      None
  Audit:        Committed to git with standard commit message; bootstrap output logged to stdout
  Abuse surface: Target path arg — must be validated (non-empty, exists or can be created, not /)

Acceptance Criteria:
  Happy path — scaffold creation:
  [ ] AC-1:  Running bootstrap on a fresh target dir creates target/signals/active.json with
             content {"signals": [], "generated_at": null, "schema_version": "4.0"}
  [ ] AC-2:  Running bootstrap creates target/signals/history/ directory
  [ ] AC-3:  Running bootstrap creates target/feedback/summary.json with
             content {"feedback": [], "total_entries": 0}
  [ ] AC-4:  Running bootstrap creates target/feedback/ subdirs: qa/ risk/ velocity/ codex/
  [ ] AC-5:  Running bootstrap copies all four validators to target/validators/:
             memory.py, feedback.py, signal_engine.py, base.py
  [ ] AC-6:  Generated target/.mcp.json includes ak-memory entry with:
             - absolute path to memory_server.py (not relative)
             - PROJECT_ROOT env var set to absolute target path
  [ ] AC-7:  Generated target/.mcp.json still contains ak-state-machine and ak-audit-log entries
             (no regression on existing .mcp.json generation)
  [ ] AC-8:  scripts/bootstrap-project.sh VERSION variable reads "4.0.0"
  [ ] AC-9:  Running bootstrap creates target/memory/index.json with
             content {"entries": [], "session_count": 0, "last_updated": null}
  [ ] AC-10: Running bootstrap creates target/memory/sessions/, target/memory/decisions/,
             target/memory/outcomes/ directories

  Post-bootstrap validation:
  [ ] AC-11: Bootstrap post-validation block reports [PASS] or [WARN] (not silent) for
             signals/active.json, feedback/summary.json, validators/signal_engine.py

  Edge cases:
  [ ] AC-12: Running with --non-interactive: all v4 scaffold steps still execute
             (v4 creation must not be gated on INTERACTIVE == true)
  [ ] AC-13: Running with --force on a target that already has signals/active.json:
             file is overwritten (--force semantics honoured)
  [ ] AC-14: Running without --force on a target with existing signals/active.json:
             [skip] printed, file not overwritten

  Security:
  [ ] AC-15: Generated feedback/summary.json and signals/active.json contain no PII,
             no project-specific data — static placeholder content only
  [ ] AC-16: ak-memory .mcp.json entry uses absolute paths for command and args
             (same pattern as ak-state-machine — no relative path)

Dependencies: none — can start immediately

---

### TASK-014 — remediate-project.sh --v4-upgrade flag
Status:       PENDING
Owner:        Junior Dev
Branch:       feature/TASK-014-remediate-v4-upgrade
Session:      28
Priority:     HIGH — the only upgrade path for the 5+ existing downstream projects

Description:
  Add --v4-upgrade mode to scripts/remediate-project.sh. This flag upgrades an existing v3
  project to v4 without overwriting any existing files (safe_copy semantics throughout).

  Changes required in scripts/remediate-project.sh:
  1. Parse --v4-upgrade flag alongside existing flags
  2. Add v4_upgrade() function that:
     a. Creates signals/ scaffold: active.json + history/ (skip if already exists)
     b. Creates feedback/ scaffold: summary.json + qa/ risk/ velocity/ codex/ (skip if exists)
     c. Creates memory/index.json + sessions/ decisions/ outcomes/ (skip if exists)
     d. Copies validators/memory.py, feedback.py, signal_engine.py, base.py → target/validators/
        using safe_copy (no overwrite)
     e. Adds ak-memory entry to target/.mcp.json if not already present (JSON merge, not overwrite)
     f. Adds mcp__ak-memory__ permissions to target/.claude/settings.json if not present
  3. After v4 upgrade: verify python3 -c "import mcp" importable — WARN if not
  4. Print summary: which dirs created, which files skipped, WARN if mcp not importable

  Usage: bash scripts/remediate-project.sh /path/to/project --v4-upgrade
  Idempotent: running twice on same project is safe.

Security model:
  Auth:         Local filesystem only — same path validation as TASK-013
  Data bounds:  Reads .mcp.json and settings.json to check existing entries; writes only
                new keys — never mutates existing values
  PII/PHI:      None
  Audit:        All changes printed to stdout; operator commits manually
  Abuse surface: JSON merge into .mcp.json — use json.load() + dict merge only; never eval or
                 shell substitution of file content; path arg validated before use

Acceptance Criteria:
  Happy path — v4 upgrade on existing v3 project:
  [ ] AC-1:  Running with --v4-upgrade creates target/signals/active.json
             with content {"signals": [], "generated_at": null, "schema_version": "4.0"}
  [ ] AC-2:  Running with --v4-upgrade creates target/feedback/summary.json
             with content {"feedback": [], "total_entries": 0} and subdirs qa/ risk/ velocity/ codex/
  [ ] AC-3:  Running with --v4-upgrade creates target/memory/index.json
             with content {"entries": [], "session_count": 0, "last_updated": null}
             plus sessions/ decisions/ outcomes/ subdirs
  [ ] AC-4:  Running with --v4-upgrade copies validators/memory.py, feedback.py,
             signal_engine.py, base.py to target/validators/ (safe_copy — no overwrite)
  [ ] AC-5:  Running with --v4-upgrade adds ak-memory entry to target/.mcp.json without
             removing or modifying the existing ak-state-machine and ak-audit-log entries
  [ ] AC-6:  Running with --v4-upgrade adds mcp__ak-memory__write, mcp__ak-memory__query,
             mcp__ak-memory__summary to target/.claude/settings.json permissions without
             removing any existing permissions
  [ ] AC-7:  Script prints a summary listing: each dir created, each file [skip]ped,
             and a WARN if mcp not importable

  Idempotency — run twice on same project:
  [ ] AC-8:  Running --v4-upgrade twice produces no duplicate entries in .mcp.json
             (ak-memory appears exactly once)
  [ ] AC-9:  Running --v4-upgrade twice produces no duplicate permission entries in settings.json
  [ ] AC-10: Running --v4-upgrade twice: signals/active.json is [skip]ped (not overwritten),
             existing content preserved

  Error states:
  [ ] AC-11: .mcp.json is malformed JSON → script prints ERROR for that step, skips .mcp.json
             update, continues with remaining steps, exits 0 (not crashing)
  [ ] AC-12: settings.json is malformed JSON → same: ERROR printed, step skipped, exits 0
  [ ] AC-13: mcp not importable after upgrade → WARN with exact remediation command
             (pip3 install mcp>=1.0.0); script still exits 0

  Security:
  [ ] AC-14: .mcp.json merge is implemented with json.load() + Python dict merge — confirmed
             by code review: no string concatenation, no eval, no shell substitution of
             file content into commands
  [ ] AC-15: target path arg validated non-empty before any write operations; if empty or
             non-existent and not creatable: ERROR + exit non-zero, no partial writes

Dependencies: TASK-013 should be complete first (confirms source files are correct), but can
              be built in parallel if needed

---

### TASK-015 — validate-framework.sh v4 checks
Status:       PENDING
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
