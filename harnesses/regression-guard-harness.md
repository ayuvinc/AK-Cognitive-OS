# Harness: regression-guard
# AK Cognitive OS

**What this tests:** The `/regression-guard` skill runs all 5 checks (tests, build, lint, :any policy, env-in-component policy) and reports legacy_label GREEN only when all pass.
**Pass condition:** All 5 checks run, legacy_label GREEN when all pass, BLOCKED on policy violations.
**Fail condition:** Fewer than 5 checks run, GREEN reported with failures, or policy violations not caught.

---

## Preconditions

Before running this harness:
- [ ] A project codebase is available (or describe check results in the fixture)
- [ ] `tasks/todo.md` exists
- [ ] `channel.md` exists

---

## Input Fixture (All passing — expect GREEN)

```
session_id: S-TEST-01
sprint_id: SP-TEST-01

Test results: 14 pass, 0 fail
Build result: exit 0, no TypeScript errors
Lint result: 0 errors, 0 warnings
:any usage in source: none found
Env vars in components: none found
```

Expected: status PASS, legacy_label GREEN, all command_results and policy_results populated.

---

## Input Fixture (Policy violation — expect BLOCKED)

```
session_id: S-TEST-01
sprint_id: SP-TEST-01

Test results: 14 pass, 0 fail
Build result: exit 0
Lint result: 0 errors
:any usage: found in components/AssigneeDropdown.tsx:42
Env vars in components: none found
```

Expected: status BLOCKED, legacy_label BLOCKED, policy_results includes the :any violation with file:line.

---

## Expected Output Contract

### Envelope checks
- [ ] `run_id` present, matches `regression-guard-*` pattern
- [ ] `agent` = "regression-guard"
- [ ] `status` is PASS | FAIL | BLOCKED
- [ ] `timestamp_utc` is valid ISO-8601
- [ ] `summary` is a single sentence
- [ ] `failures[]` is present
- [ ] `warnings[]` is present
- [ ] `artifacts_written[]` includes channel.md and regression artifact
- [ ] `next_action` is a single sentence

### Extra fields checks
- [ ] `command_results` is present and contains entries for test, build, lint
- [ ] `policy_results` is present and contains entries for :any and env-in-component checks
- [ ] `legacy_label` is GREEN | BLOCKED

### Business logic checks
- [ ] All-passing fixture → legacy_label = GREEN
- [ ] :any violation fixture → legacy_label = BLOCKED, policy_results includes file:line
- [ ] GREEN only when ALL 5 checks pass with zero violations

---

## BLOCKED Scenario

```
session_id: (missing)
sprint_id: (missing)
```

Expected:
- [ ] `status: BLOCKED`
- [ ] `failures[]` includes missing inputs
- [ ] No `legacy_label` produced

---

## Running This Harness

1. Open regression-guard using `/regression-guard`.
2. Run the all-passing fixture — verify GREEN.
3. Run the policy violation fixture — verify BLOCKED with correct file:line.
4. Run the BLOCKED Scenario.
5. Record result below.

---

## Result Record

```
harness: regression-guard
run_date: YYYY-MM-DD
result: PASS | FAIL | PARTIAL
failures: []
notes: ""
```
