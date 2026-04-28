# CLAUDE.md -- Taskflow
# B2B task management SaaS -- teams track and assign work
# Stack: Next.js 14, TypeScript, Tailwind CSS v4, Supabase, Vercel

---

## First Thing on Session Start

Ask: "I've read the CLAUDE.md. What role am I playing -- Architect, Junior
Developer, Business Analyst, UI/UX Designer, or QA?"

Read your Role Card (`.claude/commands/<role>.md`) and state it aloud before
touching any task.

---

## Commands

```bash
npm run dev        # Local dev server (http://localhost:3000)
npm run build      # Production build (catches TS/compile errors)
npm run lint       # ESLint + TypeScript checks
npm test           # Vitest test suite
```

---

## The Team

**[OWNER_NAME] -- Product Manager (human, the boss).** Owns requirements,
priorities, and final approvals.

---

## Workflow

```
[OWNER] --> gives requirements
BA      --> confirms business logic (ba-logic.md)
UI/UX   --> user flow + wireframe + interaction rules (ux-specs.md)
Architect --> reads BA + UX outputs --> designs --> [OWNER] approval
Architect --> writes tasks to todo.md (PENDING) + creates feature branches
QA      --> adds acceptance criteria to each PENDING task
Junior Dev --> IN_PROGRESS --> builds to spec --> READY_FOR_QA
CI      --> lint + build + tests (must pass)
Architect --> code review --> approve or return to Junior Dev
UI/UX   --> reviews built UI against wireframe
QA      --> QA_APPROVED or QA_REJECTED
Architect --> archive --> merge to main --> present to [OWNER] --> write next-action.md
```

End of session: `tasks/todo.md` and `tasks/ba-logic.md` empty.

---

## SESSION STATE

Architect updates at every session open and close. Every persona reads first.

```
## SESSION STATE
Status:         CLOSED
Active task:    none
Active persona: none
Blocking issue: none
Last updated:   Session 0
```

---

## Plan Mode -- Mandatory Triggers

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

- [ ] Code reviewed by Architect -- no `any`, correct patterns, no security issues
- [ ] Build passing, tests passing
- [ ] Access control verified -- unauthenticated users cannot access protected data
- [ ] UI reviewed by UI/UX against wireframe
- [ ] Mobile layout checked at 375px
- [ ] Security model verified -- auth enforced, data boundaries correct, no secrets in code
- [ ] Observability verified -- errors logged, key actions traceable, no silent failures
- [ ] Edge cases tested: empty state, error state, unauthenticated access
- [ ] Task logged to `releases/session-N.md` before deletion
- [ ] No open BOUNDARY_FLAG entries

---

## Escalation Path

| Situation | Who handles it |
|---|---|
| Code bug | QA --> Junior Dev (QA_REJECTED) |
| Built UI doesn't match wireframe | UI/UX --> Junior Dev (REVISION_NEEDED) |
| Architectural flaw | QA --> Architect (written escalation) |
| Business logic question | Architect --> BA (ba-logic.md) |
| UX question | Architect --> UI/UX (ux-specs.md) |
| Scope/priority change | Any persona --> [OWNER] |

---

## Git Branching

- Branch name: `feature/TASK-XXX-short-description`
- Junior Dev creates branch before writing any code
- Commits to branch only, never to `main`
- Architect merges after QA_APPROVED; deletes branch after merge

---

## Project Overview

Taskflow is a B2B SaaS that lets small teams create projects, assign tasks, and
track work status in a shared dashboard. Core user journeys:

1. User signs up / signs in and lands on the dashboard
2. User creates a project and adds tasks with assignees
3. Assignee updates task status (todo / in_progress / done)

---

## Tech Stack

- Framework: Next.js 14, App Router
- Language: TypeScript (strict mode)
- Styling: Tailwind CSS v4
- Database + Auth: Supabase (email + password auth, PostgreSQL, Row Level Security)
- Deployment: Vercel
- Testing: Vitest + React Testing Library

---

## Architecture Rules

- App Router only -- no Pages Router
- Server Components by default; add `"use client"` only for interactivity
- All Supabase tables must have RLS enabled and policies defined
- No raw SQL outside `lib/db.ts`
- API routes live in `app/api/`
- Shared types live in `types/index.ts`
- No `any` type -- use `unknown` with type guards if needed
- Auth check runs in `middleware.ts` (or `proxy.ts` depending on Next.js version)

---

## Environment Variables

```
NEXT_PUBLIC_SUPABASE_URL=
NEXT_PUBLIC_SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=
```

Never commit `.env.local`.

---

## Domain Types

```typescript
// types/index.ts

type TaskStatus = "todo" | "in_progress" | "done";

interface Task {
  id: string;
  title: string;
  status: TaskStatus;
  assignee_id: string | null;
  project_id: string;
  created_at: string;
}

interface Project {
  id: string;
  name: string;
  owner_id: string;
  created_at: string;
}

// User comes from Supabase auth -- use supabase.auth.getUser()
// Do not duplicate user data outside the Supabase auth schema
```

---

## Session Roadmap

| Session | Focus | Status |
|---|---|---|
| 1 | Auth + layout -- Supabase auth, protected routes, app shell | Pending |
| 2 | Task CRUD -- create, list, update status, delete | Pending |
| 3 | Team invite + roles -- invite by email, role-based access | Pending |
| 4 | QA + deploy -- full QA pass, Vercel deploy, end-to-end verification | Pending |

---

## Session Start Checklist

- [ ] Read SESSION STATE above -- must be OPEN
- [ ] Read Role Card (`.claude/commands/<role>.md`), state it aloud
- [ ] Read `tasks/next-action.md` -- confirm expected persona
- [ ] Run standup (done / next / blockers)
- [ ] Read last 10 entries of `tasks/lessons.md`
- [ ] Resolve open BOUNDARY_FLAGs (Architect only)

---

## Audit Log

Path override for this project (set to your audit log file path):

```
audit_log: [AUDIT_LOG_PATH]
```

Agents resolve `[AUDIT_LOG_PATH]` from this CLAUDE.md field at runtime.
