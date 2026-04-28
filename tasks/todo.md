## SESSION STATE
Status:         CLOSED
Active task:    none
Active persona: Architect
Blocking issue: none
Last updated:   2026-04-28T04:20:55Z — state transition by MCP server
---

## Active Tasks

<!-- v4 Phase 1 — Memory Foundation — AK approved 2026-04-28 -->

### TASK-002 — ak-memory MCP server + memory/ scaffold
Status:       QA_APPROVED
Owner:        Junior Dev
Priority:     High
Description:  Build the ak-memory MCP server (Python, stdio transport, same pattern as
              ak-state-machine). Exposes 3 tools:
                - mcp__ak-memory__write(type, content, tags, task_id, outcome) — appends entry
                  to memory/index.json and memory/MEMORY.md
                - mcp__ak-memory__query(type, tags, outcome, limit) — filtered retrieval
                  from memory/index.json, most recent first
                - mcp__ak-memory__summary(limit=20) — dense digest for session-open load;
                  returns at most 20 entries, one line each, under 30 tokens per line
              Memory entry schema: entry_id, session, timestamp_utc, type, persona, task_id,
              content, tags[], outcome, severity, linked_entries[]
              Also creates memory/ scaffold: memory/MEMORY.md (placeholder header),
              memory/index.json (empty entries array), memory/sessions/, memory/decisions/,
              memory/outcomes/
              Wiring: add server to .mcp.json (absolute python3 path, absolute server path).
              Add mcp__ak-memory__* permissions to .claude/settings.json.
              Install: pip3 install mcp; verify with python3 -c "import mcp" — fail loudly if
              import fails (do not silently skip).
Security:     Local process only, no network. All personas read; session-close + lessons-
              extractor write only. Memory entries: task IDs and outcome codes — no raw user
              data, no PII. All writes also logged to audit-log.md via auto-audit-log.sh.
AC:
  - [ ] Server starts without error when Claude Code launches; mcp__ak-memory__* tools
        appear in available tool list
  - [ ] mcp__ak-memory__write: appends a new entry to memory/index.json with all required
        fields (entry_id, session, timestamp_utc, type, persona, task_id, content, tags,
        outcome, severity, linked_entries); simultaneously appends one-line digest to
        memory/MEMORY.md
  - [ ] mcp__ak-memory__query: returns correct filtered subset when called with type, tags,
        and outcome filters; results ordered most-recent first; respects limit param
  - [ ] mcp__ak-memory__summary: returns at most 20 entries; each entry is a single line
        under 30 tokens; returns empty list (not error) when memory/index.json has 0 entries
  - [ ] memory/ scaffold created: MEMORY.md with valid header, index.json with empty entries
        array, sessions/ and decisions/ and outcomes/ directories present
  - [ ] .mcp.json entry uses absolute python3 path and absolute server path — no bare
        'python3', no relative paths
  - [ ] .claude/settings.json permissions block includes mcp__ak-memory__write,
        mcp__ak-memory__query, mcp__ak-memory__summary
  - [ ] pip install + import verify runs at server startup; if "import mcp" fails, server
        exits non-zero with explicit error message — does not silently start broken
  - [ ] No memory entry written by the server contains raw user content, code, or PII;
        content field contains task IDs and outcome codes only
  - [ ] Calling mcp__ak-memory__write when memory/index.json is missing or malformed
        returns a structured error — server does not crash
Dependencies: none

### TASK-003 — session-open + session-close contract updates
Status:       QA_APPROVED
Owner:        Junior Dev
Priority:     High
Description:  Update session-open claude-command.md:
                - After lessons read step: call mcp__ak-memory__summary(limit=20)
                - Write flag file tasks/.memory-loaded-session-{N} on success
                - Fallback: if MCP unavailable, read memory/MEMORY.md directly, log WARN
                - Add to handoff extra_fields: memory_loaded: true|false
              Update session-close claude-command.md:
                - Before final STATE write: call mcp__ak-memory__write() with session snapshot
                  (session_id, completed tasks, outcomes, approved lessons)
                - Add to handoff extra_fields: memory_snapshot_written: true|false
                - Add bd compact equivalent: trim memory/MEMORY.md to last 50 entries on write
              Snapshot content: task IDs + outcomes only — no raw code, no user data.
Security:     Reads flag file (no sensitive data). Snapshot contains task IDs only.
              Fallback path profile identical to existing file reads.
AC:
  - [ ] session-open calls mcp__ak-memory__summary(limit=20) after the lessons read step;
        result is visible in session-open output
  - [ ] After successful summary call, flag file tasks/.memory-loaded-session-{N} is written
        where N matches the current session number in SESSION STATE
  - [ ] session-open handoff envelope includes extra field memory_loaded: true when MCP call
        succeeded; memory_loaded: false when fallback path was used
  - [ ] Fallback (MCP unavailable): session-open reads memory/MEMORY.md directly, emits
        WARN "MCP unavailable — reading memory/MEMORY.md directly", does NOT block or exit
        non-zero
  - [ ] Fallback path graceful when memory/MEMORY.md does not exist (fresh project) — emits
        WARN "no memory file found", continues normally
  - [ ] session-close calls mcp__ak-memory__write() with session snapshot before STATE write;
        snapshot contains session_id, completed task IDs, outcomes — no raw code or content
  - [ ] memory/MEMORY.md is trimmed to last 50 entries after session-close write; entries
        beyond 50 are removed from MEMORY.md (index.json retains full history)
  - [ ] session-close handoff envelope includes extra field memory_snapshot_written: true|false
  - [ ] session-close memory write failure (MCP unavailable): logs WARN, does NOT block
        session close — session closes successfully regardless
Dependencies: TASK-002

### TASK-004 — PostToolUse compaction re-injection hook
Status:       QA_APPROVED
Owner:        Junior Dev
Priority:     High
Description:  Create scripts/hooks/auto-memory-reinject.sh.
              PostToolUse hook, matcher: "compact" (fires after every Claude Code compaction).
              On fire: read last 20 lines of memory/MEMORY.md and write to a context-essentials
              temp file; emit contents as a structured WARN block so it lands in the next turn.
              Advisory only — exit 0 always, even on failure.
              Add to .claude/settings.json hooks block (PostToolUse, after existing entries).
              Propagate to project-template/settings.json for bootstrap.
Security:     Read-only from memory/MEMORY.md. No exec from file content. No network.
AC:
  - [ ] Hook entry exists in .claude/settings.json PostToolUse block with matcher "compact"
        pointing to auto-memory-reinject.sh with absolute path
  - [ ] Hook entry exists identically in project-template/.claude/settings.json
  - [ ] Hook fires after a compaction event and emits last 20 lines of memory/MEMORY.md
        as a structured WARN block in the next turn output
  - [ ] Hook exits 0 when memory/MEMORY.md does not exist — no error, no output
  - [ ] Hook exits 0 when memory/MEMORY.md has fewer than 20 lines — emits all available
        lines, no error
  - [ ] Hook exits 0 when memory/MEMORY.md is empty — no output, no error
  - [ ] Hook never executes any content from memory/MEMORY.md — only reads and echoes;
        no eval, no exec, no shell expansion of file contents
Dependencies: TASK-002

### TASK-005 — PreToolUse enforcement hook (memory-loaded gate)
Status:       QA_APPROVED
Owner:        Junior Dev
Priority:     Medium
Description:  Create scripts/hooks/guard-memory-loaded.sh.
              PreToolUse hook. On any high-impact action (session-close, git merge, task
              decomposition write to todo.md): check for flag file
              tasks/.memory-loaded-session-{N} where N = current session number from
              SESSION STATE. If flag missing: emit WARN "memory not loaded this session —
              run mcp__ak-memory__summary before proceeding."
              v4.0 policy: exit 0 (WARN only). Exit 2 promoted in v4.1 after one full cycle.
              Add to .claude/settings.json hooks block.
              Propagate to project-template/settings.json.
Security:     Reads flag file only. Flag could be manually created to bypass — acceptable
              for single-operator local framework.
AC:
  - [ ] Hook entry exists in .claude/settings.json PreToolUse block with absolute path
  - [ ] Hook entry exists identically in project-template/.claude/settings.json
  - [ ] When flag file tasks/.memory-loaded-session-{N} is present: hook exits 0 silently,
        action proceeds normally
  - [ ] When flag file is missing: hook emits WARN "memory not loaded this session —
        run mcp__ak-memory__summary before proceeding" and exits 0 (NOT exit 2 in v4.0)
  - [ ] Hook exits 0 in ALL cases — never blocks in v4.0, verified by running it with and
        without flag file present and confirming exit code is 0 both times
  - [ ] When session number cannot be determined from SESSION STATE: hook exits 0 with
        WARN "could not determine session number — skipping memory check"
  - [ ] Hook reads session number from SESSION STATE in tasks/todo.md, not from a hardcoded
        value or environment variable
Dependencies: TASK-003 (flag file written by session-open)

### TASK-006 — memory.py validator + runner.py update
Status:       QA_APPROVED
Owner:        Junior Dev
Priority:     Medium
Description:  Create validators/memory.py. Checks:
                1. memory/MEMORY.md exists and has valid header
                2. memory/index.json is valid JSON with fields: entries[], last_updated
                3. Every index entry has required fields (entry_id, session, type, content, tags)
                4. MEMORY.md entry count matches index.json total (±5 tolerance for truncation)
              Severity: WARNING in v4.0 (validator exits 0, prints WARN). FAIL in v4.1.
              Update validators/runner.py: auto-discover memory.py alongside existing validators.
              Update scripts/validate-framework.sh: add memory/ structure check.
Security:     Read-only. Validates structure, does not read entry content.
AC:
  - [ ] validators/memory.py exists and is auto-discovered by validators/runner.py without
        any manual registration — same pattern as existing validators
  - [ ] Valid memory/ structure (MEMORY.md present with header, index.json valid JSON with
        entries array): validator exits 0, prints PASS
  - [ ] memory/MEMORY.md missing: validator exits 0, prints WARN (not FAIL, not exit 1)
  - [ ] memory/index.json missing or malformed JSON: validator exits 0, prints WARN
  - [ ] Any index entry missing a required field (entry_id, session, type, content, tags):
        validator exits 0, prints WARN identifying the offending entry_id
  - [ ] Entry count mismatch between MEMORY.md and index.json exceeding ±5 tolerance:
        validator exits 0, prints WARN with actual counts
  - [ ] Entry count within ±5 tolerance: validator exits 0, prints PASS (not WARN)
  - [ ] scripts/validate-framework.sh includes a memory/ structure check that calls
        memory.py and surfaces its output
  - [ ] Validator reads only structural fields — does not read or log entry content values
Dependencies: TASK-002

---

## Backlog

### TASK-001 — Fix remediate-project.sh: generate .mcp.json + set enableAllProjectMcpServers
Status:       QA_APPROVED
Owner:        Junior Dev
Priority:     High
Description:  remediate-project.sh copies mcp-servers/ but does NOT generate .mcp.json or set
              enableAllProjectMcpServers: true in settings.local.json. Any manually-wrapped or
              remediated project ships with MCP tool permissions but no working MCP servers.
              Fix: add both steps to remediate-project.sh, mirroring bootstrap-project.sh logic
              (absolute python3 path, absolute server paths, enableAllProjectMcpServers flag).
Discovered:   2026-04-27 — kundli project (manual wrap, all three MCP artefacts missing)
AC:
  - [ ] Running remediate-project.sh on a project missing .mcp.json generates .mcp.json
        with the same format as bootstrap-project.sh produces — verified by diff against
        a freshly bootstrapped project's .mcp.json structure
  - [ ] Generated .mcp.json uses absolute python3 path (verified: no bare 'python3' string)
        and absolute server script paths (verified: no relative paths)
  - [ ] Running remediate-project.sh sets enableAllProjectMcpServers: true in
        settings.local.json — verified by grep on the output file
  - [ ] Running on a project that already has .mcp.json does NOT overwrite it; script logs
        WARN "skipping .mcp.json — already exists" and continues
  - [ ] Running on a project that already has enableAllProjectMcpServers: true does NOT
        duplicate the flag in settings.local.json
  - [ ] If pip install mcp fails or "import mcp" verification fails: script exits non-zero
        with explicit message naming the remediation command — does not produce a
        silently broken project
  - [ ] Script is idempotent: running it twice on the same project produces the same result
        with no duplicate entries or errors
Dependencies: none

### BACKLOG-001 — v4 Cognitive Layer (full initiative)
Status:       IN PLANNING — Phase 1 decomposed above (TASK-002–006)
Architecture: docs/v4-architecture.md
Decision:     AK approved 2026-04-28: hand-rolled storage + ak-memory MCP server,
              per-project memory scope, per session-close compaction. Beads/Dolt rejected.
Phase 1:      TASK-002–006 (Memory Foundation) — Active Tasks above
Phase 2:      Feedback Loop — decompose after Phase 1 proven
              (feedback schemas, qa-run write, risk-manager write, feedback.py validator)
Phase 3:      Signal Engine — decompose after Phase 2 proven
              (signal_engine.py, 6 detectors, auto-signal-check.sh hook)
Phase 4:      Framework Integration — decompose after Phase 3 proven
              (bootstrap v4 scaffold, remediate --v4-upgrade, validate-framework.sh v4,
               .ak-cogos-version bump to 4.0.0)
Note:         BA waived — internal framework feature, no domain logic. AK PM approval
              2026-04-28 is sufficient authority for all phases.

---

## Archive

<!-- Completed tasks moved here by Architect at sprint close -->
