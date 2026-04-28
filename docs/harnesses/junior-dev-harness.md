# Harness: junior-dev
# AK Cognitive OS

**What this tests:** The `/junior-dev` persona implements only assigned tasks, updates task state, and reports changed files.
**Pass condition:** All envelope fields present, completed_task_ids matches input task_ids, ready_for_review true, changed_files non-empty.
**Fail condition:** Implements tasks not in task_ids, missing changed_files on PASS, or ready_for_review false with no failures listed.

---

## Preconditions

Before running this harness:
- [ ] `tasks/todo.md` exists with PENDING tasks including acceptance criteria (QA must have run first)
- [ ] `tasks/ux-specs.md` exists with relevant specs
- [ ] `channel.md` exists (may be empty)
- [ ] No open BOUNDARY_FLAG items in channel.md

---

## Input Fixture

```
session_id: S-TEST-01
sprint_id: SP-TEST-01
task_ids: [TASK-001]

TASK-001: Add assignee dropdown to task detail page
Acceptance criteria:
  AC-001: Dropdown renders on task detail page with a list of team members fetched from /api/team
  AC-002: Selecting a member updates the task's assignee_id via PATCH /api/tasks/{id}
  AC-003: Unassigned state shows "No assignee" placeholder text, not an empty field
  AC-004: Dropdown is usable on 375px viewport (full width, no overflow)

UX spec: See tasks/ux-specs.md — assignee dropdown section.
```

---

## Expected Output Contract

### Envelope checks
- [ ] `run_id` present, matches `junior-dev-*` pattern
- [ ] `agent` = "junior-dev"
- [ ] `status` is PASS | FAIL | BLOCKED
- [ ] `timestamp_utc` is valid ISO-8601
- [ ] `summary` is a single sentence
- [ ] `failures[]` is present
- [ ] `warnings[]` is present
- [ ] `artifacts_written[]` is present (includes code files written)
- [ ] `next_action` is a single sentence

### Extra fields checks
- [ ] `completed_task_ids` is present and equals `[TASK-001]`
- [ ] `ready_for_review` is `true`
- [ ] `changed_files` is present and non-empty

### Business logic checks
- [ ] Only TASK-001 implemented — no unrequested scope added
- [ ] `changed_files` does not include task files (Junior Dev does not edit todo.md directly)
- [ ] No TypeScript `any` types in changed files (policy rule)
- [ ] No environment variables accessed in component files (policy rule)

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
- [ ] No `completed_task_ids` or `changed_files` produced

---

## Running This Harness

1. Open the Junior Dev using `/junior-dev`.
2. Provide the Input Fixture above.
3. Check output against the Expected Output Contract.
4. Verify no scope creep — only TASK-001 files changed.
5. Run the BLOCKED Scenario.
6. Record result below.

---

## Result Record

```
harness: junior-dev
run_date: YYYY-MM-DD
result: PASS | FAIL | PARTIAL
failures: []
notes: ""
```
