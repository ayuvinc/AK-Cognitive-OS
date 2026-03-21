# QUICKSTART — AK Cognitive OS

Get a new project running with full Claude + Codex role parity in 15 minutes.

---

## What You're Setting Up

- 7 personas (Architect, BA, UI/UX, Junior Dev, QA, Researcher, Compliance)
- 15 skills (session lifecycle, sprint packaging, Codex handoff, security, QA, audit)
- Structured output contracts for every agent
- An audit trail that persists across sessions
- Optional Codex review integration

---

## Prerequisites

- Claude Code CLI installed (`claude` command available)
- A GitHub repo for your new project
- Your project runtime installed (Node.js, Python, etc. — framework is language-agnostic)

---

## Step 1 — Clone AK Cognitive OS

```bash
git clone https://github.com/ayuvinc/AK-Cognitive-OS.git ~/AK-Cognitive-OS
```

---

## Step 2 — Complete Project Intake

Before installing anything, answer the intake questionnaire:

```
open ~/AK-Cognitive-OS/guides/00-project-intake.md
```

Work through all 10 sections. The answers determine:
- Whether to activate the Compliance persona before architecture
- Which tooling stack to use (see `guides/06-tooling-baseline.md`)
- What to fill into `CLAUDE.md`

Keep your completed intake summary — you'll paste it into `CLAUDE.md` in Step 4.

---

## Step 3 — Install Personas and Skills

Use the install script (handles backup automatically with `--backup`):

```bash
~/AK-Cognitive-OS/scripts/install-claude-commands.sh --backup
```

Or manually:

```bash
mkdir -p ~/.claude/commands-backup
cp ~/.claude/commands/*.md ~/.claude/commands-backup/ 2>/dev/null || true

for dir in ~/AK-Cognitive-OS/personas/*/; do
  name=$(basename "$dir")
  [[ "$name" == "_template" ]] && continue
  cp "$dir/claude-command.md" ~/.claude/commands/${name}.md
done

for dir in ~/AK-Cognitive-OS/skills/*/; do
  name=$(basename "$dir")
  [[ "$name" == "_template" ]] && continue
  cp "$dir/claude-command.md" ~/.claude/commands/${name}.md
done
```

Verify:

```bash
ls ~/.claude/commands/
# Should include: architect.md, ba.md, ux.md, junior-dev.md, qa.md,
# researcher.md, compliance.md, session-open.md, session-close.md, ...
```

---

## Step 4 — Bootstrap Your Project

Use the bootstrap script (safe — skips existing files unless `--force`):

```bash
git clone [your-project-repo] ~/[your-project]
~/AK-Cognitive-OS/scripts/bootstrap-project.sh ~/[your-project]
```

Or manually:

```bash
cd ~/[your-project]
cp ~/AK-Cognitive-OS/project-template/CLAUDE.md .
cp ~/AK-Cognitive-OS/project-template/channel.md .
cp ~/AK-Cognitive-OS/project-template/framework-improvements.md .
mkdir -p tasks releases
cp ~/AK-Cognitive-OS/project-template/tasks/* tasks/
touch releases/audit-log.md
```

---

## Step 5 — Configure CLAUDE.md

Open `CLAUDE.md` and replace all placeholders:

| Placeholder | Replace with |
|---|---|
| `[PROJECT_NAME]` | Your product name |
| `[OWNER_NAME]` | Your name |
| Commands block | Your actual `npm run dev`, `npm test`, etc. |
| Project Overview | One paragraph: what it does, who uses it |
| Tech Stack | Your framework, DB, auth, AI SDK |
| Architecture Rules | Your server/client rules, API conventions |
| Environment Variables | Your `.env` keys (never the values) |
| Domain Types | Your core data models |
| Session Roadmap | Your planned sessions |

Set the audit log path in CLAUDE.md:

```
audit_log: releases/audit-log.md
```

---

## Step 6 — Open Your First Session

Use the new-session script for pre-flight checks:

```bash
cd ~/[your-project]
~/AK-Cognitive-OS/scripts/new-session.sh 1 1 architect
```

The script checks all required files exist and prints a ready-to-paste command block.
Then open Claude:

```bash
cd ~/[your-project] && claude
```

Paste the command block. Architect will read your CLAUDE.md, confirm no blockers, and set SESSION STATE to OPEN.

Read `project-template/CLAUDE_START.md` for the full first-run sequence and troubleshooting tips.

---

## Step 7 — Start Building

Tell the Architect what you're building in plain language. The framework handles
the rest — BA → UX → Architect → Junior Dev → QA → merge.

See `guides/04-first-sprint.md` for the full walkthrough.

---

## That's It

You now have:
- Full multi-persona team (Architect, BA, UX, Dev, QA)
- Researcher and Compliance gates available when needed
- Session lifecycle managed with audit trail
- Optional Codex review when code is ready

---

## Key Files to Know

| File | Purpose |
|---|---|
| `CLAUDE.md` | Project config — every session starts here |
| `tasks/todo.md` | Active tasks + SESSION STATE |
| `tasks/next-action.md` | What to do at the next session open |
| `tasks/lessons.md` | Accumulated lessons — append only |
| `channel.md` | Agent communication bus |
| `releases/audit-log.md` | Append-only audit trail |

---

## Troubleshooting

Something not working? See `guides/07-common-failures.md` — covers the 15 most common issues with exact fixes.

---

## Going Further

| File | Topic |
|---|---|
| `glossary.md` | 35 terms in plain language |
| `FAQ.md` | 22 common questions answered |
| `DECISION_MATRIX.md` | Stack selection tables |
| `guides/00-project-intake.md` | Intake questionnaire |
| `guides/01-elements-reference.md` | All 4 element types and how they connect |
| `guides/02-session-flow.md` | Opening, running, and closing sessions |
| `guides/03-review-modes.md` | SOLO_CLAUDE vs COMBINED vs SOLO_CODEX |
| `guides/04-first-sprint.md` | Full first sprint walkthrough |
| `guides/05-adding-personas.md` | Extending the framework with new roles |
| `guides/06-tooling-baseline.md` | Recommended tools for every stack layer |
| `guides/07-common-failures.md` | Top 15 failure cases with fixes |
| `guides/08-mode-selection-cheatsheet.md` | Mode decision table + anti-patterns |
| `guides/09-rag-playbook.md` | RAG ingestion, chunking, retrieval, eval |
| `examples/saas-minimal/` | Worked example: B2B SaaS |
| `examples/rag-minimal/` | Worked example: document Q&A with RAG |
| `project-template/CLAUDE_START.md` | First-run sequence for Claude |
| `project-template/CODEX_START.md` | Paste protocol for Codex |

---

## Help and Issues

Framework repo: https://github.com/ayuvinc/AK-Cognitive-OS
