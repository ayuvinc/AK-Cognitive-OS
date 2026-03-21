# Next Action

## Immediate Step

Open Session 1 -- Architect reviews TASK-001 through TASK-003 and confirms
design before Junior Dev starts any implementation. Architect must verify that
the task sequence is correct (TASK-001 --> TASK-002 --> TASK-003), that each
task's acceptance criteria are unambiguous, and that no architectural decisions
remain open before handing off to Junior Dev.

## Owner

Architect

## Inputs Required

- `CLAUDE.md` -- read domain types, architecture rules, and session roadmap
- `tasks/todo.md` -- 3 PENDING tasks for Session 1
- `tasks/ba-logic.md` -- currently empty; BA must run first to confirm
  business logic before Architect finalises task design

## Success Signal

Architect has confirmed the task sequence and written any architectural notes
directly into the relevant TASK entries in `tasks/todo.md`. Junior Dev has been
told they are unblocked and which task to start first.

## If Blocked

Run `/ba` first to confirm business logic before Architect proceeds with
architecture design. Specifically: BA should clarify whether email confirmation
is required at sign-up, and whether there is a single user role or multiple
roles needed in Session 1.
