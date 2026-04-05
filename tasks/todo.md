## SESSION STATE
Status:         OPEN
Active task:    Phase 9 — Operating Tiers (STEP-32..35)
Active persona: Architect
Blocking issue: none
Last updated:   2026-04-05T12:00:00Z — Session 12 open
---

<!--
TASK FORMAT — copy this block for each new task:

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

<!-- TASK-020 -->
## [TASK-020] Add --audit-only flag to remediate-project.sh
- Status: PENDING
- Branch: feature/TASK-020-audit-only-flag
- BA sign-off: N/A
- UX sign-off: N/A
- Spec: Add `--audit-only` mode to `scripts/remediate-project.sh`. When passed, the script must: (1) scan the target project and report current framework version and maturity level, (2) list all missing required artifacts (sourced from artifact-map.md list, hard-coded for now), (3) list missing recommended artifacts, (4) report hook/settings.json gaps, (5) report MCP server presence, (6) report mid-build state, (7) exit 0 with a structured gap report — NO file writes. Output must be human-readable and machine-parseable (pipe-separated or JSON-compatible summary line at end).
- Architect Notes: Depends on TASK-019 for the artifact list, but can hard-code initial artifact list from project-template contents. `--audit-only` must be mutually exclusive with `--force`. Existing `--dry-run` shows what would change; `--audit-only` shows what is missing entirely — different concern. Safe to run on any project at any time.
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
- Architect Notes: Write guide 16 first — it's immediately useful for the 5 projects we just remediated. Both guides can reference TASK-016/017 deliverables even if those aren't merged yet. Keep guides action-oriented: numbered steps, no theory. Depends on TASK-016 and TASK-017 for accuracy but can be drafted in parallel with placeholder references.
- Acceptance Criteria:
  - [ ] AC-1: Both files exist: `guides/15-v3-upgrade-greenfield.md` and `guides/16-v3-upgrade-existing-projects.md`
  - [ ] AC-2: Guide 15 contains numbered steps — minimum 4 steps covering: run bootstrap, select tier, confirm planning artifacts, open first session
  - [ ] AC-3: Guide 16 contains numbered steps — minimum 5 steps covering: run `--audit-only`, review gap report, run remediation, fill missing planning artifacts, verify hooks and MCP active
  - [ ] AC-4: Both guides reference `framework/governance/delivery-lifecycle.md` and `framework/governance/stage-gates.md` by path
  - [ ] AC-5: Guide 16 is written first — verified by file modification timestamp or commit order
  - [ ] AC-6: Neither guide contains procedure steps that contradict current script behaviour
  - [ ] AC-7: Both guides follow the existing guide format: `#` title, `##` sections, numbered steps, no raw JSON or envelope blocks
  - [ ] AC-8: Both files pass `validate-framework.sh` without adding new FAIL lines
- QA Notes:
<!-- /TASK-021 -->

<!-- TASK-022 -->
## [TASK-022] Harden validate-framework.sh for v3.0 Alpha governance files
- Status: PENDING
- Branch: feature/TASK-022-validate-v3-governance
- BA sign-off: N/A
- UX sign-off: N/A
- Spec: Add new checks to `scripts/validate-framework.sh` for v3.0 Alpha deliverables: (1) check existence of `framework/governance/delivery-lifecycle.md`, `stage-gates.md`, `role-design-rules.md`, `artifact-map.md`, `artifact-ownership.md`; (2) check existence of `guides/15-v3-upgrade-greenfield.md`, `guides/16-v3-upgrade-existing-projects.md`; (3) add unresolved condition scan — warn on any `[TODO]`, `[FIXME]`, `[TBD]` tokens in framework/governance/ files (advisory, not blocking); (4) increment the check counter in the summary line. All new checks must follow the existing [OK]/[WARN]/[FAIL] output pattern.
- Architect Notes: Add checks as a new section after the existing semantic lint block. The unresolved token scan should be WARN not FAIL. Depends on TASK-016 through TASK-021 being merged first, but the checks can be written speculatively.
- Acceptance Criteria:
  - [ ] AC-1: `bash scripts/validate-framework.sh` exits 0 after all TASK-016..021 are merged — new governance checks report [OK]
  - [ ] AC-2: New checks are added in a dedicated section after the existing semantic lint block
  - [ ] AC-3: Exactly 5 governance file checks present — each emits [OK] when file exists, [FAIL] when missing
  - [ ] AC-4: Exactly 2 guide file checks present: guides/15 and guides/16 — each emits [OK] when file exists, [FAIL] when missing
  - [ ] AC-5: Unresolved condition scan covers `framework/governance/` files — emits [WARN] (not [FAIL])
  - [ ] AC-6: Summary line check count is incremented — total reported checks ≥ 24
  - [ ] AC-7: Running `validate-framework.sh` on current repo produces [FAIL] lines for all 7 missing files
  - [ ] AC-8: All new check output lines follow the existing pattern: `[OK]`, `[WARN]`, or `[FAIL]` prefix
- QA Notes:
<!-- /TASK-022 -->




<!-- TASK-032 -->
## [TASK-032] Update bootstrap-project.sh — tier-aware + v3.0 intake
- Status: PENDING
- Branch: feature/TASK-032-bootstrap-tier-aware
- BA sign-off: N/A
- UX sign-off: N/A
- Spec: Edit `scripts/bootstrap-project.sh` to make intake tier-aware. Changes: (1) add tier prompt: `"Project tier [MVP/Standard/High-Risk]? [default: Standard]"`; (2) validate input with `if [[ ! "$TIER" =~ ^(MVP|Standard|High-Risk)$ ]]` — reject invalid values, error and re-prompt or exit 1; (3) prefill `Tier: <tier>` in generated CLAUDE.md; (4) create `tasks/design-system.md` placeholder from project-template; (5) deploy 3 new hooks: auto-teach.sh, auto-codex-prep.sh, auto-codex-read.sh; (6) update VERSION stamp to 3.0.0.
- Architect Notes: AK APPROVAL GATE — task is built and QA_APPROVED but does NOT merge to main until AK reviews bootstrap intake flow (STEP-35 explicit gate). Security: use `read -r`; tier input written as literal string only, never executed. Depends on TASK-031.
- Acceptance Criteria:
  - [ ] AC-1: Running the bootstrap script with tier input "Standard" generates a project with `Tier: Standard` in CLAUDE.md — verified by `grep -E '^Tier:' <project>/CLAUDE.md` returning `Tier: Standard`
  - [ ] AC-2: All 3 valid tier values accepted — "MVP" generates `Tier: MVP`, "High-Risk" generates `Tier: High-Risk`; each output passes the same grep check as AC-1
  - [ ] AC-3: Empty input (pressing Enter without a value) defaults to `Tier: Standard` in the generated CLAUDE.md — default behavior must not require the user to type "Standard"
  - [ ] AC-4: Invalid input (e.g., the string "enterprise") causes the script to print an error message and exit non-zero — the project directory must NOT be created with a malformed or missing Tier field; re-prompt or clean exit both acceptable
  - [ ] AC-5: Generated project contains `tasks/design-system.md` as a placeholder file — file exists and is not empty (must have at minimum a header line)
  - [ ] AC-6: Generated project's `scripts/hooks/` directory contains all 3 new hook files: `auto-teach.sh`, `auto-codex-prep.sh`, `auto-codex-read.sh` — all 3 must be present; a subset fails
  - [ ] AC-7: `grep 'read -r' scripts/bootstrap-project.sh` confirms `read -r` is used for the tier input prompt — bare `read` (without `-r`) fails this security criterion
  - [ ] AC-8: VERSION stamp in the generated project reads `3.0.0` — verified by reading `.ak-cogos-version` in the generated project directory or checking the bootstrap output log
- QA Notes: AK APPROVAL GATE — QA_APPROVED on this task authorises the build, NOT the merge. Per STEP-35, Architect must hold TASK-032 branch until AK explicitly approves the bootstrap intake flow before merge to main.
<!-- /TASK-032 -->
