# Session 12 Release — v3.0 Phase 9 (Operating Tiers)
# Sprint: v3-delivery
# Branch: chore/v2.2-framework-foundation
# Closed: 2026-04-05
# Persona: session-open → Architect → QA → Junior Dev → QA-Run → Architect

---

## Delivered Tasks

### [TASK-029] Write framework/governance/operating-tiers.md
- Status: QA_APPROVED → ARCHIVED
- Branch: feature/TASK-029-operating-tiers (merged)
- Files:
  - `framework/governance/operating-tiers.md` (new — governance doc #8)
- Spec: Defines the three-tier system (MVP / Standard / High-Risk) with gate tables,
  required artifacts, allowed shortcuts, and release constraints per tier.
  MVP exemption scoped to planning docs gate + compliance gate only.
  Tier field syntax (`^Tier:`) documented to match hook grep pattern.
- AC passed: 8/8
- Plan step: STEP-32 ✓

### [TASK-030] Write guides/14-risk-tier-selection.md
- Status: QA_APPROVED → ARCHIVED
- Branch: feature/TASK-030-tier-selection-guide (merged)
- Files:
  - `guides/14-risk-tier-selection.md` (new)
- Spec: Decision guide for tier selection. 3 decision questions with binary criteria,
  worked examples for all 4 project types (SaaS/AI-RAG/regulated/internal tool),
  mid-project tier change instructions (both steps: edit CLAUDE.md + run remediate),
  explicit AK approval requirement for High-Risk downgrade.
- AC passed: 8/8
- Plan step: STEP-33 ✓

### [TASK-031] Add Tier field to project-template/CLAUDE.md
- Status: QA_APPROVED → ARCHIVED
- Branch: feature/TASK-031-template-tier-field (merged)
- Files:
  - `project-template/CLAUDE.md` (edited — +2 lines, 0 deletions)
- Spec: Added `Tier: Standard` at line 4, before first `---` separator.
  Inline comment references MVP|Standard|High-Risk and operating-tiers.md.
  Added guard-planning-artifacts.sh row to Hooks table, scoped to Standard+High-Risk.
  Hook parse verified: `grep -E '^Tier:' | awk '{print $2}'` returns `Standard`.
- AC passed: 8/8
- Plan step: STEP-34 ✓

---

## Held Tasks (AK Approval Gate)

### [TASK-032] Update bootstrap-project.sh — tier-aware + v3.0 intake
- Status: QA_APPROVED — HELD on feature/TASK-032-bootstrap-tier-aware
- Branch: feature/TASK-032-bootstrap-tier-aware (NOT merged — AK gate active)
- Files:
  - `scripts/bootstrap-project.sh` (VERSION 3.0.0, tier prompt + validation, Tier sed)
- Spec: Tier prompt with validation loop (MVP/Standard/High-Risk), default Standard on empty,
  invalid input rejected with error. Tier value applied to CLAUDE.md via sed.
  read -r used. VERSION 3.0.0. design-system.md + 3 new hooks deployed.
- AC passed: 8/8
- Gate: AK must review bootstrap intake flow before this branch merges (STEP-35)
- Plan step: STEP-35 — AK APPROVAL PENDING

---

## Deferred to Next Session

- TASK-018: framework/governance/role-design-rules.md (Phase 10)
- TASK-020: remediate-project.sh --audit-only flag (Phase 13)
- TASK-021: guides/15 + guides/16 (Phase 9 tail / Phase 11)
- TASK-022: validate-framework.sh v3.0 governance checks (Phase 12)

---

## Plan Progress After This Session

| Phase | Steps | Done | Remaining |
|---|---|---|---|
| Phase 9 — Operating Tiers | 4 | 3 (STEP-32..34) | 1 (STEP-35 AK gate) |
| **Cumulative** | **76** | **34** | **42** |

---

## Validation State

```
bash scripts/validate-framework.sh → PASS (16 structural checks + semantic lint, 0 failures)
```
