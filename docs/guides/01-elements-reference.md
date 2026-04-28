# Elements Reference
# AK Cognitive OS — Guide 01
# What every element is, what it does, and where it lives

---

## The Four Element Types

| Element | What it is | Where it lives |
|---|---|---|
| Persona | A named agent role with a job, rules, and output contract | `personas/` |
| Skill | A named slash command that performs one workflow action | `skills/` |
| Schema | A contract that defines required fields and validation rules | `schemas/` |
| Harness | A test script that validates a persona or skill produces correct output | `harnesses/` |

---

## Personas

A persona is an agent identity. When you invoke `/architect`, you are activating
the Architect persona. The persona tells the AI:
- Who it is (identity + job)
- What it can and cannot do (boundaries)
- What inputs it needs (preconditions)
- What it must produce (output envelope + extra fields)
- When to stop (BOUNDARY_FLAG rules)

### Core Personas (5)

| Persona | Job |
|---|---|
| architect | Design task graph, constraints, risks, acceptance-ready breakdown |
| ba | Produce business logic and requirement detail for new features |
| ux | Define UX specs and interaction constraints including mobile |
| junior-dev | Implement scoped tasks exactly to spec and mark ready for review |
| qa | Define and enforce acceptance criteria quality before and after build |

### Extended Personas (2)

| Persona | Job |
|---|---|
| researcher | Answer questions with sourced, structured research briefs |
| compliance | Review work for legal, regulatory, and data handling compliance |

### Sub-Personas

Some personas have sub-personas — specialist modes activated within the main persona.

**Researcher sub-personas:**
- `legal` — case law, regulations, contracts
- `business` — markets, competitors, models
- `policy` — government policy, public regulation
- `news` — current events, industry news
- `technical` — tech stacks, APIs, architecture patterns

**Compliance sub-personas:**
- `data-privacy` — GDPR, CCPA, consent, data subject rights
- `data-security` — encryption, access control, breach response
- `pii-handler` — PII definition, handling rules, minimisation
- `phi-handler` — HIPAA PHI, safe harbour, covered entities

### Persona File Structure

Every persona directory contains:
```
personas/{name}/
├── claude-command.md    ← Claude slash command
├── codex-prompt.md      ← Codex system prompt equivalent
└── schema.md            ← Extra fields and persona-specific contract
```

---

## Skills

A skill is a named workflow action. It has no role identity — it just runs a procedure.

### Skills (defined in `skills/` — see directory listing)

Skills are activated with slash commands (e.g. `/session-open`, `/sprint-packager`).
Each skill has a defined purpose, preconditions, steps, and output.

### Skill File Structure

```
skills/{name}/
├── claude-command.md    ← Claude slash command
└── codex-prompt.md      ← Codex equivalent
```

---

## Schemas

Schemas are contracts. They define what valid output looks like for any element.
All agents and Codex must produce output that matches the schemas.

### Core Schemas

| Schema | What it defines |
|---|---|
| `output-envelope.md` | The 10-field universal envelope all output must include |
| `audit-log-schema.md` | Audit log entry format and exhaustive event type list |
| `persona-schema.md` | Required files and sections for a valid persona |
| `skill-schema.md` | Required files and sections for a valid skill |
| `finding-schema.md` | S0/S1/S2 finding format used by all stacks |

### Validation Header

Every schema file includes a validation header:
```
validation: markdown-contract-only | machine-validated
```

- `markdown-contract-only` — human-readable spec, enforced by reading
- `machine-validated` — JSON Schema + validator script also enforces it (Phase 2)

---

## Harnesses

A harness is a test script for the framework itself. It validates that a persona
or skill produces output that matches its schema contract.

Harnesses are not run during normal project work — they are run when you add
a new persona, modify a schema, or want to verify the framework is healthy.

### Harness File Structure

```
harnesses/
├── _template/
│   └── harness-template.md       ← Copy this to create a new harness
├── architect-harness.md
├── compliance-harness.md
├── session-close-harness.md
└── audit-chain-harness.md
```

---

## The Framework Layer

The `framework/` directory contains the dual-stack architecture and interop contracts.
It governs how Claude-core and Codex-core collaborate.

```
framework/
├── dual-stack-architecture.md    ← Execution modes and stack ownership
├── interop/                      ← Contracts both stacks obey
├── codex-core/                   ← Codex reviewer + creator specs
├── governance/                   ← Metrics and weekly delta review
└── templates/                    ← Sprint summary, review, task, audit templates
```

---

## The Project Template

`project-template/` is what you copy when starting a new project.
Fill in `CLAUDE.md` — everything else is generic.

---

## How Elements Connect

```
AK gives requirement
  → BA persona produces ba-logic.md
  → UX persona produces ux-specs.md
  → Architect persona produces tasks/todo.md
  → QA persona adds acceptance criteria
  → junior-dev persona implements
  → Skills gate the flow: /regression-guard → /sprint-packager → /codex-intake-check
  → Codex reviews (Reviewer mode)
  → Skills close: /qa-run → /session-close → /audit-log
  → Compliance persona can intercept at any stage (S0 = hard stop)
  → Researcher persona answers questions ad-hoc at any stage
```

All outputs flow through the output-envelope.md contract.
All events are logged to [AUDIT_LOG_PATH] using audit-log-schema.md event types.
All findings use finding-schema.md S0/S1/S2 format.

---

## Quick Lookup

| I want to... | Go to |
|---|---|
| Activate a persona | `personas/{name}/claude-command.md` |
| Run a workflow step | `skills/{name}/claude-command.md` |
| Understand what output is valid | `schemas/output-envelope.md` |
| Check event types for audit log | `schemas/audit-log-schema.md` |
| Format a finding | `schemas/finding-schema.md` |
| Test the framework is healthy | `harnesses/` |
| Understand execution modes | `framework/dual-stack-architecture.md` |
| Start a new project | `project-template/` |
| Get step-by-step session guide | `guides/02-session-flow.md` |
