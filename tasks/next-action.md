# Next Action Dispatch

<!--
Architect writes this at every session close.
AK pastes the COMMAND verbatim to start the next terminal.
-->

NEXT_PERSONA: none
TASK:         none
CONTEXT:      Session 0 — framework initialised, no work started yet
COMMAND:      /architect

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
