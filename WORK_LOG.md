# WORK_LOG.md — AK Cognitive OS Framework

This file tracks what has been done to the framework itself across sessions.
Read this first at the start of any framework improvement session.

---

## Current State

**Last session:** Session 3
**Next action:** No sprints planned — framework at v1. Start new audit or begin next product.
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

### Sprint 3 — Sub-personas + Schema Validation
**Done:**
- TASK-006: Created 9 sub-persona folders with `claude-command.md` + `SKILL.md`
  - Researcher: `/researcher-legal`, `/researcher-business`, `/researcher-policy`, `/researcher-news`, `/researcher-technical`
  - Compliance: `/compliance-data-privacy`, `/compliance-data-security`, `/compliance-pii-handler`, `/compliance-phi-handler`
  - 31 total slash commands now installed
- TASK-007: Added check 4 to `scripts/validate-framework.sh` — validates YAML frontmatter in all 31 SKILL.md files

---

## Earlier Work (Pre-Sprint)

**Plugin conversion (before sprints):**
- Added `.claude-plugin/plugin.json` manifest — makes repo installable as a Claude Code plugin
- Added `SKILL.md` to every skill and persona folder — Claude Code native format
- Updated all 7 persona `claude-command.md` and `SKILL.md` files with **Interactive mode** instruction — personas now ask for inputs one at a time instead of immediately blocking with MISSING_INPUT
- Ran `install-claude-commands.sh` to make all commands available as local slash commands
- Pushed to GitHub: https://github.com/ayuvinc/AK-Cognitive-OS
