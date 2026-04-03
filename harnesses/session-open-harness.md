# Harness: session-open
# AK Cognitive OS

**What this tests:** The `/session-open` skill generates a valid 3-line standup from session context.
**Pass condition:** All envelope fields present, standup_lines has exactly 3 entries, status PASS.
**Fail condition:** Missing envelope field, standup_lines empty or fewer than 3, or PASS returned when SESSION STATE is not CLOSED.

---

## Preconditions

Before running this harness:
- [ ] `tasks/todo.md` exists with SESSION STATE Status = CLOSED
- [ ] `tasks/next-action.md` exists with NEXT_PERSONA, TASK, CONTEXT fields
- [ ] `tasks/lessons.md` exists (may be empty)
- [ ] `tasks/risk-register.md` exists (may be empty)
- [ ] `channel.md` exists (may be empty)

---

## Input Fixture

```
session_id: S-TEST-01

tasks/todo.md SESSION STATE:
  Status: CLOSED
  Active task: none
  Active persona: none
  Last updated: Session 1 close

tasks/next-action.md:
  NEXT_PERSONA: Architect
  TASK: Design task assignment feature
  CONTEXT: BA logic confirmed. UX specs pending.

tasks/risk-register.md:
  R-001: RLS misconfiguration | Open

tasks/lessons.md (last 3 entries):
  [2024-01-15] — Architect: Always confirm email confirmation requirement before designing auth.
  [2024-01-15] — Junior Dev: Test RLS with non-service-role client.
  [2024-01-15] — QA: Auth redirect criteria must specify exact URL.
```

---

## Expected Output Contract

### Envelope checks
- [ ] `run_id` present, matches `session-open-*` pattern
- [ ] `agent` = "session-open"
- [ ] `status` = PASS
- [ ] `timestamp_utc` is valid ISO-8601
- [ ] `summary` is a single sentence
- [ ] `failures[]` is empty
- [ ] `warnings[]` is present
- [ ] `artifacts_written[]` includes channel.md and tasks/todo.md
- [ ] `next_action` is a single sentence

### Extra fields checks
- [ ] `standup_lines` is present
- [ ] `standup_lines` has exactly 3 entries
- [ ] Line 1 starts with "Done:"
- [ ] Line 2 starts with "Next:"
- [ ] Line 3 starts with "Blockers:"

### Business logic checks
- [ ] Line 2 (Next) references the TASK from next-action.md
- [ ] Line 3 (Blockers) references R-001 from risk-register.md (it is OPEN)
- [ ] Output includes open task count and PENDING task IDs

---

## BLOCKED Scenario

Provide this input to test BLOCKED when session is already open:

```
session_id: S-TEST-01

tasks/todo.md SESSION STATE:
  Status: OPEN
```

Expected:
- [ ] `status: BLOCKED`
- [ ] `failures[]` includes `SESSION_STATE_VIOLATION`
- [ ] No `standup_lines` produced
- [ ] SESSION STATE remains unchanged

---

## Running This Harness

1. Open session-open using `/session-open`.
2. Provide the Input Fixture above.
3. Check output against the Expected Output Contract.
4. Run the BLOCKED Scenario with a CLOSED session.
5. Record result below.

---

## Result Record

```
harness: session-open
run_date: YYYY-MM-DD
result: PASS | FAIL | PARTIAL
failures: []
notes: ""
```
