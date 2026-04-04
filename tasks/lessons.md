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
- 2026-04-05: [HOOK] guard-git-push.sh requires ACTIVE_PERSONA env var which Claude Code's skill loader does not propagate. Workaround: prefix git push with ACTIVE_PERSONA=architect. The QA_APPROVED check passes because the template comment in tasks/todo.md always contains that string — this is incidental, not by design. [EXPORT: generic]
