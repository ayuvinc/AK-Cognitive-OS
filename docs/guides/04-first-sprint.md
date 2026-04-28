# Guide 04 — Running Your First Sprint

## Before You Start

1. Copy `project-template/` contents into your project root (or use `scripts/bootstrap-project.sh`)
2. Fill in all `[PLACEHOLDER]` fields in `CLAUDE.md`
3. Install persona and skill commands:
   - Copy persona `claude-command.md` files to `~/.claude/commands/<persona>.md`
   - Copy skill `claude-command.md` files to `~/.claude/commands/<skill>.md`
4. Set your `audit_log` path in `CLAUDE.md`
5. Open a terminal and launch Claude from your project root:
   `cd [your-project] && claude`

## Planning Before Building

Your first sprint should confirm the core planning artifacts. This doesn't mean "no code" — it means grounding the project before broad implementation.

**Recommended first sprint flow:**

```
Session 1: Discovery conversation → confirm problem-definition.md + scope-brief.md
Session 2: HLD conversation → confirm hld.md
Session 3: First feature LLD → docs/lld/<feature>.md → derive tasks → begin build
```

For simple projects or spikes, you can combine sessions 1-2 into a single session. The point is to have confirmed problem, scope, and architecture before writing significant code — not to create paperwork for its own sake.

See `guides/11-conversation-first-planning.md` for the 8-question discovery flow.

---

## Sprint 1 Walkthrough

### Step 1 — Open the session

```
/session-open
session_id: 1
sprint_id: 1
persona: architect
```

Architect reads `tasks/next-action.md` (empty on first run), confirms no blockers,
sets SESSION STATE to OPEN.

---

### Step 2 — BA defines business logic

Switch to BA persona:
```
/ba
```

BA reads your requirements (tell it what you're building), then writes confirmed
decisions to `tasks/ba-logic.md`.

---

### Step 3 — UI/UX designs the flow

Switch to UI/UX:
```
/ux
```

UI/UX reads `tasks/ba-logic.md` and writes wireframes + interaction rules to
`tasks/ux-specs.md`.

---

### Step 4 — Architect designs and writes tasks

Switch to Architect:
```
/architect
```

Architect reads BA + UX outputs, designs the solution, writes tasks to `tasks/todo.md`
with status PENDING. Each task has: ID, description, acceptance criteria slot.

---

### Step 5 — QA adds acceptance criteria

Switch to QA:
```
/qa
```

QA reads PENDING tasks in `tasks/todo.md` and adds specific, testable acceptance
criteria to each one. No task moves to IN_PROGRESS without QA sign-off.

---

### Step 6 — Junior Dev builds

Switch to Junior Dev:
```
/junior-dev
```

Junior Dev reads tasks, creates a feature branch, builds to spec, marks tasks
READY_FOR_QA when done.

---

### Step 7 — QA reviews

Switch to QA:
```
/qa
```

QA reviews the built code against acceptance criteria. Either:
- `QA_APPROVED` → Architect can merge
- `QA_REJECTED` → returns to Junior Dev with specific issues

---

### Step 8 — Architect merges and closes

Switch to Architect, merge the branch, then close the session:

```
/session-close
session_id: 1
sprint_id: 1
```

Session-close archives tasks, extracts lessons, writes next-action.md, and
sets SESSION STATE to CLOSED.

---

## Tips for First Sprint

- Confirm problem-definition.md and scope-brief.md before broad implementation
- Keep Sprint 1 scope small: aim for a single working user journey end-to-end
- Don't skip the BA step — it prevents rework
- Don't skip the QA step — acceptance criteria are the contract Junior Dev builds to
- The Architect is the decision-maker — all questions escalate there
- Write `tasks/next-action.md` carefully — it's what gets the next session started without re-explaining context
- Planning docs are conversation-derived — the AI must ask, summarize, confirm, then write

---

## What a Clean Sprint Looks Like

End of Sprint 1:
- `tasks/todo.md` — empty (all tasks archived)
- `tasks/ba-logic.md` — empty (cleared)
- `tasks/lessons.md` — N new entries
- `tasks/next-action.md` — written for Sprint 2
- `releases/session-1.md` — all completed tasks archived here
- Audit log — has open + close entries for each session
- `main` branch — has the working feature
- No open BOUNDARY_FLAGs anywhere
