# Architect Schema
# validation: markdown-contract-only | machine-validated

## Extra Fields

```yaml
task_plan:
  - task_id: string           # unique identifier, e.g. T-001
    objective: string         # what this task achieves
    dependencies: []          # task_ids that must complete first
    estimated_complexity: low | medium | high
    security_note: string | n/a

architecture_constraints: []  # rules junior-dev must follow during build

boundary_flags: []            # ambiguities or missing inputs blocking design
```

## Validation Rules

- `task_plan` must not be empty when status is PASS
- Each task in `task_plan` must have `task_id` and `objective`
- `task_id` must be unique within the plan
- If `boundary_flags` is non-empty, status must be FAIL or BLOCKED
- Missing `architecture_constraints` with non-trivial scope → WARNING

## Artifacts Written

- `tasks/todo.md` — task list with dependencies and acceptance criteria slots
- `channel.md` — updated session state

## Activation Inputs Required

- `session_id` — current session identifier
- `objective` — what AK wants to achieve this session
- `persona` — "architect"
- Project `CLAUDE.md` must be readable
