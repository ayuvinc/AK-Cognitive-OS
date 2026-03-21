# UX Schema
# validation: markdown-contract-only | machine-validated

## Extra Fields

```yaml
ux_requirements:
  - component: string         # component name
    states: []                # default, hover, active, error, empty, loading
    spacing: string           # e.g. "16px padding, 8px gap"
    breakpoints: []           # e.g. ["375px mobile", "768px tablet", "1280px desktop"]
    behavior_notes: string    # interaction rules

mobile_375_checks:
  - component: string
    check: string             # what was verified at 375px
    result: PASS | FAIL | N/A

accessibility_notes: []       # ARIA, keyboard navigation, colour contrast notes
```

## Validation Rules

- `ux_requirements` must not be empty when UI components were in scope
- Each requirement must include at least `component` and `states`
- `mobile_375_checks` required whenever any component file changed
- If no UI components changed: `mobile_375_checks: []` is valid
- Missing `ui_scope` input → BLOCKED with `MISSING_INPUT: ui_scope`

## Artifacts Written

- `tasks/ux-specs.md` — UX specifications for current sprint
- `channel.md` — updated session state

## Activation Inputs Required

- `session_id` — current session identifier
- `sprint_id` — current sprint identifier
- `ui_scope` — which UI components or flows are being specified
