# Session 25 — v4 Phase 1: Memory Foundation

**Date:** 2026-04-28
**Sprint:** main
**Merged commit:** feat: v4 Phase 1 — Memory Foundation (TASK-001–006)
**Framework validation:** PASS (20/20 structural + memory validator PASS)

---

## Tasks Completed

### TASK-001 — Fix remediate-project.sh: .mcp.json + enableAllProjectMcpServers
**Branch:** feature/TASK-001-remediate-mcp-fix
**Status:** QA_APPROVED

Added Steps 8a/8b/8c to remediate-project.sh:
- 8a: Generate .mcp.json with absolute python3 path and absolute server paths (idempotent — skips if file exists)
- 8b: Set enableAllProjectMcpServers: true in .claude/settings.json via sys.argv Python (injection-safe)
- 8c: pip install mcp + import verify; exits non-zero with MCP_BROKEN flag if either fails

Codex fixes applied: Step 8b path-via-sys.argv (Q7); $PYTHON3_BIN for pip+verify (Q9); MCP_BROKEN exit-code (QA_REJECTED → fix → QA_APPROVED).

---

### TASK-002 — ak-memory MCP server + memory/ scaffold
**Branch:** feature/TASK-002-ak-memory-mcp-server
**Status:** QA_APPROVED

New file: `mcp-servers/memory_server.py` — stdio MCP server, 3 tools:
- `write(type, content, tags, task_id, outcome, persona, session, severity, linked_entries)` — appends to index.json, rebuilds MEMORY.md
- `query(type, tags, outcome, persona, limit)` — filtered retrieval, most-recent-first
- `summary(limit=20)` — dense single-line digest for session-open context load

Entry schema: MEM-NNN, session, timestamp_utc, type, persona, task_id, content (≤500 chars), tags[], outcome, severity, linked_entries[]

Scaffolds created: memory/index.json, memory/MEMORY.md, memory/sessions/, memory/decisions/, memory/outcomes/
Wired: .mcp.json (absolute paths), .claude/settings.json (mcp__ak-memory__* permissions)

Codex fix: _next_entry_id uses max(existing IDs)+1 (Q1).

---

### TASK-003 — session-open + session-close contract updates
**Branch:** feature/TASK-003-session-memory-contracts
**Status:** QA_APPROVED (covers TASK-003, TASK-004, TASK-005)

session-open: calls mcp__ak-memory__summary(limit=20) after lessons read; writes tasks/.memory-loaded-session-{N} on success; fallback to MEMORY.md direct read on MCP unavailable; memory_loaded: true|false in handoff.

session-close: step 10a (after CLOSED transition) calls mcp__ak-memory__write() with session snapshot (task IDs + outcomes only); memory_snapshot_written: true|false in handoff; MEMORY.md auto-trimmed to 50 entries by server.

Codex fix: memory write moved from 9a (before CLOSED) to 10a (after CLOSED) — prevents duplicate snapshots on retried close (Q6).

---

### TASK-004 — PostToolUse compaction re-injection hook
**Branch:** feature/TASK-003-session-memory-contracts
**Status:** QA_APPROVED

New file: `scripts/hooks/auto-memory-reinject.sh`
- Fires on PostToolUse "compact" event
- Reads last 20 lines of memory/MEMORY.md via `tail -n 20`
- Emits as [MEMORY-REINJECT] block — re-surfaces memory digest after context compaction
- printf '%s\n' "$LINES" — no eval, no shell expansion of file content (Q4 confirmed)
- Exits 0 always; wired in .claude/settings.json and project-template/.claude/settings.json

---

### TASK-005 — PreToolUse enforcement hook (memory-loaded gate)
**Branch:** feature/TASK-003-session-memory-contracts
**Status:** QA_APPROVED

New file: `scripts/hooks/guard-memory-loaded.sh`
- Fires on PreToolUse Write|Edit
- Extracts session number from SESSION STATE Last updated (fallback path) OR audit log run_id (MCP primary path — Q5 fix)
- Checks tasks/.memory-loaded-session-{N} flag file
- Missing flag: WARN "[MEMORY-GATE] memory not loaded this session" → exit 0 (advisory, v4.0)
- All paths exit 0; wired in .claude/settings.json and project-template/.claude/settings.json

Codex fix: audit-log fallback for session number extraction (Q5).

---

### TASK-006 — memory.py validator + runner.py update
**Branch:** feature/TASK-006-memory-validator
**Status:** QA_APPROVED

New file: `validators/memory.py` — auto-discovered by runner.py (ValidatorResult pattern)
Four checks (all WARN in v4.0, exit 0):
1. memory/MEMORY.md exists + starts with "# Memory Index"
2. memory/index.json valid JSON + entries[] + last_updated fields
3. Every entry has required fields (entry_id, session, timestamp_utc, type, content, tags)
4. MEMORY.md entry count vs index.json count within ±5 tolerance

validate-framework.sh: Step 15b added — calls memory.py advisory, labels output "(v4-advisory)"

---

## Architecture Decisions (AK Approved 2026-04-28)

- Hand-rolled JSON/Markdown storage — no Dolt, no beads, no external DB
- Per-project memory scope — memory/ lives in each project repo
- Per session-close compaction — MEMORY.md trimmed to last 50 entries automatically
- ak-memory MCP server — 3 tools (write/query/summary), stdio transport
- All v4.0 hooks advisory (exit 0) — enforcement (exit 2) promoted in v4.1 after one proven cycle
- BA waived — internal framework feature; AK PM approval sufficient

## Codex Review

CONDITIONAL_PASS → all 3 required fixes + 2 hardening items applied before merge.
See channel.md for full per-question findings.

## Phase 2 (Next)

Feedback Loop — decompose after Phase 1 proven in production:
- feedback schemas
- qa-run write to memory
- risk-manager write to memory
- feedback.py validator
