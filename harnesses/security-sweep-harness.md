# Harness: security-sweep
# AK Cognitive OS

**What this tests:** The `/security-sweep` skill evaluates all 8 security questions and produces a sign-off or block.
**Pass condition:** All 8 questions checked, signoff true, status PASS. If a vulnerability found: signoff false, status FAIL.
**Fail condition:** Fewer than 8 questions checked, signoff true when a vulnerability exists, or missing task_results.

---

## Preconditions

Before running this harness:
- [ ] `tasks/todo.md` exists with task IDs to sweep
- [ ] Architecture notes or task descriptions available
- [ ] `tasks/risk-register.md` exists
- [ ] `channel.md` exists

---

## Input Fixture (Clean — expect PASS)

```
session_id: S-TEST-01
sprint_id: SP-TEST-01
task_ids: [TASK-001]

TASK-001: Add assignee dropdown — reads /api/team, writes PATCH /api/tasks/{id}
Architecture notes:
  - /api/team returns only team members from the authenticated user's organisation (RLS enforced)
  - PATCH /api/tasks/{id} validates task ownership before updating (server-side)
  - No PII beyond user display name in the response
  - All requests require a valid Supabase session token
  - assignee_id validated server-side against auth.users — not trusted from client
```

Expected: status PASS, signoff true, all 8 questions checked, no blocked_reasons.

---

## Input Fixture (Vulnerable — expect FAIL)

```
session_id: S-TEST-01
sprint_id: SP-TEST-01
task_ids: [TASK-002]

TASK-002: Assignee lookup endpoint
Architecture notes:
  - GET /api/users returns ALL users in the database (no org scoping)
  - The client passes assignee_id directly; server trusts it without validation
```

Expected: status FAIL, signoff false, blocked_reasons includes auth model and client-trusted ID violations.

---

## Expected Output Contract

### Envelope checks
- [ ] `run_id` present, matches `security-sweep-*` pattern
- [ ] `agent` = "security-sweep"
- [ ] `status` is PASS | FAIL | BLOCKED
- [ ] `timestamp_utc` is valid ISO-8601
- [ ] `summary` is a single sentence
- [ ] `failures[]` is present
- [ ] `warnings[]` is present
- [ ] `artifacts_written[]` includes channel.md
- [ ] `next_action` is a single sentence

### Extra fields checks
- [ ] `security_questions_checked` = 8
- [ ] `task_results` is present and non-empty
- [ ] `signoff` is true | false
- [ ] `blocked_reasons` is present (empty if PASS)

### Business logic checks
- [ ] Clean fixture → signoff = true, blocked_reasons = []
- [ ] Vulnerable fixture → signoff = false, blocked_reasons lists specific violations
- [ ] All 8 questions are explicitly addressed in task_results

---

## BLOCKED Scenario

```
session_id: (missing)
sprint_id: (missing)
task_ids: (missing)
```

Expected:
- [ ] `status: BLOCKED`
- [ ] `failures[]` includes missing inputs
- [ ] `signoff` not present or false

---

## Running This Harness

1. Open security-sweep using `/security-sweep`.
2. Run the Clean fixture — verify PASS and signoff true.
3. Run the Vulnerable fixture — verify FAIL and correct blocked_reasons.
4. Run the BLOCKED Scenario.
5. Record result below.

---

## Result Record

```
harness: security-sweep
run_date: YYYY-MM-DD
result: PASS | FAIL | PARTIAL
failures: []
notes: ""
```
