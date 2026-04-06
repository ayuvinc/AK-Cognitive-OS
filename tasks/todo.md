## SESSION STATE
Status:         OPEN
Active task:    TASK-FIX-001 through TASK-FIX-005 (hook/MCP fix sprint)
Active persona: architect
Blocking issue: none
Last updated:   2026-04-06T00:10:00Z — Session 19, Architect check pass + design correction

---

## TASK-FIX-001 — Fix guard-session-state.sh + session-open/close fallback path
- Status: QA_APPROVED
- Owner: Junior Dev
- Priority: P0 — blocks all session-open/close in every bootstrapped project when MCP is down
- Description: Three-part fix:
  (A) guard-session-state.sh: replace dead ACTIVE_SKILL env var check with flag file read.
      Guard reads tasks/.session-transition-lock. If file present and fresh (<30 min): ALLOW.
      If file absent: BLOCK. If file >30 min old: BLOCK with STALE_LOCK_FLAG.
  (B) session-open.md: add explicit fallback path for MCP unavailability. When MCP call
      fails with anything other than INVALID_TRANSITION, emit WARN (not BLOCKED) and fall
      back to: (1) create tasks/.session-transition-lock, (2) update SESSION STATE fields
      directly via Bash python3 file edit, (3) delete tasks/.session-transition-lock.
  (C) session-close.md: same fallback path at step 10 (mcp__ak-state-machine__transition_session
      to CLOSED). MCP failure -> WARN -> lock file -> python3 file edit -> delete lock.
- Files touched:
    scripts/hooks/guard-session-state.sh
    .claude/commands/session-open.md   (add fallback path)
    .claude/commands/session-close.md  (add fallback path at step 10-11)
- Constraints:
    Lock file content = skill name (session-open or session-close)
    Guard: stale check = mtime >30 min -> STALE_LOCK_FLAG with manual delete instructions
    Skills: use bash trap ERR EXIT to delete lock file on any exit (normal and error)
    Lock file must NOT be committed (.gitignore tasks/.session-transition-lock)
    Fallback path emits WARN to audit log: "MCP unavailable — fell back to direct file write"
    INVALID_TRANSITION from MCP is still BLOCKED (session already open/closed — real error)
    MCP path remains primary. Fallback is last resort, not default.
#### AC — TASK-FIX-001
**guard-session-state.sh (part A)**
- [ ] With no lock file present: Edit to tasks/todo.md touching SESSION STATE is BLOCKED with existing message
- [ ] With fresh lock file (content = "session-open", mtime <30 min): Edit to SESSION STATE is ALLOWED
- [ ] With fresh lock file (content = "session-close", mtime <30 min): Edit to SESSION STATE is ALLOWED
- [ ] With stale lock file (mtime >30 min): Edit is BLOCKED with message containing "STALE_LOCK_FLAG" and manual delete instructions
- [ ] Lock file content other than "session-open" or "session-close": Edit is BLOCKED
- [ ] Edit to tasks/todo.md that does NOT touch SESSION STATE content: ALLOWED regardless of lock file state
- [ ] Edit to any file other than tasks/todo.md: ALLOWED (hook does not fire)

**session-open.md fallback path (part B)**
- [ ] MCP available: transition_session succeeds -> SESSION STATE updated via MCP, no lock file created, no fallback warning in output
- [ ] MCP unavailable (import error or server not running): session-open emits WARN (not BLOCKED), falls back to direct file write
- [ ] Fallback path: tasks/.session-transition-lock is created before STATE is written and deleted after
- [ ] Fallback path: audit log contains entry with "MCP unavailable — fell back to direct file write"
- [ ] Fallback path: SESSION STATE Status field reads OPEN after completion
- [ ] Fallback path: SESSION STATE Active persona field reads correct persona after completion
- [ ] MCP returns INVALID_TRANSITION (session already open): session-open emits BLOCKED with SESSION_STATE_VIOLATION — fallback does NOT activate
- [ ] Simulate crash after lock file created (delete lock manually, re-run): guard blocks with STALE_LOCK_FLAG after 30 min; blocks cleanly before 30 min

**session-close.md fallback path (part C)**
- [ ] MCP unavailable at step 10: session-close emits WARN, falls back to direct file write, SESSION STATE Status reads CLOSED after
- [ ] Fallback path lock file created before write and deleted after
- [ ] MCP returns INVALID_TRANSITION (session already closed): BLOCKED, fallback does NOT activate
- [ ] tasks/.session-transition-lock does not appear in git status after a complete session-open or session-close run (normal or fallback path)

**Edge cases**
- [ ] tasks/todo.md does not exist: guard exits 0 (hook only applies to todo.md edits — non-existent file means no match)
- [ ] Lock file directory (tasks/) does not exist: fallback path creates it before writing lock
- Security model:
    Auth: only session-open and session-close create the lock
    Abuse: stale lock (crash) detected by mtime >30 min -> STALE_LOCK_FLAG
    Audit: lock create/delete + fallback activation logged to tasks/audit-log.md

## TASK-FIX-002 — Fix guard-git-push.sh: read Active persona from SESSION STATE in tasks/todo.md
- Status: QA_APPROVED
- Owner: Junior Dev
- Priority: P0 — blocks all git push to main in every bootstrapped project
- Description: guard-git-push.sh checks ACTIVE_PERSONA env var that Claude Code never sets.
  Replace with a direct read of "Active persona:" from the SESSION STATE block in tasks/todo.md.
  tasks/todo.md is the single source of truth — no separate file needed.
- Files touched:
    scripts/hooks/guard-git-push.sh
- Constraints:
    Read Active persona field using python3 (same regex pattern as state_machine_server.py)
    If tasks/todo.md missing or Active persona field empty -> BLOCK (same behavior as before)
    If Active persona = "none" (session closed) -> BLOCK with "no active session"
    Must not break QA_APPROVED / codex-review / security gate logic in the hook
    No changes to session-open.md or session-close.md (SESSION STATE already written correctly)
#### AC — TASK-FIX-002
**Persona read from SESSION STATE**
- [ ] SESSION STATE Active persona = "architect", git push to main: persona gate PASSES (proceeds to QA_APPROVED and other gates)
- [ ] SESSION STATE Active persona = "junior-dev", git push to main: BLOCKED with message naming the active persona
- [ ] SESSION STATE Active persona = "qa", git push to main: BLOCKED
- [ ] SESSION STATE Active persona = "none" (session closed): BLOCKED with "no active session" message
- [ ] SESSION STATE Active persona field missing or empty: BLOCKED
- [ ] tasks/todo.md does not exist: BLOCKED (same behavior as before this fix)

**Existing gates not broken**
- [ ] With Active persona = "architect" but no QA_APPROVED task: BLOCKED by QA_APPROVED gate (unchanged)
- [ ] With Active persona = "architect", QA_APPROVED present, codex-review FAIL: BLOCKED by codex gate (unchanged)
- [ ] With Active persona = "architect", QA_APPROVED present, open Security risk: BLOCKED by security gate (unchanged)
- [ ] git push to feature branch (not main/master): ALLOWED regardless of Active persona value
- [ ] git push --force: BLOCKED regardless of Active persona value (force-push gate unchanged)

**No regression**
- [ ] ACTIVE_PERSONA env var set to "architect": has NO effect on gate result (env var is no longer read)
- [ ] ACTIVE_PERSONA env var unset: gate reads tasks/todo.md — same result as before
- Security model:
    Auth: SESSION STATE is written only via MCP or fallback path (TASK-FIX-001 governs this)
    No PII/PHI
    Audit: no new audit requirement — persona is already logged at session-open

## TASK-FIX-003 — Fix bootstrap: copy requirements.txt + pip install MCP
- Status: QA_APPROVED
- Owner: Junior Dev
- Priority: P0 — every new bootstrap produces a project with broken MCP servers
- Description: mcp-servers/requirements.txt exists in source but is NOT copied to project-template
  and bootstrap has no pip install step. All new projects start with broken MCP.
- Files touched:
    project-template/mcp-servers/requirements.txt  (create with content: mcp>=1.0.0)
    scripts/bootstrap-project.sh                   (add pip3 install step after mcp-servers copy)
- Constraints:
    pip install is non-fatal: emit WARN on failure, not ERROR (venv/conda envs may differ)
    Print pip output on failure only
    After install, verify python3 -c "import mcp" -> emit visible WARN block on failure
    WARN block must include exact remediation command: pip3 install mcp>=1.0.0
    requirements.txt: only mcp>=1.0.0, no unpinned deps
#### AC — TASK-FIX-003
**requirements.txt in project-template**
- [ ] File project-template/mcp-servers/requirements.txt exists after this task
- [ ] File contains exactly one dependency line: mcp>=1.0.0 (no additional deps, no loose pins)
- [ ] File does not contain unpinned or wildcard specifiers (e.g. mcp, mcp==*, mcp>0)

**bootstrap-project.sh pip install step**
- [ ] Running bootstrap on a clean directory results in pip3 install being invoked on mcp-servers/requirements.txt
- [ ] pip install step executes AFTER mcp-servers/ files are copied (not before)
- [ ] On pip install success: no pip output printed, bootstrap continues normally
- [ ] On pip install failure: bootstrap does NOT exit with error; prints a visible WARN block (multi-line, clearly delimited — not a single inline message)
- [ ] WARN block on failure includes exact remediation command: pip3 install mcp>=1.0.0
- [ ] After pip install (success or failure): bootstrap runs python3 -c "import mcp" to verify
- [ ] Verification failure: emits a second WARN stating mcp is not importable with same remediation command
- [ ] bootstrap exit code is 0 even when pip install fails (non-fatal)

**End-to-end verification**
- [ ] After a fresh bootstrap run on a machine where mcp was not previously installed: python3 -c "import mcp; print('ok')" exits 0 in the new project directory
- [ ] After bootstrap: mcp-servers/state_machine_server.py can be started without ImportError
- [ ] After bootstrap: mcp-servers/audit_log_server.py can be started without ImportError
- Security model: no auth/PII/PHI; no unpinned deps

## TASK-FIX-004 — Normalize SESSION STATE format: remove code fences from project-template
- Status: QA_APPROVED
- Owner: Junior Dev
- Priority: P1 — format inconsistency across all bootstrapped projects
- Description: project-template/tasks/todo.md wraps SESSION STATE in markdown code fences.
  AK-Cognitive-OS source does not. Normalize to plain text.
- Files touched:
    project-template/tasks/todo.md  (remove backtick fences around SESSION STATE content only)
- Constraints:
    Do NOT touch forensic-ai/tasks/todo.md — session is OPEN (defer to that project next close)
    Transplant-workflow/tasks/todo.md — fix safe (CLOSED); handle in TASK-FIX-005
    Do NOT change any field values — format change only
#### AC — TASK-FIX-004
**Format change — project-template only**
- [ ] project-template/tasks/todo.md contains no backtick code fences (```) anywhere in the file
- [ ] All SESSION STATE field values are identical before and after the change (Status, Active task, Active persona, Blocking issue, Last updated)
- [ ] The "## SESSION STATE" heading is present and unmodified
- [ ] The MCP server state_machine_server.py can parse the updated template file: python3 -c "from mcp-servers.state_machine_server import get_session_state" (or equivalent import test) succeeds without error
- [ ] guard-session-state.sh grep for "SESSION STATE" in the updated template file exits 0

**Scope enforcement**
- [ ] forensic-ai/tasks/todo.md is byte-for-byte identical before and after this task (no modification)
- [ ] Transplant-workflow/tasks/todo.md is NOT touched by this task (deferred to TASK-FIX-005)
- [ ] AK-Cognitive-OS/tasks/todo.md is NOT touched by this task (production file, not template)

## TASK-FIX-005 — Sync hook fixes to all downstream projects
- Status: QA_APPROVED
- Owner: Junior Dev
- Priority: P1 — downstream projects carry broken hooks until synced
- Description: After source fixes complete, copy updated hooks + requirements.txt to all
  bootstrapped projects. Fix Transplant-workflow SESSION STATE code fences (CLOSED).
  Also sync updated session-open.md and session-close.md contracts where safe.
- Per-project actions:
    Copy: scripts/hooks/guard-session-state.sh
    Copy: scripts/hooks/guard-git-push.sh
    Copy: mcp-servers/requirements.txt (create if missing)
    Copy: .claude/commands/session-open.md (SKIP Transplant-workflow — already fixed in S-012; diff first)
    Copy: .claude/commands/session-close.md (SKIP Transplant-workflow — already fixed in S-012; diff first)
    Run: pip3 install -r mcp-servers/requirements.txt (in each project dir)
    Verify: python3 -c "import mcp; print(ok)"
    Transplant-workflow only: remove code fences from tasks/todo.md SESSION STATE block
- Projects: forensic-ai, Transplant-workflow, Pharma-Base, policybrain
  (absolute paths: /Users/akaushal011/<project>)
- Constraints:
    Diff each file against source BEFORE copying — log diff summary in commit message
    Do NOT overwrite task content in tasks/todo.md (hook and contract files only)
    Do NOT touch forensic-ai/tasks/todo.md at all (OPEN session)
    Commit in each project: fix: sync hook env-var fix from AK-Cognitive-OS source
    If diff shows downstream has diverged from source in a meaningful way, STOP and flag to AK
#### AC — TASK-FIX-005
**Hook sync — all 4 projects**
- [ ] forensic-ai/scripts/hooks/guard-session-state.sh matches AK-Cognitive-OS source (diff exits 0)
- [ ] forensic-ai/scripts/hooks/guard-git-push.sh matches AK-Cognitive-OS source (diff exits 0)
- [ ] Transplant-workflow/scripts/hooks/guard-session-state.sh matches AK-Cognitive-OS source
- [ ] Transplant-workflow/scripts/hooks/guard-git-push.sh matches AK-Cognitive-OS source
- [ ] Pharma-Base/scripts/hooks/guard-session-state.sh matches AK-Cognitive-OS source
- [ ] Pharma-Base/scripts/hooks/guard-git-push.sh matches AK-Cognitive-OS source
- [ ] policybrain/scripts/hooks/guard-session-state.sh matches AK-Cognitive-OS source
- [ ] policybrain/scripts/hooks/guard-git-push.sh matches AK-Cognitive-OS source

**requirements.txt and mcp install — all 4 projects**
- [ ] All 4 projects have mcp-servers/requirements.txt containing mcp>=1.0.0
- [ ] python3 -c "import mcp" exits 0 in each of the 4 project directories

**Contract sync — session-open.md and session-close.md**
- [ ] forensic-ai/.claude/commands/session-open.md updated to match AK-Cognitive-OS source
- [ ] forensic-ai/.claude/commands/session-close.md updated to match AK-Cognitive-OS source
- [ ] Transplant-workflow session-open.md and session-close.md: diff was run and result logged in commit message; file was NOT overwritten if Transplant-workflow version diverged (AK must approve any Transplant-workflow contract overwrite separately)
- [ ] Pharma-Base and policybrain session-open.md and session-close.md updated to match source

**SESSION STATE format — Transplant-workflow only**
- [ ] Transplant-workflow/tasks/todo.md SESSION STATE block contains no backtick code fences
- [ ] All SESSION STATE field values in Transplant-workflow are identical before and after (no data loss)

**Scope enforcement**
- [ ] forensic-ai/tasks/todo.md is NOT touched (OPEN session — any modification to this file is a blocker)
- [ ] No tasks/todo.md modified in any project except Transplant-workflow SESSION STATE fence removal

**Commits**
- [ ] Each of the 4 projects has a git commit with message starting: "fix: sync hook env-var fix from AK-Cognitive-OS source"
- [ ] Each commit message includes a summary of which files were changed and any diff notes

**Edge case — diverged downstream**
- [ ] If any hook diff showed meaningful divergence (not whitespace-only), task was stopped and flagged to AK before copying; no silent overwrite occurred
- Security model: no user data, no auth, no network
