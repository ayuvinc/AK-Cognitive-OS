# AK Cognitive OS — Agentic AI Software Company Framework

A portable, file-based multi-persona development framework for building software with AI agents.
Clone it, fill in your project context, and your AI team is ready to work.

Status: **v1.1** — Ambiguity reduction pack complete. Full docs, examples, scripts, glossary, and FAQ included.

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

## Start Here in 10 Minutes

New? Start with these four files in order:

| Step | File | What it does |
|---|---|---|
| 1 | `guides/00-project-intake.md` | Answer questions about your product before touching code |
| 2 | `DECISION_MATRIX.md` | Choose your stack based on intake answers |
| 3 | `QUICKSTART.md` | Full setup walkthrough with scripts |
| 4 | `project-template/CLAUDE_START.md` | First-run sequence once Claude is open |

Not sure about a term? See `glossary.md`. Stuck? See `guides/07-common-failures.md` or `FAQ.md`.

---

## How to Use

See `QUICKSTART.md` for the full setup guide.

### Quick steps (or use the scripts)

> **Note:** All scripts require bash. Run them with `bash scripts/<name>.sh`, not `sh` or `zsh`.

```bash
# 1. Clone the framework
git clone https://github.com/ayuvinc/AK-Cognitive-OS.git ~/AK-Cognitive-OS

# 2. Install all personas + skills into Claude
~/AK-Cognitive-OS/scripts/install-claude-commands.sh --backup

# 3. Bootstrap your project
~/AK-Cognitive-OS/scripts/bootstrap-project.sh ~/[your-project]

# 4. Start a session (from inside your project)
cd ~/[your-project]
~/AK-Cognitive-OS/scripts/new-session.sh 1 1 architect
```

Then fill in `CLAUDE.md` and open Claude.

---

## Folder Structure

```
AK-Cognitive-OS/
├── README.md
├── QUICKSTART.md                      ← Full setup walkthrough
├── glossary.md                        ← 35 terms in plain language
├── FAQ.md                             ← 22 common questions answered
├── DECISION_MATRIX.md                 ← Stack selection tables
├── RELEASE_NOTES.md                   ← Changelog
│
├── guides/
│   ├── 00-project-intake.md           ← Answer before writing code
│   ├── 01-elements-reference.md       ← What every element is and how they connect
│   ├── 02-session-flow.md             ← Opening, running, and closing sessions
│   ├── 03-review-modes.md             ← SOLO_CLAUDE vs COMBINED vs SOLO_CODEX
│   ├── 04-first-sprint.md             ← Full first sprint walkthrough
│   ├── 05-adding-personas.md          ← Extending the framework with new roles
│   ├── 06-tooling-baseline.md         ← Recommended tools for every stack layer
│   ├── 07-common-failures.md          ← Top 15 failure cases with fixes
│   ├── 08-mode-selection-cheatsheet.md ← Mode decision table + anti-patterns
│   ├── 09-rag-playbook.md             ← RAG ingestion, chunking, retrieval, eval
│   └── 10-plugins.md                  ← Adding domain-specific personas and skills
│
├── examples/
│   ├── saas-minimal/                  ← Worked example: B2B SaaS (auth + CRUD)
│   └── rag-minimal/                   ← Worked example: document Q&A with RAG
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
│   ├── output-envelope.md             ← Universal 10-field contract
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
├── scripts/
│   ├── bootstrap-project.sh           ← Copy project-template to a new project
│   ├── install-claude-commands.sh     ← Install all personas + skills to ~/.claude/commands/
│   ├── new-session.sh                 ← Pre-flight checks + ready-to-paste session open
│   └── validate-framework.sh          ← CI lint: BOUNDARY_FLAG, envelope fields, schema headers
│
└── project-template/                  ← Copy this to start a new project
    ├── CLAUDE.md
    ├── CLAUDE_START.md                ← First-run sequence for Claude
    ├── CODEX_START.md                 ← Paste protocol + startup checklist for Codex
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
- **machinepersonhood.com** — AI agent staffing agency (in design)

AK built the workflow that became this framework while shipping a production web app solo
using Claude Code + Codex as a dual-stack AI engineering team.

---

## License

MIT
