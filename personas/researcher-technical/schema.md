# Researcher-Technical Schema
# validation: markdown-contract-only | machine-validated

## Extra Fields

```yaml
research_brief:
  question: string
  researcher: "technical"
  date: YYYY-MM-DD
  confidence: high | medium | low
  confidence_note: string
  key_findings: []                # each entry: "finding — source / docs link"
  sources: []                     # each entry: "name | url_or_ref | version_or_date"
  gaps: []                        # what could not be verified or is version-dependent
  recommended_next_step: string

sub_persona_used: "technical"
confidence: high | medium | low
```

## Confidence Definitions

| Level | Meaning |
|---|---|
| high | Multiple corroborating primary sources (official documentation, published benchmarks, release notes); findings are well-established |
| medium | Some primary sources; some inference or community sources (blog posts, Stack Overflow) involved |
| low | Limited sources; version-dependent findings; significant uncertainty; treat as preliminary only |

## Validation Rules

- `research_brief.question` must match the original `research_question` input exactly
- `research_brief.researcher` must be `"technical"`
- `research_brief.key_findings` must not be empty when status is PASS
- Each finding must contain a source reference (parenthetical inline or docs link is acceptable)
- Each finding involving version-specific behavior must note the version tested or referenced
- `research_brief.sources` must not be empty when findings are present
- Each source should include version or date where applicable
- `research_brief.gaps` must be present (empty list is valid — means no known gaps)
- `research_brief.recommended_next_step` must be one sentence and name a persona or action
- `confidence: low` should trigger a WARNING in the envelope
- Missing `research_question` input -> BLOCKED with `MISSING_INPUT: research_question`

## Artifacts Written

- Optional: `tasks/research-{date}.md` if AK wants brief saved
- `channel.md` — updated session state (if research materially affects sprint direction)

## Activation Inputs Required

- `session_id` — current session identifier
- `research_question` — the exact technical question to answer
- `topic_area` — technical domain focus (e.g. tech stack comparison, API evaluation, architecture pattern, benchmark analysis)
