# Skill Schema
# AK Cognitive OS
# validation: markdown-contract-only | machine-validated

---

## Purpose

Defines the required structure for every skill in `skills/`.
A skill is a named slash command that performs a specific workflow action
(not a persona — no role identity, just a task runner).

---

## Skill vs Persona Distinction

| Aspect | Persona | Skill |
|---|---|---|
| Identity | Named role (architect, qa, etc.) | Named action (session-open, etc.) |
| Job | Ongoing judgment within a domain | Single-purpose operation |
| Activation | `/persona-name` | `/skill-name` |
| Output | Persona-specific artifacts | Action-specific artifacts |

---

## Required Files Per Skill

Every skill directory must contain:

```
skills/{name}/
├── claude-command.md    ← Claude slash command definition
└── codex-prompt.md      ← Codex equivalent (if Codex can run this skill)
```

Note: skills do not have a `schema.md` — their output contract is defined in `claude-command.md`.

---

## claude-command.md Required Sections

```
# /{skill-name}

## PURPOSE
[One sentence: what this skill does]

## PRECONDITIONS
[What must exist before this skill can run]

## STEPS
[Numbered execution steps]

## OUTPUT
[What this skill writes/returns]

## HANDOFF
[Required output envelope — YAML format]
```

---

## Validation Rules

- Missing `PURPOSE` → `SCHEMA_VIOLATION: skill purpose undefined`
- Missing `PRECONDITIONS` → skill can run in invalid state, not safe to deploy
- Missing `STEPS` → skill has no executable body
- Missing `OUTPUT` → consuming persona cannot verify skill ran correctly
- Missing output envelope in HANDOFF → `SCHEMA_VIOLATION: envelope missing`
