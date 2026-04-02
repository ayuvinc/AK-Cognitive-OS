# Designer Schema
# validation: markdown-contract-only | machine-validated

## Extra Fields

```yaml
brand_personality:
  - is: string
    is_not: string            # 5 adjective pairs defining brand voice
color_primary: string          # hex code (e.g., "#2563EB")
typography: string             # font family name (e.g., "Inter")
ui_libraries:
  - name: string
    url: string
    license: string
    role: string               # "core|dashboard|animation|landing"
    rationale: string
    conflicts: string
theme: string                  # "dark|light|auto"
```

## Validation Rules

- `brand_personality` must contain exactly 5 entries, each with `is` and `is_not` string fields
- `color_primary` must be a valid hex color code (3 or 6 digit, prefixed with `#`)
- `typography` must name a specific font family (not a generic like "sans-serif")
- `ui_libraries` must not be empty when status is PASS; each entry must include `name`, `url`, `license`, `role`, and `rationale`
- `ui_libraries` entries with non-open-source licenses must include a WARNING in the envelope
- `theme` must be one of: `dark`, `light`, `auto`
- Every color, typography, and library recommendation must include a rationale tied to research (not personal preference)
- Dark/light mode consideration must be present — a system without it triggers FAIL
- Missing `ba-logic.md` or `todo.md` input artifacts -> BLOCKED with `MISSING_ARTIFACT`
- Missing any required input -> BLOCKED with `MISSING_INPUT`

## Artifacts Written

- `tasks/design-system.md` — full design system document consumed by /ux
- `channel.md` — updated session state with design decisions

## Handoff Target

- `/ux` — always. The /ux agent consumes the design system to produce wireframes and interaction specs.

## Activation Inputs Required

- `session_id` — current session identifier
- `product_name` — name of the product being designed
- `buyer_persona` — target buyer profile (e.g., "enterprise IT director", "solo founder")
- `product_vertical` — industry vertical (e.g., "enterprise", "compliance", "education", "health")
