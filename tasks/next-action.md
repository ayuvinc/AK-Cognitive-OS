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

Persona without task argument (Architect, BA, UX, QA full sweep):
  COMMAND: /architect
  COMMAND: /ba
  COMMAND: /ux
  COMMAND: /qa

Persona with task argument (Junior Dev, QA on specific task):
  COMMAND: /junior-dev TASK-001
  COMMAND: /qa TASK-001

AK pastes the COMMAND value verbatim into a new Claude Code terminal
opened in the project directory. The persona activates immediately.
-->
