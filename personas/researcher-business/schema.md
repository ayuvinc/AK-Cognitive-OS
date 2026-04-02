# Researcher-Business Schema
# validation: markdown-contract-only | machine-validated

## Extra Fields

```yaml
research_brief:
  question: string
  researcher: "business"
  date: YYYY-MM-DD
  confidence: high | medium | low
  confidence_note: string
  key_findings: []                # each entry: "finding — source"
  sources: []                     # each entry: "name | url_or_ref | date"
  gaps: []                        # what could not be found or verified
  recommended_next_step: string

sub_persona_used: "business"
confidence: high | medium | low
```

## Confidence Definitions

| Level | Meaning |
|---|---|
| high | Multiple corroborating primary sources (SEC filings, official reports, verified data); findings are well-established |
| medium | Some primary sources; some inference or secondary sources (analyst reports, estimates) involved |
| low | Limited sources; significant uncertainty; estimates not independently verified; treat as preliminary only |

## Validation Rules

- `research_brief.question` must match the original `research_question` input exactly
- `research_brief.researcher` must be `"business"`
- `research_brief.key_findings` must not be empty when status is PASS
- Each finding must contain a source reference (parenthetical inline is acceptable)
- Each finding involving numerical data must note whether the figure is estimated or verified
- `research_brief.sources` must not be empty when findings are present
- `research_brief.gaps` must be present (empty list is valid — means no known gaps)
- `research_brief.recommended_next_step` must be one sentence and name a persona or action
- `confidence: low` should trigger a WARNING in the envelope
- Missing `research_question` input -> BLOCKED with `MISSING_INPUT: research_question`

## Artifacts Written

- Optional: `tasks/research-{date}.md` if AK wants brief saved
- `channel.md` — updated session state (if research materially affects sprint direction)

## Activation Inputs Required

- `session_id` — current session identifier
- `research_question` — the exact business question to answer
- `topic_area` — business domain focus (e.g. market sizing, competitor analysis, pricing strategy)
