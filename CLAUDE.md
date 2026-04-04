# CLAUDE.md — AK Cognitive OS
# Multi-persona AI development framework for Claude Code
# Stack: Markdown, Python (validators), Bash (scripts), Claude Code (runtime)

---

## First Thing on Session Start

Ask: "I've read the CLAUDE.md. What role am I playing — Architect, Junior Developer, Business Analyst, UI/UX Designer, or QA?"

Read your **Role Card** (`.claude/commands/<role>.md`) and state it aloud before touching any task.

---

## Commands

```bash
bash scripts/validate-framework.sh   # Validate framework structure and integrity
python3 validators/runner.py         # Run all schema/envelope validators
bash scripts/bootstrap-project.sh    # Bootstrap a new project from the template
bash scripts/remediate-project.sh    # Fix common project structure issues
```

---

## The Team

**AK — Product Manager (human, the boss).** Owns requirements, priorities, final approvals.

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
Status:         CLOSED
Active task:    none
Active persona: none
Blocking issue: none
Last updated:   2026-04-02T16:20:19Z — Session 3 closeout by Codex
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

AK Cognitive OS is a multi-persona AI development framework for Claude Code. It provides 27 personas, 15 skills, enforcement hooks, and structured schemas that enable AI agents to deliver software in a structured, auditable way. Core user journeys:

1. **Bootstrap a project** — Run the bootstrap script to scaffold a new project with all personas, skills, hooks, and planning docs pre-wired.
2. **Run a development session** — Open a session, activate the correct persona via next-action.md, execute tasks through the full workflow (BA -> UX -> Architect -> Dev -> QA), and close the session with audit trail.
3. **Contribute to the framework** — Add or modify personas, skills, schemas, and hooks following the required file structure conventions.

---

## Tech Stack

- **Runtime:** Claude Code (CLI agent)
- **Configuration:** Markdown (personas, skills, schemas, guides)
- **Validators:** Python 3 (schema and envelope validation)
- **Scripts:** Bash (bootstrap, remediation, hooks, framework validation)
- **Testing:** Framework validation suite (`scripts/validate-framework.sh`, `validators/runner.py`)
- **No database, no auth, no CSS** — this is a config-file-driven framework

---

## Architecture Rules

- All personas must include: `claude-command.md`, `codex-prompt.md`, `schema.md`, `SKILL.md`
- All skills must include: `claude-command.md`, `SKILL.md`
- Output envelope (10-field) is mandatory on all skill/persona output
- BOUNDARY_FLAG is mandatory — every persona must declare CAN/CANNOT boundaries
- Hooks enforce mechanical checks (session state, persona boundaries, git push, audit log, envelope validation)
- Never bypass hooks — they are the enforcement layer, not advisory

---

## Environment Variables

```
# None — AK Cognitive OS is entirely config-file driven.
# No environment variables required.
```

---

## Domain Types

- **Personas** — `.claude/commands/<persona>/` — Role definitions with boundaries, prompts, and schemas
- **Skills** — `.claude/commands/<skill>/` — Reusable capabilities invoked by personas
- **Schemas** — `schemas/` — Structural contracts (state machine, envelope, output format)
- **Harnesses** — `project-template/.claude/settings.json` — Hook wiring and permission grants
- **Planning Docs** — `docs/` — Problem definition, scope, HLD, LLD, assumptions, decision log

---

## Session Roadmap

| Session | Focus | Status |
|---|---|---|
| 1 | Foundation — personas, skills, schemas | Complete |
| 2 | Planning docs, conversation-first workflow | Complete |
| 3 | Hooks, enforcement, validation suite | Complete |
| 4 | Claude Code native integration — hooks, settings, bootstrap | In Progress |

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
