# Next Action Dispatch

NEXT_PERSONA: Architect (or AK directive)
TASK:         none — tasks/todo.md is empty
CONTEXT:      Session 24 complete (v3.1.0 release):
                - status-update and smoke-test skills generalized from forensic-ai,
                  applied to all active projects (Transplant-workflow, Pharma-Base, Project-Dig)
                - MCP config fixed: .mcp.json format at project root, full python3 binary path,
                  enableAllProjectMcpServers: true — propagated to all active projects
                - bootstrap-project.sh v3.1.0: produces 22-skill core set (non-core → skills/optional/)
                - .claude-plugin/plugin.json v3.1.0: paths fixed, smoke-test + status-update added
                - GitHub CI green: 20/20 structural checks + semantic lint PASS (commit bb77fe1)
                - Project-Dig: AI Submission Layer insight captured in docs/decision-log.md
                  and tasks/ba-logic.md (BA-007)

              Pending items for next session (AK to direct):
                - Project-Dig has no GitHub remote yet — 3 local commits pending push
                  (INSIGHT-001, bootstrap fix, MCP fix)
                - .mcp.json command field in Transplant-workflow, Pharma-Base, forensic-ai
                  still uses bare 'python3' (not full path) — may need fixing if MCP fails
                - .claude/commands/medical-researcher.md untracked — AK to decide disposition
                - BL-001 in ba-logic.md (INCORPORATED but not yet deleted) — carry forward

              AK-Cognitive-OS has no pending tasks.
              Next session focus is at AK's discretion.

COMMAND:      /session-open (when ready for next session)
SESSION_STATUS: CLOSED (set by /session-close)
NEXT_FOCUS:    AK to direct
BLOCKERS:      none
