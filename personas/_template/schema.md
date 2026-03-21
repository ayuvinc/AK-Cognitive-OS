# {persona-name} Schema
# TEMPLATE — copy this to personas/{your-persona}/schema.md
# validation: markdown-contract-only | machine-validated

## Extra Fields

```yaml
# Define the extra_fields this persona produces in its HANDOFF YAML.
# These must match the extra_fields block in claude-command.md and codex-prompt.md.
# Example:
{field_1}: []   # description of what this field contains
{field_2}: []   # description of what this field contains
```

## Validation Rules

- Replace these with rules specific to your persona.
- `{field_1}` must not be empty when status is PASS
- If boundary_flags is non-empty, status must be FAIL or BLOCKED

## Artifacts Written

- List every file this persona writes, and what it contains.
- Example: `tasks/todo.md` — updated task list

## Handoff Target

- Which persona or skill runs next after this one completes.
- Example: QA adds acceptance criteria, then Junior Dev builds.
