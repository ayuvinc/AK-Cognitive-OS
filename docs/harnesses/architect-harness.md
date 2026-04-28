# Harness: architect
# AK Cognitive OS

**What this tests:** The `/architect` persona produces a valid task plan with required envelope and extra fields.
**Pass condition:** All envelope fields present, task_plan non-empty, architecture_constraints present, status PASS.
**Fail condition:** Missing envelope field, empty task_plan on PASS, or status not in PASS|FAIL|BLOCKED.

---

## Preconditions

Before running this harness:
- [ ] A project with a valid `CLAUDE.md` is available (or use the fixture below)
- [ ] `tasks/todo.md` exists (may be empty)
- [ ] `channel.md` exists (may be empty)

---

## Input Fixture

```
Session: S-TEST-01
Objective: Add user authentication — email/password login and logout.
Persona: architect

Context: This is a new web application. The stack is Next.js with TypeScript and Supabase for auth.
There is no existing auth implementation.
```

---

## Expected Output Contract

### Envelope checks
- [ ] `run_id` present, matches `architect-*` pattern
- [ ] `agent` = "architect"
- [ ] `status` is PASS | FAIL | BLOCKED
- [ ] `timestamp_utc` is valid ISO-8601
- [ ] `summary` is a single sentence
- [ ] `failures[]` is present
- [ ] `warnings[]` is present
- [ ] `artifacts_written[]` is present and non-empty (must include tasks/todo.md)
- [ ] `next_action` is a single sentence

### Extra fields checks
- [ ] `task_plan` is present and non-empty
- [ ] Each task in `task_plan` has `task_id` and `objective`
- [ ] `architecture_constraints` is present (may be empty if simple scope)
- [ ] `boundary_flags` is present (may be empty)

### Business logic checks
- [ ] Tasks have explicit dependencies where applicable
- [ ] Auth-related tasks include a security note
- [ ] `architecture_constraints` include auth patterns if auth is in scope

---

## BLOCKED Scenario

Provide this input to test BLOCKED behaviour:

```
Session: (missing)
Objective: (missing)
Persona: architect
```

Expected:
- [ ] `status: BLOCKED`
- [ ] `failures[]` includes `MISSING_INPUT: session_id` and `MISSING_INPUT: objective`
- [ ] No `task_plan` produced

---

## Running This Harness

1. Open the architect using `/architect`.
2. Provide the Input Fixture above.
3. Check output against the Expected Output Contract.
4. Run the BLOCKED Scenario and verify BLOCKED behaviour.
5. Record result below.

---

## Result Record

```
harness: architect
run_date: YYYY-MM-DD
result: PASS | FAIL | PARTIAL
failures: []
notes: ""
```
