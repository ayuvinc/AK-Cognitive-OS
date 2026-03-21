# AK Cognitive OS — Agentic AI Software Company Framework

A portable, file-based multi-persona development framework for building software with AI agents.
Clone it, fill in your project context, and your AI team is ready to work.

Status: **DRAFT** — Session 1 complete. Session 2 required before publishable.
See Session 1 done criteria in `guides/01-elements-reference.md`.

---

## What This Is

A complete operating system for running a software project using AI personas as a team.
Each persona has a defined role, clear boundaries, and a slash command to activate it.
All handoffs happen through files — no direct terminal communication required.

Both Claude and Codex are supported with full role parity. The framework runs in three modes:
COMBINED (default), SOLO_CLAUDE, and SOLO_CODEX.

---

## The Team

Personas and skills are defined in `personas/` and `skills/` — see directory listing for the full set.

**Core personas:**
| Command | Persona | Job |
|---|---|---|
| `/architect` | Architect | System design, task definition, constraints |
| `/ba` | Business Analyst | Requirements, business logic, edge cases |
| `/ux` | UX Designer | UX specs, interaction constraints, mobile |
| `/junior-dev` | Junior Developer | Implementation, exact scope only |
| `/qa` | QA Engineer | Acceptance criteria, quality gate |
| `/researcher` | Researcher | Sourced research briefs (5 sub-personas) |
| `/compliance` | Compliance Reviewer | S0/S1/S2 compliance gate |

---

## How to Use

### 1. Clone this repo

```bash
git clone https://github.com/ayuvinc/AK-Cognitive-OS.git my-project
cd my-project
```

### 2. Fill in your project context

Edit `project-template/CLAUDE.md` — replace every `[PLACEHOLDER]` with your project details:
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

Claude will read your CLAUDE.md, activate the Architect persona, and run a standup.
Follow the workflow from there.

### 4. Handoff between personas

Each session ends with `tasks/next-action.md` updated by the Architect.
The next session owner and objective are written there.

---

## Folder Structure

```
AK-Cognitive-OS/
├── README.md
├── QUICKSTART.md                      (Session 2)
│
├── guides/
│   ├── 01-elements-reference.md       ← What every element is and how they connect
│   └── [02–05 coming in Session 2]
│
├── personas/
│   ├── _template/                     ← Copy to create a new persona
│   ├── architect/                     ← claude-command.md + codex-prompt.md + schema.md
│   ├── ba/
│   ├── ux/
│   ├── junior-dev/
│   ├── qa/
│   ├── researcher/                    ← + 5 sub-personas (legal, business, policy, news, technical)
│   └── compliance/                    ← + 4 sub-personas + 4 jurisdiction docs
│
├── skills/                            (Session 2)
│
├── schemas/
│   ├── output-envelope.md             ← Universal 8-field contract
│   ├── audit-log-schema.md            ← Audit entry format + exhaustive event type list
│   ├── persona-schema.md              ← Required structure for any persona
│   ├── skill-schema.md                ← Required structure for any skill
│   └── finding-schema.md             ← S0/S1/S2 finding format
│
├── harnesses/
│   ├── _template/                     ← Copy to create a new harness
│   ├── architect-harness.md
│   ├── compliance-harness.md
│   ├── session-close-harness.md
│   └── audit-chain-harness.md
│
├── framework/                         (Session 2)
│   ├── dual-stack-architecture.md
│   ├── interop/
│   ├── codex-core/
│   ├── governance/
│   └── templates/
│
└── project-template/                  (Session 2)
    ├── CLAUDE.md
    ├── tasks/
    └── releases/
```

---

## The Workflow

```
AK gives requirements
  → BA confirms business logic         (tasks/ba-logic.md)
  → UX designs the experience          (tasks/ux-specs.md)
  → Architect plans + writes tasks     (tasks/todo.md)
  → QA adds acceptance criteria        (tasks/todo.md)
  → Junior Dev builds                  (code + tests)
  → Sprint packager + intake check     (review packet for Codex)
  → Codex reviews                      (COMBINED mode)
  → QA validates                       (QA_APPROVED gate)
  → Architect + UX review
  → Session close + audit log
```

Compliance persona can intercept at any stage. S0 = hard stop, nothing ships.
Researcher persona answers questions ad-hoc at any stage.

---

## Execution Modes

| Mode | When | Who |
|---|---|---|
| COMBINED (default) | Standard features, bug fixes, refactors | Claude + Codex |
| SOLO_CLAUDE | Codex unavailable, hotfix, simple task | Claude only |
| SOLO_CODEX | Claude unavailable (degraded) | Codex only |

See `framework/dual-stack-architecture.md` for full mode specification.

---

## Persona Boundaries

Every persona has explicit **CAN / CANNOT** rules. When a request falls outside those rules,
the persona emits a **BOUNDARY_FLAG** and stops — it does not comply or refuse silently.

---

## Compliance Gate

The compliance persona uses three severity tiers:
- **S0** — Hard block. Nothing ships until resolved.
- **S1** — AK decision required. Fix before launch or explicitly accept risk.
- **S2** — Advisory. Log and defer.

---

## Origin

Built and battle-tested on a production fitness coaching platform.
Distilled into this framework for reuse across any software project.

---

## License

MIT
