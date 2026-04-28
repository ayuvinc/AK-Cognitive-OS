# Harness: session-lifecycle
# AK Cognitive OS

**What this tests:** The full CLOSED→OPEN→CLOSED state machine lifecycle across `/session-open` and `/session-close`.
**Pass condition:** State transitions correctly in both directions; invalid transitions are blocked.
**Fail condition:** State doesn't change, wrong state accepted, or missing BLOCKED on invalid transition.

---

## Preconditions

Before running this harness:
- [ ] `tasks/todo.md` exists with SESSION STATE block
- [ ] `tasks/next-action.md` exists with NEXT_PERSONA, TASK, CONTEXT fields
- [ ] `tasks/lessons.md` exists (may be empty)
- [ ] `tasks/risk-register.md` exists (may be empty)
- [ ] `channel.md` exists (may be empty)

---

## Test Case 1: CLOSED → OPEN (Happy Path)

**Setup:**
```
tasks/todo.md SESSION STATE:
  Status: CLOSED
  Active task: none
  Active persona: none
  Last updated: —
```

**Action:** Run `/session-open` with `session_id: S-TEST-LC-01`

**Expected:**
- [ ] `status: PASS`
- [ ] `tasks/todo.md` SESSION STATE Status is now `OPEN`
- [ ] `standup_lines` has exactly 3 entries
- [ ] `artifacts_written[]` includes `channel.md` and `tasks/todo.md`

---

## Test Case 2: OPEN → CLOSED (Happy Path)

**Setup:** Immediately after Test Case 1 (Status = OPEN).

**Action:** Run `/session-close` with `session_id: S-TEST-LC-01, sprint_id: sprint-test`

**Expected:**
- [ ] `status: PASS`
- [ ] `tasks/todo.md` SESSION STATE Status is now `CLOSED`
- [ ] `closure_checklist` is present and non-empty
- [ ] `artifacts_written[]` includes `tasks/next-action.md` and `tasks/todo.md`

---

## Test Case 3: OPEN → OPEN (Invalid — Double Open)

**Setup:**
```
tasks/todo.md SESSION STATE:
  Status: OPEN
  Active task: TASK-99
  Active persona: Architect
  Last updated: Test
```

**Action:** Run `/session-open` with `session_id: S-TEST-LC-02`

**Expected:**
- [ ] `status: BLOCKED`
- [ ] `failures[]` includes `SESSION_STATE_VIOLATION`
- [ ] `tasks/todo.md` SESSION STATE Status remains `OPEN` (unchanged)
- [ ] No `standup_lines` produced

---

## Test Case 4: CLOSED → CLOSED (Invalid — Double Close)

**Setup:**
```
tasks/todo.md SESSION STATE:
  Status: CLOSED
  Active task: none
  Active persona: none
  Last updated: —
```

**Action:** Run `/session-close` with `session_id: S-TEST-LC-03, sprint_id: sprint-test`

**Expected:**
- [ ] `status: BLOCKED`
- [ ] `failures[]` includes `SESSION_STATE_VIOLATION`
- [ ] `tasks/todo.md` SESSION STATE Status remains `CLOSED` (unchanged)

---

## Test Case 5: Missing SESSION STATE Block

**Setup:** `tasks/todo.md` exists but has no `## SESSION STATE` section.

**Action:** Run `/session-open` with `session_id: S-TEST-LC-04`

**Expected:**
- [ ] `status: BLOCKED`
- [ ] `failures[]` includes `MISSING_SESSION_STATE`

---

## Test Case 6: Full Round Trip

**Setup:** Start with Status = CLOSED.

**Actions:**
1. `/session-open` → verify Status = OPEN
2. `/session-close` → verify Status = CLOSED
3. `/session-open` → verify Status = OPEN again

**Expected:**
- [ ] All three transitions succeed with `status: PASS`
- [ ] State toggles correctly each time

---

## Running This Harness

1. Reset `tasks/todo.md` SESSION STATE to `Status: CLOSED`.
2. Run Test Cases 1-6 in order.
3. Check output against expected results for each case.
4. Record result below.

---

## Result Record

```
harness: session-lifecycle
run_date: YYYY-MM-DD
result: PASS | FAIL | PARTIAL
test_cases:
  tc1_open: PASS | FAIL
  tc2_close: PASS | FAIL
  tc3_double_open: PASS | FAIL
  tc4_double_close: PASS | FAIL
  tc5_missing_state: PASS | FAIL
  tc6_round_trip: PASS | FAIL
failures: []
notes: ""
```
