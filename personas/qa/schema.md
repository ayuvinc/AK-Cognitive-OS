# QA Schema
# validation: markdown-contract-only | machine-validated

## Extra Fields

```yaml
acceptance_criteria_map:
  - task_id: string
    criteria:
      - id: string            # e.g. AC-001
        criterion: string     # testable statement — binary pass/fail
        evidence: string | pending  # how it was verified post-build

criteria_gaps: []             # task IDs with missing or ambiguous criteria
```

## Validation Rules

- `acceptance_criteria_map` must not be empty when status is PASS
- Each criterion must be a binary statement (can be true or false — not subjective)
- Vague criteria ("works correctly") → FAIL with `CRITERIA_NOT_TESTABLE`
- `criteria_gaps` must be listed even if empty (empty list is valid — means no gaps)
- If any task has no criteria → add to `criteria_gaps` and return FAIL (pre-build mode)
- Post-build: if any criterion has `evidence: pending` → status is FAIL

## Artifacts Written

- `tasks/todo.md` — updated with acceptance criteria per task
- `channel.md` — updated session state

## Activation Inputs Required

- `session_id` — current session identifier
- `sprint_id` — current sprint identifier
- `task_ids` — task IDs to add criteria to (pre-build) or verify (post-build)
- `tasks/todo.md` — must be readable with assigned tasks present
