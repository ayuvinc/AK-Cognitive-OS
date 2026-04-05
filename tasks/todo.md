## SESSION STATE
Status:         OPEN
Active task:    none
Active persona: Junior Dev
Blocking issue: none
Last updated:   2026-04-05T13:00:00Z — Session 13 — TASK-033..037 built, READY_FOR_REVIEW

---

## TASK-033 — Write framework/governance/role-taxonomy.md
- Status: READY_FOR_REVIEW
- Step: STEP-36 (Phase 10)
- Owner: Junior Dev
- Description: Classify all 20 commands into 6 categories using BL-001 taxonomy.
  Categories: delivery persona, router persona, specialist persona,
  mechanical skill, advisory/meta skill, quality skill.
  Include rationale for each classification.
- Deliverable: framework/governance/role-taxonomy.md
- Dependencies: none
- Security model: N/A — static governance doc
- Acceptance criteria:
  - AC-1: File exists at framework/governance/role-taxonomy.md
  - AC-2: All 20 Final Command Set commands appear exactly once — no omissions, no additions.
           Authoritative list: architect, ba, junior-dev, qa, ux, designer, risk-manager,
           researcher, compliance, qa-run, security-sweep, codex-prep, codex-read,
           teach-me, lessons-extractor, check-channel, session-open, session-close,
           compact-session, audit-log
  - AC-3: All 6 category headers present: delivery persona, router persona, specialist persona,
           mechanical skill, advisory/meta skill, quality skill
  - AC-4: Category counts exact: delivery=5, router=2, specialist=2, mechanical=4, advisory=3, quality=4
  - AC-5: Each command entry includes command name, assigned category, and rationale (min 1 sentence)
  - AC-6: designer classified as specialist persona (visual/brand direction, not interaction behavior) per BL-001
  - AC-7: compliance and researcher classified as router personas per BL-001
  - AC-8: qa-run, security-sweep, codex-prep, codex-read classified as quality skills

---

## TASK-034 — Write framework/governance/role-design-rules.md
- Status: READY_FOR_REVIEW
- Step: STEP-37 (Phase 10)
- Owner: Junior Dev
- Description: Document rules for adding new commands to the framework.
  Cover: persona vs skill decision, router vs specialist pattern,
  maximum command set size (20), deprecation rules.
- Deliverable: framework/governance/role-design-rules.md
- Dependencies: TASK-033
- Security model: N/A — static governance doc
- Acceptance criteria:
  - AC-1: File exists at framework/governance/role-design-rules.md
  - AC-2: Covers persona vs skill decision — minimum 3 binary decision criteria stated
           as prescriptive rules (MUST / MUST NOT), not suggestions
  - AC-3: Covers router vs specialist pattern — explains when to use each;
           router = broad domain with sub-specializations, specialist = narrow expert scope
  - AC-4: States maximum command set size is 20 explicitly; adding a command requires
           retiring another or AK approval to exceed the limit
  - AC-5: Covers deprecation rules — minimum: how to retire a command, notice period or
           replacement requirement, what happens to dependent command references
  - AC-6: References framework/governance/role-taxonomy.md as the classification authority
  - AC-7: No rule contradicts any CAN/CANNOT boundary in the 20 existing command files
  - AC-8: All rules use prescriptive language (MUST, SHOULD, MUST NOT) — zero aspirational phrasing

---

## TASK-035 — Write framework/governance/change-policy.md
- Status: READY_FOR_REVIEW
- Step: STEP-38 (Phase 10)
- Owner: Junior Dev
- Description: Document how the framework evolves.
  Cover: proposal format, review process, how repeated failures
  become framework changes via framework-delta-log pattern.
- Deliverable: framework/governance/change-policy.md
- Dependencies: TASK-034
- Security model: N/A — static governance doc
- Acceptance criteria:
  - AC-1: File exists at framework/governance/change-policy.md
  - AC-2: Includes proposal format table or template — required fields: change description,
           motivation, affected commands/artifacts, risk level (LOW/MEDIUM/HIGH)
  - AC-3: Documents review process — states who approves (AK for scope/priority,
           Architect for design) and in what order
  - AC-4: Documents escalation from repeated failure to framework change —
           explicit trigger condition (e.g., same failure in 2+ sessions = framework change required)
  - AC-5: References /framework-delta-log skill by exact name as the canonical
           delta capture mechanism
  - AC-6: States that no framework change proceeds without an entry in framework-improvements.md
  - AC-7: Covers rollback — states what action is taken if a framework change causes regression

---

## TASK-036 — Write framework/governance/versioning-policy.md
- Status: READY_FOR_REVIEW
- Step: STEP-39 (Phase 10)
- Owner: Junior Dev
- Description: Document version bump rules.
  Cover: major/minor/patch criteria, .ak-cogos-version as authoritative
  stamp location, compatibility guarantees across versions.
- Deliverable: framework/governance/versioning-policy.md
- Dependencies: TASK-035
- Security model: N/A — static governance doc
- Acceptance criteria:
  - AC-1: File exists at framework/governance/versioning-policy.md
  - AC-2: Defines major version bump criteria with minimum 2 concrete examples
           (e.g., breaking change to envelope schema, removal of a command)
  - AC-3: Defines minor version bump criteria with minimum 2 concrete examples
           (e.g., new governance doc, new hook added)
  - AC-4: Defines patch version bump criteria with minimum 2 concrete examples
           (e.g., bug fix in hook script, wording correction)
  - AC-5: Names .ak-cogos-version as the authoritative version stamp file explicitly
  - AC-6: Documents all secondary stamp locations: VERSION variable in
           remediate-project.sh AND bootstrap-project.sh (both must be named)
  - AC-7: States compatibility guarantee for minor versions — which interfaces
           remain stable (e.g., envelope schema, hook exit codes)
  - AC-8: States that version is bumped by the Architect and the bump is recorded
           in tasks/audit-log.md

---

## TASK-037 — Write framework/governance/release-policy.md
- Status: READY_FOR_REVIEW
- Step: STEP-40 (Phase 10)
- Owner: Junior Dev
- Description: Document how framework releases are packaged, tested,
  and deployed to projects. Must align with remediate-project.sh
  --audit-only / --safe-remediate / --full-remediate modes.
- Deliverable: framework/governance/release-policy.md
- Dependencies: TASK-036
- Security model: N/A — static governance doc
- Acceptance criteria:
  - AC-1: File exists at framework/governance/release-policy.md
  - AC-2: Defines all three remediation modes with what each does:
           --audit-only (reports gaps, no writes), --safe-remediate (adds missing, skips conflicts),
           --full-remediate (full deploy, overwrites where safe)
  - AC-3: Includes pre-release checklist — minimum 3 items including:
           validate-framework.sh PASS, .ak-cogos-version updated, AK STEP-49 approval gate cleared
  - AC-4: Documents project deployment sequence matching plan order:
           Pharma-Base → forensic-ai → policybrain → mission-control → Transplant-workflow
  - AC-5: States that STEP-49 AK approval gate must be cleared before any project is touched
  - AC-6: Documents verification step after each project remediation (what to check)
  - AC-7: References scripts/remediate-project.sh as the deployment mechanism by exact path
  - AC-8: Covers failed remediation — states recovery action if a project remediation
           fails mid-run (e.g., re-run --audit-only, do not proceed to next project)
