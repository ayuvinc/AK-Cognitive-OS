# Next Action Dispatch

<!--
Architect writes this at every session close.
AK pastes the COMMAND verbatim to start the next terminal.
-->

NEXT_PERSONA: Architect
TASK:         Phase 4 — Notification/Stop hook upgrades + Agent SDK integration
CONTEXT:      Session 4 (Phase 3) is closed. Delivered: 2 MCP servers (state_machine_server.py,
              audit_log_server.py), mcpServers config in both settings.json files, validate-envelope.sh
              matcher tightened (.*→Bash|Task), validate-framework.sh extended to 16 checks,
              Context Budget sections added to all 18 persona cards. Coverage: ~55% (10/18).
              Phase 4 targets ~61% (11/18): Notification hooks, Stop hook improvements, Agent SDK work.
              Two prior carry-forward items still open (see below).
COMMAND:      /architect

SESSION_STATUS: CLOSED
NEXT_FOCUS:    Phase 4 — Notification hooks + Stop hook upgrades + Agent SDK
BLOCKERS:      none
CARRY_FORWARD:
- Carry-forward 1: Verify the designer persona is fully integrated into the framework
  command/install/validation path (not only scaffolded in-tree).
- Carry-forward 2: Verify task/release/audit handoff conventions are consistent —
  working tree used releases/session-3.md while the requested closeout path expects
  tasks/audit-log.md. One of these should be canonical.
PHASE_4_SCOPE:
- Gap 4.1: PostToolCall Notification hooks — surface structured warnings to user
- Gap 4.2: Stop hook improvements — richer session integrity check output
- Gap 3.x: Agent SDK integration — subagent dispatch via sdk, not just slash commands
- Coverage target: ~61% (11/18 Claude Code native features)

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
