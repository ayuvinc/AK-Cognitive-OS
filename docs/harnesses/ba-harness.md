# Harness: ba
# AK Cognitive OS

**What this tests:** The `/ba` persona produces valid business logic with required envelope and extra fields.
**Pass condition:** All envelope fields present, requirements non-empty, assumptions and out_of_scope present, status PASS.
**Fail condition:** Missing envelope field, empty requirements on PASS, or status not in PASS|FAIL|BLOCKED.

---

## Preconditions

Before running this harness:
- [ ] A project with a valid `CLAUDE.md` is available (or use the fixture below)
- [ ] `tasks/ba-logic.md` exists (may be empty)
- [ ] `channel.md` exists (may be empty)

---

## Input Fixture

```
session_id: S-TEST-01
objective: Add task assignment feature — users can assign tasks to team members
feature_scope: Task assignment UI, assignment API endpoint, email notification on assignment

Context: Taskflow is a B2B SaaS. Tasks currently have no assignee. We want to add
an assignee field that links to a user in the team. Assignments should trigger
an email notification to the assignee.
```

---

## Expected Output Contract

### Envelope checks
- [ ] `run_id` present, matches `ba-*` pattern
- [ ] `agent` = "ba"
- [ ] `status` is PASS | FAIL | BLOCKED
- [ ] `timestamp_utc` is valid ISO-8601
- [ ] `summary` is a single sentence
- [ ] `failures[]` is present
- [ ] `warnings[]` is present
- [ ] `artifacts_written[]` is present and includes tasks/ba-logic.md
- [ ] `next_action` is a single sentence

### Extra fields checks
- [ ] `requirements` is present and non-empty
- [ ] `assumptions` is present (may be empty)
- [ ] `out_of_scope` is present (may be empty)

### Business logic checks
- [ ] Requirements cover the assignee field data model
- [ ] Requirements specify what happens when an assignee is removed
- [ ] Email notification trigger is captured as a requirement or assumption
- [ ] `out_of_scope` clarifies what is NOT being built (e.g. bulk assignment, reassignment history)

---

## BLOCKED Scenario

Provide this input to test BLOCKED behaviour:

```
session_id: (missing)
objective: (missing)
feature_scope: (missing)
```

Expected:
- [ ] `status: BLOCKED`
- [ ] `failures[]` includes `MISSING_INPUT: session_id`, `MISSING_INPUT: objective`, `MISSING_INPUT: feature_scope`
- [ ] No `requirements` produced

---

## Running This Harness

1. Open the BA using `/ba`.
2. Provide the Input Fixture above.
3. Check output against the Expected Output Contract.
4. Run the BLOCKED Scenario and verify BLOCKED behaviour.
5. Record result below.

---

## Result Record

```
harness: ba
run_date: YYYY-MM-DD
result: PASS | FAIL | PARTIAL
failures: []
notes: ""
```
