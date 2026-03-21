# Persona Schema
# AK Cognitive OS
# validation: markdown-contract-only | machine-validated

---

## Purpose

Defines the required structure for every persona in `personas/`.
A persona is a named agent identity with a specific job, rules, and output contract.

---

## Required Files Per Persona

Every persona directory must contain:

```
personas/{name}/
├── claude-command.md    ← Claude slash command definition
├── codex-prompt.md      ← Codex system prompt equivalent
└── schema.md            ← Extra fields and persona-specific contract
```

Sub-personas (if any) live in a `sub-personas/` subdirectory within the persona folder.

---

## claude-command.md Required Sections

```
# /{persona-name}

## WHO YOU ARE
[One sentence: name, system, job]

## YOUR RULES
CAN: [list]
CANNOT: [list]
BOUNDARY_FLAG: [when to stop and emit BLOCKED]

## ON ACTIVATION - AUTO-RUN SEQUENCE
[Numbered steps including path resolution and validation]

## TASK EXECUTION
Reads: [artifacts]
Writes: [artifacts]
Checks/Actions: [what it does]

## HANDOFF
[Required output envelope — YAML format]
```

---

## codex-prompt.md Required Sections

```
# Codex System Prompt: {persona-name}

## Role
[Who Codex is acting as in this context]

## Scope
[What Codex does and does not do in this persona]

## Required Output
[Envelope fields + extra fields]

## Rules
[Constraints — same spirit as claude-command.md but Codex-native]
```

---

## schema.md Required Sections

```
# {Persona Name} Schema

## Extra Fields
[YAML block of required fields beyond the base envelope]

## Validation Rules
[What makes output PASS, FAIL, BLOCKED]

## Artifacts Written
[List of files this persona writes]

## Activation Inputs Required
[What must exist before this persona can run]
```

---

## Validation Rules

- Missing `claude-command.md` → persona is incomplete, do not activate
- Missing `codex-prompt.md` → Codex cannot run in this persona
- Missing `schema.md` → extra fields undefined, BLOCKED on first run
- Missing `## WHO YOU ARE` section → `SCHEMA_VIOLATION: persona identity undefined`
- Missing `BOUNDARY_FLAG` rule → persona has no stop condition, not safe to deploy
