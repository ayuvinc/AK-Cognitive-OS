# Changelog

All notable changes to AK Cognitive OS are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
Versions follow [Semantic Versioning](https://semver.org/).

---

## [3.0.0] — 2026-04-05

### Added
- **Operating tier system** — MVP / Standard / High-Risk. Each tier activates different gate requirements. Set `Tier:` in `CLAUDE.md`.
- **Canonical 11-stage delivery lifecycle** (`framework/governance/delivery-lifecycle.md`) with formal entry/exit conditions per stage.
- **Stage-gate rules** (`framework/governance/stage-gates.md`) — machine-readable gate conditions for every stage transition.
- **Artifact ownership map** (`framework/governance/artifact-ownership.md`) — every planning artifact has an explicit owner and a list of personas that are blocked from writing it.
- **Artifact map** (`framework/governance/artifact-map.md`) — all 16+ framework artifacts with path, owner, and consumer matrix.
- **Role taxonomy** (`framework/governance/role-taxonomy.md`) — all 20 commands classified into five classes: delivery persona, router persona, specialist persona, mechanical skill, advisory/meta skill.
- **Role design rules** (`framework/governance/role-design-rules.md`) — criteria for adding new commands, deprecation rules, maximum command set size.
- **Change policy** (`framework/governance/change-policy.md`) — how the framework evolves: proposal format, review process, delta log pattern.
- **Versioning policy** (`framework/governance/versioning-policy.md`) — what constitutes a major/minor/patch version change.
- **Release policy** (`framework/governance/release-policy.md`) — how framework releases are packaged, tested, and deployed to projects.
- **Default workflows** (`framework/governance/default-workflows.md`) — standard execution paths for greenfield SaaS, AI/RAG, regulated app, internal tool.
- **`guard-planning-artifacts.sh`** — blocks Junior Dev from writing source code when planning docs are absent (Standard + High-Risk tiers).
- **`auto-teach.sh`**, **`auto-codex-prep.sh`**, **`auto-codex-read.sh`** — auto-triggered hooks on task state transitions.
- **`set-teach-me-flag.sh`**, **`set-codex-prep-flag.sh`** — PostToolUse flag setters for auto-hook triggers.
- **`/teach-me`** — auto-triggered plain-language brief when a task goes IN_PROGRESS.
- **`/risk-manager`** — owns `tasks/risk-register.md`; structured S0/S1/S2 risk tracking.
- **`/codex-prep`** — pre-flight gate before sending work to Codex review; token-efficient sprint packaging.
- **`/codex-read`** — routes Codex output: PASS → READY_FOR_QA, FAIL → REVISION_NEEDED.
- **`tasks/design-system.md`** placeholder deployed to all projects by `remediate-project.sh`.
- **`--audit-only`** mode for `remediate-project.sh` — reports gaps without writing.
- **`validators/governance.py`** — 8 checks (doc presence, version stamp, placeholder scan); auto-discovered by `runner.py`; governance FAIL blocks push to main.
- **`session-integrity-check.sh`** extended — checks for unprocessed codex-review.md, open BOUNDARY_FLAGs, and unresolved S0 risks at session close.
- Non-coder mode guide (`guides/13-non-coder-mode.md`) — safe path for non-technical project owners.
- Risk tier selection guide (`guides/14-risk-tier-selection.md`).
- Framework validation extended from 14 → 20 structural checks + semantic lint.

### Changed
- **Command set rationalized to exactly 20** — retired 17 commands: `researcher-business`, `researcher-technical`, `researcher-legal`, `researcher-policy`, `researcher-news`, `review-packet`, `codex-intake-check`, `codex-creator`, `codex-delta-verify`, `framework-delta-log`, `handoff-validator`, `sprint-packager`, `regression-guard`, `compliance-data-privacy`, `compliance-data-security`, `compliance-phi-handler`, `compliance-pii-handler`.
- `/researcher` and `/compliance` are now unified single commands (sub-persona routing is internal, not exposed as separate slash commands).
- All 5 delivery personas (`/architect`, `/ba`, `/junior-dev`, `/qa`, `/ux`) upgraded to v2-FULL contract (manual_action + override fields).
- `schemas/output-envelope.md` extended to 12 fields (`manual_action` + `override`).
- `settings.json` template updated to 14 hook scripts across 6 matchers.
- `bootstrap-project.sh` now tier-aware — asks for MVP/Standard/High-Risk during intake.
- `remediate-project.sh` now deploys: design-system.md, channel.md, framework-improvements.md, all 13 governance docs, all 14 hook scripts.
- `guard-git-push.sh` — added security risk gate (blocks push when open S0 Security risks exist) and governance gate (FAIL blocks push).
- `.ak-cogos-version` bumped to `3.0.0`.

### Fixed
- `validators/governance.py` — path bug `docs/role-taxonomy.md` → `framework/governance/role-taxonomy.md`.
- `remediate-project.sh` Step 6 — now deploys `channel.md` (v3.0 format) and `framework-improvements.md`, previously omitted.

---

## [2.2.0] — 2026-03-15

### Added
- `validate-framework.sh` — structural validation suite (16 checks + semantic lint).
- `.ak-cogos-version` version stamp.
- `guard-git-push.sh` — Codex PASS gate added to push protection.
- All personas and skills upgraded to v2-FULL contract.

### Changed
- `.claude/commands/` trimmed to a defined explicit deploy list.
- `remediate-project.sh` made idempotent with explicit 20-command deploy list.

---

## [2.1.0] — 2026-02-28

### Added
- `session-integrity-check.sh` — warns on unclosed sessions at stop.
- `guard-persona-boundaries.sh` — file-path-based persona boundary enforcement.
- `validate-envelope.sh` — output envelope validation on every agent response.

---

## [2.0.0] — 2026-01-15

### Added
- Initial Claude Code native integration: `settings.json`, hooks, `.claudeignore`, MCP servers.
- `bootstrap-project.sh` and `remediate-project.sh`.
- Multi-persona delivery workflow with session lifecycle.
- Python validator suite (`validators/runner.py`).
