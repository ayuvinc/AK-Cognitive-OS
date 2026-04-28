# Harness: ux
# AK Cognitive OS

**What this tests:** The `/ux` persona produces valid UX specs with required envelope and extra fields.
**Pass condition:** All envelope fields present, ux_requirements non-empty, mobile_375_checks present, status PASS.
**Fail condition:** Missing envelope field, empty ux_requirements on PASS, or no mobile spec for UI scope.

---

## Preconditions

Before running this harness:
- [ ] A project with a valid `CLAUDE.md` is available (or use the fixture below)
- [ ] `tasks/ux-specs.md` exists (may be empty)
- [ ] `tasks/ba-logic.md` exists with confirmed business logic

---

## Input Fixture

```
session_id: S-TEST-01
sprint_id: SP-TEST-01
ui_scope: Task assignment dropdown — select an assignee from a list of team members on the task detail page

Context: Taskflow B2B SaaS. Task detail page exists. We are adding an assignee
dropdown. Team members come from the Supabase users table. The dropdown must
work on mobile (375px). Unassigned state must be visually distinct.
```

---

## Expected Output Contract

### Envelope checks
- [ ] `run_id` present, matches `ux-*` pattern
- [ ] `agent` = "ux"
- [ ] `status` is PASS | FAIL | BLOCKED
- [ ] `timestamp_utc` is valid ISO-8601
- [ ] `summary` is a single sentence
- [ ] `failures[]` is present
- [ ] `warnings[]` is present
- [ ] `artifacts_written[]` is present and includes tasks/ux-specs.md
- [ ] `next_action` is a single sentence

### Extra fields checks
- [ ] `ux_requirements` is present and non-empty
- [ ] `mobile_375_checks` is present and non-empty (UI scope was specified)
- [ ] `accessibility_notes` is present (may be empty)

### Business logic checks
- [ ] Spec describes idle, open, and selected states of the dropdown
- [ ] Unassigned state is explicitly specified (not left to Junior Dev to decide)
- [ ] Mobile behaviour at 375px is explicitly described
- [ ] Loading state covered (while team members list fetches)

---

## BLOCKED Scenario

Provide this input to test BLOCKED behaviour:

```
session_id: (missing)
sprint_id: (missing)
ui_scope: (missing)
```

Expected:
- [ ] `status: BLOCKED`
- [ ] `failures[]` includes `MISSING_INPUT: session_id`, `MISSING_INPUT: sprint_id`, `MISSING_INPUT: ui_scope`
- [ ] No `ux_requirements` produced

---

## Running This Harness

1. Open the UX persona using `/ux`.
2. Provide the Input Fixture above.
3. Check output against the Expected Output Contract.
4. Run the BLOCKED Scenario and verify BLOCKED behaviour.
5. Record result below.

---

## Result Record

```
harness: ux
run_date: YYYY-MM-DD
result: PASS | FAIL | PARTIAL
failures: []
notes: ""
```
