# Next Action Dispatch

<!--
Architect writes this at every session close.
AK pastes the COMMAND verbatim to start the next terminal.
-->

NEXT_PERSONA: Architect
TASK:         Session closed — pick up TASK-011 through TASK-014
CONTEXT:      Session 3 is closed. Treat TASK-006 through TASK-010 as complete. Current tree includes the Sprint 3 archive, 9 sub-persona command directories with `claude-command.md` plus companion `codex-prompt.md` and `schema.md` files, `skills/check-channel/claude-command.md` execution-contract updates, a new `designer` persona scaffold, and task-state cleanup in `tasks/todo.md`. Carry forward two review findings from the prior review pass before declaring the next batch done.
COMMAND:      /architect

SESSION_STATUS: CLOSED
NEXT_FOCUS:    TASK-011 to TASK-014
BLOCKERS:      Repo-root validation is unavailable as configured. There is no root `package.json` or `tsconfig.json`, so `npm run build` fails with ENOENT and `npx tsc --noEmit` cannot validate a local TS project at repo root.
CARRY_FORWARD:
- Review finding 1: verify the `designer` persona is fully integrated into the framework command/install/validation path rather than only scaffolded in-tree.
- Review finding 2: verify task/release/audit handoff conventions are consistent, because the working tree used `releases/session-3.md` while the requested closeout path expects `tasks/audit-log.md`.
HANDOFF_NOTE:  Session closeout executed by Codex on 2026-04-02T16:20:19Z using the user-provided framing: T06-T10 complete, T11-T14 next, two review findings carried forward.

<!--
COMMAND FORMAT — Architect writes one of these at session close:

  COMMAND: /architect
  COMMAND: /ba
  COMMAND: /ux
  COMMAND: /junior-dev
  COMMAND: /qa

Each persona auto-picks its task from tasks/todo.md on activation:
- Junior Dev → first IN_PROGRESS, then first PENDING with criteria
- QA         → all READY_FOR_QA anchors
- Architect  → reads full file, SESSION STATE first
- BA         → reads ba-logic.md, picks up PENDING entries
- UX         → reads ux-specs.md, picks up PENDING entries

AK pastes the COMMAND value verbatim into a Claude Code terminal
opened in the project directory. The persona activates immediately.
-->
