## SESSION STATE
Status:         OPEN
Active task:    v4-architecture-design
Active persona: architect
Blocking issue: none
Last updated:   2026-04-27T00:00:00Z — Session 25 open by Architect (v4 Cognitive Layer design)
---

## Active Tasks

<!-- Architect writes tasks here. Format from framework/templates/task.md -->


## Backlog

<!-- Tasks not yet scheduled for a sprint -->

### [BACKLOG-001] v4 Cognitive Layer — Beads Memory Integration
- Status: PENDING AK REVIEW
- Plan: `docs/v4-beads-integration-plan.md`
- Architecture: `docs/v4-architecture.md`
- Scope:
  - Phase 1–3: Install beads CLI + beads-mcp, wire MCP server
  - Phase 4–5: Establish memory conventions, update 5 command files
  - Phase 6: Memory decay/compaction at session-close
  - Phase 7–8: Bootstrap script update + smoke test
  - Custom build (not in beads): feedback.py, signal_engine.py, 2 hooks, 2 schemas
- Gate: AK approves Dolt as dependency before execution
- Open decisions:
  1. Accept Dolt + beads? (YES/NO)
  2. Memory scope: per-project or cross-project?
  3. Compaction: per session-close or manual?

---

## Archive

<!-- Completed tasks moved here by Architect at sprint close -->
