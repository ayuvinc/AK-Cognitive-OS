# AK Cognitive OS — Agentic AI Software Company Framework

A portable, file-based multi-persona development framework for building software with AI agents. Clone it, fill in your project context, and your AI team is ready to work.

---

## What This Is

A complete operating system for running a software project using AI personas as a team. Each persona has a defined role, clear boundaries, and a slash command to activate it. All handoffs happen through files — no direct terminal communication required.

**The team:**
| Command | Persona | Job |
|---|---|---|
| `/ba` | Business Analyst | Requirements, domain logic, gap analysis |
| `/ux` | UI/UX Designer | Wireframes, user flows, interaction specs |
| `/architect` | Architect | System design, task definition, session close |
| `/junior-dev` | Junior Developer | Implementation, bug fixes, tests |
| `/qa` | QA Engineer | Test cases, acceptance criteria, quality gate |

---

## How to Use

### 1. Clone this repo
```bash
git clone https://github.com/[your-username]/ak-cognitive-os.git my-project
cd my-project
```

### 2. Fill in your project context
Edit `CLAUDE.md` — replace every `[PLACEHOLDER]` with your project details:
- Project name and description
- Tech stack
- Architecture rules
- Domain types
- Environment variables

### 3. Start a session
Open a Claude Code terminal in your project directory and type:
```
/architect
```

Claude will read your CLAUDE.md, activate the Architect persona, and run a standup. From there, follow the workflow.

### 4. Handoff between personas
Each session ends with `tasks/next-action.md` updated by the Architect. The COMMAND field tells you exactly what to paste to start the next terminal.

---

## File Structure

```
your-project/
├── CLAUDE.md                    ← Project context (fill this in)
├── .claude/
│   └── commands/                ← Persona skill files (do not edit)
│       ├── architect.md
│       ├── ba.md
│       ├── junior-dev.md
│       ├── qa.md
│       └── ux.md
├── tasks/
│   ├── todo.md                  ← Live task queue (max 100 lines)
│   ├── ba-logic.md              ← Business logic decisions (max 80 lines)
│   ├── ux-specs.md              ← UX specs and wireframes (max 150 lines)
│   ├── next-action.md           ← Session dispatch (Architect writes at close)
│   ├── lessons.md               ← Accumulated lessons
│   ├── risk-register.md         ← Permanent risk log
│   ├── roadmap.md               ← Future sessions (Architect only)
│   └── [ak-learning.md]         ← Optional: concepts taught to the principal
└── releases/
    ├── knowledge-transfer.md    ← Proven patterns, copy-paste ready
    └── session-N.md             ← One file per session milestone
```

---

## The Workflow

```
AK gives requirements
  → BA confirms business logic       (tasks/ba-logic.md)
  → UX designs the experience        (tasks/ux-specs.md)
  → Architect plans + writes tasks   (tasks/todo.md)
  → QA adds acceptance criteria      (tasks/todo.md, PENDING blocks)
  → Junior Dev builds                (sets IN_PROGRESS → READY_FOR_QA)
  → Architect + UX review
  → QA tests                         (sets QA_APPROVED or QA_REJECTED)
  → Architect archives + merges      (releases/ → main → next-action.md)
```

---

## Persona Boundaries

Every persona has explicit **You CAN / You CANNOT** rules. When a request falls outside those rules, the persona files a **BOUNDARY_FLAG** and stops — it does not comply or refuse silently. The flag routes to the correct persona automatically.

---

## Porting to a New Project

1. Copy `.claude/commands/` — unchanged, these are generic
2. Copy `tasks/` template files — clear the content, keep the format comments
3. Write a new `CLAUDE.md` for your project — use the template in this repo
4. Run `git init`, push to your new repo

The skill files never change. Only `CLAUDE.md` changes per project.

---

## Origin

Built and battle-tested on AKCoach (Sessions 1–10), a fitness coaching platform. Distilled into this framework for reuse across any software project.

---

## License

MIT
