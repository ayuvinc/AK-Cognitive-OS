# Release Notes -- AK Cognitive OS

Most recent version at top. Each entry covers what changed, what was added, and what was fixed.
For definitions of any term used here, see glossary.md.

---

## v3.1.0 -- Microservices Architecture Assessment

**Date:** 2026-04-11
**Type:** Minor Enhancement

Adds a validated microservices architecture guide derived from the Transplant-workflow
production HLD (Session 23). The guide provides a decision framework for when to use
microservices vs a modular monolith, validates seven core patterns for cross-project
adoption, and provides domain-specific architecture overlays for three project types.

### Added

- **`guides/15-microservices-assessment.md`** — Microservices architecture assessment guide:
  - Decision framework: service count emerges from domain complexity, not upfront choice
  - Seven validated core patterns (strangler-fig, adapter, partition key, schema isolation,
    CQRS read models, audit-by-consumption, correlation ID propagation)
  - Mandatory pre-production checklist for all project types
  - **Greenfield architecture**: starting point rules, service count guidelines by entity count,
    modular monolith as Phase A framing
  - **Pharma-based architecture**: 21 CFR Part 11 overlay, ALCOA+ data integrity at the
    schema layer, GxP validation documentation mapping, 9-service pharma service map,
    PHI pseudonymisation contract
  - **Forensic AI architecture**: chain-of-custody as a dedicated service, cryptographic
    integrity at ingest, read logging (not just write logging), AI advisory-only constraint
    with human review gate, 9-service forensic service map
  - Cross-type comparison table (partition key, audit scope, soft-delete policy, AI autonomy,
    retention requirements)
  - Anti-patterns list and architecture review checklist before first service extract

### Changed

- `README.md` bumped to v3.1. Guide 15 added to guides directory listing.
- `README.md` "What vX Adds" section updated.

### Source

Validated against: Transplant-workflow HLD (`docs/hld.md`), Pharma-Base README + repo structure,
GoodWork Forensic AI HLD (`forensic-ai/docs/hld.md`). Assessed: AK Cognitive OS Session 23.

---

## v2.0.0 -- Conversation-First, Artifact-Driven Development

**Date:** 2026-04-03
**Type:** Major Enhancement

This release shifts AK-Cognitive-OS from persona-heavy process orchestration to conversation-first,
engineering-artifact-driven development. Every project is now grounded in real user intent, explicit
scope, HLD, LLD, traceable tasks, and honest release framing. A Python validator suite provides
ground-truth verification to prevent LLM hallucination about document status and traceability.

### Core Principle

Planning artifacts are conversation-derived. The AI must ask structured questions, summarize answers,
get user confirmation, then create documents. It must not infer the whole project and start writing
planning docs immediately.

### Added

- **10 planning doc templates** (`project-template/docs/`):
  - `problem-definition.md` — who, what, why
  - `scope-brief.md` — must-have, out-of-scope, delivery target
  - `hld.md` — architecture, data flow, integrations
  - `lld/README.md` + `lld/feature-template.md` — per-feature implementation design
  - `assumptions.md` — confirmed vs ai-inferred vs unresolved
  - `decision-log.md` — decisions with provenance and alternatives
  - `release-truth.md` — honest feature status (real/mocked/partial/deferred)
  - `traceability-matrix.md` — task → scope → HLD → LLD → tests mapping
  - `current-state.md` — mid-build recovery snapshot

- **Metadata headers** on every planning doc:
  ```
  Status: draft | confirmed | superseded
  Source: user-confirmed | ai-inferred | code-observed | mixed
  Last confirmed with user: YYYY-MM-DD
  Owner: Product | Architect | Dev | QA
  Open questions: 0
  ```

- **Guide 11 — Conversation-First Planning** (`guides/11-conversation-first-planning.md`):
  8-question discovery conversation, artifact creation order, metadata rules, persona ownership mapping

- **Guide 12 — Mid-Build Recovery** (`guides/12-mid-build-recovery.md`):
  7-question recovery conversation, 5-stage recovery flow, rules for backfilled documents

- **Python validator suite** (`validators/`) — 4 core validators, Python 3.8+ stdlib only:
  - `planning_docs.py` — verifies docs exist, metadata is honest, no placeholders in confirmed docs
  - `task_traceability.py` — every active task traces to design artifacts
  - `release_truth.py` — "real" claims backed by actual source code
  - `session_state.py` — session consistency between todo.md and channel.md
  - `runner.py` — CLI entry point with `--warn-only`, `--strict`, `--format json|text`, `--only` flags

- **Greenfield workflow**: Discovery → Problem/Scope → HLD → LLD → Tasks → Build → QA → Release

- **Recovery workflow**: Recovery conversation + code inspection → current-state.md → backfill artifacts → task realignment

- **validate-framework.sh checks 6-9**: Planning doc templates present, metadata headers valid, guides exist, validator suite exists

### Changed

- `scripts/bootstrap-project.sh` — v2.0.0: creates `docs/lld/` directory, copies all 10 planning doc
  templates, adds 4 discovery questions to intake interview (primary user, problem, delivery target,
  success metric), auto-fills problem-definition.md and scope-brief.md stubs (Status: draft, Source: mixed),
  prints planning workflow guidance in post-bootstrap output

- `scripts/new-session.sh` — adds `--mode greenfield|recovery` flag. Greenfield mode checks for
  confirmed problem-definition.md and scope-brief.md. Recovery mode checks for current-state.md
  and prints recovery conversation prompt. Runs Python validators in warn-only mode if available.

- `scripts/remediate-project.sh` — v2.0.0: creates `docs/lld/` directory, copies planning doc
  templates (skip existing), detects mid-build state and prints recovery guidance

- `project-template/CLAUDE_START.md` — new "Before Building — Planning First" section, greenfield
  first flow, mid-build recovery flow

- `project-template/CODEX_START.md` — planning doc verification in startup checklist, note that
  Codex must not create planning docs without prior user conversation

- `project-template/CLAUDE.md` — "Planning Artifacts" section with status table, 3 new Plan Mode
  mandatory triggers, traceability in Definition of Done, updated workflow description

- `FRAMEWORK_FLOW.md` — planning stages before AK_REQ node, recovery path as alternative entry,
  pink colour for planning nodes

- `README.md` — v2.0 status, planning artifacts section, updated folder structure with docs/ and
  validators/, updated workflow description

- `QUICKSTART.md` — added Step 7 (discovery conversation), planning docs in key files table

- `guides/00-project-intake.md` — artifact mapping note showing which intake sections feed into
  which planning documents

- `guides/02-session-flow.md` — session modes (greenfield/recovery), validator runs at session boundaries

- `guides/04-first-sprint.md` — planning-before-building section (grounding, not blocking),
  recommended first sprint flow with sessions for discovery → HLD → LLD → build

### Non-Goals

- No LLDs required for trivial one-file changes
- No "first sprint = no code" mandate — planning grounds but doesn't block
- Backfilled docs are drafts, not truth — requires explicit user confirmation
- Validators default to warn-only — never block normal development
- 4 heuristic validators deferred to v2.1 (scope_drift, decision_authority, test_coverage, persona_boundary)

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
