# Lessons Learned — [PROJECT_NAME]

<!--
One entry per lesson. Architect adds after any correction or new discovery.
Review last 10 entries at every session start.
Tag [EXPORT: generic] for lessons that belong in the framework, not just this project.
-->

---

- 2026-04-02: When adding new personas or sub-personas, ship the full contract set together (`claude-command.md`, `codex-prompt.md`, `schema.md`, and any command-install wiring) or the framework will look complete in-tree while remaining only partially integrated.
- 2026-04-02: Session closeout should record environment-level validation limits explicitly. In this repo, repo-root `npm run build` and `npx tsc --noEmit` are not meaningful checks until a root workspace manifest or scoped validation target exists.
