---
Status: confirmed
Source: user-confirmed
Last confirmed with user: 2026-04-05
Owner: AK
Open questions: 0
---

# Scope Brief

## Must-Have

Features that must ship. Without these the framework has no value.

- [x] Persona role cards with CAN/CANNOT boundary enforcement (27 personas)
- [x] Reusable skill contracts invokable by any persona (15 skills)
- [x] 10-field output envelope mandatory on all skill/persona output
- [x] Hooks wired in `.claude/settings.json` enforcing session state, persona boundaries, git push, audit log, and envelope validation
- [x] Bootstrap script to scaffold new projects from the template
- [x] Session open/close workflow with audit trail
- [x] Framework validation suite (`validate-framework.sh`, `validators/runner.py`)

## Should-Have

Important but can ship in a fast-follow.

- [x] Schema validators with structured PASS/WARN/FAIL output and JSON format option
- [x] Planning doc templates with metadata headers and confirmation gates
- [x] MCP server stubs (state machine, audit log) for future tool integration
- [ ] docs/lld/ directory with LLD per major framework subsystem

## Cut-for-Now

Explicitly deferred.

- [ ] Web UI for session management or task board
- [ ] Multi-user or team collaboration support
- [ ] Automatic PR creation or CI/CD integration beyond hook enforcement
- [ ] Natural language task parsing (tasks are written by Architect in structured Markdown)

## Explicit Out-of-Scope

- Model hosting, fine-tuning, or inference infrastructure
- Database or persistent storage (framework is entirely config-file driven)
- Authentication or access control (single-user CLI tool)
- Integration with Linear, Jira, or other external project management tools

## Delivery Target

| Field | Value |
|-------|-------|
| Target | production (v3.0 shipped) |
| Success metric | Full BA → QA cycle executable on any bootstrapped project without manual role re-statement |
| Deadline | Delivered — v3.0 released 2026-04-05 |

## Constraints and Dependencies

| Constraint | Impact |
|-----------|--------|
| Python 3.8+ stdlib only in validators | No third-party validator dependencies |
| Claude Code CLI runtime only | No browser, no server, no persistent process |
| Bash hooks must be POSIX-compatible | Hooks run on macOS and Linux without modification |
| No environment variables | All configuration is file-driven; secrets never enter the framework |
