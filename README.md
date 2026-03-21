# AK Cognitive OS — Agentic AI Software Company Framework

A portable, file-based multi-persona development framework for building software with AI agents.
Clone it, fill in your project context, and your AI team is ready to work.

Status: **v1.0** — Fully published. All personas, skills, schemas, guides, and project template complete.

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

See `QUICKSTART.md` for the full 15-minute setup guide.

### Quick steps

1. Clone this repo
2. Copy `project-template/` contents to your project
3. Copy persona and skill `claude-command.md` files to `~/.claude/commands/`
4. Fill in `CLAUDE.md` placeholders with your project context
5. Open Claude from your project root: `cd [your-project] && claude`
6. Run `/session-open` and start building

---

## Folder Structure

```
AK-Cognitive-OS/
├── README.md
├── QUICKSTART.md                      ← Start here
│
├── guides/
│   ├── 01-elements-reference.md       ← What every element is and how they connect
│   ├── 02-session-flow.md             ← Opening, running, and closing sessions
│   ├── 03-review-modes.md             ← SOLO_CLAUDE vs COMBINED vs SOLO_CODEX
│   ├── 04-first-sprint.md             ← Full first sprint walkthrough
│   └── 05-adding-personas.md         ← Extending the framework with new roles
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
├── skills/                            ← 15 workflow skills (session lifecycle, sprint, QA, audit)
│   ├── _template/
│   ├── session-open/
│   ├── session-close/
│   ├── sprint-packager/
│   ├── review-packet/
│   ├── codex-intake-check/
│   ├── audit-log/
│   ├── lessons-extractor/
│   ├── framework-delta-log/
│   ├── regression-guard/
│   ├── security-sweep/
│   ├── handoff-validator/
│   ├── qa-run/
│   ├── check-channel/
│   ├── codex-creator/
│   └── codex-delta-verify/
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
├── framework/
│   ├── dual-stack-architecture.md     ← Full Claude + Codex architecture spec
│   ├── interop/                       ← interop contract, combined-mode runbook, failover policy
│   ├── codex-core/                    ← reviewer/creator contracts, intake spec, runbooks, validator
│   ├── governance/                    ← metrics tracker, weekly delta review
│   └── templates/                    ← sprint summary, sprint review, audit entry, task, next-action
│
└── project-template/                  ← Copy this to start a new project
    ├── CLAUDE.md
    ├── channel.md
    ├── framework-improvements.md
    ├── tasks/                         ← todo, ba-logic, ux-specs, lessons, next-action, risk-register
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

## About the Author

**AK** is a product manager and entrepreneur building AI-powered software products
without a traditional engineering background. His approach: use AI agents as the
engineering team, and focus personal energy on product vision, business logic, and
user experience.

Current projects:
- **akcoach** — AI fitness coaching web app (production)
- **machinepersonhood.com** — AI agent staffing agency (in design)

AK built the workflow that became this framework while shipping akcoach solo
using Claude Code + Codex as a dual-stack AI engineering team.

---

## License

MIT
