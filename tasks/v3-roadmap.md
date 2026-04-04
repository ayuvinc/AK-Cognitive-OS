# AK Cognitive OS v3.0 Roadmap

## Objective

Turn AK Cognitive OS from a strong multi-agent workflow framework into a comprehensive software delivery operating system with:

- explicit role taxonomy
- canonical lifecycle and stage gates
- artifact ownership and dependency mapping
- stronger validation and enforcement
- bootstrap and remediation support for the v3.0 model
- clearer support for non-coder operators with explicit limits
- governance for framework evolution

## Guiding Principles

- Tighten before expanding
- Prefer explicit ownership over overlap
- Make artifacts first-class
- Enforce critical rules mechanically
- Keep the framework honest about what it guarantees

## Workstream 1: Operating Model

Define the canonical lifecycle:

- intake
- discovery
- scope
- architecture
- design
- implementation
- QA
- security/compliance
- release
- lessons
- framework improvement

Deliverables:

- `framework/governance/delivery-lifecycle.md`
- `framework/governance/stage-gates.md`
- `framework/governance/default-workflows.md`

## Workstream 2: Role Taxonomy

Classify all framework components as one of:

- delivery persona
- router persona
- specialist persona
- mechanical skill
- advisory/meta skill

Deliverables:

- `framework/governance/role-taxonomy.md`
- `framework/governance/role-design-rules.md`

## Workstream 3: Persona Rationalization

Tighten the persona surface without adding unnecessary sprawl.

Priority overlap areas:

- `designer` vs `ux`
- `researcher` vs `researcher-*`
- `compliance` vs `compliance-*`
- `qa` vs post-build QA execution responsibilities

Recommended direction:

- keep `ux` on interaction behavior, states, breakpoints, and accessibility expectations
- narrow `designer` to visual/brand direction or split into `designer` and `design-systems`
- keep `researcher` and `compliance` as default routers
- keep sub-personas as direct specialist shortcuts

Deliverables:

- updated persona contracts
- updated README/team descriptions
- updated plugin command surface descriptions if needed

## Workstream 4: Skill Rationalization

Clarify which skills are hard gates vs advisory/meta tools.

Priority overlap areas:

- `qa-run` vs `qa`
- `security-sweep` vs `compliance-data-security`
- `review-packet` vs `sprint-packager`
- `handoff-validator` vs `codex-intake-check`
- `check-channel`, `lessons-extractor`, `framework-delta-log` as advisory/meta skills

Deliverables:

- updated skill contracts
- skill classification table
- usage guidance in docs

## Workstream 5: Artifact System

Define all required artifacts, their owners, and their downstream dependencies.

Core artifacts:

- `docs/problem-definition.md`
- `docs/scope-brief.md`
- `docs/hld.md`
- `docs/lld/*.md`
- `tasks/todo.md`
- `tasks/ba-logic.md`
- `tasks/ux-specs.md`
- `tasks/design-system.md`
- `tasks/risk-register.md`
- `tasks/next-action.md`
- `docs/release-truth.md`
- sprint summary artifacts
- review packet artifacts
- audit log
- lessons
- framework improvements

Deliverables:

- `framework/governance/artifact-map.md`
- `framework/governance/artifact-ownership.md`

## Workstream 6: Enforcement Layer

Move more of the framework from advisory process to enforceable operating system behavior.

Target enforcement:

- block implementation when required planning artifacts are missing
- block release when QA/security/compliance gates are incomplete
- validate handoff prerequisites
- validate unresolved conditions before closeout
- validate artifact presence before role execution where practical

Deliverables:

- updates to `scripts/validate-framework.sh`
- new hook/check scripts if needed
- documented stage-gate enforcement rules

## Workstream 7: Validation and Semantic Linting

Extend validation beyond structural checks.

Add checks for:

- unresolved placeholders
- missing required sections
- invalid handoff targets
- inconsistent artifact references
- docs contradicting shipped behavior
- missing role classification metadata if introduced

Deliverables:

- expanded `scripts/validate-framework.sh`
- optional Python semantic validator

## Workstream 8: Operating Tiers

Support different risk and sophistication levels.

Tiers:

- `MVP`
- `Standard`
- `High-Risk`

Each tier should define:

- required artifacts
- required gates
- required reviews
- allowed shortcuts
- release constraints

Deliverables:

- `framework/governance/operating-tiers.md`
- `guides/14-risk-tier-selection.md`

## Workstream 9: Non-Coder Mode

Make non-coder use explicit rather than accidental.

Define:

- what non-coders can realistically build
- what requires expert review
- the minimum safe workflow for non-coder-led projects
- escalation triggers for technical oversight

Deliverables:

- `guides/13-non-coder-mode.md`
- updates to `README.md` and `QUICKSTART.md`

## Workstream 10: Governance

Define how the framework itself evolves.

Needed policies:

- when to add a new persona
- when to add a new skill
- when to use router vs specialist patterns
- deprecation rules
- versioning policy
- release policy
- how repeated failures become framework changes

Deliverables:

- `framework/governance/change-policy.md`
- `framework/governance/versioning-policy.md`
- `framework/governance/release-policy.md`

## Workstream 11: Reference Implementations

Prove the framework with worked examples.

Recommended examples:

- CRUD SaaS
- AI/RAG app
- internal dashboard
- regulated-lite app

Each example should include:

- planning docs
- tasks
- UX/design artifacts
- release truth
- sprint summary
- review packet
- lessons

Deliverables:

- expanded `examples/`
- example walkthrough docs

## Workstream 12: Documentation Consolidation

Make the framework explain itself clearly.

Deliverables:

- updated `README.md`
- updated `QUICKSTART.md`
- possible `framework/governance/system-overview.md`
- revised workflow visualization and command guidance docs

## Workstream 13: Bootstrap and Remediation

### Goal

Ensure v3.0 is adoptable for both:

- new greenfield projects
- existing in-flight projects

### Greenfield Bootstrap

Bootstrap should install a v3.0-ready project with:

- `.claude/settings.json`
- `.claudeignore`
- `memory/MEMORY.md`
- hook scripts
- planning docs
- risk tier defaults
- audit log
- next-action scaffolding
- references to role taxonomy and lifecycle docs

Bootstrap should also:

- ask intake questions
- set project tier: `MVP`, `Standard`, or `High-Risk`
- identify whether the project is non-coder-friendly or expert-required
- prefill relevant sections in `CLAUDE.md`
- create missing required artifacts based on the chosen tier

### Existing Project Remediation

Remediation should:

1. detect current framework maturity
2. compare the project against v3.0 expectations
3. install missing required files and structures safely
4. report what cannot be auto-fixed

Gap classes:

- auto-fixable
- requires user confirmation
- manual migration required

### Gap Audit

Add a `v3-gap-audit` capability that reports:

- current framework version
- current maturity level
- missing required artifacts
- missing recommended artifacts
- lifecycle and stage-gate gaps
- enforcement gaps
- governance/tier gaps
- whether safe auto-remediation is possible

### Migration Modes

Recommended remediation modes:

- `--audit-only`
- `--safe-remediate`
- `--full-remediate`
- `--tier MVP|Standard|High-Risk`

### Migration Documentation

Deliverables:

- `guides/15-v3-upgrade-greenfield.md`
- `guides/16-v3-upgrade-existing-projects.md`
- `framework/governance/remediation-policy.md`

### Files Likely Affected

- `scripts/bootstrap-project.sh`
- `scripts/remediate-project.sh`
- `scripts/validate-framework.sh`
- `project-template/CLAUDE.md`
- `project-template/tasks/next-action.md`
- `project-template/docs/*`
- `README.md`
- `QUICKSTART.md`

## Release Structure

### v3.0-alpha

- role taxonomy
- lifecycle
- stage gates
- artifact map
- overlap cleanup
- validation hardening

### v3.0-beta

- operating tiers
- non-coder mode
- governance docs
- release policy
- stronger enforcement

### v3.0-rc

- reference implementations
- final docs alignment
- smoke-test workflows

### v3.0

- complete integrated release

## Recommended Merge Order

1. `v3.0-foundation`
2. `v3.0-governance`
3. `v3.0-operator-modes`
4. `v3.0-enforcement`
5. `v3.0-examples`

## Immediate Next Review Step

After Claude finishes the current enhancement pass:

1. re-review repo state against this roadmap
2. identify what is already covered
3. identify remaining gaps
4. convert gaps into a focused implementation plan for Claude
