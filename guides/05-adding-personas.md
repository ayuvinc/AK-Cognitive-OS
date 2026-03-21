# Guide 05 — Adding New Personas and Skills

## When to Add a Persona

Add a new persona when you need a stable role identity that:
- Has a consistent mental model and scope
- Will be reused across many sessions
- Needs both a Claude-native command and a Codex-readable contract

Example: adding a DevOps persona to handle CI/CD decisions.

## When to Add a Skill

Add a new skill when you need a repeatable, deterministic workflow action that:
- Takes specific inputs and produces a specific output envelope
- Can be run by either Claude or Codex
- Needs an audit trail

Example: adding a `/db-migration-check` skill to validate database migration safety.

---

## Persona File Structure

Every persona needs two files (see `personas/_template/` for starters):

```
personas/[persona-name]/
├── claude-command.md    ← Claude reads this when the persona is invoked
└── codex-prompt.md      ← Codex reads this to understand the persona's contract
```

Optional third file for output-contract personas:
```
└── schema.md            ← Machine-readable (or markdown-contract) output spec
```

### claude-command.md must include:

- `## WHO YOU ARE` — one sentence role identity
- `## YOUR RULES` — CAN / CANNOT / BOUNDARY_FLAG
- `## ON ACTIVATION - AUTO-RUN SEQUENCE` — numbered steps
- `## TASK EXECUTION` — Reads / Writes / Checks
- `## HANDOFF` — output envelope (YAML)

### codex-prompt.md must include:

- `## Role` — what this persona does in Codex context
- `## Scope` — what it reads and writes
- `## Required Output` — YAML envelope
- `## Rules` — invariants Codex must follow

---

## Skill File Structure

Every skill needs two files (see `skills/_template/` for starters):

```
skills/[skill-name]/
├── claude-command.md
└── codex-prompt.md
```

Skills follow the same two-file contract as personas. The difference:
- Personas = role identity + ongoing task execution
- Skills = one-shot workflow action with deterministic input → output

---

## Output Envelope (Required for All)

Every persona and skill output must conform to `schemas/output-envelope.md`:

```yaml
run_id: "[agent-name]-{session_id}-{sprint_id}-{timestamp}"
agent: "[agent-name]"
origin: claude-core | codex-core
status: PASS | FAIL | BLOCKED
timestamp_utc: "ISO-8601"
summary: "single-line outcome"
failures: []
warnings: []
artifacts_written: []
next_action: "what to run next"
```

Missing any required field → `BLOCKED` with `SCHEMA_VIOLATION`.

---

## Normalization Rules

Before committing any new persona or skill file, check for forbidden literals:

| Forbidden | Replace with |
|---|---|
| `~/.claude` or `[FRAMEWORK_ROOT]` hardcoded | `[FRAMEWORK_ROOT]` |
| Absolute paths like `/Users/...` | `[PROJECT_ROOT]` |
| `releases/audit-log.md` literal | `[AUDIT_LOG_PATH]` |
| Sprint-specific IDs (e.g. `sprint-001`) | `{sprint_id}` template variable |
| Fixed agent counts ("18 agents") | "agents defined in personas/ and skills/" |

---

## Registering the Persona or Skill

After writing the files:

1. **For Claude use:** copy `claude-command.md` to `~/.claude/commands/[name].md`
2. **For Codex use:** the `codex-prompt.md` is read from the framework repo path directly
3. **Update README.md:** add to the personas or skills directory listing

---

## Harness Testing (Optional but Recommended)

Write a harness in `harnesses/[persona]-harness.md` to validate the output contract.
A harness is a test scenario that checks:
- The output envelope is correct
- Extra fields are present
- BOUNDARY_FLAG behaviour triggers correctly on bad input

See `harnesses/_template/harness-template.md` for the format.

---

## Schema Validation

New personas with structured output should have a `schema.md` with:

```yaml
validation: markdown-contract-only | machine-validated
```

For v1.0 of this framework, all schemas are `markdown-contract-only`.
Machine validation (JSON Schema + validator script) is a Phase 2 improvement
tracked in `framework-improvements.md`.
