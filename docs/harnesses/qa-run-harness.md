# Harness: qa-run
# AK Cognitive OS

**What this tests:** The `/qa-run` skill runs post-build QA checks against each acceptance criterion and correctly reports pass/fail per criterion.
**Pass condition:** All envelope fields present, criterion_results covers all AC items, status PASS only when all criteria pass.
**Fail condition:** Missing criteria results, PASS returned with failing criteria, or mobile check skipped when UI was changed.

---

## Preconditions

Before running this harness:
- [ ] Sprint has been built (Junior Dev PASS)
- [ ] Acceptance criteria map exists from QA pre-build run
- [ ] `tasks/todo.md` exists
- [ ] `channel.md` exists
- [ ] Sprint summary with test/build/lint evidence is available

---

## Input Fixture (All passing — expect PASS)

```
session_id: S-TEST-01
sprint_id: SP-TEST-01
acceptance_criteria_map:
  TASK-001:
    - AC-001: Dropdown renders on task detail page with team members from /api/team
    - AC-002: Selecting member calls PATCH /api/tasks/{id} and updates assignee_id
    - AC-003: Unassigned state shows "No assignee" placeholder
    - AC-004: Dropdown usable at 375px (full width, no overflow)

Test results: 14 pass, 0 fail
Build: clean
Lint: 0 errors
Evidence for AC-001: verified in Playwright test task-detail.spec.ts:22
Evidence for AC-002: verified in API test assignee.spec.ts:18
Evidence for AC-003: verified in unit test AssigneeDropdown.test.tsx:44
Evidence for AC-004: verified in mobile test 375px.spec.ts:11
```

Expected: status PASS, all criterion_results PASS with evidence, mobile_issues empty.

---

## Input Fixture (Failing criterion — expect FAIL)

```
session_id: S-TEST-01
sprint_id: SP-TEST-01
acceptance_criteria_map:
  TASK-001:
    - AC-001: Dropdown renders on task detail page — PASS
    - AC-002: Selecting member updates assignee_id — PASS
    - AC-003: Unassigned state shows "No assignee" — FAIL (shows empty string)
    - AC-004: Usable at 375px — PASS
```

Expected: status FAIL, AC-003 marked FAIL in criterion_results, failures[] lists AC-003.

---

## Expected Output Contract

### Envelope checks
- [ ] `run_id` present, matches `qa-run-*` pattern
- [ ] `agent` = "qa-run"
- [ ] `status` is PASS | FAIL | BLOCKED
- [ ] `timestamp_utc` is valid ISO-8601
- [ ] `summary` is a single sentence
- [ ] `failures[]` is present
- [ ] `warnings[]` is present
- [ ] `artifacts_written[]` includes channel.md
- [ ] `next_action` is a single sentence

### Extra fields checks
- [ ] `criterion_results` is present and covers all criteria from input
- [ ] Each entry has `criterion_id`, `result` (PASS|FAIL), and `evidence`
- [ ] `mobile_issues` is present (empty list valid if no mobile failures)

### Business logic checks
- [ ] All-passing fixture → status PASS, all criterion_results PASS
- [ ] Failing criterion fixture → status FAIL, failing AC listed in failures[]
- [ ] Mobile criterion (AC-004) checked — mobile_issues populated if failed
- [ ] No evidence = pending → status FAIL, not PASS

---

## BLOCKED Scenario

```
session_id: (missing)
sprint_id: (missing)
acceptance_criteria_map: (missing)
```

Expected:
- [ ] `status: BLOCKED`
- [ ] `failures[]` includes `MISSING_INPUT: acceptance_criteria_map`

---

## Running This Harness

1. Open qa-run using `/qa-run`.
2. Run the all-passing fixture — verify status PASS.
3. Run the failing criterion fixture — verify status FAIL with correct AC in failures[].
4. Run the BLOCKED Scenario.
5. Record result below.

---

## Result Record

```
harness: qa-run
run_date: YYYY-MM-DD
result: PASS | FAIL | PARTIAL
failures: []
notes: ""
```
