# BA Schema
# validation: markdown-contract-only | machine-validated

## Extra Fields

```yaml
requirements:
  - id: string              # e.g. REQ-001
    user_outcome: string    # "As a [user], I can [action] so that [value]"
    acceptance_intent: string
    edge_cases: []

assumptions: []             # explicit statements taken as true — must be validated

out_of_scope: []            # explicit exclusions — prevents scope creep
```

## Validation Rules

- `requirements` must not be empty when status is PASS
- Each requirement must have `user_outcome` — feature descriptions alone are rejected
- `assumptions` must be explicitly listed even if empty (empty list is valid)
- `out_of_scope` must be explicitly listed even if empty
- Missing `feature_scope` input → BLOCKED with `MISSING_INPUT: feature_scope`

## Artifacts Written

- `tasks/ba-logic.md` — business requirements for current feature
- `channel.md` — updated session state

## Activation Inputs Required

- `session_id` — current session identifier
- `objective` — what the feature is meant to achieve
- `feature_scope` — boundary of what is being specified
