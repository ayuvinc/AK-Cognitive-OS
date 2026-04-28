# Guide 03 — Review Modes

## The Three Operating Modes

AK Cognitive OS runs in one of three modes depending on whether Codex is available
and what kind of work is in progress.

---

## SOLO_CLAUDE

**Use when:** Documentation-only work, planning, research, framework changes,
no code being reviewed.

In SOLO_CLAUDE mode:
- Claude runs all personas and skills
- No Codex review packet is required
- `/sprint-packager` produces the sprint summary only (no intake check)
- Audit log records mode as `SOLO_CLAUDE`

When to choose this:
- Writing docs, guides, schemas, or templates
- Research sessions
- Planning and architecture design without code changes
- Framework extraction or improvement sessions

---

## SOLO_CODEX

**Use when:** Codex is reviewing code that Claude has written, without Claude
re-reviewing. Rare — typically used when Claude is unavailable mid-sprint.

In SOLO_CODEX mode:
- Codex uses the review packet produced by a previous Claude session
- Codex runs from `framework/codex-core/reviewer-contract.md`
- Results written back to `channel.md` for Claude to read at next session open

---

## COMBINED

**Use when:** Code is being actively developed and Codex review adds value —
typically for production features, security-sensitive code, or anything with
non-trivial business logic.

In COMBINED mode:
1. Claude runs all personas → code written and committed to branch
2. `/sprint-packager` + `/review-packet` assembles the full 7-item packet
3. `/codex-intake-check` verifies all 7 items present (BLOCKED if any missing)
4. Codex reviews against `framework/codex-core/reviewer-contract.md`
5. Codex findings returned via `channel.md`
6. Architect (Claude) reviews findings, escalates S0/S1 items, resolves
7. Merge to main after all S0 cleared

---

## Mode Selection Guide

| Situation | Mode |
|---|---|
| Writing docs, guides, schemas | SOLO_CLAUDE |
| Research or compliance review | SOLO_CLAUDE |
| Feature build with code changes | COMBINED |
| Hotfix (low risk, single file) | SOLO_CLAUDE or COMBINED |
| Security-sensitive feature | COMBINED mandatory |
| New API route or data model | COMBINED recommended |
| Framework improvement session | SOLO_CLAUDE |

---

## Switching Modes

Mode is set in `CLAUDE.md` under `codex_mode: SOLO_CLAUDE | SOLO_CODEX | COMBINED`.

If not set, default is **COMBINED** for any session with code changes,
**SOLO_CLAUDE** for doc-only sessions.

---

## Review Packet — 7 Required Items

When running COMBINED mode, all 7 must be present before Codex opens:

1. `sprint-{sprint_id}-summary.md` — what was built
2. Changed-files manifest — list of every modified file
3. Acceptance criteria map — 1:1 with task IDs
4. Regression evidence — test + build + lint results
5. `tasks/ux-specs.md` reference — if any component file changed
6. Architecture constraints — if new type or API route added
7. Security sign-off — from `/security-sweep` or Architect note

`/codex-intake-check` gates Codex entry. Missing any item → `BLOCKED`.

---

## Compliance Findings in Review

The compliance persona runs during the session (not at Codex review time).
Findings are tiered:

| Tier | Action |
|---|---|
| S0 | Hard block — nothing ships. Must be resolved before Codex review. |
| S1 | Owner decision — fix before launch or explicitly accept risk. |
| S2 | Logged and deferred — addressed in a future sprint. |

S0 findings must be resolved before the review packet is assembled.
