# Lessons Learned — [PROJECT_NAME]

<!--
One entry per lesson. Architect adds after any correction or new discovery.
Review last 10 entries at every session start.
Tag [EXPORT: generic] for lessons that belong in the framework, not just this project.
-->

---

- 2026-04-02: When adding new personas or sub-personas, ship the full contract set together (`claude-command.md`, `codex-prompt.md`, `schema.md`, and any command-install wiring) or the framework will look complete in-tree while remaining only partially integrated.
- 2026-04-02: Session closeout should record environment-level validation limits explicitly. In this repo, repo-root `npm run build` and `npx tsc --noEmit` are not meaningful checks until a root workspace manifest or scoped validation target exists.
- 2026-04-04: [PROCESS] QA acceptance criteria must be written before a task leaves PENDING — not retroactively. When the Acceptance Criteria field still reads the placeholder text, the workflow must treat that as a blocker on IN_PROGRESS. The Architect is responsible for ensuring QA fills criteria before dispatching Junior Dev.
- 2026-04-05: [ARCHITECTURE] When normalizing a file set that contains mixed formats, declare format classes explicitly rather than forcing homogenization. The .claude/commands/ directory contains three legitimate classes (persona-card, role-card, reference-doc). Structural validation must check format class first, then apply class-appropriate requirements.
- 2026-04-08: [HOOK] UserPromptSubmit hooks that parse stdin to detect specific prompts for passthrough WILL deadlock. If the parse fails (empty stdin, JSON error), the passthrough check silently fails — blocking the very command meant to satisfy the gate. Design rule: UserPromptSubmit gating hooks must use flag files only (see auto-codex-prep.sh pattern). Never parse stdin to detect /command passthrough. [EXPORT: generic]
- 2026-04-05: [HOOK] guard-git-push.sh requires ACTIVE_PERSONA env var which Claude Code's skill loader does not propagate. Workaround: prefix git push with ACTIVE_PERSONA=architect. The QA_APPROVED check passes because the template comment in tasks/todo.md always contains that string — this is incidental, not by design. [EXPORT: generic]
- 2026-04-06: [HOOK] guard-session-state.sh must use file-position detection, not diff-text matching. Reading the actual target file from disk and computing SESSION STATE block offsets closes the bypass where an attacker omits the "SESSION STATE" marker from old_string/new_string. Heuristic grep on diff content is always bypassable. [EXPORT: generic]
- 2026-04-06: [HOOK] Never embed shell variables inside python3 single-quoted heredoc literals — pass them as positional args (sys.argv[1]). Paths with quotes, backslashes, or newlines will break the Python string literal silently. [EXPORT: generic]
- 2026-04-06: [HOOK] Regex scoping matters: reading Active persona with re.MULTILINE from the whole file matches the first occurrence anywhere, including task descriptions. Always scope the regex to the SESSION STATE block by extracting it first, then searching. [EXPORT: generic]
- 2026-04-06: [BOOTSTRAP] requirements.txt for MCP servers was missing from project-template, causing all bootstrapped projects to ship with broken MCP. The bootstrap script must pip install + verify import after copying any dependency-bearing directory. [EXPORT: generic]
- 2026-04-06: [PROCESS] When a Codex review returns FAIL, Junior Dev must fix only what Codex flagged — then route straight to qa-run without a second Codex pass, unless the fix touched new logic paths. Second Codex passes on targeted bug fixes add token cost without proportionate risk reduction.
- 2026-04-08: [HOOK] Blocking `UserPromptSubmit` gates must always preserve a reliable escape hatch for the command that satisfies the gate. If command-aware bypass logic is used at all, it must be explicit, deterministic, and validated against actual prompt payload shape. [EXPORT: generic]
- 2026-04-08: [MCP] Server availability failures are often configuration failures, not server-code failures. Check launch cwd assumptions, script paths, `PROJECT_ROOT`, and log-path resolution before changing MCP server implementation. [EXPORT: generic]
- 2026-04-08: [MCP] Framework-generated MCP config should not use cwd-dependent relative paths for server startup or critical env vars; bootstrap/remediation should emit project-stable absolute paths or equivalent deterministic resolution. [EXPORT: generic]
