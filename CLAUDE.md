# CLAUDE.md — [PROJECT_NAME]
# [One line: what this product does]
# Stack: [Framework], [Language], [DB], [Auth], [AI SDK if applicable]

---

## First Thing on Session Start

Ask: "I've read the CLAUDE.md. What role am I playing — Architect, Junior Developer, Business Analyst, UI/UX Designer, or QA?"

Read your **Role Card** (`.claude/commands/<role>.md`) and state it aloud before touching any task.

---

## Commands

```bash
# Replace with your project's actual commands
npm run dev        # Local dev server
npm run build      # Production build (catches TS/compile errors)
npm run lint       # Linter
npm run test       # Test suite
```

---

## The Team

**[OWNER_NAME] — Product Manager (human, the boss).** Owns requirements, priorities, final approvals.

---

## Workflow

```
AK → gives requirements
BA → confirms business logic (ba-logic.md)
UI/UX → user flow + wireframe + interaction rules (ux-specs.md)
Architect → reads BA + UX outputs → designs → AK approval
Architect → writes tasks to todo.md (PENDING) + creates feature branches
QA → adds acceptance criteria to each PENDING task
Junior Dev → IN_PROGRESS → builds to spec → READY_FOR_QA
CI → lint + build + tests (must pass)
Architect → code review → approve or return to Junior Dev
UI/UX → reviews built UI against wireframe
QA → QA_APPROVED or QA_REJECTED
Architect → archive → merge to main → present to AK → write next-action.md
```

End of session: `tasks/todo.md` and `tasks/ba-logic.md` empty.

---

## SESSION STATE

Architect updates at every session open and close. Every persona reads first.

```
## SESSION STATE
Status:         OPEN
Active task:    none
Active persona: none
Blocking issue:
Last updated:   Session 0
```

---

## Plan Mode — Mandatory Triggers

| Condition | Rule |
|---|---|
| Task touches more than 2 files | Mandatory |
| Task modifies types | Mandatory |
| New data model or schema change | Mandatory |
| Modifies shared services | Mandatory |
| No BA sign-off on business logic | Mandatory |
| Hotfix with uncertain scope | Mandatory |

---

## Definition of Done

- [ ] Code reviewed by Architect — no `any`, correct patterns, no security issues
- [ ] Build passing, tests passing
- [ ] Access control verified — unauthenticated users cannot access protected data
- [ ] UI reviewed by UI/UX against wireframe
- [ ] Mobile layout checked at 375px
- [ ] Security model verified — auth enforced, data boundaries correct, no secrets in code
- [ ] Observability verified — errors logged, key actions traceable, no silent failures
- [ ] Edge cases tested: empty state, error state, unauthenticated access
- [ ] Task logged to `releases/session-N.md` before deletion
- [ ] No open BOUNDARY_FLAG entries

---

## Escalation Path

| Situation | Who handles it |
|---|---|
| Code bug | QA → Junior Dev (QA_REJECTED) |
| Built UI doesn't match wireframe | UI/UX → Junior Dev (REVISION_NEEDED) |
| Architectural flaw | QA → Architect (written escalation) |
| Business logic question | Architect → BA (ba-logic.md) |
| UX question | Architect → UI/UX (ux-specs.md) |
| Scope/priority change | Any persona → AK |

---

## Git Branching

- Branch name: `feature/TASK-XXX-short-description`
- Junior Dev creates branch before writing any code
- Commits to branch only, never to `main`
- Architect merges after QA_APPROVED; deletes branch after merge

---

## Project Overview

> [Replace with: what this product does, who uses it, and what the two or three core user journeys are]

---

## Tech Stack

> [Replace with: framework, language, database, auth provider, AI SDK, testing tools, CSS approach]

---

## Architecture Rules

> [Replace with: server/client component rules, API conventions, DB access patterns, type safety rules, auth patterns]

---

## Environment Variables

```
# Replace with your project's actual env vars
# Never commit .env.local
```

---

## Domain Types

> [Replace with: your core data models and where they live]

---

## Session Roadmap

| Session | Focus | Status |
|---|---|---|
| 1 | Foundation — auth, types, CI/CD | Pending |
| 2 | [Next feature] | Pending |

---

## Session Start Checklist

- [ ] Read SESSION STATE in `tasks/todo.md` — must be OPEN
- [ ] Read Role Card (`.claude/commands/<role>.md`), state it aloud
- [ ] Read `tasks/next-action.md` — confirm expected persona
- [ ] Run standup (done / next / blockers)
- [ ] Read last 10 entries of `tasks/lessons.md`
- [ ] Resolve open BOUNDARY_FLAGs (Architect only)

---

## Anti-Sycophancy (Mandatory)

This OS operates under a standing Anti-Sycophancy Protocol in `ANTI-SYCOPHANCY.md`.
Required in every session:

- Treat user technical assertions as hypotheses, not confirmed facts
- Challenge before assisting on architecture, design, and code decisions
- Surface failure modes and alternatives without being asked
- Interrupt and name the pattern if 3+ exchanges show rising confidence
  with no counter-evidence surfaced

Full protocol: see `ANTI-SYCOPHANCY.md`
