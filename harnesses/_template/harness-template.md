# Harness Template
# AK Cognitive OS
# TEMPLATE — copy this to harnesses/{your-harness}.md

---

## Harness: [name]

**What this tests:** [persona or skill being validated]
**Pass condition:** [what must be true for the harness to pass]
**Fail condition:** [what constitutes a failure]

---

## Preconditions

Before running this harness:
- [ ] [precondition 1]
- [ ] [precondition 2]

---

## Input Fixture

The test input to provide to the persona/skill:

```
[paste the exact input prompt or context to use]
```

---

## Expected Output Contract

The output must satisfy ALL of:

### Envelope checks
- [ ] `run_id` present and matches `{agent}-*` pattern
- [ ] `agent` field matches expected persona/skill name
- [ ] `status` is one of: PASS | FAIL | BLOCKED
- [ ] `timestamp_utc` is valid ISO-8601
- [ ] `summary` is a single sentence
- [ ] `failures[]` is present (may be empty if PASS)
- [ ] `warnings[]` is present (may be empty)
- [ ] `artifacts_written[]` is present (may be empty)
- [ ] `next_action` is a single sentence

### Extra fields checks
- [ ] [extra field 1] is present
- [ ] [extra field 2] is present

### Business logic checks
- [ ] [specific expected behaviour 1]
- [ ] [specific expected behaviour 2]

---

## BLOCKED Scenario

If required inputs are missing, the persona must:
- [ ] Return `status: BLOCKED`
- [ ] List exact missing items in `failures[]`
- [ ] Not produce partial output

---

## Running This Harness

1. Open the persona using its slash command.
2. Provide the Input Fixture above as the activation prompt.
3. Check output against the Expected Output Contract above.
4. Record result: PASS / FAIL / PARTIAL.

---

## Result Record

```
harness: [name]
run_date: YYYY-MM-DD
result: PASS | FAIL | PARTIAL
failures: []
notes: ""
```
