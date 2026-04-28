# Session 28 Release Archive

Session: 28
Date: 2026-04-28
Architect: AK Cognitive OS

---

## TASK-013 — bootstrap-project.sh v4 scaffold additions
Status:    QA_APPROVED → merged to main
Branch:    feature/TASK-013-bootstrap-v4-scaffold
Commits:   39751e3 (impl), 8525887 (AC-11 fix)
Merge:     main (--no-ff)

Summary:
  Extended bootstrap-project.sh so every newly bootstrapped project gets
  the full v4 cognitive layer scaffold: signals/, feedback/, validators/,
  ak-memory in .mcp.json, memory v4 subdirs (index.json + sessions/
  decisions/ outcomes/), and VERSION bumped to 4.0.0.

Files changed:
  - scripts/bootstrap-project.sh (VERSION bump, v4 scaffold steps, validation)
  - project-template/.claude/settings.json (ak-memory permissions + mcpServers)
  - project-template/memory/index.json (new scaffold)
  - project-template/memory/sessions|decisions|outcomes/.gitkeep (new dirs)

AC result: 17/17 PASS (1 QA_REJECTED cycle on AC-11 — fixed same session)
QA_REJECTED reason: post-bootstrap validation block was not naming v4 files
Fix: added explicit echo in validation block

---

## In Progress (as of session close)

- TASK-014 — remediate-project.sh --v4-upgrade flag — PENDING → dispatched to Junior Dev
- TASK-015 — validate-framework.sh v4 checks — PENDING
- TASK-016 — .ak-cogos-version bump to 4.0.0 — PENDING (blocked on 014+015)
