## SESSION STATE
Status:         OPEN
Active task:    v3.0 Phase 6 — Operating Model documents (STEP-22, 23, 24)
Active persona: Architect
Blocking issue: none
Last updated:   2026-04-05T00:00:00Z — Session 9 open

---

<!--
TASK FORMAT — copy this block for each new task:

<!-- TASK-001 -->
## [TASK-001] Short task title
- Status: PENDING
- Branch: feature/TASK-001-short-description
- BA sign-off: [session N, §BL-XXX — or "N/A"]
- UX sign-off: [session N, §UX-XXX — or "N/A"]
- Spec: [what to build]
- Architect Notes: [decisions, constraints, files to touch]
- Acceptance Criteria: (QA fills before Junior Dev starts)
- QA Notes: (QA fills if rejected)
<!-- /TASK-001 -->

STATUS LIFECYCLE:
PENDING → IN_PROGRESS → READY_FOR_QA → QA_APPROVED → [archived + deleted]
                                      ↘ QA_REJECTED → IN_PROGRESS → READY_FOR_QA

RULES:
- Junior Dev sets IN_PROGRESS before any code
- Junior Dev sets READY_FOR_QA when done
- QA picks up READY_FOR_QA only
- Architect archives before deleting
- Hard limit: 100 active lines
-->

## Checkpoint
Timestamp: 2026-04-05T12:00:00Z

### Done this session (13/49 steps of framework-upgrade-plan.md)
- STEP-14: output-envelope.md → 12-field schema (+manual_action, +override)
- STEP-01..04: /teach-me, /risk-manager, /codex-prep, /codex-read written (v2-FULL)
- STEP-05..08: 3 new hooks written + guard-git-push.sh updated with Codex PASS gate
- STEP-09..13: architect, ba, junior-dev, qa, ux upgraded to v2-FULL

### Next immediate action (before continuing plan steps)
Upgrade auto-teach/auto-codex-prep/auto-codex-read from PostToolUse (advisory) to
UserPromptSubmit (blocking) — AK requires enforcement, not just hints.

### Remaining: STEP-15 to STEP-49 (36 steps)
Phase 4 (infra) → Phase 5 (validation) → Phases 6-10 (project remediation) →
Phase 11 (global cleanup) → Phase 12 (verification)

---

<!-- TASK-018 -->
## [TASK-018] Write framework/governance/role-design-rules.md
- Status: PENDING
- Branch: feature/TASK-018-role-design-rules
- BA sign-off: N/A
- UX sign-off: N/A
- Spec: Create `framework/governance/role-design-rules.md` defining the policy for adding, modifying, and deprecating personas and skills. Must cover: threshold for adding a new persona (new stage in delivery lifecycle, not new domain task), threshold for adding a new skill (repeatable gate or workflow action used by 2+ personas), when to use router vs specialist pattern, deprecation criteria and sunset process, required file set for new personas (claude-command.md, codex-prompt.md, schema.md, SKILL.md), required file set for new skills (claude-command.md, SKILL.md).
- Architect Notes: Derive rules from existing taxonomy in `docs/role-taxonomy.md`. The goal is to prevent sprawl — the framework currently has 33 commands and must not grow unbounded. Rules should be restrictive by default. Cross-reference `docs/gating-cluster-boundaries.md` for skill boundary examples.
- Acceptance Criteria:
  - [ ] AC-1: File exists at `framework/governance/role-design-rules.md`
  - [ ] AC-2: All 6 required sections present: threshold for new persona, threshold for new skill, router vs specialist decision rule, deprecation criteria, required file set for personas, required file set for skills
  - [ ] AC-3: New persona threshold rule is restrictive and testable — must reference "new delivery lifecycle stage" as the primary criterion, not domain novelty
  - [ ] AC-4: New skill threshold rule requires use by 2+ personas as a necessary condition — stated explicitly
  - [ ] AC-5: Deprecation section specifies at minimum: sunset trigger condition, notice period or transition mechanism, who approves removal
  - [ ] AC-6: Required file sets match the Architecture Rules in `CLAUDE.md` exactly — no invented files, no missing required files
  - [ ] AC-7: File does not contradict `docs/role-taxonomy.md` — role classes and routing logic must be consistent
  - [ ] AC-8: File passes `validate-framework.sh` without adding new FAIL lines
- QA Notes:
<!-- /TASK-018 -->

<!-- TASK-019 -->
## [TASK-019] Write framework/governance/artifact-map.md and artifact-ownership.md
- Status: PENDING
- Branch: feature/TASK-019-artifact-map
- BA sign-off: N/A
- UX sign-off: N/A
- Spec: Create two files. (1) `framework/governance/artifact-map.md` — canonical inventory of all required project artifacts: name, path, format, lifecycle stage it belongs to, whether required or recommended, and which tier (MVP/Standard/High-Risk) requires it. (2) `framework/governance/artifact-ownership.md` — ownership matrix: artifact name, owner persona (who creates), reader personas (who reads), writer personas (who may update), gate persona (who signs off), downstream artifacts that depend on it.
- Architect Notes: Source artifact list from the v3-roadmap.md Workstream 5 list plus project-template contents. Tier column can use placeholder values (MVP/Standard/High-Risk TBD) since TASK-016/017 must settle tier definitions first — mark as [TIER-TBD] if needed. This doc becomes the source of truth for `--audit-only` gap detection in TASK-020.
- Acceptance Criteria:
  - [ ] AC-1: Both files exist: `framework/governance/artifact-map.md` and `framework/governance/artifact-ownership.md`
  - [ ] AC-2: `artifact-map.md` contains every artifact named in the v3-roadmap.md Workstream 5 list — no omissions
  - [ ] AC-3: Every row in `artifact-map.md` has all 6 columns populated: name, path, format, lifecycle stage, required/recommended, tier — [TIER-TBD] is acceptable for tier column
  - [ ] AC-4: All artifact paths in `artifact-map.md` match actual paths used in `project-template/` — no invented paths
  - [ ] AC-5: `artifact-ownership.md` contains an entry for every artifact listed in `artifact-map.md` — count must match
  - [ ] AC-6: Every row in `artifact-ownership.md` has all 5 columns populated: artifact name, owner persona, reader personas, writer personas, gate persona — "none" is acceptable where applicable
  - [ ] AC-7: All persona names in `artifact-ownership.md` match existing commands in `.claude/commands/` — no invented personas
  - [ ] AC-8: Both files pass `validate-framework.sh` without adding new FAIL lines
- QA Notes:
<!-- /TASK-019 -->

<!-- TASK-020 -->
## [TASK-020] Add --audit-only flag to remediate-project.sh
- Status: PENDING
- Branch: feature/TASK-020-audit-only-flag
- BA sign-off: N/A
- UX sign-off: N/A
- Spec: Add `--audit-only` mode to `scripts/remediate-project.sh`. When passed, the script must: (1) scan the target project and report current framework version and maturity level, (2) list all missing required artifacts (sourced from artifact-map.md list, hard-coded for now), (3) list missing recommended artifacts, (4) report hook/settings.json gaps, (5) report MCP server presence, (6) report mid-build state, (7) exit 0 with a structured gap report — NO file writes. Output must be human-readable and machine-parseable (pipe-separated or JSON-compatible summary line at end).
- Architect Notes: Depends on TASK-019 for the artifact list, but can hard-code initial artifact list from project-template contents and be updated once artifact-map.md is written. `--audit-only` must be mutually exclusive with `--force`. Existing `--dry-run` shows what would change; `--audit-only` shows what is missing entirely — different concern. Safe to run on any project at any time.
- Acceptance Criteria:
  - [ ] AC-1: `bash scripts/remediate-project.sh <path> --audit-only` runs without error and exits 0
  - [ ] AC-2: `--audit-only` produces no file writes — verified by running on a clean project and confirming no `[create]` or `[overwrite]` lines in output and no file modification timestamps changed
  - [ ] AC-3: Output contains all 6 required report sections: framework version, maturity level, missing required artifacts, missing recommended artifacts, hook/settings gaps, MCP server presence
  - [ ] AC-4: `--audit-only` and `--force` together are rejected — script must print an error and exit non-zero
  - [ ] AC-5: `--audit-only` and `--dry-run` together are rejected — mutually exclusive, error and exit non-zero
  - [ ] AC-6: Running on a freshly bootstrapped project reports 0 missing required artifacts
  - [ ] AC-7: Running on a project missing `tasks/ba-logic.md` reports that artifact as missing required
  - [ ] AC-8: Output ends with a machine-parseable summary line (pipe-separated or JSON) containing at minimum: version, required_missing count, recommended_missing count
- QA Notes:
<!-- /TASK-020 -->

<!-- TASK-021 -->
## [TASK-021] Write guides/15-v3-upgrade-greenfield.md and guides/16-v3-upgrade-existing-projects.md
- Status: PENDING
- Branch: feature/TASK-021-v3-upgrade-guides
- BA sign-off: N/A
- UX sign-off: N/A
- Spec: Create two migration guides. (1) `guides/15-v3-upgrade-greenfield.md` — step-by-step guide for starting a new project on v3.0: run bootstrap, select tier, confirm planning artifacts, open first session. (2) `guides/16-v3-upgrade-existing-projects.md` — step-by-step guide for migrating an in-flight v2.x project: run `--audit-only`, review gap report, run `--safe-remediate` (or `remediate-project.sh` until that flag exists), manually fill missing planning artifacts, verify hooks and MCP servers active. Both guides must reference the canonical lifecycle (TASK-016) and stage gates (TASK-017).
- Architect Notes: Write guide 16 first — it's immediately useful for the 5 projects we just remediated. Both guides can reference TASK-016/017 deliverables even if those aren't merged yet (link to path, note "see delivery-lifecycle.md"). Keep guides action-oriented: numbered steps, no theory. Depends on TASK-016 and TASK-017 for accuracy but can be drafted in parallel with placeholder references.
- Acceptance Criteria:
  - [ ] AC-1: Both files exist: `guides/15-v3-upgrade-greenfield.md` and `guides/16-v3-upgrade-existing-projects.md`
  - [ ] AC-2: Guide 15 contains numbered steps — minimum 4 steps covering: run bootstrap, select tier, confirm planning artifacts, open first session
  - [ ] AC-3: Guide 16 contains numbered steps — minimum 5 steps covering: run `--audit-only`, review gap report, run remediation, fill missing planning artifacts, verify hooks and MCP active
  - [ ] AC-4: Both guides reference `framework/governance/delivery-lifecycle.md` and `framework/governance/stage-gates.md` by path — references may note "(see delivery-lifecycle.md — TASK-016)" if not yet merged
  - [ ] AC-5: Guide 16 is written first — verified by file modification timestamp or commit order
  - [ ] AC-6: Neither guide contains procedure steps that contradict current script behaviour — e.g. guide 16 must not instruct `--safe-remediate` flag if that flag does not yet exist (must say "until --safe-remediate is available, use remediate-project.sh")
  - [ ] AC-7: Both guides follow the existing guide format: `#` title, `##` sections, numbered steps, no raw JSON or envelope blocks
  - [ ] AC-8: Both files pass `validate-framework.sh` without adding new FAIL lines
- QA Notes:
<!-- /TASK-021 -->

<!-- TASK-023 -->
## [TASK-023] Add PLANNING_SESSION mode to session-close contract
- Status: QA_APPROVED
- Branch: feature/TASK-023-planning-session-close
- BA sign-off: N/A
- UX sign-off: N/A
- Spec: Edit `.claude/commands/session-close.md` to add `PLANNING_SESSION` as a valid mode. When `PLANNING_SESSION: true`: (1) allow PENDING tasks — do not emit PENDING_TASKS_EXIST violation, (2) block on any IN_PROGRESS tasks — nothing mid-flight is allowed, (3) record deferred task IDs in the session summary line, (4) emit a WARNING (not FAIL) noting tasks are deferred to next session. Update the BLOCKED logic accordingly. Also update the session-open dispatch options to mention PLANNING_SESSION as a valid close mode.
- Architect Notes: Single-file contract change — `.claude/commands/session-close.md` only. No hook changes, no schema changes. The key invariant: PLANNING_SESSION allows PENDING (planned, not started) but never IN_PROGRESS (mid-flight work abandoned). Deferred task IDs must appear in the session summary for audit traceability.
- Acceptance Criteria:
  - [ ] AC-1: `/session-close` with `PLANNING_SESSION: true` and 7 PENDING tasks exits PASS (not BLOCKED)
  - [ ] AC-2: `/session-close` with `PLANNING_SESSION: true` and any IN_PROGRESS task exits BLOCKED with IN_PROGRESS_TASKS_EXIST
  - [ ] AC-3: Session summary line includes deferred task IDs when PLANNING_SESSION mode is used
  - [ ] AC-4: A WARNING entry is emitted listing the count and IDs of deferred PENDING tasks
  - [ ] AC-5: Normal close (PLANNING_SESSION absent) still blocks on PENDING tasks — existing behaviour unchanged
  - [ ] AC-6: Contract change does not break existing session-close hook or audit-log integration
- QA Notes:
<!-- /TASK-023 -->

<!-- TASK-022 -->
## [TASK-022] Harden validate-framework.sh for v3.0 Alpha governance files
- Status: PENDING
- Branch: feature/TASK-022-validate-v3-governance
- BA sign-off: N/A
- UX sign-off: N/A
- Spec: Add new checks to `scripts/validate-framework.sh` for v3.0 Alpha deliverables: (1) check existence of `framework/governance/delivery-lifecycle.md`, `stage-gates.md`, `role-design-rules.md`, `artifact-map.md`, `artifact-ownership.md`; (2) check existence of `guides/15-v3-upgrade-greenfield.md`, `guides/16-v3-upgrade-existing-projects.md`; (3) add unresolved condition scan — warn on any `[TODO]`, `[FIXME]`, `[TBD]` tokens in framework/governance/ files (advisory, not blocking); (4) increment the check counter in the summary line. All new checks must follow the existing [OK]/[WARN]/[FAIL] output pattern.
- Architect Notes: Add checks as a new section after the existing semantic lint block. Gate on file existence only for now (not content validity — that's a later pass). The unresolved token scan should be WARN not FAIL since [TIER-TBD] placeholders are expected in early Alpha docs. Depends on TASK-016 through TASK-021 being merged first, but the checks can be written speculatively and will fail until those tasks land.
- Acceptance Criteria:
  - [ ] AC-1: `bash scripts/validate-framework.sh` exits 0 after all TASK-016..021 are merged — new governance checks report [OK]
  - [ ] AC-2: New checks are added in a dedicated section after the existing semantic lint block — not interspersed with existing checks
  - [ ] AC-3: Exactly 5 governance file checks present: delivery-lifecycle.md, stage-gates.md, role-design-rules.md, artifact-map.md, artifact-ownership.md — each emits [OK] when file exists, [FAIL] when missing
  - [ ] AC-4: Exactly 2 guide file checks present: guides/15 and guides/16 — each emits [OK] when file exists, [FAIL] when missing
  - [ ] AC-5: Unresolved condition scan covers `framework/governance/` files — emits [WARN] (not [FAIL]) for each file containing `[TODO]`, `[FIXME]`, or `[TBD]` tokens
  - [ ] AC-6: Summary line check count is incremented — total reported checks ≥ 24 (was 17+semantic; now +7 new checks minimum)
  - [ ] AC-7: Running `validate-framework.sh` on the current repo (before TASK-016..021 land) produces [FAIL] lines for all 7 missing files — confirming checks are active and not silently passing
  - [ ] AC-8: All new check output lines follow the existing pattern exactly: `[OK]`, `[WARN]`, or `[FAIL]` prefix — no new output formats introduced
- QA Notes:
<!-- /TASK-022 -->

