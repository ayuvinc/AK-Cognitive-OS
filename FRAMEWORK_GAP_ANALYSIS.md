# Framework Gap Analysis — Claude Code Native Integration
# AK Cognitive OS v2.0.0 → Zero-Gap with Claude Code System
# Date: 2026-04-04
# Author: Architect (automated analysis)

---

## Executive Summary

AK Cognitive OS v2.0.0 is a well-structured multi-persona AI development framework with 27 personas, 15 skills, 13 guides, and a full validation suite. However, it currently operates as a **documentation-driven framework** that relies on Claude reading markdown instructions rather than leveraging Claude Code's native enforcement mechanisms.

This analysis identifies **31 gaps across 8 categories** that, when closed, would make the framework a **zero-gap, natively-enforced Claude Code system** — where rules are mechanically enforced, not just documented.

---

## Gap Categories

| # | Category | Gaps | Severity |
|---|----------|------|----------|
| 1 | Hooks & Automated Enforcement | 7 | Critical |
| 2 | Settings & Permissions | 4 | Critical |
| 3 | Slash Command Registration | 4 | High |
| 4 | CLAUDE.md Configuration | 3 | High |
| 5 | MCP Server Integration | 3 | Medium |
| 6 | Memory & Context Management | 4 | Medium |
| 7 | Plugin Manifest & Distribution | 3 | Medium |
| 8 | Agent SDK & Programmatic Orchestration | 3 | Low (future) |

---

## Category 1: Hooks & Automated Enforcement (CRITICAL)

Claude Code supports **hooks** in `settings.json` — shell commands that execute automatically on events like `PreToolCall`, `PostToolCall`, `Notification`, and `Stop`. The framework has **zero hooks configured**, meaning all governance rules (BOUNDARY_FLAG, envelope validation, state machine, audit logging) rely entirely on the AI remembering to follow them.

### Gap 1.1 — No `PreToolCall` hook for file-write gating

**Current state:** The framework says "No other skill or persona may write to the SESSION STATE block" (state-machine.md). This is a prose rule only.

**Zero-gap fix:** A `PreToolCall` hook on `Write`/`Edit` tools that checks if the target file is `tasks/todo.md` and the SESSION STATE block is being modified — block unless the active skill is `session-open` or `session-close`.

```json
{
  "hooks": {
    "PreToolCall": [
      {
        "matcher": "Write|Edit",
        "command": "bash scripts/hooks/guard-session-state.sh"
      }
    ]
  }
}
```

### Gap 1.2 — No `PostToolCall` hook for output envelope validation

**Current state:** Every agent must return a 10-field output envelope (schemas/output-envelope.md). Compliance is voluntary.

**Zero-gap fix:** A `PostToolCall` hook that parses agent output for envelope fields and fails if any are missing. This turns the schema from documentation into enforcement.

### Gap 1.3 — No `PostToolCall` hook for automatic audit-log appending

**Current state:** Skills say "Append one audit entry via /audit-log after completing work." This is a prose instruction agents can forget.

**Zero-gap fix:** A `PostToolCall` hook that automatically appends an audit entry to `tasks/audit-log.md` after any skill execution completes, extracting the `run_id`, `agent`, `status`, and `timestamp_utc` from the output envelope.

### Gap 1.4 — No `PreToolCall` hook for persona boundary enforcement

**Current state:** Each persona has CAN/CANNOT rules. Junior Dev "CANNOT modify types/ or shared services without Architect plan." This is unenforced.

**Zero-gap fix:** A `PreToolCall` hook on `Write`/`Edit` that reads the active persona from SESSION STATE and blocks writes to restricted paths (e.g., Junior Dev writing to `types/`, `lib/`, `middleware/`).

### Gap 1.5 — No `user-prompt-submit-hook` for auto-persona detection

**Current state:** CLAUDE.md says "Ask: what role am I playing?" — requires manual user declaration every session.

**Zero-gap fix:** A hook that reads `tasks/next-action.md` NEXT_PERSONA field and auto-loads the correct persona command, eliminating the manual question.

### Gap 1.6 — No `Stop` hook for session integrity checks

**Current state:** Architect must manually run session-close checklist before ending. If forgotten, session state is left OPEN.

**Zero-gap fix:** A `Stop` hook (or `Notification` hook on session end) that checks if SESSION STATE is still OPEN and warns/blocks if close checklist hasn't been run.

### Gap 1.7 — No `PreToolCall` hook for `git push` gating

**Current state:** "Junior Dev creates branch before writing any code. Commits to branch only, never to main." Prose only.

**Zero-gap fix:** A `PreToolCall` hook on Bash that detects `git push` commands targeting `main` and blocks them unless the active persona is Architect with QA_APPROVED status confirmed.

---

## Category 2: Settings & Permissions (CRITICAL)

### Gap 2.1 — No `.claude/settings.json` exists

**Current state:** The `.claude/` directory only contains `commands/`. There is no project-level settings file.

**Zero-gap fix:** Create `.claude/settings.json` with:
- Allowed/denied tool configurations per context
- Hook definitions (from Category 1)
- MCP server configurations (from Category 5)
- Default model preferences

```json
{
  "permissions": {
    "allow": [
      "Read",
      "Glob",
      "Grep",
      "Bash(git status)",
      "Bash(git diff)",
      "Bash(git log)",
      "Bash(npm run lint)",
      "Bash(npm run test)",
      "Bash(npm run build)",
      "Bash(python3 validators/runner.py*)"
    ],
    "deny": [
      "Bash(rm -rf *)",
      "Bash(git push --force*)",
      "Bash(git reset --hard*)"
    ]
  }
}
```

### Gap 2.2 — No `.claude/settings.local.json` template

**Current state:** No guidance on per-developer overrides.

**Zero-gap fix:** Add a `.claude/settings.local.json.example` template and add `.claude/settings.local.json` to `.gitignore`. This is where developers put personal API keys, model preferences, or hook overrides.

### Gap 2.3 — No persona-scoped permission profiles

**Current state:** All personas have the same tool access. Junior Dev can theoretically do anything Claude can do.

**Zero-gap fix:** Define permission profiles per persona in settings:
- **Junior Dev:** Allow Write/Edit only in `src/`, `app/`, `components/`. Deny Write to `types/`, `lib/`, config files.
- **Architect:** Allow all reads, allow Write only to `tasks/`, `releases/`, scaffolding.
- **QA:** Allow Read, Grep, Glob, Bash(test commands). Deny Write to source code.

### Gap 2.4 — No `.claudeignore` file

**Current state:** No file telling Claude Code what to exclude from context.

**Zero-gap fix:** Create `.claudeignore` to exclude:
- `archive/` (obsolete content)
- `node_modules/`, `.next/`, `dist/` (build artifacts in project usage)
- Large binary files
- Codex-specific files when running in SOLO_CLAUDE mode

---

## Category 3: Slash Command Registration (HIGH)

### Gap 3.1 — Sub-persona commands not in `.claude/commands/`

**Current state:** `.claude/commands/` has 6 files (architect, ba, designer, junior-dev, qa, ux). The 5 researcher sub-personas and 4 compliance sub-personas have SKILL.md files in `personas/` but are **not registered** as slash commands in `.claude/commands/`.

**Zero-gap fix:** Add 9 files to `.claude/commands/`:
- `researcher-business.md`, `researcher-legal.md`, `researcher-news.md`, `researcher-policy.md`, `researcher-technical.md`
- `compliance-data-privacy.md`, `compliance-data-security.md`, `compliance-pii-handler.md`, `compliance-phi-handler.md`

### Gap 3.2 — Skill commands not in `.claude/commands/`

**Current state:** 15 skills have `claude-command.md` files in `skills/` but are **not registered** in `.claude/commands/`. The `install-claude-commands.sh` script copies them to `~/.claude/commands/` (global), but the project-level `.claude/commands/` is the correct location for project-scoped commands.

**Zero-gap fix:** Either:
- (a) Symlink or copy all 15 skill `claude-command.md` files into `.claude/commands/` at project level, OR
- (b) Update `install-claude-commands.sh` to also install to `.claude/commands/` (project-level), OR
- (c) Add a `postinstall` or bootstrap step that does this automatically.

### Gap 3.3 — `install-claude-commands.sh` targets global, not project-level

**Current state:** Script installs to `~/.claude/commands/` which makes commands available in ALL Claude Code sessions, not scoped to this project.

**Zero-gap fix:** Default to project-level `.claude/commands/`. Add a `--global` flag for the current behavior. This prevents command collisions when users have multiple projects.

### Gap 3.4 — No command argument passing / parameterization

**Current state:** Slash commands are static markdown files. There's no mechanism to pass arguments (e.g., `/qa-run TASK-007` or `/architect --session 5`).

**Zero-gap fix:** Use Claude Code's `$ARGUMENTS` variable support in command files. Update command templates to accept and parse `$ARGUMENTS` for dynamic invocation:

```markdown
# /session-open $ARGUMENTS

Parse arguments: session_id from $ARGUMENTS
```

---

## Category 4: CLAUDE.md Configuration (HIGH)

### Gap 4.1 — Root CLAUDE.md is a template with placeholders

**Current state:** The root `CLAUDE.md` contains `[PROJECT_NAME]`, `[OWNER_NAME]`, `[Replace with: ...]` placeholders. It is not configured for the framework repository itself.

**Zero-gap fix:** The framework repo's own CLAUDE.md should be fully populated — it IS the product. Replace all placeholders with actual framework-specific values:
- Project name: AK Cognitive OS
- Stack: Markdown + Python (validators) + Bash (scripts)
- Architecture rules: Framework contribution rules
- Commands: `bash scripts/validate-framework.sh`, `python3 validators/runner.py`

### Gap 4.2 — CLAUDE.md doesn't declare hook behaviors

**Current state:** CLAUDE.md describes manual processes but doesn't reference any automated hooks.

**Zero-gap fix:** Add a `## Hooks` section to CLAUDE.md that documents what automated behaviors are enforced via settings.json hooks, so Claude knows what's already being checked mechanically vs. what it must check manually.

### Gap 4.3 — No CLAUDE.md inheritance chain documented

**Current state:** Claude Code supports CLAUDE.md at multiple levels: `~/.claude/CLAUDE.md` (global), repo root, and subdirectories. The framework doesn't document or leverage this hierarchy.

**Zero-gap fix:** Document the inheritance chain:
- `~/.claude/CLAUDE.md` — User's global preferences (model, style)
- `{project}/CLAUDE.md` — Project-specific rules (the main config)
- `{project}/src/CLAUDE.md` — Subdirectory overrides (e.g., different rules for frontend vs backend)

---

## Category 5: MCP Server Integration (MEDIUM)

### Gap 5.1 — No MCP server for state machine enforcement

**Current state:** Session state transitions are documented in `schemas/state-machine.md` but enforced only by Claude reading and following instructions.

**Zero-gap fix:** Build a lightweight MCP server (Node.js or Python) that exposes tools:
- `get_session_state()` — reads current state from `tasks/todo.md`
- `transition_session(from, to)` — validates and executes state transitions
- `get_active_persona()` — returns current persona
- `validate_envelope(output)` — validates output envelope schema

This makes state management a **tool call** rather than a **prose instruction**.

### Gap 5.2 — No MCP server for audit log

**Current state:** Audit log appending is a manual write to `tasks/audit-log.md`.

**Zero-gap fix:** An MCP server tool `append_audit_entry(run_id, agent, status, summary)` that enforces append-only semantics, validates schema, and prevents mutation of historical entries mechanically.

### Gap 5.3 — No MCP server configuration in settings

**Current state:** No `mcpServers` block in any settings file.

**Zero-gap fix:** Add MCP server definitions to `.claude/settings.json`:

```json
{
  "mcpServers": {
    "ak-cognitive-os": {
      "command": "node",
      "args": ["mcp-server/index.js"],
      "env": {
        "PROJECT_ROOT": "."
      }
    }
  }
}
```

---

## Category 6: Memory & Context Management (MEDIUM)

### Gap 6.1 — `memory/MEMORY.md` referenced but doesn't exist

**Current state:** Architect role card (line 67) says "Read `memory/MEMORY.md` — full file" but no `memory/` directory exists in the repo.

**Zero-gap fix:** Create `memory/MEMORY.md` as a persistent context file that survives across sessions. Define its schema: project decisions, architectural patterns chosen, known constraints, tech debt items.

### Gap 6.2 — No context-window management strategy

**Current state:** The framework has 300+ markdown files. Claude Code's context window is finite. No guidance on what to load when.

**Zero-gap fix:** Add a `## Context Budget` section to each persona's role card specifying:
- **Always load:** (critical files, <5)
- **Load on demand:** (reference files, when relevant)
- **Never load:** (files outside persona scope)

Example for Junior Dev:
- Always: `tasks/todo.md`, current task's LLD, `tasks/lessons.md` (last 10)
- On demand: `schemas/output-envelope.md`, relevant `docs/lld/*.md`
- Never: `framework/codex-core/*`, `guides/*`, `releases/*`

### Gap 6.3 — No `/compact` or summarization strategy

**Current state:** Long sessions will hit context limits. No guidance on when/how to compact.

**Zero-gap fix:** Add a skill `/compact-session` that:
1. Summarizes current progress into SESSION STATE
2. Writes checkpoint to `tasks/todo.md`
3. Allows context to be compressed without losing critical state

### Gap 6.4 — No structured knowledge transfer between sessions

**Current state:** `releases/knowledge-transfer.md` exists but is an empty template. Session continuity depends on `tasks/next-action.md` (3 fields only).

**Zero-gap fix:** Expand next-action.md schema to include:
- Active branch name
- Files modified this session
- Decisions made (with rationale)
- Open questions for next persona
- Test results summary

---

## Category 7: Plugin Manifest & Distribution (MEDIUM)

### Gap 7.1 — `plugin.json` is minimal and incomplete

**Current state:** `.claude-plugin/plugin.json` has only name, description, version, author. Missing fields that Claude Code plugin system supports.

**Zero-gap fix:** Expand to full plugin manifest:

```json
{
  "name": "ak-cognitive-os",
  "description": "Multi-persona AI development framework",
  "version": "2.0.0",
  "author": { "name": "AK" },
  "commands": [
    { "name": "architect", "file": "personas/architect/claude-command.md" },
    { "name": "session-open", "file": "skills/session-open/claude-command.md" }
  ],
  "hooks": {},
  "mcpServers": {},
  "settings": ".claude/settings.json"
}
```

### Gap 7.2 — No `package.json` for npm distribution

**Current state:** Framework is git-clone only. No package manager distribution.

**Zero-gap fix:** Add a `package.json` with `bin` entries for CLI scripts, making the framework installable via `npx ak-cognitive-os init` or `npm install -g ak-cognitive-os`.

### Gap 7.3 — No versioned migration path

**Current state:** `RELEASE_NOTES.md` documents what changed but no automated migration from v1.x to v2.0.

**Zero-gap fix:** Add `scripts/migrate.sh` that detects current framework version in a project and applies incremental patches (rename files, update schemas, add new required fields).

---

## Category 8: Agent SDK & Programmatic Orchestration (LOW — Future)

### Gap 8.1 — No Claude Agent SDK integration

**Current state:** All orchestration is manual — user invokes slash commands, reads output, invokes next command.

**Zero-gap fix:** Build a thin orchestrator using the Claude Agent SDK (`claude_agent_sdk`) that can:
- Chain persona invocations automatically (BA → UX → Architect → Junior Dev → QA)
- Enforce the workflow graph from FRAMEWORK_FLOW.md programmatically
- Run validation gates between transitions

### Gap 8.2 — No programmatic persona switching

**Current state:** Switching personas requires user to type `/architect`, `/junior-dev`, etc.

**Zero-gap fix:** A `next_action` field in the output envelope could trigger automatic persona switching when the `handoff-validator` skill confirms readiness.

### Gap 8.3 — No parallel agent execution

**Current state:** One persona at a time, strictly sequential.

**Zero-gap fix:** Using Claude Agent SDK's sub-agent capabilities, enable parallel execution where safe:
- BA + UX can work simultaneously on requirements
- QA can review while Junior Dev works on the next task
- Researcher sub-personas can run in parallel

---

## Priority Implementation Roadmap

### Phase 1 — Foundation (Immediate, 1 session)
| Gap | Action | Impact |
|-----|--------|--------|
| 2.1 | Create `.claude/settings.json` | Unlocks all hook and permission features |
| 4.1 | Populate root CLAUDE.md for the framework itself | Framework eats its own dog food |
| 3.1 | Register sub-persona commands in `.claude/commands/` | 9 commands become invocable |
| 3.2 | Register skill commands in `.claude/commands/` | 15 skills become invocable |
| 6.1 | Create `memory/MEMORY.md` | Fixes broken reference in Architect role |

### Phase 2 — Enforcement (Next session, 1-2 sessions)
| Gap | Action | Impact |
|-----|--------|--------|
| 1.1 | Build session-state guard hook | State machine mechanically enforced |
| 1.4 | Build persona boundary hook | CAN/CANNOT rules mechanically enforced |
| 1.7 | Build git-push guard hook | Branch policy mechanically enforced |
| 2.3 | Define persona permission profiles | Least-privilege per role |
| 3.4 | Add `$ARGUMENTS` to command templates | Dynamic command invocation |

### Phase 3 — Intelligence (2-3 sessions)
| Gap | Action | Impact |
|-----|--------|--------|
| 5.1 | Build state-machine MCP server | State as a tool, not prose |
| 5.2 | Build audit-log MCP server | Append-only enforced mechanically |
| 1.2 | Build envelope validation hook | Schema compliance automated |
| 1.3 | Build auto-audit hook | Audit trail never missed |
| 6.2 | Add context budgets to role cards | Efficient context window usage |

### Phase 4 — Automation (3-4 sessions)
| Gap | Action | Impact |
|-----|--------|--------|
| 8.1 | Agent SDK orchestrator | Full workflow automation |
| 8.2 | Auto persona switching | Hands-free workflow |
| 1.5 | Auto persona detection hook | Session start is frictionless |
| 1.6 | Session integrity stop hook | Sessions never left dangling |
| 7.2 | npm distribution | One-command framework install |

---

## What "Zero Gap" Looks Like

When all 31 gaps are closed:

1. **Rules are enforced, not suggested.** Hooks block invalid actions before they happen.
2. **State is managed by tools, not prose.** MCP servers own session state, audit logs, and envelope validation.
3. **Personas have real boundaries.** Permission profiles prevent Junior Dev from touching architecture files.
4. **Commands are all registered.** All 27 personas and 15 skills are invocable via `/slash-command` natively.
5. **Context is budgeted.** Each persona loads only what it needs, preserving context window.
6. **Sessions are self-healing.** Hooks detect and warn about incomplete closings, missing audits, broken state.
7. **The framework uses itself.** The repo's own CLAUDE.md is fully populated, not a template.
8. **Distribution is one command.** `npx ak-cognitive-os init` scaffolds a new project with all hooks, commands, and settings pre-configured.
9. **Orchestration is programmable.** Agent SDK enables automated workflow chains beyond manual slash command invocation.

---

## Appendix: Claude Code Features Audit

| Claude Code Feature | Framework Usage | Status |
|---|---|---|
| `CLAUDE.md` project instructions | Template with placeholders | PARTIAL |
| `.claude/commands/` slash commands | 6 of 42 registered | PARTIAL |
| `.claude/settings.json` | Does not exist | MISSING |
| `.claude/settings.local.json` | Does not exist | MISSING |
| `.claudeignore` | Does not exist | MISSING |
| Hooks: `PreToolCall` | Not configured | MISSING |
| Hooks: `PostToolCall` | Not configured | MISSING |
| Hooks: `Notification` | Not configured | MISSING |
| Hooks: `Stop` | Not configured | MISSING |
| Hooks: `user-prompt-submit-hook` | Not configured | MISSING |
| MCP Servers | Not configured | MISSING |
| `$ARGUMENTS` in commands | Not used | MISSING |
| Plugin manifest (full) | Minimal plugin.json | PARTIAL |
| Agent SDK orchestration | Not implemented | MISSING |
| Context window management | No strategy | MISSING |
| CLAUDE.md inheritance (subdirs) | Not leveraged | MISSING |
| Memory persistence | Referenced but missing | BROKEN |
| Tool permission profiles | Not configured | MISSING |

**Score: 2 PARTIAL, 1 BROKEN, 15 MISSING out of 18 features = ~11% coverage**

To reach zero gap: all 18 rows must show COMPLETE.
