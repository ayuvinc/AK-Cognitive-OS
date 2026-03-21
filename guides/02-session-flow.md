# Guide 02 — Session Flow

## What is a Session?

A session is one focused work period with a defined goal (e.g. "build authentication",
"wire up the dashboard"). Sessions have a fixed opening ritual, active work, and a
closing ritual. The framework tracks state across sessions so any Claude instance
can pick up exactly where the last one left off.

---

## Session Open

Run `/session-open` with:
- `session_id` — sequential number (1, 2, 3…)
- `sprint_id` — which sprint this session belongs to
- `persona` — which role is active

What session-open does:
1. Reads `CLAUDE.md` → verifies SESSION STATE is CLOSED
2. Opens the session (sets status: OPEN, active_persona, timestamp)
3. Reads `tasks/next-action.md` → confirms expected persona matches
4. Reads last 10 `tasks/lessons.md` entries
5. Reports: done / next / blockers standup
6. Updates SESSION STATE in `tasks/todo.md`
7. Writes audit entry

If SESSION STATE is already OPEN: session-open emits BLOCKED. Close the previous
session before opening a new one.

---

## During the Session

Each persona has a specific scope:

| Persona | Reads | Writes |
|---|---|---|
| BA | channel.md, requirements | tasks/ba-logic.md |
| UI/UX | ba-logic.md | tasks/ux-specs.md |
| Architect | ba-logic.md, ux-specs.md | tasks/todo.md, architecture notes |
| Junior Dev | tasks/todo.md, ux-specs.md | code files |
| QA | tasks/todo.md, ux-specs.md | acceptance criteria in todo.md |
| Researcher | question input | research brief (channel.md or artifact) |
| Compliance | code/design artifacts | compliance findings (channel.md) |

The Architect owns `tasks/todo.md` and is the only persona that merges to `main`.

---

## Task Lifecycle

```
PENDING → IN_PROGRESS → READY_FOR_QA → QA_APPROVED → ARCHIVED
                    ↑                        ↓
               QA_REJECTED ←————————————————
```

- PENDING: Architect has written the task, QA has added acceptance criteria
- IN_PROGRESS: Junior Dev is working on it
- READY_FOR_QA: Junior Dev done, pushed to branch
- QA_APPROVED: QA passes — Architect can merge
- QA_REJECTED: QA found issues — returns to Junior Dev
- ARCHIVED: Logged to `releases/session-N.md`, deleted from todo.md

---

## Session Close

Run `/session-close` at the end of every session. What it does:

1. Verifies no IN_PROGRESS tasks remain
2. Archives completed tasks to `releases/session-N.md`
3. Runs `/lessons-extractor` to capture session learnings
4. Writes `tasks/next-action.md` for the next session
5. Clears `tasks/ba-logic.md` and stale channel.md messages
6. Sets SESSION STATE to CLOSED
7. Writes audit entry

Never exit a session without running `/session-close`. If you must stop mid-session,
set the active task status to IN_PROGRESS and note the blocker in `tasks/next-action.md`.

---

## Sprint vs Session

A **sprint** is a collection of sessions with a shared goal (e.g. Sprint 1 = Sessions 1–3).
A **session** is one work block. Sessions belong to sprints.

Sprint close runs `/sprint-packager` + `/review-packet` → assembles the Codex review packet
if applicable, or produces the sprint summary for audit only.

---

## Audit Trail

Every `/session-open` and `/session-close` writes one append-only entry to `[AUDIT_LOG_PATH]`.
Never delete or edit audit entries. The audit log is the ground truth of what happened.
