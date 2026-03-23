## SESSION STATE
Status:         OPEN
Active task:    none
Active persona: none
Blocking issue: none
Last updated:   Session 2 close — Sprint 1 + Sprint 2 complete, Sprint 3 pending

## Sprint 3 — PENDING

<!-- TASK-006 -->
## [TASK-006] Promote sub-personas to invocable slash commands
- Status: PENDING
- Spec: Create claude-command.md + SKILL.md for researcher sub-personas (legal, business, policy, news, technical) and compliance sub-personas (data-privacy, data-security, pii-handler, phi-handler) so they appear as /researcher-legal, /compliance-data-privacy etc.
- Acceptance Criteria: Each sub-persona has its own command file and is testable via slash command
<!-- /TASK-006 -->

<!-- TASK-007 -->
## [TASK-007] Add schema.md validation to validate-framework.sh
- Status: PENDING
- Spec: validate-framework.sh currently checks file presence only. Add a check that each skill/persona SKILL.md has valid YAML frontmatter (name, description, tools fields present).
- Acceptance Criteria: Script exits non-zero if any SKILL.md is missing required frontmatter fields
<!-- /TASK-007 -->

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
