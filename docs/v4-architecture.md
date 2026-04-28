# AK Cognitive OS — v4 Architecture
# Cognitive Layer Integration
# Owner: Architect
# Status: DRAFT — Pending AK Approval
# Session: 25
# Date: 2026-04-27

---

## 1. Architecture Overview

v4 transforms AK-Cognitive-OS from a governed execution framework into a cognitive system. Three new subsystems are added on top of the existing v3.1 governance layer — they do not replace it.

```
┌─────────────────────────────────────────────────────────────────┐
│                     AK Cognitive OS v4                          │
│                                                                 │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │               Signal Engine (NEW)                        │   │
│  │   Reads memory + feedback → generates structured signals │   │
│  └───────────────────────┬─────────────────────────────────┘   │
│                          │                                      │
│  ┌───────────────────────▼─────────────────────────────────┐   │
│  │               Feedback Loop (NEW)                        │   │
│  │   Captures QA results, failures, velocity per task       │   │
│  └───────────────────────┬─────────────────────────────────┘   │
│                          │                                      │
│  ┌───────────────────────▼─────────────────────────────────┐   │
│  │               Memory Layer (NEW)                         │   │
│  │   Persistent cross-session storage — decisions, outcomes  │   │
│  └───────────────────────┬─────────────────────────────────┘   │
│                          │                                      │
│  ┌───────────────────────▼─────────────────────────────────┐   │
│  │          v3.1 Governance + Enforcement (existing)        │   │
│  │   Hooks, commands, validators, personas, lifecycle       │   │
│  └─────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────┘
```

**Design constraints honoured:**
- File-based throughout — JSON + Markdown hybrid, no external database
- Works in SOLO_CLAUDE and COMBINED modes
- All existing hooks preserved — new hooks additive only
- Each subsystem independently testable
- Governance layer is not touched — only extended

---

## 2. Subsystem Design

---

### 2A. Memory Layer

**Purpose:** Provide persistent, structured storage of decisions, task outcomes, and session history that survives across sessions. Enables each persona to start with informed context rather than blank state.

#### Storage Approach: File-Based Hybrid

| Component | Format | Purpose |
|---|---|---|
| `memory/MEMORY.md` | Markdown | Human-readable index + 50 most recent entries — loaded as context |
| `memory/index.json` | JSON | Machine-readable manifest — queried by validators and signal engine |
| `memory/sessions/session-{N}.json` | JSON | Per-session snapshot written at session-close |
| `memory/decisions/{decision-id}.json` | JSON | Individual decision records |
| `memory/outcomes/{task-id}.json` | JSON | Per-task outcome records |

**Why hybrid:** Markdown is Claude-readable without tooling. JSON is machine-queryable. Splitting the responsibility between the two eliminates the need for a database while keeping both paths functional.

#### Memory Entry Schema

```json
{
  "entry_id": "MEM-{NNN}",
  "session": "session-{N}",
  "timestamp_utc": "ISO-8601",
  "type": "decision | outcome | lesson | task_history | audit_event",
  "persona": "architect | qa | junior-dev | ba | ux",
  "task_id": "TASK-{NNN} | null",
  "content": "single-paragraph structured description",
  "tags": ["auth", "schema", "risk"],
  "outcome": "PASS | FAIL | PARTIAL | DEFERRED | null",
  "severity": "S0 | S1 | S2 | null",
  "linked_entries": ["MEM-{NNN}"]
}
```

#### Retrieval Interface

Python function (callable by validators and signal engine):

```python
def memory_query(
    type: str | None = None,         # filter by entry type
    tags: list[str] | None = None,   # filter by tag intersection
    persona: str | None = None,      # filter by persona
    outcome: str | None = None,      # filter by outcome
    session_range: tuple | None = None,  # (start_N, end_N) inclusive
    limit: int = 20                  # max results, most recent first
) -> list[dict]:
    ...
```

Bash wrapper for hook access:

```bash
python3 validators/memory_query.py --type outcome --outcome FAIL --limit 10
```

#### MEMORY.md Format

```markdown
# Memory Index — AK-Cognitive-OS
Last updated: ISO-8601
Total entries: NNN
Sessions covered: 1–N

## Recent Entries (last 50)

### MEM-001 | 2026-04-27 | outcome | TASK-042 | FAIL
Persona: qa | Tags: auth, boundary
Content: TASK-042 auth boundary enforcement failed QA — access control check
bypassed when request header was malformed. Fixed in TASK-043.

...
```

---

### 2B. Feedback Loop System

**Purpose:** Capture structured feedback from QA runs, risk escalations, and delivery velocity so that patterns can be detected by the signal engine and surfaced to personas.

#### What Is Captured

| Event | Trigger | Written by |
|---|---|---|
| QA result | qa-run completes | `/qa-run` (new output field) |
| S0/S1 risk escalation | risk-register entry created/updated | `/risk-manager` (new output field) |
| Task velocity | task moves IN_PROGRESS → READY_FOR_QA | `auto-feedback-capture.sh` hook |
| Codex verdict | codex-read processes VERDICT | existing `auto-codex-read.sh` (extended) |

#### Feedback Entry Schema

```json
{
  "feedback_id": "FB-{NNN}",
  "session": "session-{N}",
  "timestamp_utc": "ISO-8601",
  "feedback_type": "qa_result | risk_escalation | velocity | codex_verdict",
  "task_id": "TASK-{NNN} | null",
  "persona": "qa-run | risk-manager | junior-dev | codex",
  "outcome": "PASS | FAIL | PARTIAL",
  "duration_minutes": null,
  "criteria_results": [],
  "failure_codes": [],
  "notes": ""
}
```

#### How Feedback Is Written

1. `/qa-run` appends a structured JSON block to `feedback/qa/qa-{task-id}-{timestamp}.json` after each run — not to channel.md. The existing handoff envelope gains a new extra field `feedback_written: true`.

2. `auto-feedback-capture.sh` (new PostToolUse hook) fires when `tasks/todo.md` is written. It detects task status transitions (IN_PROGRESS → READY_FOR_QA) by diffing the before/after state of the todo file and writes velocity records to `feedback/velocity/`.

3. `/risk-manager` writes S0/S1 escalations to `feedback/risk/` at the point of registration.

#### How Feedback Updates System State

- `feedback/summary.json` is the aggregated state file. It is regenerated by `validators/feedback.py` on demand.
- The signal engine reads `feedback/summary.json` as its primary input.
- No persona reads raw feedback files — they read signals only. This keeps the feedback layer decoupled.

#### Storage Layout

```
feedback/
  summary.json                       # Aggregated state — regenerated on demand
  qa/
    qa-{task-id}-{timestamp}.json    # One per qa-run execution
  risk/
    risk-{entry-id}-{timestamp}.json # One per S0/S1 escalation
  velocity/
    velocity-{session}-{task-id}.json # One per task completion
  codex/
    codex-{task-id}-{timestamp}.json  # One per codex verdict
```

---

### 2C. Signal Engine

**Purpose:** Detect patterns across memory and feedback data and emit structured, machine-readable signals that personas can act on. Signals replace ad-hoc intuition with evidence-based triggers.

#### Signal Types

| Signal Type | Trigger Condition | Severity |
|---|---|---|
| `RISK_HOTSPOT` | Same module/area failing QA in 3+ tasks across sessions | HIGH |
| `FAILURE_PATTERN` | Same failure code appearing in 3+ feedback entries | HIGH |
| `VELOCITY_DROP` | Task duration > 2× session average for 2+ consecutive tasks | MEDIUM |
| `DEBT_ACCUMULATION` | S1+ risk unresolved across 2+ sessions | HIGH |
| `COVERAGE_GAP` | Area with zero QA feedback entries in last 5 tasks | MEDIUM |
| `LESSON_RECURRENCE` | A lesson tag appearing 3+ times without a structural fix | LOW |

#### Signal Output Schema

```json
{
  "signal_id": "SIG-{NNN}",
  "generated_at": "ISO-8601",
  "signal_type": "RISK_HOTSPOT | FAILURE_PATTERN | VELOCITY_DROP | DEBT_ACCUMULATION | COVERAGE_GAP | LESSON_RECURRENCE",
  "severity": "HIGH | MEDIUM | LOW",
  "evidence": [
    {
      "source": "feedback | memory | risk-register | lessons",
      "entry_id": "FB-{NNN} | MEM-{NNN}",
      "detail": "short description"
    }
  ],
  "affected_area": "module name or task ID range",
  "recommended_action": "single imperative sentence",
  "persona_to_notify": "architect | qa | risk-manager",
  "auto_escalate": false,
  "status": "ACTIVE | RESOLVED | ACKNOWLEDGED"
}
```

#### Input Sources

```
feedback/summary.json          → primary pattern source
memory/index.json              → cross-session context
tasks/risk-register.md         → unresolved risk tracking
tasks/lessons.md               → recurrence detection
```

#### Processing Logic

`validators/signal_engine.py` implements 6 detector functions — one per signal type. Each detector:
1. Reads its required input source
2. Applies the trigger condition with configurable thresholds
3. Emits a signal entry if the condition is met
4. Writes to `signals/active.json` (upsert by signal_type + affected_area)
5. Archives resolved signals to `signals/history/signal-{id}.json`

The engine is pure-read with a single write to `signals/active.json`. It is stateless — re-running produces the same output for the same input.

#### Output Files

```
signals/
  active.json                  # Current signals — read by architect, risk-manager
  history/
    signal-{id}.json           # Archived/resolved signals
```

---

## 3. Integration Plan

### Persona Ownership

| Subsystem | Owner Persona | Other Consumers |
|---|---|---|
| Memory Layer | `/architect` (writes session summaries) | All personas (read-only) |
| Feedback Loop | `/qa-run` (QA records), `/risk-manager` (risk records) | `/signal engine` |
| Signal Engine | `/risk-manager` (acts on HIGH signals) | `/architect` (reads at session open) |

### Lifecycle Plug-in Points

| Stage | What Changes |
|---|---|
| Stage 1 — intake | `/session-open` loads `memory/MEMORY.md` as additional context |
| Stage 4 — architecture | Architect reads `signals/active.json` before task decomposition |
| Stage 6 — implementation | `auto-feedback-capture.sh` writes velocity records on task transitions |
| Stage 7 — QA | `/qa-run` writes QA feedback records after each run |
| Stage 8 — security | `/risk-manager` reads signals to identify risk hotspots before review |
| Stage 9 — release | Architect writes session snapshot to `memory/sessions/` at release |
| Stage 10 — lessons | `/lessons-extractor` writes approved lessons to `memory/` in addition to `tasks/lessons.md` |
| Stage 11 — framework improvement | Signal engine run advisory — patterns inform framework backlog |

### Hook Modifications

#### New Hooks

| Hook | Event | Type | Purpose |
|---|---|---|---|
| `auto-memory-write.sh` | Stop | advisory (exit 0) | Writes session snapshot to `memory/sessions/session-{N}.json` at session end |
| `auto-feedback-capture.sh` | PostToolUse (Write/Edit) | advisory (exit 0) | Detects task status transitions in `tasks/todo.md`, writes velocity feedback |
| `auto-signal-check.sh` | UserPromptSubmit | advisory (exit 0) | Runs signal engine, surfaces any HIGH signals as a warning to persona |

#### Modified Hooks

| Hook | Change |
|---|---|
| `session-integrity-check.sh` | Add check: `signals/active.json` has no unacknowledged HIGH signals at session close — WARN only |
| `auto-audit-log.sh` | Add: tag audit entries with active signal IDs if relevant |

**v4.0 policy:** All new hooks are advisory (exit 0 on failure) — they warn, never block. Enforcement promoted to exit 2 in v4.1 after one full session cycle validates the new data.

---

## 4. File/Folder Changes

### New Folders and Files

```
memory/
  MEMORY.md                           # Human-readable context index
  index.json                          # Machine-readable manifest
  sessions/                           # Per-session JSON snapshots
  decisions/                          # Decision records
  outcomes/                           # Task outcome records

feedback/
  summary.json                        # Aggregated feedback state
  qa/                                 # QA result records
  risk/                               # Risk escalation records
  velocity/                           # Task velocity records
  codex/                              # Codex verdict records

signals/
  active.json                         # Current active signals
  history/                            # Archived signals

schemas/
  memory-entry.schema.json            # Memory entry contract
  feedback-entry.schema.json          # Feedback entry contract
  signal.schema.json                  # Signal output contract

validators/
  memory.py                           # Memory consistency validator
  feedback.py                         # Feedback completeness validator
  signal_engine.py                    # Signal generation + correctness

scripts/hooks/
  auto-memory-write.sh                # Stop hook — session snapshot
  auto-feedback-capture.sh            # PostToolUse — task transition capture
  auto-signal-check.sh                # UserPromptSubmit — signal surface

project-template/
  memory/MEMORY.md                    # Bootstrap placeholder
  feedback/summary.json               # Bootstrap placeholder
  signals/active.json                 # Bootstrap placeholder
```

### Modified Files

```
.claude/commands/architect.md         # Add: read memory/MEMORY.md + signals/active.json at session open
.claude/commands/session-open.md      # Add: load memory/MEMORY.md in context budget
skills/qa-run/claude-command.md       # Add: write feedback/qa/ record after each run
skills/risk-manager/claude-command.md # Add: read signals/active.json; write feedback/risk/ on escalation
skills/lessons-extractor/claude-command.md  # Add: write to memory/ on AK approval
skills/session-close/claude-command.md # Add: trigger auto-memory-write
.claude/settings.json                 # Add: 3 new hooks
scripts/bootstrap-project.sh          # Add: create memory/, feedback/, signals/ scaffolds
scripts/remediate-project.sh          # Add: --v4-upgrade mode
validators/runner.py                  # Add: auto-discover memory.py, feedback.py, signal_engine.py
.ak-cogos-version                     # Bump to 4.0.0
```

---

## 5. Command/Skill Changes

### New Commands

| Command | File | Purpose |
|---|---|---|
| `/memory-query` | `.claude/commands/memory-query.md` | Query memory across sessions — read-only |
| `/signal-review` | `.claude/commands/signal-review.md` | Surface and triage active signals — Architect/risk-manager only |

### Updated Commands

#### `/qa-run`
- Add to TASK EXECUTION: After run, write structured feedback entry to `feedback/qa/qa-{task_id}-{timestamp}.json`
- Add to HANDOFF extra_fields: `feedback_id: "FB-{NNN}"`, `feedback_written: true`

#### `/risk-manager`
- Add to ON ACTIVATION: Read `signals/active.json` — surface any HIGH signals relevant to current scope
- Add to TASK EXECUTION: On S0/S1 registration, write to `feedback/risk/risk-{entry-id}-{timestamp}.json`
- Add to HANDOFF extra_fields: `signals_consumed: []`, `feedback_written: true`

#### `/lessons-extractor`
- Add to TASK EXECUTION: On AK approval, write lesson to `memory/` as type=lesson entry in addition to `tasks/lessons.md`
- Add to HANDOFF extra_fields: `memory_entry_id: "MEM-{NNN}" | null`

#### `/architect`
- Add to CONTEXT BUDGET (Always load): `memory/MEMORY.md`, `signals/active.json`
- Add to ON ACTIVATION step 2: Read `memory/MEMORY.md` and `signals/active.json`
- Add to ON ACTIVATION step 9: After task decomposition, check signals — WARN if any HIGH signal overlaps task scope

#### `/session-open`
- Add to CONTEXT BUDGET: `memory/MEMORY.md`
- Add to TASK EXECUTION: Read `memory/MEMORY.md` — last 50 entries loaded as session context

#### `/session-close`
- Add to TASK EXECUTION: Trigger `auto-memory-write.sh` — write session snapshot before close
- Add to HANDOFF extra_fields: `memory_snapshot_written: true | false`

---

## 6. Validator Additions

### `validators/memory.py`

Checks:
1. `memory/MEMORY.md` exists and has valid header (project name, last updated, total entries)
2. `memory/index.json` is valid JSON with fields: `entries`, `session_count`, `last_updated`
3. Every entry in `index.json` has all required fields from the memory entry schema
4. `memory/sessions/` contains one file per session listed in `releases/` archive
5. No memory entry references a session ID not present in `memory/index.json`
6. `memory/MEMORY.md` entry count matches `memory/index.json` total (within ±5 tolerance for summary truncation)

Severity: WARNING in v4.0, FAIL in v4.1

### `validators/feedback.py`

Checks:
1. `feedback/summary.json` exists and is valid JSON
2. Every `qa/` file has required fields: `feedback_id`, `session`, `task_id`, `outcome`, `criteria_results`
3. Every `risk/` file has required fields: `feedback_id`, `session`, `entry_id`, `severity`, `outcome`
4. Every `velocity/` file has required fields: `feedback_id`, `session`, `task_id`, `duration_minutes`
5. No task in QA_APPROVED state (in `tasks/todo.md`) lacks a corresponding `feedback/qa/` entry
6. `feedback/summary.json` field `total_entries` matches actual file count across subdirs

Severity: WARNING in v4.0, FAIL in v4.1

### `validators/signal_engine.py`

Checks (run mode — validates existing `signals/active.json`):
1. `signals/active.json` is valid JSON with field `signals: []`
2. Every signal entry has all required fields from signal schema
3. `signal_type` is one of the 6 defined enum values
4. `severity` is one of HIGH/MEDIUM/LOW
5. `evidence` array is non-empty for every active signal
6. `recommended_action` is non-empty for every signal
7. `status` is one of ACTIVE/RESOLVED/ACKNOWLEDGED

Generation mode (invoked by `auto-signal-check.sh`):
- Runs all 6 detectors against current inputs
- Writes detected signals to `signals/active.json`
- Archives resolved signals (no longer triggered) to `signals/history/`
- Exits 0 always — advisory only in v4.0

---

## 7. Migration Plan (v3 → v4)

### Backward Compatibility Rules

1. All v3 files are unchanged — memory/, feedback/, signals/ are purely additive
2. No existing command contracts are broken — new fields are appended only
3. All existing hooks remain — new hooks are added at the end of each matcher block
4. A v3 project with no v4 folders passes all existing validators (new validators are additive)
5. Memory reads are optional context — no command is BLOCKED if memory/ is empty

### Migration Path

**Step 1 — Upgrade framework source**
- Add all new files to AK-Cognitive-OS (validators, hooks, schemas, command updates)
- Bump `.ak-cogos-version` to 4.0.0
- Run `bash scripts/validate-framework.sh` — must PASS

**Step 2 — Upgrade a project (per-project)**
```bash
bash scripts/remediate-project.sh /path/to/project --v4-upgrade
```
Script actions:
- Creates `memory/`, `feedback/`, `signals/` with placeholder files
- Appends 3 new hooks to `settings.json`
- Copies updated command files for architect, session-open, session-close, qa-run, risk-manager, lessons-extractor
- Does NOT overwrite any existing project files

**Step 3 — Backfill historical memory (optional)**
```bash
python3 validators/memory.py --backfill /path/to/project
```
- Reads `releases/session-*.md` files
- Constructs skeleton memory entries from existing session archives
- Populates `memory/sessions/` and updates `memory/index.json`
- Leaves `memory/MEMORY.md` for architect to review and trim

**Step 4 — Verify**
```bash
python3 validators/runner.py
```
All 3 new validators run advisory. Any WARN entries are logged but do not block.

### Phased Enforcement

| Version | Memory | Feedback | Signals |
|---|---|---|---|
| v4.0 | Advisory (WARN) | Advisory (WARN) | Advisory only |
| v4.1 | Enforced (FAIL) | Enforced (FAIL) | Signals gate architect session open |
| v4.2 | Full (backfill required) | Full (coverage check) | Signals gate risk-manager |

### Minimal Disruption Path

A project can run v4 with no behaviour change by simply not creating the v4 folders. The new hooks are advisory and exit 0 when the folders are absent. The new validators emit WARN only. The new context budget additions in commands gracefully degrade when files are missing.

---

## Appendix A — Security Model

| Concern | Decision |
|---|---|
| Who writes memory? | Only `auto-memory-write.sh` (Stop hook) and `/lessons-extractor` (on AK approval). No persona writes directly. |
| Who reads memory? | All personas — read-only via context budget load. |
| PII/PHI in memory? | Memory entries must not contain raw user data. Task IDs and outcome codes only. If project handles PII, memory stores references, not values. |
| Feedback data integrity | Feedback files are append-only JSON. No file is mutated after write. |
| Signal injection | `signal_engine.py` reads only local files. No network calls. No shell exec from signal content. |
| Audit trail | All memory writes are also logged to `tasks/audit-log.md` via `auto-audit-log.sh`. |

---

## Appendix B — SOLO_CLAUDE vs COMBINED Mode

| Feature | SOLO_CLAUDE | COMBINED |
|---|---|---|
| Memory reads | Claude reads MEMORY.md as context | Same |
| Memory writes | `auto-memory-write.sh` writes at Stop | Same |
| Signal engine | `python3 validators/signal_engine.py` | Same |
| Feedback capture | `auto-feedback-capture.sh` writes JSON | Same |
| MCP servers | ak-state-machine + ak-audit-log (existing) | Same + additional MCP tools if wired |

No mode-specific code paths. v4 subsystems are fully portable.

---

*Architecture approved by: PENDING AK APPROVAL*
*Next step: BA confirms business logic requirements → Junior Dev implements tasks*
