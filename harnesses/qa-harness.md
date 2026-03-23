# Harness: qa
# AK Cognitive OS

**What this tests:** The `/qa` persona produces valid acceptance criteria with required envelope and extra fields.
**Pass condition:** All envelope fields present, acceptance_criteria_map non-empty with binary criteria, status PASS.
**Fail condition:** Missing envelope field, vague/non-binary criteria accepted, or criteria_gaps not reported when tasks have no criteria.

---

## Preconditions

Before running this harness:
- [ ] `tasks/todo.md` exists with at least one PENDING task
- [ ] `channel.md` exists (may be empty)

---

## Input Fixture

```
session_id: S-TEST-01
sprint_id: SP-TEST-01
task_ids: [TASK-001, TASK-002]

TASK-001: Add assignee dropdown to task detail page
TASK-002: Send email notification when a task is assigned

Context: Pre-build QA pass. Junior Dev has not started yet.
Criteria must be binary (can be tested true/false).
```

---

## Expected Output Contract

### Envelope checks
- [ ] `run_id` present, matches `qa-*` pattern
- [ ] `agent` = "qa"
- [ ] `status` is PASS | FAIL | BLOCKED
- [ ] `timestamp_utc` is valid ISO-8601
- [ ] `summary` is a single sentence
- [ ] `failures[]` is present
- [ ] `warnings[]` is present
- [ ] `artifacts_written[]` is present and includes tasks/todo.md
- [ ] `next_action` is a single sentence

### Extra fields checks
- [ ] `acceptance_criteria_map` is present and non-empty
- [ ] Each entry in `acceptance_criteria_map` has `task_id` and `criteria[]`
- [ ] Each criterion has `id` (e.g. AC-001) and `criterion` (testable statement)
- [ ] `criteria_gaps` is present (empty list is valid if all tasks have criteria)

### Business logic checks
- [ ] All criteria are binary statements (can be unambiguously true or false)
- [ ] No vague criterion accepted (e.g. "works correctly" → must be FAIL with CRITERIA_NOT_TESTABLE)
- [ ] Email notification criteria specifies the trigger condition and recipient
- [ ] Dropdown criteria specifies exact states that must be verifiable

---

## BLOCKED Scenario

Provide this input to test BLOCKED behaviour:

```
session_id: (missing)
sprint_id: (missing)
task_ids: (missing)
```

Expected:
- [ ] `status: BLOCKED`
- [ ] `failures[]` includes missing inputs
- [ ] No `acceptance_criteria_map` produced

---

## Vague Criteria Scenario

Provide this input to test rejection of vague criteria:

```
session_id: S-TEST-01
sprint_id: SP-TEST-01
task_ids: [TASK-001]
Proposed criterion: "The dropdown works correctly on all devices"
```

Expected:
- [ ] `status: FAIL`
- [ ] `failures[]` includes `CRITERIA_NOT_TESTABLE` for the vague criterion

---

## Running This Harness

1. Open the QA persona using `/qa`.
2. Provide the Input Fixture above.
3. Check output against the Expected Output Contract.
4. Run the BLOCKED Scenario.
5. Run the Vague Criteria Scenario.
6. Record result below.

---

## Result Record

```
harness: qa
run_date: YYYY-MM-DD
result: PASS | FAIL | PARTIAL
failures: []
notes: ""
```
