# Guide 10 — Plugins: Extending the Framework

## What Is a Plugin?

A plugin adds new capability to the Cognitive OS without modifying the core framework.

The core (personas/, skills/, schemas/) ships with a universal set of roles and workflows.
A plugin is anything you drop in on top of it for a specific project or domain.

---

## Two Types of Plugins

| Type | What it adds | Where it lives |
|---|---|---|
| **Persona plugin** | A new role (e.g. fraud-analyst, devops, data-engineer) | `personas/your-persona/` |
| **Skill plugin** | A new workflow (e.g. changelog-generator, deploy-check) | `skills/your-skill/` |

---

## When to Build a Plugin vs Use the Core

Use the **core personas** for work any software project needs:
Architect, BA, UX, Junior Dev, QA, Researcher, Compliance.

Build a **plugin** when:
- The role is domain-specific (fintech, healthcare, legal, infra)
- The workflow only applies to one project or stack
- You don't want to ship the capability in the public framework
- A client or team needs a custom persona not in the core set

---

## Building a Persona Plugin

### Step 1 — Copy the template

Run from the repo root:

```bash
cp -r personas/_template personas/your-persona
```

### Step 2 — Fill in the three files

```
personas/your-persona/
├── claude-command.md    ← slash command for Claude
├── codex-prompt.md      ← Codex equivalent
└── schema.md            ← output contract
```

The `_template` directory contains all three files. Fill in each one:

**claude-command.md:**
- WHO YOU ARE — role, domain, one-sentence job
- YOUR RULES — CAN / CANNOT boundaries
- ON ACTIVATION — what to read first (CLAUDE.md, relevant task files)
- TASK EXECUTION — what to read, what to write, validation contracts
- Required extra fields — define the `extra_fields` block
- HANDOFF — envelope YAML with `origin: claude-core`

**codex-prompt.md:**
- Same role, scope, boundaries as claude-command.md
- Required output envelope with `origin: codex-core`
- Boundary section with BOUNDARY_FLAG block

**schema.md:**
- Extra fields definition — must match `extra_fields` in both command files
- Validation rules for each field
- Artifacts written list
- Validation header: `validation: markdown-contract-only | machine-validated`

### Step 3 — Install

Run from the repo root:

```bash
bash scripts/install-claude-commands.sh
```

The install script scans `personas/` and `skills/` under the repo root and copies
every `claude-command.md` to `~/.claude/commands/`. Your new `/your-persona`
slash command is now available in any Claude session.

---

## Building a Skill Plugin

Copy from `skills/_template/` instead:

```bash
cp -r skills/_template skills/your-skill
```

Skills use two files (no schema.md required):

```
skills/your-skill/
├── claude-command.md
└── codex-prompt.md
```

Skills are workflows, not roles. A skill executes a repeatable task
(generate changelog, run deploy check, package a release).
A persona is an ongoing role with CAN/CANNOT boundaries.

---

## Validation

Run the framework validator after adding any plugin:

```bash
bash scripts/validate-framework.sh
```

The validator checks:
- BOUNDARY_FLAG present in all claude-command.md and codex-prompt.md files
- All 10 base envelope fields present in HANDOFF YAML blocks
- Schema validation header present in all files under `schemas/`

Note: the validator does not check persona `schema.md` files under `personas/*/schema.md`.
Verify those manually against `schemas/persona-schema.md`.

---

## Project-Local Plugins

If a plugin is specific to one project and should not live in the shared framework repo,
keep it in your project directory:

```
your-project/
└── plugins/
    ├── personas/
    │   └── fraud-analyst/
    │       ├── claude-command.md
    │       ├── codex-prompt.md
    │       └── schema.md
    └── skills/
        └── changelog-generator/
            ├── claude-command.md
            └── codex-prompt.md
```

To install project-local plugins, copy them into the framework's `personas/` or `skills/`
directory first, then run the install script:

```bash
cp -r your-project/plugins/personas/fraud-analyst personas/fraud-analyst
bash scripts/install-claude-commands.sh
```

Or install directly to `~/.claude/commands/` without going through the framework:

```bash
cp your-project/plugins/personas/fraud-analyst/claude-command.md ~/.claude/commands/fraud-analyst.md
```

---

## Plugin Examples

### `fraud-analyst` — for fintech projects

Scope: reviews task output for fraud vectors, sanctions exposure, transaction anomalies.
CAN: flag risk patterns, recommend controls, escalate to Compliance.
CANNOT: make legal determinations, approve transactions.

### `devops` — for infra-heavy projects

Scope: CI/CD pipeline design, container strategy, deployment runbooks.
CAN: write pipeline config, define rollback procedures, advise on secrets management.
CANNOT: write application code, define business logic.

### `data-engineer` — for data-heavy projects

Scope: pipeline architecture, schema design, ingestion strategy.
CAN: design ETL flows, advise on storage format, write data validation rules.
CANNOT: define business logic, approve product requirements.

### `changelog-generator` — skill

Scope: reads git log and [AUDIT_LOG_PATH], produces a formatted CHANGELOG.md entry.
Trigger: run at end of every sprint before release.

---

## Plugin Checklist

- [ ] Three files present for persona plugins (claude-command.md, codex-prompt.md, schema.md)
- [ ] Two files present for skill plugins (claude-command.md, codex-prompt.md)
- [ ] BOUNDARY_FLAG block in both claude-command.md and codex-prompt.md
- [ ] All 10 base envelope fields in HANDOFF YAML (run_id, agent, origin, status, timestamp_utc, summary, failures, warnings, artifacts_written, next_action)
- [ ] `extra_fields` block defined in HANDOFF YAML and matching schema.md
- [ ] `origin: claude-core` in claude-command.md HANDOFF YAML
- [ ] `origin: codex-core` in codex-prompt.md HANDOFF YAML
- [ ] Schema validation header in schema.md (`validation: markdown-contract-only | machine-validated`)
- [ ] No hardcoded paths — use [PROJECT_ROOT], [FRAMEWORK_ROOT], [AUDIT_LOG_PATH]
- [ ] `bash scripts/validate-framework.sh` passes with zero failures
- [ ] schema.md manually verified against `schemas/persona-schema.md`
