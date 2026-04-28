# Guide 08 -- Mode Selection Cheatsheet
# AK Cognitive OS
# Last reviewed: 2026-03-21

---

## Introduction

Every session in this framework runs in one of three modes. Choosing the right mode
matters because the wrong choice either adds unnecessary overhead (using COMBINED when
you only needed Claude) or leaves a quality gap (using SOLO_CLAUDE when Codex review
was needed). Use this guide to pick the right mode in under two minutes. When in doubt,
the Fallback Rules section at the bottom gives a safe default.

---

## The Three Modes

**SOLO_CLAUDE** -- Claude runs all personas. No Codex session is opened.
Use for planning, documentation, design, and low-stakes feature work.

**SOLO_CODEX** -- Codex runs the task entirely. No Claude session is involved.
Use for isolated, well-specified code tasks where all context is provided upfront.

**COMBINED** -- Claude handles coordination and session management. Codex handles
code creation or review. Both run in the same sprint.
Use when a sprint involves significant code that needs an independent review, or when
code creation requires the depth of Codex's code model.

---

## Pick Your Mode

| Situation                                              | Mode          | Why                                          |
|--------------------------------------------------------|---------------|----------------------------------------------|
| Planning session: BA + Architect only, no code         | SOLO_CLAUDE   | No code to review or create                  |
| Documentation update: README, guides, task files       | SOLO_CLAUDE   | Text work, no code model needed              |
| Small UI tweak: one component, one file                | SOLO_CLAUDE   | Low scope, Claude handles it cleanly         |
| Compliance review run: /compliance only                | SOLO_CLAUDE   | Compliance persona is a Claude persona       |
| Research task: /researcher gathering context           | SOLO_CLAUDE   | No code produced                             |
| New feature: 3+ files, new types, new routes           | COMBINED      | Architecture + code creation at Codex depth  |
| Auth implementation or security-sensitive feature      | COMBINED      | Security review needs Codex independence     |
| Sprint review: code was written, needs sign-off        | COMBINED      | Codex reviewer checks Claude's Junior Dev    |
| Database schema change or migration                    | COMBINED      | Schema changes need independent verification |
| Bug fix: isolated, well-understood, one file           | SOLO_CLAUDE   | Narrow scope, Claude + QA sufficient         |
| Codex-only task: well-scoped, full context available   | SOLO_CODEX    | Independent code task, no session state needed |
| Session close only: wrapping up, writing next-action   | SOLO_CLAUDE   | Admin task, no code involved                 |

---

## Anti-Patterns

**Anti-pattern 1: Using COMBINED for documentation or planning sprints**
COMBINED mode means two AI systems are running in coordination. Documentation does not
need a Codex code review. You are adding overhead with no benefit and setting
origin: combined on outputs that were entirely produced by Claude.

**Anti-pattern 2: Using SOLO_CLAUDE for auth or payment feature code**
Security-sensitive code needs independent review. If Claude writes the code and Claude
reviews the code in the same session, you have no independent check. Use COMBINED so
Codex reviews what Claude's Junior Dev produced.

**Anti-pattern 3: Using SOLO_CODEX when session state is required**
Codex does not read CLAUDE.md or manage SESSION STATE. If a task needs to integrate
with the session audit log, write to tasks/todo.md, or resolve a BOUNDARY_FLAG, it
must involve Claude. SOLO_CODEX is for isolated, stateless code tasks only.

**Anti-pattern 4: Switching modes mid-sprint**
Once a sprint starts in SOLO_CLAUDE mode, switching to COMBINED halfway through
means the Codex reviewer will not have seen the full sprint context. Either plan for
COMBINED from the start, or finish the sprint in SOLO_CLAUDE and run a separate
Codex review in the next sprint.

**Anti-pattern 5: Running COMBINED for every sprint by default**
COMBINED has overhead: you need a sprint summary, a changed-files manifest, and
regression evidence before Codex can run. Small sprints do not need this. Reserve
COMBINED for the situations listed in the decision table above.

**Anti-pattern 6: Using SOLO_CODEX without a complete codex-prompt.md**
Codex has no CLAUDE.md, no session context, and no role cards unless you provide them
via the system prompt. Running Codex with an incomplete or missing system prompt produces
outputs that do not conform to the output envelope and cannot be integrated into the
session audit log.

---

## Fallback Rules

When you are genuinely unsure which mode to use:

1. **Default to SOLO_CLAUDE.** It is safer, simpler, and faster to start. If the output
   quality is insufficient (e.g. the code review feels shallow), you can always follow up
   with a Codex review in the next sprint.

2. **If any file in scope is security-sensitive, upgrade to COMBINED.** Auth, payments,
   data access, external APIs, and session management all qualify. When in doubt about
   whether something is security-sensitive, treat it as if it is.

3. **If you cannot write a sprint summary yet, do not start COMBINED.** A missing sprint
   summary means Codex will block immediately. If you cannot describe what was built and
   which files changed, the sprint is not ready for Codex review.

4. **Ask the Architect.** If you are still unsure, activate /architect and describe what
   the sprint involves. The Architect will recommend a mode as part of session planning.
