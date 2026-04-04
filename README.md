# AK Cognitive OS

A portable, file-based multi-persona development framework for building software with Claude Code and Codex.

Status: **v2.1.0** — conversation-first planning, artifact-driven execution, native Claude Code integration, enforcement hooks, bootstrap/remediation flows, and framework validation.

---

## What This Is

AK Cognitive OS is a structured delivery framework for running a software project with AI agents as explicit roles.

- personas define responsibilities and boundaries
- skills define repeatable workflow actions
- planning artifacts provide traceable delivery context
- hooks add runtime guardrails for Claude Code sessions
- validators check repository integrity and framework contracts

Both Claude and Codex are supported. The framework runs in three modes: `COMBINED` (default), `SOLO_CLAUDE`, and `SOLO_CODEX`.

---

## The Team

Personas and skills are defined in `personas/` and `skills/`. Every artifact belongs to one of five classes — see [`docs/role-taxonomy.md`](docs/role-taxonomy.md) for the full classification table and routing logic.

**Delivery personas** — own named roles in the delivery chain:
| Command | Persona | Job |
|---|---|---|
| `/architect` | Architect | System design, task definition, constraints |
| `/ba` | Business Analyst | Requirements, business logic, edge cases |
| `/ux` | UX Designer | Interaction behavior, states, breakpoints, accessibility |
| `/designer` | Designer | Visual direction, brand, component look-and-feel |
| `/junior-dev` | Junior Developer | Implementation, exact scope only |
| `/qa` | QA Engineer | Acceptance criteria design, quality intent gate |

**Router personas** — default entry points that delegate to specialists:
| Command | Delegates to |
|---|---|
| `/researcher` | researcher-business, researcher-legal, researcher-news, researcher-policy, researcher-technical |
| `/compliance` | compliance-data-privacy, compliance-data-security, compliance-phi-handler, compliance-pii-handler |

**Skills** — mechanical (session lifecycle, gating, CI checks) and advisory/meta (framework health). Full list: [`docs/role-taxonomy.md`](docs/role-taxonomy.md).

---

## Start Here

New? Start with these four files in order:

| Step | File | What it does |
|---|---|---|
| 1 | `guides/00-project-intake.md` | Answer questions about your product before touching code |
| 2 | `DECISION_MATRIX.md` | Choose your stack based on intake answers |
| 3 | `QUICKSTART.md` | Full setup walkthrough with scripts |
| 4 | `project-template/CLAUDE_START.md` | First-run sequence once Claude is open |

Not sure about a term? See `glossary.md`. Stuck? See `guides/07-common-failures.md` or `FAQ.md`.

---

## Quick Start

See `QUICKSTART.md` for the full setup guide.

> **Note:** All scripts require bash. Run them with `bash scripts/<name>.sh`, not `sh` or `zsh`.

```bash
# 1. Clone the framework
git clone https://github.com/ayuvinc/AK-Cognitive-OS.git ~/AK-Cognitive-OS

# 2. Install all personas + skills into Claude
~/AK-Cognitive-OS/scripts/install-claude-commands.sh --backup

# 3. Bootstrap your project with v2.1.0 native Claude Code files
~/AK-Cognitive-OS/scripts/bootstrap-project.sh ~/[your-project]

# 4. Validate the framework repo itself
cd ~/AK-Cognitive-OS
bash scripts/validate-framework.sh
```

Then move into your target project, review `CLAUDE.md`, and open Claude Code.

## What v2.1.0 Adds

- native Claude Code settings at repo root and in the project template
- enforcement hooks for session state, persona boundaries, push protection, and envelope validation
- bootstrap and remediation support for `.claude/`, `.claudeignore`, `memory/`, and hook scripts
- packaging metadata for `npx ak-cognitive-os`
- expanded framework validation from 9 checks to 14 checks

---

## Repository Structure

```
AK-Cognitive-OS/
├── README.md
├── QUICKSTART.md                      ← Full setup walkthrough
├── glossary.md                        ← 35 terms in plain language
├── FAQ.md                             ← 22 common questions answered
├── DECISION_MATRIX.md                 ← Stack selection tables
├── RELEASE_NOTES.md                   ← Changelog
├── .claude/                           ← Repo-level Claude Code settings + bundled commands
├── .claude-plugin/                    ← Plugin manifest
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
│   ├── 10-plugins.md                  ← Adding domain-specific personas and skills
│   ├── 11-conversation-first-planning.md ← Discovery conversation → planning artifacts
│   └── 12-mid-build-recovery.md       ← Retrofit fundamentals into active projects
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
│   ├── bootstrap-project.sh           ← Bootstrap a new project with native Claude Code assets
│   ├── remediate-project.sh           ← Retrofit an active project to the current framework standard
│   ├── install-claude-commands.sh     ← Install personas + skills to ~/.claude/commands/
│   ├── cli.sh                         ← `ak-cognitive-os` / `ak-cogos` entry point
│   ├── hooks/                         ← Claude Code enforcement hooks
│   └── validate-framework.sh          ← Framework validation suite
│
├── validators/                        ← Python ground-truth verification suite
│   ├── base.py                        ← Shared utilities (metadata parser, task parser)
│   ├── runner.py                      ← CLI entry point
│   ├── planning_docs.py               ← Verify planning docs exist + are honest
│   ├── task_traceability.py           ← Tasks trace to design artifacts
│   ├── release_truth.py              ← "Real" claims backed by actual code
│   └── session_state.py              ← Session consistency across files
│
└── project-template/                  ← Bootstrap source for new projects
    ├── CLAUDE.md
    ├── CLAUDE_START.md                ← First-run sequence for Claude
    ├── CODEX_START.md                 ← Paste protocol + startup checklist for Codex
    ├── .claude/
    ├── .claudeignore
    ├── memory/
    ├── channel.md
    ├── framework-improvements.md
    ├── docs/                          ← Planning artifact templates
    │   ├── problem-definition.md      ← Who, what, why
    │   ├── scope-brief.md             ← Must-have, out-of-scope, delivery target
    │   ├── hld.md                     ← Architecture and data flow
    │   ├── assumptions.md             ← Confirmed vs inferred vs unresolved
    │   ├── decision-log.md            ← Decisions with provenance
    │   ├── release-truth.md           ← Honest feature status
    │   ├── traceability-matrix.md     ← Task → design artifact mapping
    │   ├── current-state.md           ← Mid-build recovery snapshot
    │   └── lld/                       ← Low-level designs per feature
    │       ├── README.md
    │       └── feature-template.md
    ├── tasks/                         ← todo, ba-logic, ux-specs, lessons, next-action, risk-register
    └── releases/
```

---

## Planning Artifacts

Every non-trivial project starts with structured conversation and planning docs before code.

```
Discovery Conversation → Problem/Scope docs → HLD → LLD → Tasks → Build → QA → Release
```

| Doc | Purpose | Required Before |
|-----|---------|-----------------|
| `docs/problem-definition.md` | Who, what, why | Any build work |
| `docs/scope-brief.md` | Must-have, out-of-scope, delivery target | Any build work |
| `docs/hld.md` | Architecture, data flow, integrations | Multi-feature sprint |
| `docs/lld/<feature>.md` | Implementation details per feature | Feature implementation |
| `docs/assumptions.md` | What's confirmed vs inferred vs unresolved | Ongoing |
| `docs/decision-log.md` | Decisions with provenance | Ongoing |
| `docs/release-truth.md` | Honest feature status: real/mocked/partial/deferred | Demo or release |
| `docs/traceability-matrix.md` | Task → scope → HLD → LLD → tests mapping | Task derivation |

Two entry paths: **greenfield** (new projects, Guide 11) and **recovery** (mid-build projects, Guide 12).

## Enforcement Layer

`v2.1.0` adds runtime guardrails through Claude Code hooks:

- `guard-session-state.sh`
- `guard-persona-boundaries.sh`
- `guard-git-push.sh`
- `auto-audit-log.sh`
- `auto-persona-detect.sh`
- `session-integrity-check.sh`
- `validate-envelope.sh`

These are intended to reduce drift between documented process and actual session behavior.

---

## The Workflow

```
Discovery conversation (8 questions)
  → Confirm problem-definition.md + scope-brief.md
  → HLD conversation → confirm hld.md
  → LLD for first features
  → Derive tasks into todo.md
  → BA confirms business logic         (tasks/ba-logic.md)
  → UX designs the experience          (tasks/ux-specs.md)
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

## Contributing and Policy

- Contribution guide: [CONTRIBUTING.md](CONTRIBUTING.md)
- Code of conduct: [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md)
- Security policy: [SECURITY.md](SECURITY.md)
- License: [LICENSE](LICENSE)

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
