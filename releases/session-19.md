# Session 19 Release — Hook Env-Var Fix + MCP Bootstrap Fix
# Date: 2026-04-06
# Branch: feature/TASK-FIX-001-005-hook-mcp-fix
# Sprint: hook-mcp-fix (P0 regression sprint)

---

## Summary

Root cause: two independent failures introduced since v2.0 bootstrap:
1. Hooks read `ACTIVE_SKILL` / `ACTIVE_PERSONA` env vars that Claude Code's skill loader never sets → hooks always blocked or always allowed (depending on logic path)
2. `mcp-servers/requirements.txt` missing from project-template → all bootstrapped projects start with broken MCP servers

This sprint fixed both, added file-position SESSION STATE detection (closes Codex-identified bypass), and synced all 4 downstream projects.

---

## Tasks Delivered

| ID | Description | AC | Result |
|---|---|---|---|
| TASK-FIX-001 | guard-session-state.sh: file-position detection + lock file auth; session-open/close MCP fallback path | 17/17 | QA_APPROVED |
| TASK-FIX-002 | guard-git-push.sh: read Active persona from SESSION STATE block (not env var) | 11/11 | QA_APPROVED |
| TASK-FIX-003 | Bootstrap: copy requirements.txt + pip install MCP + import verification | 12/12 | QA_APPROVED |
| TASK-FIX-004 | Normalize SESSION STATE format: remove code fences from project-template | 8/8 | QA_APPROVED |
| TASK-FIX-005 | Sync all fixes to forensic-ai, Transplant-workflow, Pharma-Base, policybrain | 16/17 | QA_APPROVED (1 pre-existing) |

**Total: 64/65 criteria PASS. 1 pre-existing working-tree diff (forensic-ai session 010, not introduced by sprint).**

---

## Key Design Decisions

### File-position detection (guard-session-state.sh)
Replaces heuristic diff-text matching (bypassable). The guard now:
1. Reads `tasks/todo.md` from disk
2. Computes `## SESSION STATE` block character offsets
3. For Edit tool: checks if `old_string` position overlaps the block
4. For Write tool: compares SESSION STATE block content between current and new file

This closes the Codex CRITICAL finding: an attacker can no longer bypass the guard by crafting an edit that changes SESSION STATE without including the literal "SESSION STATE" marker in the diff.

### Lock file path safety (LOCK_FILE)
`LOCK_FILE` passed as `sys.argv[1]` to python3 subprocesses — not inline-expanded into Python string literals. Prevents path injection from special characters.

### project-template exclusion (guard-session-state.sh)
Exact suffix match `*/project-template/tasks/todo.md` replaces substring match `*project-template*`. Prevents accidental bypass for real project paths containing "project-template" as a directory component.

### SESSION STATE block-scoped regex (guard-git-push.sh)
`Active persona:` pattern scoped to `## SESSION STATE` block only — not whole file. Prevents a stray `Active persona: architect` line in a task description from authorizing a non-architect push.

---

## Files Changed

### AK-Cognitive-OS (source)
- `scripts/hooks/guard-session-state.sh` — complete rewrite (file-position detection)
- `scripts/hooks/guard-git-push.sh` — persona read from SESSION STATE block
- `.claude/commands/session-open.md` — MCP fallback path added
- `.claude/commands/session-close.md` — MCP fallback path added at step 10-11
- `project-template/mcp-servers/requirements.txt` — created (mcp>=1.0.0)
- `scripts/bootstrap-project.sh` — pip3 install + import verification
- `project-template/tasks/todo.md` — code fences removed from SESSION STATE
- `.gitignore` — tasks/.session-transition-lock added

### Downstream projects synced
- `forensic-ai`: guard-session-state.sh, guard-git-push.sh, session-open.md, session-close.md, requirements.txt, .gitignore
- `Transplant-workflow`: guard-session-state.sh, guard-git-push.sh, requirements.txt, .gitignore, tasks/todo.md (code fences removed); session contracts NOT overwritten (S-012 divergence flagged to AK)
- `Pharma-Base`: guard-session-state.sh, guard-git-push.sh, session-open.md, session-close.md, requirements.txt, .gitignore
- `policybrain`: guard-session-state.sh, guard-git-push.sh, session-open.md, session-close.md, requirements.txt, .gitignore

---

## Open Items

- forensic-ai/tasks/todo.md: SESSION STATE has code fences (session 010 is OPEN — deferred to session 010 close)
- Transplant-workflow session-open.md / session-close.md: diverged from source (S-012 customizations). AK must approve before overwriting.
- RISK-003 (S1): forensic-ai session 010 working-tree changes uncommitted — will resolve when AK closes session 010
- RISK-004 (S1): Transplant-workflow contract divergence — AK must review before next Transplant-workflow session

---

## Codex Review

VERDICT: FAIL (initial) → PASS (after fixes)
4 real bugs found and fixed. CRITICAL (bypass via heuristic detection) closed.
