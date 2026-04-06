# Risk Register — AK Cognitive OS
# Permanent — never deleted

<!--
FORMAT:

### RISK-[NNN] — Short risk title
- Status:     OPEN | ACCEPTED | MITIGATED | CLOSED
- Severity:   S0 | S1 | S2
- Task:       [TASK-ID or "cross-cutting"]
- Identified: [ISO-8601 date]
- Owner:      AK | Architect | Junior Dev
- Risk:       [One sentence — what could go wrong]
- Impact:     [One sentence — what happens if it does]
- Mitigation: [What is being done or should be done]
- Resolution: [How it was closed — or blank if still open]
-->

---

### RISK-001 — Orphan lock file blocks all future session transitions
- Status:     ACCEPTED
- Severity:   S0
- Task:       TASK-FIX-001
- Identified: 2026-04-06
- Owner:      Junior Dev
- Risk:       If session-open or session-close crashes mid-execution after creating
              tasks/.session-transition-lock but before deleting it, the file persists
              and all subsequent session transitions are blocked by the guard.
- Impact:     Session cannot be opened or closed until the stale lock is manually removed;
              no graceful recovery path without operator intervention.
- Mitigation: Guard must check lock file mtime — if >30 min old, emit STALE_LOCK_FLAG and
              block with instructions to delete manually. Skills must delete lock on trap
              (bash trap ERR EXIT). Architect has specified this constraint in TASK-FIX-001.
- Resolution: Accepted by AK 2026-04-06. Mitigations (bash trap + 30-min stale expiry +
              manual recovery command in error message) deemed adequate for a local
              config-file-driven framework with single operator.

### RISK-002 — Orphan .active-persona file causes wrong persona detection (VOIDED by design change)
- Status:     CLOSED
- Severity:   S1
- Task:       TASK-FIX-002
- Identified: 2026-04-06
- Owner:      Architect
- Risk:       Separate .active-persona file could persist across sessions with stale persona value.
- Impact:     Voided — design revised. TASK-FIX-002 now reads Active persona directly from
              SESSION STATE in tasks/todo.md (single source of truth). No separate file is created.
- Mitigation: N/A
- Resolution: Closed — design change eliminates the risk. Architect check pass 2026-04-06.

### RISK-003 — pip install step in bootstrap fails silently in restricted environments
- Status:     OPEN
- Severity:   S1
- Task:       TASK-FIX-003
- Identified: 2026-04-06
- Owner:      Junior Dev
- Risk:       If pip3 install fails (venv not active, conda env, permissions restriction) and
              the bootstrap script only emits a warning, the project appears successfully
              bootstrapped but MCP servers will not work at runtime.
- Impact:     Developer opens a freshly bootstrapped project, runs /session-open, hits the
              same MCP unavailability failure that triggered this sprint — no visible indicator
              at bootstrap time that MCP is broken.
- Mitigation: Bootstrap must verify import after install attempt (python3 -c "import mcp") and
              emit a clearly visible WARN block (not just a one-liner) if verification fails.
              WARN block must include exact remediation command. Architect constraint in TASK-FIX-003.
- Resolution:

### RISK-004 — Hook sync to downstream projects overwrites project-specific customizations
- Status:     MITIGATED
- Severity:   S1
- Task:       TASK-FIX-005
- Identified: 2026-04-06
- Owner:      Junior Dev
- Risk:       Copying guard-session-state.sh and guard-git-push.sh from AK-Cognitive-OS source
              to downstream projects may overwrite customizations made in those projects
              (e.g. Transplant-workflow S-012 manual fixes to session-open/close contracts).
- Impact:     A downstream project's manually applied fix is silently reverted; next session
              fails with the old error again.
- Mitigation: Before copying, diff each hook against source. If different, log the diff to
              the commit message so AK can review. Do not overwrite session-open/close contracts
              (those are not in scope for TASK-FIX-005 — only the hook .sh files are copied).
              Transplant-workflow already has mcp installed and contracts updated — verify those
              are not regressed by hook sync.
- Resolution: Session-19 — Transplant-workflow session contracts merged (not overwritten).
              Fallback path + PLANNING_SESSION handling added; S-012 customizations preserved.
              Committed to Transplant-workflow main (986fee9). 2026-04-06.

### RISK-005 — forensic-ai SESSION STATE code-fence format deferred — risk of future MCP parsing failure
- Status:     ACCEPTED
- Severity:   S2
- Task:       TASK-FIX-004
- Identified: 2026-04-06
- Owner:      Architect
- Risk:       forensic-ai/tasks/todo.md has SESSION STATE in code fences; fix is deferred
              because its session is currently OPEN. If the MCP server's regex behaviour
              changes or a future validator enforces plain-text format, forensic-ai will
              need a manual fix during a live session.
- Impact:     Minor — MCP server currently handles code-fence format correctly via regex.
              Risk is low until a stricter validator is added.
- Mitigation: Fix is queued for forensic-ai's next session-close. Architect to add reminder
              to forensic-ai/tasks/next-action.md when this session closes.
- Resolution: Accepted by Architect pending forensic-ai session close.
