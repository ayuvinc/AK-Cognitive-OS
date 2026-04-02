# Researcher-News Schema
# validation: markdown-contract-only | machine-validated

## Extra Fields

```yaml
research_brief:
  question: string
  researcher: "news"
  date: YYYY-MM-DD
  confidence: high | medium | low
  confidence_note: string         # must note recency of sources
  key_findings: []                # each entry: "finding — source and date"
  sources: []                     # each entry: "name | url_or_ref | publication_date"
  gaps: []                        # what could not be found or verified
  recommended_next_step: string

sub_persona_used: "news"
confidence: high | medium | low
```

## Confidence Definitions

| Level | Meaning |
|---|---|
| high | Multiple corroborating recent sources (established outlets, official announcements); findings are well-established |
| medium | Some primary sources; some reports unverified or from single outlet; recency varies |
| low | Limited sources; breaking or unverified news; significant uncertainty; treat as preliminary only |

## Validation Rules

- `research_brief.question` must match the original `research_question` input exactly
- `research_brief.researcher` must be `"news"`
- `research_brief.key_findings` must not be empty when status is PASS
- Each finding must contain a source reference with publication date (parenthetical inline is acceptable)
- `research_brief.sources` must not be empty when findings are present
- Each source must include a publication date
- `research_brief.gaps` must be present (empty list is valid — means no known gaps)
- `research_brief.confidence_note` must mention recency of sources
- `research_brief.recommended_next_step` must be one sentence and name a persona or action
- `confidence: low` should trigger a WARNING in the envelope
- Missing `research_question` input -> BLOCKED with `MISSING_INPUT: research_question`

## Artifacts Written

- Optional: `tasks/research-{date}.md` if AK wants brief saved
- `channel.md` — updated session state (if research materially affects sprint direction)

## Activation Inputs Required

- `session_id` — current session identifier
- `research_question` — the exact news/events question to answer
- `topic_area` — news domain focus (e.g. industry news, product launches, funding, regulatory developments)
