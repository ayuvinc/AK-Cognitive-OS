# Release Notes -- AK Cognitive OS

Most recent version at top. Each entry covers what changed, what was added, and what was fixed.
For definitions of any term used here, see glossary.md.

---

## v1.2.0 -- Complete Bootstrap & State Machine Fix

**Date:** 2026-04-03
**Type:** Enhancement + Bugfix

This release fixes the session state machine bug ("locked door"), makes bootstrap fully self-contained
(personas, skills, contracts, templates, schemas all installed into each project), adds an interactive
intake interview, and provides a remediation script for existing projects.

### Fixed

- **Session state machine bug (locked door):** `/session-open` required `Status == OPEN` as a
  precondition, which is always false after `/session-close` sets it to CLOSED. session-open now
  correctly expects CLOSED and transitions to OPEN. session-close now explicitly verifies OPEN
  before closing.
- **Duplicate SESSION STATE:** The project-template CLAUDE.md contained a SESSION STATE block that
  conflicted with the canonical copy in `tasks/todo.md`. CLAUDE.md now points to `tasks/todo.md`
  as the single source of truth.
- **session-open-harness.md:** Updated preconditions and BLOCKED scenario to match the fixed state
  machine (expects CLOSED, not OPEN).

### Added

- **schemas/state-machine.md:** Formal specification of the CLOSED↔OPEN session lifecycle, including
  valid transitions, preconditions, error handling, and validation rules.
- **harnesses/session-lifecycle-harness.md:** End-to-end test harness covering happy path (CLOSED→OPEN→CLOSED),
  invalid transitions (double-open, double-close), missing state block, and full round trip.
- **scripts/remediate-project.sh:** Repair script for existing projects. Adds SESSION STATE block to
  `tasks/todo.md` if missing, installs all persona and skill commands into `.claude/commands/`, creates
  `framework/` directory with contracts/templates/schemas, writes `.ak-cogos-version`. Safe to run
  multiple times. Supports `--dry-run` and `--force` flags.
- **Complete bootstrap:** `scripts/bootstrap-project.sh` now installs the full team — 17 persona commands,
  15 skill commands, review contracts (interop, codex-core, governance), reference templates, and schemas
  — directly into each project's `.claude/commands/` and `framework/` directories.
- **Interactive intake interview:** Bootstrap now asks project name, owner, product description, tech stack,
  risk level, compliance requirements, and AI features. Answers are auto-filled into CLAUDE.md. Skip with
  `--non-interactive`.
- **Version stamp:** Bootstrap and remediation write `.ak-cogos-version` to track which framework version
  was used.
- **validate-framework.sh check 5:** State machine consistency check verifies session-open expects CLOSED
  and session-close expects OPEN.

### Changed

- `scripts/bootstrap-project.sh` — rewritten with intake interview, full command installation, framework
  directory creation, and version stamp. Backwards-compatible: `--non-interactive` preserves old behavior.
- `skills/session-open/claude-command.md` — now expects CLOSED, writes OPEN, validates write.
- `skills/session-close/claude-command.md` — now explicitly checks for OPEN before closing.
- `project-template/CLAUDE.md` — SESSION STATE block replaced with pointer to `tasks/todo.md`.
- `scripts/validate-framework.sh` — added check 5 (state machine consistency).

### Projects Remediated

- Transplant-workflow (Dhara) — 50 files added
- forensic-ai — 57 files added, SESSION STATE normalized from OPEN to CLOSED
- mission-control — 58 files added, SESSION STATE block created
- policybrain — 58 files added, SESSION STATE block created

---

## v1.1.0 -- Ambiguity Reduction Pack

**Date:** 2026-03-21
**Type:** Enhancement

This release addresses the most common sources of confusion and failure in v1.0.0 sprints. After
running the framework across multiple active projects, 16 recurring ambiguity patterns were
identified: unclear placeholder instructions, inconsistent envelope field counts, missing required
files that blocked Codex entry, and template fields that did not match the schema definitions.
The Ambiguity Reduction Pack resolves all 16. No breaking changes are introduced -- existing
projects can adopt individual files from this pack without re-running setup.

### Added

- glossary.md -- 35-term plain-English reference covering every framework concept
- FAQ.md -- 22 common questions with direct answers
- DECISION_MATRIX.md -- 7 decision tables covering frontend, backend, database, vector DB, LLM
  provider, hosted vs local AI, and operating mode selection
- RELEASE_NOTES.md -- this file; version history for the framework itself
- persona-compliance.md -- dedicated Compliance persona for regulated-data sprints (previously
  handled ad hoc by the Developer persona)
- skill-session-close-v2.md -- updated session-close skill with explicit CLOSED status field;
  fixes prior version that could return ambiguous completion state
- skill-codex-intake-check-v2.md -- updated intake check with 10-field envelope validation;
  replaces 8-field version from v1.0.0
- schema-output-envelope-v2.md -- canonical 10-field envelope schema replacing the 8-field schema;
  adds origin and flags fields
- schema-sprint-brief-v2.md -- sprint brief schema now marked required in codex-prompt.md
  generation step; previously optional which caused Codex intake failures
- template-codex-prompt-v2.md -- updated Codex prompt template referencing 10-field envelope and
  v2 sprint brief schema
- template-channel-v2.md -- channel.md template with explicit SESSION STATE block and mode field
- harness-envelope-validation.md -- new harness that tests output envelope compliance for all
  personas against the v2 schema
- harness-intake-check.md -- new harness for /codex-intake-check skill testing all 7 required
  artifact states (present, missing, malformed)
- guides/guide-boundary-flag.md -- step-by-step guide for handling BOUNDARY_FLAG in practice
- guides/guide-mid-sprint-blocker.md -- procedure for pausing and resuming a sprint cleanly
- guides/guide-placeholder-setup.md -- checklist for replacing all forbidden literals in CLAUDE.md
  and codex-prompt.md before first sprint

### Fixed

- template-codex-prompt-v1.md: origin field was missing from the output envelope block; Codex
  sessions were producing 9-field envelopes that failed validation silently
- skill-session-close-v1.md: status field could return "done" (lowercase string) instead of
  CLOSED (uppercase enum); downstream checks were not catching this inconsistency
- skill-schema-validator.md: was validating against the 8-field envelope schema instead of the
  10-field schema introduced in v1.0.0 late-stage review
- CLAUDE.md project template: field count in the envelope section header said 8 fields; corrected
  to 10 to match schema-output-envelope-v2.md
- schema.md reference in /codex-intake-check: schema was listed as optional input; changed to
  required since intake check cannot validate envelope structure without it

---

## v1.0.0 -- Initial Release

**Date:** 2026-03-20
**Type:** Initial release

The first complete release of the AK Cognitive OS framework. Built to support a non-coder Product
Manager running AI-assisted development sprints using Claude and Codex in tandem. The framework
establishes the core concepts of personas, skills, schemas, operating modes, and the output
envelope. It is designed to be stack-agnostic, beginner-readable, and extensible -- each
component can be adopted independently rather than requiring full framework adoption from day one.

### Included

**Personas (7):** Architect, Developer, Researcher, QA, BA (Business Analyst), UX, Compliance

**Skills (15):** /sprint-packager, /codex-intake-check, /session-open, /session-close,
/ba-logic-builder, /ux-spec-builder, /definition-of-done, /audit-log-entry, /finding-raiser,
/schema-validator, /regression-checker, /persona-switcher, /next-action-writer,
/channel-writer, /sprint-closer

**Schemas (5):** output-envelope, sprint-brief, BA-logic, UX-spec, definition-of-done

**Framework core:** CLAUDE.md (project template), operating mode definitions (COMBINED,
SOLO_CLAUDE, SOLO_CODEX), BOUNDARY_FLAG specification, S0/S1/S2 finding severity levels,
forbidden literals policy, placeholder naming convention

**Guides (7):** guide-first-sprint.md, guide-combined-mode.md, guide-solo-claude.md,
guide-solo-codex.md, guide-codex-intake.md, guide-session-lifecycle.md, guide-findings.md

**Project template:** Full directory scaffold with channel.md, audit-log.md, next-action.md,
and CLAUDE.md pre-configured with placeholder values

**QUICKSTART.md:** End-to-end setup guide from cloning the repo to completing the first sprint

**CI:** GitHub Actions workflow validating envelope schema on every pull request

**Repo standards:** CODE_OF_CONDUCT.md, CONTRIBUTING.md, SECURITY.md, LICENSE
