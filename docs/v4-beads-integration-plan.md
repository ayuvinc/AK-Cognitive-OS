# v4 Memory Layer — Beads Integration Plan
# Owner: Architect
# Status: PENDING AK REVIEW
# Session: 25
# Date: 2026-04-27
#
# This plan is self-contained. Execute each phase in order from terminal.
# Each step shows the exact command to run and what success looks like.

---

## Overview

Replace the hand-rolled `memory/` file system in v4 with `beads-mcp` — a purpose-built
agentic memory system backed by Dolt (version-controlled SQL). This gives AK-Cognitive-OS
persistent, structured, cross-session memory with zero custom storage code.

Custom-built pieces that beads does NOT replace:
- Feedback loop (QA results, velocity, risk escalations) → `validators/feedback.py`
- Signal engine (pattern detection) → `validators/signal_engine.py`

---

## Phase 1 — Install Dependencies

### Step 1.1 — Install Beads CLI

```bash
# Option A: via npm (recommended, cross-platform)
npm install -g @beads/bd

# Option B: via Homebrew (macOS only)
brew install beads

# Verify
bd --version
```

Expected output: `bd version X.Y.Z`

---

### Step 1.2 — Install Beads MCP Server

```bash
# Requires uv (preferred) or pip
uv tool install beads-mcp

# Alternative
pip install beads-mcp

# Verify
beads-mcp --version
```

Expected output: version string, no errors.

---

## Phase 2 — Initialise Beads in AK-Cognitive-OS

### Step 2.1 — Init beads in the project root

```bash
cd /path/to/AK-Cognitive-OS
bd init --quiet
```

Creates `.beads/` directory with embedded Dolt database. This is the persistent store.

Expected output: `Initialised beads in .beads/`

---

### Step 2.2 — Verify the database

```bash
bd list
```

Expected output: empty list (no issues yet). No errors.

---

### Step 2.3 — Add `.beads/` to .gitignore (database is local, not committed)

```bash
echo ".beads/" >> .gitignore
git add .gitignore
git commit -m "chore: ignore beads embedded database"
```

> Note: If you want cross-machine memory persistence, use beads Server Mode
> (`bd daemon`) and push the Dolt remote. For single-machine use, local only is fine.

---

## Phase 3 — Wire Beads MCP Server

### Step 3.1 — Add beads-mcp to `.mcp.json`

Open `.mcp.json` at the project root and add the beads server entry:

```json
{
  "mcpServers": {
    "beads": {
      "command": "beads-mcp"
    }
  }
}
```

Full `.mcp.json` after edit (merge with existing entries — do not overwrite other servers):

```json
{
  "mcpServers": {
    "ak-state-machine": { ... existing entry ... },
    "ak-audit-log":     { ... existing entry ... },
    "beads": {
      "command": "beads-mcp"
    }
  }
}
```

---

### Step 3.2 — Add beads MCP permissions to `.claude/settings.json`

In the `permissions.allow` array, add:

```json
"mcp__beads__create",
"mcp__beads__list",
"mcp__beads__show",
"mcp__beads__update",
"mcp__beads__close",
"mcp__beads__ready",
"mcp__beads__dep",
"mcp__beads__stats"
```

---

### Step 3.3 — Verify MCP connection

Open Claude Code in the project and run:

```
/check-channel
```

Confirm `beads` appears as an available MCP server alongside `ak-state-machine` and `ak-audit-log`.

---

## Phase 4 — Establish Memory Conventions

These are the naming and tagging conventions personas must follow when writing to beads.
No code changes — pure convention documented in command files.

### Memory Entry Types (bd issue types)

| bd type | AK-Cognitive-OS meaning | Written by |
|---|---|---|
| `task` | Task history record — one per completed TASK-NNN | Junior Dev / QA via session-close |
| `decision` | Architecture or BA decision | Architect / BA |
| `lesson` | Approved lesson from lessons-extractor | Architect (after AK approval) |
| `outcome` | QA result summary per task | QA / qa-run |
| `risk` | S0/S1 risk escalation record | Risk-manager |

### Tagging Convention

Every `bd create` call must include relevant labels:
```bash
bd create "TASK-042 auth boundary — QA FAIL" -t outcome --label auth,boundary,qa-fail
```

---

## Phase 5 — Update Command Files

### Step 5.1 — Update `/architect` context budget

In `.claude/commands/architect.md`, add to the **Always load** section:

```
bd ready --json            # unblocked tasks at session open
bd list --status closed --limit 20 --json   # recent completions for context
```

---

### Step 5.2 — Update `/session-open` task execution

In `skills/session-open/claude-command.md`, add after the lessons read step:

```
- Run `bd ready --json` — surface any unblocked carry-forward items from previous sessions
- Run `bd list --status open --json` — load open memory items as session context
```

---

### Step 5.3 — Update `/session-close` task execution

In `skills/session-close/claude-command.md`, add before final STATE write:

```
- For each QA_APPROVED task: run `bd create "<TASK-ID> <title>" -t task --label <tags>`
  to write the task outcome to persistent memory
- For each approved lesson: run `bd create "<lesson text>" -t lesson`
```

---

### Step 5.4 — Update `/lessons-extractor` task execution

In `skills/lessons-extractor/claude-command.md`, add to TASK EXECUTION:

```
- On AK approval: run `bd create "<lesson>" -t lesson --label <tags>` in addition to
  appending to tasks/lessons.md
```

---

### Step 5.5 — Update `/risk-manager` task execution

In the risk-manager command, add to S0/S1 registration:

```
- On S0/S1: run `bd create "<risk title>" -t risk --label s0|s1,<area> -p 0|1`
- This creates a persistent risk record that signal_engine.py can query
```

---

## Phase 6 — Memory Decay / Compaction

Beads handles this natively. No custom code required.

```bash
# Compact old closed issues (summarise to save context window)
bd compact

# Or set a threshold (keep last N closed issues in full, summarise rest)
bd compact --keep 50
```

Add `bd compact --keep 50` to the session-close procedure so compaction runs automatically
at the end of each session.

---

## Phase 7 — Bootstrap Script Update

### Step 7.1 — Add beads init to `scripts/bootstrap-project.sh`

Find the section where new project directories are created and add:

```bash
# Step N — Initialise beads memory layer
echo "[bootstrap] Initialising beads persistent memory..."
cd "$PROJECT_DIR"
bd init --quiet
echo "  ✓ .beads/ initialised"

# Add to .gitignore
echo ".beads/" >> "$PROJECT_DIR/.gitignore"
```

---

### Step 7.2 — Add beads MCP to `project-template/.mcp.json`

Add the beads server entry to the project template MCP config so all bootstrapped
projects get it automatically.

---

## Phase 8 — Validate

### Step 8.1 — Run framework validator

```bash
bash scripts/validate-framework.sh
```

Must PASS. No new checks needed — beads integration is additive and does not touch
existing validated artifacts.

---

### Step 8.2 — Smoke test memory write + read

```bash
# Write a test memory entry
bd create "SMOKE-TEST: memory layer working" -t task --label smoke-test

# Read it back
bd list --json | grep SMOKE-TEST

# Clean up
bd close $(bd list --json | python3 -c "import sys,json; items=json.load(sys.stdin); print(next(i['id'] for i in items if 'SMOKE-TEST' in i['title']))") --reason "smoke test complete"
```

Expected: entry appears in list, closes cleanly.

---

## What This Does NOT Cover (Custom Build Still Required)

These items are not in beads and must be built separately:

| Item | File | Priority |
|---|---|---|
| Feedback aggregation (QA, velocity, risk) | `validators/feedback.py` | v4.0 |
| Signal engine (pattern detection) | `validators/signal_engine.py` | v4.0 |
| `auto-feedback-capture.sh` hook | `scripts/hooks/` | v4.0 |
| `auto-signal-check.sh` hook | `scripts/hooks/` | v4.0 |
| Signal output schemas | `schemas/signal.schema.json` | v4.0 |
| Feedback entry schemas | `schemas/feedback-entry.schema.json` | v4.0 |

These are designed in `docs/v4-architecture.md` and will be broken into tasks
once AK approves this plan.

---

## Decision Gate

Before executing Phase 1: AK confirms acceptance of Dolt as a dependency.

| Question | Options |
|---|---|
| Accept Dolt + beads as memory backend? | YES → execute Phase 1–8 / NO → use hand-rolled memory/ |
| Memory scope | Per-project (default) / Cross-project (needs `bd daemon` + shared remote) |
| Compaction schedule | Per session-close (recommended) / Manual on demand |

---

## Rollback

If beads is installed and you want to remove it:

```bash
# Remove the database
rm -rf .beads/

# Remove from .gitignore
# (edit .gitignore manually, remove ".beads/" line)

# Remove beads-mcp entry from .mcp.json and settings.json
# (edit those files manually)

# Uninstall
npm uninstall -g @beads/bd
uv tool uninstall beads-mcp
```

All existing AK-Cognitive-OS files are untouched. Beads is purely additive.

---

*Plan written by: Architect — Session 25*
*Pending: AK review and approval before any terminal execution*
