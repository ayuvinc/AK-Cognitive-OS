# Harness: researcher
# AK Cognitive OS

**What this tests:** The `/researcher` persona produces a sourced research brief using the correct sub-persona.
**Pass condition:** All envelope fields present, research_brief non-empty with sources, sub_persona_used matches question type, confidence labelled.
**Fail condition:** Finding without a source, invented citation, wrong sub-persona selected, or confidence unlabelled.

---

## Preconditions

Before running this harness:
- [ ] `channel.md` exists (may be empty)

---

## Input Fixture (Business sub-persona)

```
session_id: S-TEST-01
research_question: What are the top 3 project management SaaS tools competing with Taskflow, and what are their pricing models?
sub_persona: business
```

---

## Expected Output Contract

### Envelope checks
- [ ] `run_id` present, matches `researcher-*` pattern
- [ ] `agent` = "researcher"
- [ ] `status` is PASS | FAIL | BLOCKED
- [ ] `timestamp_utc` is valid ISO-8601
- [ ] `summary` is a single sentence
- [ ] `failures[]` is present
- [ ] `warnings[]` is present
- [ ] `artifacts_written[]` is present (may be empty if brief is inline)
- [ ] `next_action` is a single sentence

### Extra fields checks
- [ ] `research_brief` is present and non-empty
- [ ] `sub_persona_used` = "business"
- [ ] `confidence` is one of: high | medium | low

### Business logic checks
- [ ] Research brief contains `question`, `researcher`, `date`, `confidence`, `confidence_note`
- [ ] At least 2 Key Findings present, each with a source
- [ ] Sources section present with at least 2 entries (name + URL + date)
- [ ] Gaps section present (even if empty)
- [ ] Recommended Next Step present
- [ ] No finding without a source — every claim is attributed
- [ ] Confidence note explains why that confidence level was assigned

---

## BLOCKED Scenario

Provide this input to test BLOCKED behaviour:

```
session_id: S-TEST-01
research_question: (missing)
sub_persona: (missing)
```

Expected:
- [ ] `status: BLOCKED`
- [ ] `failures[]` includes `MISSING_INPUT: research_question`
- [ ] No `research_brief` produced

---

## Sub-persona Auto-select Scenario

Provide this input to test automatic sub-persona selection:

```
session_id: S-TEST-01
research_question: What does GDPR say about storing user IP addresses?
```
(no sub_persona provided)

Expected:
- [ ] Researcher selects `legal` sub-persona automatically
- [ ] `sub_persona_used` = "legal"
- [ ] Research brief contains compliance-relevant findings

---

## Running This Harness

1. Open the Researcher using `/researcher`.
2. Provide the Business Input Fixture above.
3. Check output against the Expected Output Contract.
4. Run the BLOCKED Scenario.
5. Run the Sub-persona Auto-select Scenario.
6. Record result below.

---

## Result Record

```
harness: researcher
run_date: YYYY-MM-DD
result: PASS | FAIL | PARTIAL
failures: []
notes: ""
```
