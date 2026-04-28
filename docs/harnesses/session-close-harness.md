# Harness: session-close
# AK Cognitive OS

**What this tests:** The `/session-close` skill produces valid output, writes next-action.md, and appends SESSION_CLOSED to the audit log.
**Pass condition:** Envelope valid, next_action.md updated, SESSION_CLOSED logged in [AUDIT_LOG_PATH].
**Fail condition:** Missing SESSION_CLOSED entry, next-action.md not updated, envelope fields missing.

---

## Preconditions

Before running this harness:
- [ ] A session is open (SESSION STATE = OPEN in channel.md or todo.md)
- [ ] At least one task has been completed this session
- [ ] [AUDIT_LOG_PATH] exists with SESSION_OPENED entry for this session
- [ ] `tasks/next-action.md` is writable

---

## Input Fixture

```
Session: S-TEST-01
Sprint: TST-001
All tasks complete. Session ready to close.
Next session owner: architect
Next session objective: Add dashboard feature.
```

---

## Expected Output Contract

### Envelope checks
- [ ] `run_id` present, matches `session-close-*` pattern
- [ ] `agent` = "session-close"
- [ ] `status` is PASS | FAIL | BLOCKED
- [ ] `timestamp_utc` valid ISO-8601
- [ ] `summary` is a single sentence
- [ ] `failures[]` present
- [ ] `warnings[]` present
- [ ] `artifacts_written[]` includes `tasks/next-action.md` and [AUDIT_LOG_PATH]
- [ ] `next_action` present

### Business logic checks
- [ ] `tasks/next-action.md` updated with next session owner and objective
- [ ] [AUDIT_LOG_PATH] has new entry with `event_type: SESSION_CLOSED`
- [ ] SESSION_CLOSED entry has `run_id` matching the session-close run_id
- [ ] SESSION_CLOSED entry has `origin` field set

---

## BLOCKED Scenario (open tasks)

Provide input with tasks still in progress:

```
Session: S-TEST-01
Sprint: TST-001
Tasks: T-001 = IN_PROGRESS (not complete)
```

Expected:
- [ ] `status: BLOCKED`
- [ ] `failures[]` includes "open tasks: T-001"
- [ ] SESSION_CLOSED is NOT written to [AUDIT_LOG_PATH]
- [ ] SESSION_CLOSE_ATTEMPT entry is written instead

---

## Running This Harness

1. Set up preconditions above.
2. Run `/session-close` with the Input Fixture.
3. Check output envelope.
4. Verify `tasks/next-action.md` was updated.
5. Verify [AUDIT_LOG_PATH] has SESSION_CLOSED entry.
6. Run the BLOCKED scenario — verify SESSION_CLOSE_ATTEMPT logged.
7. Record result below.

---

## Result Record

```
harness: session-close
run_date: YYYY-MM-DD
result: PASS | FAIL | PARTIAL
next_action_written: yes | no
session_closed_logged: yes | no
blocked_scenario: PASS | FAIL
notes: ""
```
