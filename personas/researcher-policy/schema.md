# Researcher-Policy Schema
# validation: markdown-contract-only | machine-validated

## Extra Fields

```yaml
research_brief:
  question: string
  researcher: "policy"
  jurisdiction: string            # e.g. UK, EU, US, global, or sector-specific
  date: YYYY-MM-DD
  confidence: high | medium | low
  confidence_note: string
  key_findings: []                # each entry: "finding — source"
  sources: []                     # each entry: "name | url_or_ref | date"
  gaps: []                        # what could not be found or verified
  recommended_next_step: string

sub_persona_used: "policy"
confidence: high | medium | low
```

## Confidence Definitions

| Level | Meaning |
|---|---|
| high | Multiple corroborating primary sources (official gazettes, enacted legislation, government publications); findings are well-established |
| medium | Some primary sources; some inference or secondary commentary (think-tank reports, consultation responses) involved |
| low | Limited sources; significant uncertainty; draft or proposed policy only; treat as preliminary only |

## Validation Rules

- `research_brief.question` must match the original `research_question` input exactly
- `research_brief.researcher` must be `"policy"`
- `research_brief.jurisdiction` must be present (use "general" if not jurisdiction-specific)
- `research_brief.key_findings` must not be empty when status is PASS
- Each finding must contain a source reference (parenthetical inline is acceptable)
- Each finding must note whether the policy is enacted, draft, or proposed
- `research_brief.sources` must not be empty when findings are present
- `research_brief.gaps` must be present (empty list is valid — means no known gaps)
- `research_brief.recommended_next_step` must be one sentence and name a persona or action
- `confidence: low` should trigger a WARNING in the envelope
- Missing `research_question` input -> BLOCKED with `MISSING_INPUT: research_question`
- Missing `jurisdiction` input -> use default "general"

## Artifacts Written

- Optional: `tasks/research-{date}.md` if AK wants brief saved
- `channel.md` — updated session state (if research materially affects sprint direction)

## Activation Inputs Required

- `session_id` — current session identifier
- `research_question` — the exact policy question to answer
- `jurisdiction` — jurisdiction or sector (e.g. UK, EU, US, global, or specific sector)
