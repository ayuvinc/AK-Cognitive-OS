# Junior-Dev Schema
# validation: markdown-contract-only | machine-validated

## Extra Fields

```yaml
completed_task_ids: []      # task IDs implemented this sprint

ready_for_review: true|false  # true only when all tasks complete and build passing

changed_files: []           # list of all files modified or created
```

## Validation Rules

- `completed_task_ids` must not be empty when status is PASS
- `ready_for_review: true` requires at least one `completed_task_id`
- `changed_files` must not be empty when status is PASS
- If any assigned task was not completed → `ready_for_review: false` + reason in `failures[]`
- Scope expansion (touching files outside assigned tasks) → BLOCKED with `BOUNDARY_FLAG`

## Artifacts Written

- Code and test files per assigned task IDs
- `channel.md` — updated session state with task status changes

## Activation Inputs Required

- `session_id` — current session identifier
- `sprint_id` — current sprint identifier
- `task_ids` — explicit list of task IDs to implement
- `tasks/todo.md` — must be readable with assigned tasks in PENDING or IN_PROGRESS state
- Architecture constraints from last Architect run
