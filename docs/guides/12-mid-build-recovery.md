# Guide 12 — Mid-Build Recovery

## When to Use This

Use the recovery flow when:

- A project has code but is missing planning docs (problem-definition, scope-brief, HLD)
- The project feels like it's drifting — unclear what's in scope, what's done, what's next
- A new team member or AI agent is joining a project already in progress
- Existing docs don't match what the code actually does
- You want to re-ground an active project without starting over

Do NOT use this when:
- Starting a new project (use the greenfield flow in Guide 11)
- The project has confirmed planning docs that are up to date

---

## Recovery Conversation — 7 Questions

Before generating any recovery documents, ask the user these questions:

1. **What is this project supposed to achieve?** — The original intent, in the user's words.
2. **Who is the real user?** — Not the abstract target market, but the specific person or role.
3. **What is already built and working?** — Features the user considers complete.
4. **What is only planned or partially done?** — Features that exist in docs or code but aren't finished.
5. **What feels unclear or drifting?** — Areas where scope, design, or priority isn't clear.
6. **What matters most right now?** — The one thing that should be true by end of next sprint.
7. **What should be cut?** — Features or plans that are no longer worth pursuing.

Also inspect the codebase independently. Compare what the code shows against what the user says.

---

## Stage 1: Current Reality Capture

Generate `docs/current-state.md` with these sections:

### Code-Observed Reality
Read the codebase. List what actually exists:
- Working routes, components, tests
- Database schema and migrations
- Configuration and infrastructure
- What tests pass, what tests exist

### User-Stated Intent
From the recovery conversation — what the user says the project should do.

### Mocked Features
Features that appear to work but are backed by fake data, hardcoded responses, or incomplete logic. Be honest.

### Unresolved Contradictions
Places where code, docs, and user intent disagree. Flag these explicitly — don't pick a winner, document the conflict.

**Set metadata:** `Status: draft`, `Source: code-observed` (or `mixed` if user statements are included).

---

## Stage 2: Backfill Core Artifacts

After current-state.md is drafted, backfill the planning docs:

### problem-definition.md
Draft from the recovery conversation answers (questions 1, 2, 6). If existing docs contain relevant content, reference them but do not treat them as confirmed.

**Important:** Set `Source: mixed` and `Status: draft`. These are drafts until the user explicitly confirms them. Do not "migrate" content from existing docs and mark it as user-confirmed — that would be fabricating provenance.

### scope-brief.md
Draft from recovery conversation answers (questions 3, 4, 7). Use code-observed reality to fill the must-have list (things that are built) and cut-for-now list (things the user said to drop).

### hld.md
Draft from code inspection:
- Infer system architecture from directory structure, package.json, Prisma schema, route files
- Document integration points found in code
- Note auth/security model from middleware

**Set Source: code-observed.** This is the AI's reading of the codebase, not the user's confirmed design.

### assumptions.md
Populate with assumptions found during recovery:
- Mark code-derived assumptions as `ai-inferred`
- Mark user-stated assumptions as `user-confirmed` only if directly stated
- Mark contradictions as `unresolved`

### decision-log.md
Backfill with decisions that are evident from the codebase (tech stack choices, architectural patterns) and from the recovery conversation. Mark each with accurate `Made by` attribution.

---

## Stage 3: LLD Backfill

Create LLDs only for:

1. **The currently active feature** — whatever is being built right now
2. **The next 1-2 critical features** — whatever comes immediately after
3. **Risky shared infrastructure** — if the current work touches auth, database schema, or shared services

Do NOT try to fully document every feature at once. LLDs for future phases can wait until those phases begin.

---

## Stage 4: Task Realignment

Rewrite `tasks/todo.md` so every non-trivial task references:
- A scope item from `scope-brief.md`
- An HLD section from `hld.md`
- An LLD file from `docs/lld/` (for features that have one)

Update `traceability-matrix.md` to connect the dots.

Tasks that can't trace to any design artifact should be questioned:
- Is this actually in scope?
- Does this support a confirmed feature?
- Should this be cut?

---

## Stage 5: Honest Release Framing

Create `docs/release-truth.md` for the current project state. Be ruthlessly honest:

- Features that work end-to-end → **real**
- Features with UI but no backend → **mocked**
- Features that work for the happy path only → **partial**
- Features discussed but not built → **deferred**
- Features that work in dev but not in production conditions → **not-production-ready**

---

## Rules for Backfilled Documents

1. **Backfilled docs are drafts, not truth.** Set `Status: draft` until the user explicitly confirms.
2. **Source must be honest.** Code-derived content is `code-observed`. Conversation-derived is `user-confirmed` only for directly stated facts. Mixed content is `mixed`.
3. **Don't invent clean provenance.** If you derived content from existing docs that were themselves unverified, say so. Don't launder AI inferences through existing docs to make them look user-confirmed.
4. **Unresolved contradictions stay unresolved.** Don't pick winners. Document both sides and let the user decide.
5. **Progress is more important than completeness.** A partial current-state.md that is honest is better than a complete one that is fabricated.

---

## Common Recovery Mistakes

| Mistake | Fix |
|---------|-----|
| Treating existing docs as confirmed truth | Mark them code-observed or mixed, require user re-confirmation |
| Trying to document everything at once | Focus on current + next 1-2 features only |
| Halting all progress until docs are complete | Recovery is additive — continue building while backfilling |
| Hiding contradictions to make docs look clean | Contradictions section exists for a reason — use it |
| Marking AI-derived content as user-confirmed | Be honest about Source. The user will confirm when ready. |
