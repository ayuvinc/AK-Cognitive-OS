# Next Action Dispatch

NEXT_PERSONA: Junior Dev
TASK:         TASK-014 — remediate-project.sh --v4-upgrade flag
CONTEXT:      TASK-013 QA_APPROVED and merged to main (2026-04-28).

              TASK-014 is now IN_PROGRESS. Implement --v4-upgrade flag in
              scripts/remediate-project.sh. AC is written in tasks/todo.md
              (15 AC covering happy path, idempotency, error states, security).

              Key constraints from Architect:
                - safe_copy semantics throughout (never overwrite existing files)
                - JSON merge for .mcp.json via json.load() + dict merge only
                  (no string concat, no eval)
                - Idempotent: running twice must produce identical state
                - Malformed .mcp.json or settings.json → ERROR + skip that step,
                  do not crash, continue remaining steps, exit 0
                - mcp not importable → WARN + remediation command, exit 0

              Branch to create: feature/TASK-014-remediate-v4-upgrade
              Source files to copy validators from: validators/ (framework root)
              Source scaffold to reference: project-template/signals/, project-template/memory/

COMMAND:      /junior-dev
BLOCKERS:     none
