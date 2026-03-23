# WORK_LOG.md — AK Cognitive OS Framework

This file tracks what has been done to the framework itself across sessions.
Read this first at the start of any framework improvement session.

---

## Current State

**Last session:** Session 2
**Next action:** Sprint 3 — sub-persona CLI commands + schema validation
**GitHub:** https://github.com/ayuvinc/AK-Cognitive-OS

---

## Sprint Log

### Sprint 1 — Bootstrap + Examples
**Done:**
- Fixed `scripts/bootstrap-project.sh` to copy `CODEX_START.md` and `CLAUDE_START.md` into new projects (was missing)
- Populated `examples/saas-minimal/` with full task dirs, releases, ba-logic, ux-specs, lessons, risk-register, audit log
- Populated `examples/rag-minimal/` with same — based on a RAG document Q&A app

**Files changed:**
- `scripts/bootstrap-project.sh`
- `examples/saas-minimal/tasks/` (ba-logic.md, ux-specs.md, lessons.md, risk-register.md)
- `examples/saas-minimal/releases/` (session-1.md, audit-log.md)
- `examples/rag-minimal/tasks/` (same)
- `examples/rag-minimal/releases/` (session-1.md, audit-log.md)

---

### Sprint 2 — Session Template + Harnesses
**Done:**
- Created `framework/templates/session-summary.md` — reusable template for sprint summaries
- Created 10 harnesses in `harnesses/` — one per persona and key skill, each with pass/fail/BLOCKED fixtures

**Harnesses created:**
- `ba-harness.md`, `ux-harness.md`, `qa-harness.md`, `junior-dev-harness.md`, `researcher-harness.md`
- `session-open-harness.md`, `security-sweep-harness.md`, `regression-guard-harness.md`
- `review-packet-harness.md`, `qa-run-harness.md`

---

### Sprint 3 — PENDING
**Planned:**
- TASK-006: Promote sub-personas to invocable slash commands
  - researcher sub-personas: legal, business, policy, news, technical → `/researcher-legal` etc.
  - compliance sub-personas: data-privacy, data-security, pii-handler, phi-handler → `/compliance-data-privacy` etc.
- TASK-007: Add YAML frontmatter validation to `scripts/validate-framework.sh`
  - Each SKILL.md must have `name`, `description`, `tools` fields
  - Script exits non-zero if any are missing

---

## Earlier Work (Pre-Sprint)

**Plugin conversion (before sprints):**
- Added `.claude-plugin/plugin.json` manifest — makes repo installable as a Claude Code plugin
- Added `SKILL.md` to every skill and persona folder — Claude Code native format
- Updated all 7 persona `claude-command.md` and `SKILL.md` files with **Interactive mode** instruction — personas now ask for inputs one at a time instead of immediately blocking with MISSING_INPUT
- Ran `install-claude-commands.sh` to make all commands available as local slash commands
- Pushed to GitHub: https://github.com/ayuvinc/AK-Cognitive-OS
