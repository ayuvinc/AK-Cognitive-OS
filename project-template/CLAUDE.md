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

## Planning Artifacts (docs/)

| Doc | Status | Required Before |
|-----|--------|-----------------|
| docs/problem-definition.md | [draft/confirmed] | Any build work |
| docs/scope-brief.md | [draft/confirmed] | Any build work |
| docs/hld.md | [draft/confirmed] | Multi-feature sprint |
| docs/lld/<feature>.md | [draft/confirmed] | Feature implementation |
| docs/assumptions.md | [maintained] | Ongoing |
| docs/decision-log.md | [maintained] | Ongoing |
| docs/release-truth.md | [draft/confirmed] | Demo or release |
| docs/traceability-matrix.md | [maintained] | Task derivation |

All planning docs are conversation-derived. See guides/11-conversation-first-planning.md.

---

## Workflow

```
Discovery → Problem/Scope docs → HLD → LLD → Tasks → Build → QA → Release

[OWNER] → gives requirements
BA      → discovery conversation → confirms problem-definition.md + scope-brief.md
UI/UX   → user flow + wireframe + interaction rules (ux-specs.md)
Architect → reads BA + UX outputs → drafts hld.md → [OWNER] approval
Architect → creates lld/<feature>.md for each feature → derives tasks to todo.md (PENDING)
Architect → creates feature branches
QA      → adds acceptance criteria to each PENDING task
Junior Dev → IN_PROGRESS → builds to spec → READY_FOR_QA
CI      → lint + build + tests (must pass)
Architect → code review → approve or return to Junior Dev
UI/UX   → reviews built UI against wireframe
QA      → QA_APPROVED or QA_REJECTED
Architect → archive → merge to main → present to [OWNER] → write next-action.md
```

End of session: `tasks/todo.md` and `tasks/ba-logic.md` empty.

---

## SESSION STATE

Session state lives in `tasks/todo.md`. All personas read it there. `/session-open` transitions CLOSED→OPEN. `/session-close` transitions OPEN→CLOSED. See `schemas/state-machine.md` for the full contract.

---

## Hooks (Automated Enforcement)

The following hooks are configured in `.claude/settings.json` and run automatically by the Claude Code harness. These are MECHANICAL checks — Claude does not need to manually re-check what hooks already enforce.

**PreToolCall hooks** (run before Write/Edit/Bash):

| Hook | Enforces |
|---|---|
| `guard-session-state.sh` | Blocks unauthorized writes to SESSION STATE in tasks/todo.md |
| `guard-persona-boundaries.sh` | Enforces persona CAN/CANNOT file-path restrictions |
| `guard-git-push.sh` | Blocks git push to main unless Architect with QA_APPROVED |

**PostToolCall hooks** (run after tool calls):

| Hook | Enforces |
|---|---|
| `auto-audit-log.sh` | Auto-appends audit entries after skill execution |
| `validate-envelope.sh` | Warns if skill output is missing required envelope fields |

**UserPromptSubmit hooks** (run on each user prompt):

| Hook | Enforces |
|---|---|
| `auto-persona-detect.sh` | Reads next-action.md and hints which persona to activate |

**Stop hooks** (run when session ends):

| Hook | Enforces |
|---|---|
| `session-integrity-check.sh` | Warns if session is still OPEN when exiting |

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
| No confirmed problem-definition.md or scope-brief.md | Mandatory |
| Feature work without corresponding LLD | Mandatory |
| Release packaging without release-truth.md | Mandatory |

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
- [ ] Task traces to scope item + HLD section + LLD file (traceability-matrix.md)
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
| Scope/priority change | Any persona → [OWNER] |

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

- [ ] Read SESSION STATE in tasks/todo.md — run /session-open to transition CLOSED→OPEN
- [ ] Read Role Card (`.claude/commands/<role>.md`), state it aloud
- [ ] Read `tasks/next-action.md` — confirm expected persona
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
