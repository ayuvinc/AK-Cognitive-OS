# AK Development Framework — Interim
# Version: 0.9 (interim — final at project end)
# Classification: Universal, sector-agnostic, model-agnostic
# Last updated: 2026-03-18
# Status: DRAFT — PENDING CODEX REVIEW

---

## Section 1 — Purpose and Core Idea

This framework is an operating system for building software with AI models. It defines how a builder model, a reviewer model, and a human authority coordinate through shared files to produce auditable, high-quality output. It does not eliminate model limitations. It reduces them through role separation, independent review, fresh sessions, and persistent memory.

The system has three layers:
- **Delivery layer** — tasks, code changes, reviews, fixes
- **Memory layer** — decisions, lessons, risks, compliance, release history
- **Control layer** — human authority assigns roles, approves direction, resolves disputes

No layer operates autonomously. The human authority triggers every phase transition.

---

## Section 2 — Design Principles

1. **Model-agnostic** — roles are defined by function, not by vendor. Builder and Reviewer are seats. Any capable model can occupy either seat.
2. **Memory-first** — decisions and lessons are written to durable files, not left in temporary chat context. Every session reads memory before doing anything else.
3. **Archive not erase** — sprint records, findings, and decisions are permanent. Only execution queues (todo, channel) are cleared. Nothing that has already happened is deleted.
4. **Fresh reviewer sessions** — the reviewer starts each sprint with no memory of the build process. This reduces anchoring bias and creates genuine independent judgement.
5. **Evidence over opinion** — every finding must cite code, a spec requirement, a test gap, or a security boundary. Findings without evidence are treated as low-confidence until confirmed.
6. **AK triggers every transition** — nothing moves automatically. AK opens the reviewer session, carries the review packet, reads findings, and decides outcomes. The files are the record. AK is the message bus.
7. **Fast path for small work** — full sprint ceremony applies to non-trivial changes only. Small bug fixes use a short summary block. The framework must not create overhead that exceeds the work.
8. **Compliance designed in** — legal and regulatory requirements are identified by BA before architecture begins. Compliance is never retrofitted. It is a design input, not a test gate.
9. **Independent convergence confirms risk** — when two reviewers flag the same risk without coordination, treat it as confirmed. Independent convergence is stronger evidence than consensus in a single session.

---

## Section 3 — Team Roles

### Architect
Designs systems, defines tasks, resolves conflicts, closes sessions. Does not write feature code. Reads all memory files at session start. Owns `work/todo.md`. Final technical authority before human approval.

**Must not:** write feature implementation code, approve own designs, merge without QA_APPROVED status.

**Skip permitted:** never — Architect is required on all sessions involving code.

---

### Business Analyst (BA)
Confirms business logic, identifies compliance requirements, validates assumptions, defines non-goals. Owns `spec/requirements.md`, `memory/compliance-register.md`, `memory/assumption-register.md`, `memory/non-goals.md`.

**Must not:** define technical solutions, write acceptance criteria for QA (QA owns technical AC; BA owns business AC).

**Skip permitted:** bug fix with zero logic change; config/infra only; prior session sign-off cited.

---

### UI/UX Designer
Defines user flows, wireframes, interaction rules. Owns `spec/ux-specs.md`. Reviews built UI before QA tests it.

**Must not:** make technical implementation decisions, define business logic.

**Skip permitted:** no new UI; no layout or flow change; existing spec covers it (cite it).

---

### Junior Developer
Implements approved tasks. Marks tasks `READY_FOR_REVIEW` — never `READY_FOR_QA` directly. Reads `memory/compliance-register.md` before touching any regulated feature.

**Must not:** self-approve, skip compliance constraints, use `any` type, write secrets in code.

**Skip permitted:** never — all code must be written by someone.

---

### QA Engineer
Defines acceptance criteria before build starts. Tests behaviour after sprint review approves. Owns technical AC. Does not re-review code logic — Reviewer owns code quality. QA owns functional quality.

**Skip permitted:** docs-only change; comment/whitespace-only; explicit human decision.

---

### Builder Seat
Assigned by human authority at session start. Default: Claude Code. Writes all production code for the sprint. Marks tasks `READY_FOR_REVIEW`. Writes sprint summary at sprint end.

---

### Reviewer Seat
Assigned by human authority at session start. Default: Codex. Reads builder output in a fresh session. Does not write production code during review. Writes sprint review at sprint end. Marks findings with severity and disposition.

---

### Human Authority (AK)
Assigns roles. Approves spec and direction. Triggers every phase transition. Decides on disputed findings. Accepts or defers risk. The only entity that can move a task to `QA_APPROVED`. Cannot be bypassed.

---

## Section 4 — Workflow

### Session Archetypes

| Type | Sequence |
|---|---|
| New feature | BA → UX → Architect → Junior Dev → Sprint Review → QA |
| Bug fix | Architect → Junior Dev → Sprint Review → QA |
| Refactor | Architect → Junior Dev → Sprint Review → QA |
| Config / infra | Architect → Junior Dev |
| Hotfix | Architect (abbreviated) → Junior Dev → Sprint Review → QA |
| Spec only | BA and/or UX only |
| Compliance review | BA → Architect → compliance-register update |

---

### Task Status Machine

```
PENDING
  → READY_FOR_BUILD      (Architect assigns to builder)
  → IN_PROGRESS          (builder starts)
  → READY_FOR_REVIEW     (builder done — sprint review next, not QA)
  → CHANGES_REQUESTED    (reviewer findings accepted — back to builder)
  → APPROVED_FOR_QA      (reviewer verdict = approved)
  → QA_APPROVED          (QA passes)
  → DONE                 (archived, removed from todo)
```

---

### Session State Machine

```
OPEN → IN_PROGRESS → BLOCKED → CLOSING
```

Recorded in `work/current-session.md` at all times.

---

### Activation Gate

No work begins without human authority explicitly assigning builder and reviewer. If roles are not declared in `work/current-session.md`, no code work starts. Models flag and wait.

---

### 30-Minute Check-in Protocol

Every 30 minutes, Architect pauses and asks human authority:
> "30-minute check — mid-session update, continue, or start session close?"

If any task is IN_PROGRESS: wait until READY_FOR_REVIEW before running update or close. Never interrupt a task mid-build.

Mid-session update: commit all approved work, update session state, push. Then continue.

---

### Session Close Checklist

1. All tasks QA_APPROVED and archived from `work/todo.md`
2. All `spec/requirements.md` entries INCORPORATED and cleared
3. All `spec/ux-specs.md` entries APPROVED and cleared
4. Completed tasks logged in `/releases/`
5. `memory/risk-register.md` reviewed — new risks added
6. `memory/compliance-register.md` reviewed — new compliance entries added
7. Human authority shown what was built and why
8. `memory/lessons.md` updated
9. `work/next-action.md` written
10. Commit and push

---

## Section 5 — Peer Review Sub-Framework

### The Two Seats

Every sprint has two seats. Human authority assigns both at session start. Neither model assumes a seat. Assignments recorded in `work/current-session.md`.

```
work/current-session.md
...
Builder:  [Claude Code / Codex]
Reviewer: [Claude Code / Codex]
Assigned by: AK
```

Seats may be swapped. Swap requires human authority callout and a new session state entry before swap takes effect.

---

### Builder Responsibilities

- Writes all code for the sprint
- Marks completed tasks `READY_FOR_REVIEW`
- Updates `work/todo.md` throughout
- Runs local verification before marking ready
- At sprint end: writes `work/reviews/sprint-NNN-summary.md`

---

### Reviewer Responsibilities

- Opens a fresh session — no prior context from the build phase
- Receives the review packet from human authority (see Section 5 — Review Packet)
- Does not write production code
- Performs implementation review and requirement review separately
- Writes `work/reviews/sprint-NNN-review.md` with structured findings
- Logs all actions in `reviewer/reviewer-activity-log.md`

---

### Two Review Modes

These are separate questions. Both must be answered every sprint.

**Implementation Review** — checks:
- Logic correctness
- Security boundaries and role guards
- Reliability and error handling
- Maintainability and pattern consistency
- Test coverage

**Requirement Review** — checks:
- Does the change satisfy the approved behaviour?
- Does the UX match the intended flow?
- Are all acceptance criteria actually met?
- Are any compliance constraints from `memory/compliance-register.md` unaddressed?

---

### Review Packet

Human authority gives the reviewer exactly this — nothing else:

- Changed files for this sprint
- `work/reviews/sprint-NNN-summary.md`
- Relevant acceptance criteria from `spec/acceptance-criteria.md`
- Relevant spec excerpt from `spec/requirements.md`
- Relevant architecture constraints from `spec/architecture.md`
- Any open decisions from `memory/decision-log.md` that affect this sprint
- Any open compliance entries from `memory/compliance-register.md` that affect this sprint

---

### Fast Path

Use when all of these are true:
- One small bug fix or isolated edit
- No schema change
- No new architecture decision
- No UX flow change
- No compliance surface touched
- Low regression risk

Fast path: builder writes a short summary block in `work/current-session.md`. Reviewer writes a short review block in the same file. No separate review files unless there is a finding.

---

### Review-Plus-Fix Mode

Default: builder builds, reviewer reviews.

Optional for urgent or obvious issues: reviewer may produce a patch proposal, failing test, or exact fix plan alongside the finding. Human authority decides whether to accept the proposed fix or return to builder.

---

## Section 6 — Communication Channel

### The Shared File

One file at project root: `channel.md`

Purpose: short handoff messages between builder and reviewer. Transport only — not a task board, not a decision record, not a findings archive. Once a message has been acted on, the durable record lives in the relevant memory or review file.

### Slash Commands

Every model has two commands:

- `/read-[other model]` — reads the latest entry in `channel.md` from the other model, summarises it in plain English
- `/respond-to-[other model]` — appends a structured response to `channel.md`

Default commands:
- `/read-codex` — Claude Code reads Codex's latest channel entry
- `/respond-to-codex` — Claude Code writes to the channel
- `/read-claude` — Codex reads Claude Code's latest channel entry
- `/respond-to-claude` — Codex writes to the channel

### Channel Entry Format

```
## From: [Claude Code / Codex / AK]
## To: [Claude Code / Codex / AK]
## Thread: [Thread ID]
## Date: [YYYY-MM-DD]

[Message — plain English, as short as possible]
```

### AK Is the Bridge

Human authority manually triggers every handoff:
- Opens the reviewer terminal
- Provides the review packet
- Carries findings back to the builder
- Nothing moves between models automatically

---

## Section 7 — File System

### Complete Structure

```
/project-root/
│
├── channel.md                        ← shared transport (handoffs only)
├── CLAUDE.md                         ← master rulebook
├── audit-log.md                      ← permanent, append-only, never deleted
│
├── /developer/                       ← builder workspace
│   ├── build-notes.md                ← working notes during build (cleared per sprint)
│   └── scratch.md                    ← temporary working space
│
├── /reviewer/                        ← reviewer workspace
│   ├── review-queue.md               ← what is waiting to be reviewed this sprint
│   ├── open-findings.md              ← all unresolved findings across sprints
│   ├── reviewer-activity-log.md      ← every action Codex takes, session by session
│   └── /archive/                     ← permanent sprint review records
│       ├── sprint-001-review.md
│       ├── sprint-001-findings.md
│       └── ...
│
├── /memory/                          ← permanent project memory
│   ├── project-context.md            ← first file any new session reads
│   ├── decision-log.md               ← architectural and workflow decisions
│   ├── decision-index.jsonl          ← compact machine-readable decision index
│   ├── lessons.md                    ← permanent lessons tagged UNIVERSAL or PROJECT
│   ├── risk-register.md              ← permanent risk record
│   ├── compliance-register.md        ← legal and regulatory requirements
│   ├── assumption-register.md        ← BA's unvalidated assumptions
│   ├── non-goals.md                  ← what the product explicitly does not do
│   └── reconciliation-log.md         ← disputes and human authority decisions
│
├── /spec/                            ← authoritative specifications
│   ├── requirements.md               ← BA-owned business requirements
│   ├── acceptance-criteria.md        ← QA-owned technical acceptance criteria
│   ├── architecture.md               ← Architect-owned technical design
│   ├── ux-specs.md                   ← UX-owned flows and wireframes
│   ├── legal-constraints.md          ← BA-owned hard legal constraints
│   └── user-segments.md              ← BA-owned user definitions
│
├── /work/                            ← live execution state
│   ├── todo.md                       ← task queue (empty at session end)
│   ├── current-session.md            ← single-session state (roles, goal, status)
│   ├── next-action.md                ← written at session close — who does what next
│   └── /reviews/                     ← sprint review records (permanent)
│       ├── sprint-001-summary.md
│       ├── sprint-001-review.md
│       ├── sprint-001-resolution.md
│       └── ...
│
└── /releases/                        ← session release notes (permanent)
    ├── session-001.md
    └── ...
```

---

### File Ownership

| File | Written by | Read by | Cleared |
|---|---|---|---|
| `channel.md` | Any model or AK | Any model or AK | After each handoff is actioned |
| `audit-log.md` | All actors | All actors | Never |
| `reviewer/review-queue.md` | AK | Reviewer | Each sprint |
| `reviewer/open-findings.md` | Reviewer | Builder + AK | When finding resolved |
| `reviewer/reviewer-activity-log.md` | Reviewer | AK | Never |
| `memory/decision-log.md` | Architect | All | Never |
| `memory/compliance-register.md` | BA | All | Never |
| `memory/assumption-register.md` | BA | Architect + Reviewer | When validated |
| `memory/reconciliation-log.md` | Both models + AK | Both models + AK | Never |
| `work/todo.md` | Architect | All | End of session |
| `work/current-session.md` | Architect | All | End of session |
| `work/reviews/sprint-NNN-*` | Builder + Reviewer | All | Never |

---

### Source-of-Truth Precedence

When files conflict, use this order:

1. `memory/reconciliation-log.md`
2. `spec/acceptance-criteria.md`
3. `spec/requirements.md`
4. `spec/architecture.md`
5. `work/todo.md`
6. `work/current-session.md`
7. `memory/decision-log.md`
8. `memory/lessons.md`
9. Sprint summaries and review files

---

## Section 8 — Memory Layer

### `memory/project-context.md`
First file any new session reads. Contains: what the product is, current milestone, tech stack, active constraints, open risks, known non-goals. Updated at every session close.

### `memory/decision-log.md`
Human-readable record of important choices. Each entry: decision ID, date, status, context, choice made, consequences, related files, Thread ID.

### `memory/decision-index.jsonl`
Compact machine-readable substrate. One JSON object per line. Enables fast context loading without scanning long markdown files.

```json
{"decision_id":"D-014","date":"2026-03-18","status":"accepted","tags":["auth","routing"],"summary":"Client routes live under /app, coach routes under /coach","source":"memory/decision-log.md","thread":"D-014"}
```

Written by Architect at session close. One entry per new decision.

### `memory/lessons.md`
Permanent plain-language lessons. Tagged:
- `UNIVERSAL` — applies to any project, exports to starter kit
- `PROJECT` — specific to this project only
- `PROCESS` — workflow and framework improvements

### `memory/risk-register.md`
Permanent record of known risks. Fields: risk ID, category, severity, status, owner, mitigation, review date, Thread ID. Never cleared. Reviewed at every session close.

### `memory/compliance-register.md`
Legal and regulatory requirements. Pre-populated with universal regulations (GDPR, basic data protection). Project-specific entries added by BA at project start and when new regulated features are introduced. See Section 9 for full format.

### `memory/reconciliation-log.md`
Highest-precedence memory file. Records every dispute between models and every human authority decision. Both model positions in plain English. Human decision timestamped. See Section 12 for full format.

---

## Section 9 — BA and Research Layer

### Research Gate

BA must answer these questions before writing any requirement:

1. Has this domain been researched? (check `memory/research-log.md` first)
2. Is there a regulatory or legal requirement that touches this feature?
3. Is there a compliance surface? (personal data / financial / health / minors / regulated activity)
4. Is this a validated fact or a working assumption?

If any answer is "no" or "unknown" — BA opens a `RESEARCH-NNN` entry before writing the requirement. The requirement status is `PENDING_RESEARCH` until the gate clears.

### Compliance Register Format

```
COMPLIANCE-[N]
Regulation:     [GDPR / HIPAA / FCA / CCPA / sector-specific name]
Jurisdiction:   [EU / UK / US / global / specify]
Applies when:   [what product behaviour triggers this requirement]
Requirement:    [what the product must do or must not do — plain English]
Owner:          BA identifies / Architect designs / Junior Dev implements / QA tests
Status:         PENDING / DESIGNED / IMPLEMENTED / TESTED / VERIFIED
Evidence:       [where in the codebase this is enforced — file and function]
Review date:    [when to re-check — regulations change]
Thread ID:      [links to audit log and related task]
```

### Assumption Register Format

```
ASSUMPTION-[N]
Date:           [when assumption was made]
Owner:          BA
Statement:      [what BA is assuming to be true]
Basis:          [why BA believes this — source, prior research, human statement]
Risk if wrong:  [what breaks or changes if this assumption is false]
Validation:     [how to confirm — user interview, research, legal check]
Status:         UNVALIDATED / VALIDATED / INVALIDATED
Thread ID:      [links to requirement it underpins]
```

### Non-Goals

BA maintains `memory/non-goals.md`. Any feature or behaviour explicitly out of scope is logged here with a reason. This prevents scope creep and gives future sessions a clear boundary. Non-goals require human authority sign-off before they can be removed.

### Acceptance Criteria Ownership

| Type | Owner | Meaning |
|---|---|---|
| Business AC | BA | Does this satisfy the business requirement? |
| Technical AC | QA | Does this work correctly, securely, and reliably? |

These are written separately. BA writes business AC in `spec/requirements.md`. QA writes technical AC in `spec/acceptance-criteria.md`.

### User Segments

`spec/user-segments.md` — BA defines who the users are before defining what they need. Each segment: name, description, validated or assumed, primary goal, key constraints. Reviewer checks that implementation serves the defined segment, not an assumed one.

---

## Section 10 — Finding Standard

Every finding in a sprint review must use this structure. No exceptions.

```
FINDING-ID: RVW-[NNN]
Task:          [Task ID]
Sprint:        [sprint number]
Type:          bug | security | performance | reliability | maintainability |
               requirement-gap | test-gap | design-risk | compliance-gap
Severity:      critical | high | medium | low
Disposition:   must-fix | should-fix | accept-risk | defer | invalid
Confidence:    high | medium | low
Scope reviewed:[what the reviewer actually examined — file range, functions, paths]
Blocking?:     yes | no
Expected:      [what the spec or AC says should happen]
Actual / Risk: [what the code does or what the risk is]
Evidence:      [file, function, line, or test reference — required]
Recommended next step: [plain English — not code]
Status:        open | resolved | deferred | rejected
Thread ID:     [links to audit log]
```

### Evidence Rules

A finding is weak unless it points to at least one of:
- Acceptance criteria mismatch (cite the criterion)
- Explicit code path (cite the file and function)
- Missing test (name the scenario)
- Security boundary issue (name the boundary)
- User-visible behavioural risk (describe the user impact)
- Conflict with a prior decision log entry (cite the decision ID)

Findings without evidence are marked `Confidence: low` and treated as advisory only until confirmed.

---

## Section 11 — Audit Log

### Purpose

One file. Append only. Never deleted. Never cleared. Every action by any actor — model or human — is logged here. This is the compliance evidence trail, the debugging record, and the complete history of the project.

Location: `audit-log.md` at project root.

### Thread ID — The Common Link

Every activity in the system carries a Thread ID. When a task is created, its ID becomes the Thread ID for all actions related to that task. Search the audit log for any Thread ID and get the complete history of that thread across every file.

Thread ID conventions:
- Task: `S8-04`, `TASK-014` — the task ID
- Decision: `D-014` — the decision ID
- Reconciliation: `REC-003` — the reconciliation ID
- Sprint: `SPRINT-008` — the sprint number
- Compliance: `COMP-002` — the compliance register ID
- Research: `RES-001` — the research log ID

### Entry Format

```
AUDIT-[sequential number]
Thread:      [Thread ID]
Timestamp:   [YYYY-MM-DD HH:MM]
Actor:       [Claude Code / Codex / AK / Architect / BA / QA / Junior Dev]
Action:      [action type — see below]
File:        [path/to/affected/file]
Description: [one sentence — what happened]
Linked:      [comma-separated AUDIT IDs sharing this Thread ID]
```

### Action Types

| Type | Meaning |
|---|---|
| `FILE_CREATED` | New file written to disk |
| `FILE_DELETED` | File removed |
| `ENTRY_ADDED` | New entry written inside an existing file |
| `ENTRY_MODIFIED` | Existing entry changed |
| `ENTRY_DELETED` | Entry removed from a file |
| `TASK_STATUS_CHANGED` | Task moved to a new status |
| `REVIEW_STARTED` | Reviewer opened a review session |
| `REVIEW_COMPLETED` | Reviewer wrote sprint review output |
| `FINDING_RAISED` | New finding written |
| `FINDING_RESOLVED` | Finding marked resolved |
| `DECISION_MADE` | Entry added to decision-log |
| `ASSUMPTION_ADDED` | New entry in assumption-register |
| `COMPLIANCE_ADDED` | New entry in compliance-register |
| `COMPLIANCE_VERIFIED` | Compliance entry status → VERIFIED |
| `RECONCILIATION_OPENED` | Dispute logged |
| `RECONCILIATION_CLOSED` | Human authority decision timestamped |
| `CHANNEL_MESSAGE_SENT` | Entry written to channel.md |
| `CHANNEL_MESSAGE_READ` | channel.md read by a model |
| `SPRINT_OPENED` | New sprint started |
| `SPRINT_CLOSED` | Sprint close checklist completed |
| `SESSION_OPENED` | Role assignments confirmed, work begins |
| `SESSION_CLOSED` | Session close checklist completed |

### What the Audit Log Does Not Do

- Does not store the content of changes — that lives in the files
- Does not replace version control — git tracks what changed, audit log tracks who, why, and when
- Does not get summarised or compressed — it grows indefinitely and that is correct
- Does not link to external systems — it is self-contained

### Example Thread Chain

```
AUDIT-0147  Thread: S8-04  AK             ENTRY_ADDED           work/todo.md                  S8-04 security task created
AUDIT-0148  Thread: S8-04  Codex          FINDING_RAISED        reviewer/open-findings.md     Finding that generated S8-04
AUDIT-0201  Thread: S8-04  Claude Code    TASK_STATUS_CHANGED   work/todo.md                  S8-04 → IN_PROGRESS
AUDIT-0218  Thread: S8-04  Claude Code    ENTRY_MODIFIED        app/api/coach/invite/route.ts Role guard added
AUDIT-0219  Thread: S8-04  Claude Code    TASK_STATUS_CHANGED   work/todo.md                  S8-04 → READY_FOR_REVIEW
AUDIT-0231  Thread: S8-04  Codex          REVIEW_COMPLETED      reviewer/archive/sprint-008   S8-04 approved
AUDIT-0245  Thread: S8-04  AK             TASK_STATUS_CHANGED   work/todo.md                  S8-04 → QA_APPROVED
AUDIT-0251  Thread: S8-04  Architect      ENTRY_DELETED         work/todo.md                  S8-04 archived and removed
```

---

## Section 12 — Reconciliation Protocol

### When It Triggers

When builder and reviewer disagree on a finding — either the finding itself or the recommended resolution.

### Protocol

1. Human authority asks builder: "Reviewer flagged X — do you agree?"
2. Builder writes position to `memory/reconciliation-log.md`
3. Human authority shares builder position with reviewer
4. Reviewer writes position to same entry
5. Human authority reads both, decides, timestamps

No disputed code ships until human authority's timestamp exists in the reconciliation log.

### Entry Format

```
RECONCILIATION-[N]
Date:        [date]
Sprint:      [sprint number]
Finding:     [FINDING-ID reference]
Thread ID:   [Thread ID]

Builder position:
  Recommends: [what builder thinks should be done]
  Rationale:  [why — plain English, no code arguments]
  Risk if wrong: [what breaks if reviewer is right]

Reviewer position:
  Recommends: [what reviewer thinks should be done]
  Rationale:  [why — plain English, no code arguments]
  Risk if wrong: [what breaks if builder is right]

Human authority decision:
  Decision:   [Builder position / Reviewer position / Neither: describe]
  Reason:     [one sentence minimum]
  Timestamp:  [ISO datetime]

Outcome:
  Assigned to:  [builder — implement per decision]
  Verified by:  [reviewer — confirm implementation matches decision]
  Status:       PENDING / IMPLEMENTED / VERIFIED
```

---

## Section 13 — Security Model

Every task that touches authentication, data access, or external input must answer these five questions before build starts. If any are unanswered, the task does not leave PENDING.

1. **Who can access this?** — which roles, authenticated or anonymous, and how is it enforced?
2. **What data can each role read or write?** — data boundaries defined explicitly
3. **What sensitive data is touched?** — PII, credentials, health data, financial data
4. **What actions must be auditable?** — what gets logged and to what level
5. **What happens with malformed or malicious input?** — validation, error handling, abuse surface

### Hard Rules

- **API routes must have explicit role guards inside the handler.** Page routing, middleware, and deployment-layer controls are not sufficient. The check must be in the handler itself.
- **Every server component page needs two guards:** unauthenticated → redirect to login; wrong role → redirect to their correct home. Never assume middleware caught it.
- **Never send an authenticated user to the login page.** Unauthenticated → login. Wrong role → their home.
- **Admin/service-role credentials are server-side only.** Never imported in client components, never logged, never passed through user-controlled input.
- **Two-step ownership on nested resources.** Always verify the full chain: resource → parent → owner. Never verify only the leaf node.

---

## Section 14 — Definition of Done

### Per-Task Checklist

- [ ] Code reviewed by Architect — no `any`, correct server/client pattern, no security issues
- [ ] Security model answered — all five questions from Section 13
- [ ] Explicit role guard in API handler if route uses elevated privileges
- [ ] Compliance register checked — no open PENDING entries for this feature
- [ ] Tests passing and build passing
- [ ] RLS or equivalent data access control verified
- [ ] UI reviewed against wireframe and design system
- [ ] Mobile layout checked at 375px
- [ ] Edge cases tested: empty state, error state, unauthenticated access, wrong role
- [ ] Task logged to `releases/session-N.md` before deletion
- [ ] `memory/risk-register.md` checked — new risks added
- [ ] Audit log entry written for task completion

### Per-Session Checklist

1. All tasks QA_APPROVED and deleted from `work/todo.md`
2. All `spec/requirements.md` entries INCORPORATED and cleared
3. All `spec/ux-specs.md` entries APPROVED and cleared
4. Completed tasks logged in `/releases/`
5. `memory/risk-register.md` reviewed — new risks added
6. `memory/compliance-register.md` reviewed — new entries added
7. Human authority shown what was built and why
8. `memory/lessons.md` updated
9. `memory/decision-log.md` updated with new decisions
10. `work/next-action.md` written
11. Audit log entries complete for the session
12. Commit and push

---

## Section 15 — Universal Lessons

These lessons are proven on a live project. Each is actionable. Tagged `UNIVERSAL` — they export to any new project.

### AI Model Coordination
- The shared file channel works. Two models in separate terminals, one shared file, human as bridge — viable coordination mechanism.
- Independent review finds real gaps the builder misses. A model reviewing its own work has a blind spot toward its own assumptions.
- When two models flag the same risk independently, treat it as confirmed. Independent convergence is stronger evidence than single-session consensus.
- The reviewer needs the spec. Information asymmetry was the wrong model. Fresh session provides enough independence; withholding the spec prevents requirement compliance checking.
- The shared channel file is transport only. Durable records go into dedicated files immediately.

### Security
- API routes need explicit role guards inside the handler. Page routing is not sufficient — API routes can be called directly by any authenticated session.
- Two-step ownership on nested resources. Always verify the full chain, never just the leaf node.
- Admin/service-role keys are server-side only. Never client-side, never logged, never in user-controlled input.
- Any route that uses elevated privileges must verify the caller's role before using those privileges.

### Database and Schema
- DB schema before TypeScript types before code. Never the reverse.
- Any deferred migration comment is a risk-register entry at the time of writing, not at the time of discovery.
- Use aggregation queries (one query with nested count) instead of N+1 loops.
- Migration files are the source of truth for DB state. Dashboard execution is the run; the file is the record.

### Auth
- Every server component page needs two guards: unauthenticated → login; wrong role → their home.
- Never send an authenticated user to the login page.
- Any Supabase email flow must use `token_hash` not `ConfirmationURL` for SSR apps.
- Any invite flow must handle two paths: new user (send invite) and existing user (direct link).
- Always pass `redirectTo` explicitly in invite flows. Never rely on dashboard Site URL default.

### Testing
- Test name and assertion must agree. A test named "singular" asserting "plural" is the test's bug, not the code's.
- Every API route needs: happy path + auth failure + validation failure.
- CI catches what local checks miss. Never rely on humans to remember to run lint.

### Framework Discipline
- No persona active = no work. Reading is permitted. Writing, designing, planning are not.
- Commit and push at session end — without being asked. If work happened, it gets pushed.
- CLAUDE.md is working memory, not a manual. Keep it lean. Everything else is reference material.
- Any `-- deferred` or `-- TODO` in a migration file is a risk-register entry immediately.
- Stop at architectural decision points. Never code through an unresolved design question.

---

## Section 16 — Starter Kit

### Deployable Folder

```
/ak-dev-framework/
│
├── CLAUDE.md                         ← master rulebook v2.0
├── QUICKSTART.md                     ← first 15 minutes of any new project
├── FRAMEWORK-CHANGELOG.md            ← v1 → v0.9 interim and why
├── audit-log.md                      ← empty, append-only
├── channel.md                        ← empty transport file
│
├── /developer/
│   ├── build-notes.md                ← empty template
│   └── scratch.md                    ← empty
│
├── /reviewer/
│   ├── review-queue.md               ← empty template
│   ├── open-findings.md              ← empty template
│   ├── reviewer-activity-log.md      ← empty template
│   └── /archive/                     ← empty folder
│
├── /memory/
│   ├── project-context.md            ← template with prompts to fill in
│   ├── decision-log.md               ← pre-populated with universal decisions
│   ├── decision-index.jsonl          ← pre-populated with universal decisions
│   ├── lessons.md                    ← pre-populated with UNIVERSAL lessons from Section 15
│   ├── risk-register.md              ← empty template
│   ├── compliance-register.md        ← pre-populated with universal regulations (GDPR etc.)
│   ├── assumption-register.md        ← empty template
│   ├── non-goals.md                  ← empty template
│   └── reconciliation-log.md         ← empty template
│
├── /spec/
│   ├── requirements.md               ← empty template
│   ├── acceptance-criteria.md        ← empty template
│   ├── architecture.md               ← empty template
│   ├── ux-specs.md                   ← empty template
│   ├── legal-constraints.md          ← empty template
│   └── user-segments.md              ← empty template
│
├── /work/
│   ├── todo.md                       ← template with SESSION STATE block
│   ├── current-session.md            ← template with role assignment fields
│   ├── next-action.md                ← empty template
│   └── /reviews/                     ← empty folder
│
├── /releases/                        ← empty folder
│
└── /skills/
    ├── SKILL-architect.md            ← v2.0
    ├── SKILL-junior-developer.md     ← v2.0 with READY_FOR_REVIEW step
    ├── SKILL-qa-engineer.md          ← v2.0 sprint-review-first note
    ├── SKILL-ba.md                   ← v2.0 with research gate + compliance gate
    ├── SKILL-ux.md                   ← v2.0 with accessibility + research check
    └── SKILL-codex-reviewer.md       ← NEW — reviewer seat responsibilities
```

### What is Pre-Populated vs Empty

| File | Contents |
|---|---|
| `memory/lessons.md` | All 36 UNIVERSAL lessons from Section 15 |
| `memory/compliance-register.md` | GDPR, basic data protection — universal entries only |
| `memory/decision-log.md` | Universal architectural decisions proven on AKCoach |
| `memory/project-context.md` | Template with fill-in prompts |
| `QUICKSTART.md` | 11-step sequence for first 15 minutes |
| Everything else | Empty template with structure only |

### QUICKSTART — First 15 Minutes

1. Drop `/ak-dev-framework/` into project root
2. Open `CLAUDE.md` — update project name and stack
3. Open `memory/project-context.md` — fill in product description, milestone, constraints
4. Open `memory/compliance-register.md` — add any sector-specific regulations
5. Launch Claude Code from inside the project directory
6. Activate Architect: `/architect`
7. Architect reads all memory files in order
8. Architect opens `RESEARCH-001` in research-log if there is an obvious regulatory question
9. Human authority assigns Builder and Reviewer for first sprint
10. Record assignments in `work/current-session.md`
11. Architect presents initial design to human authority — approval before any task is written

---

## Codex Review Request

**Reviewer:** Codex
**Date:** 2026-03-18
**File:** `ak-dev-framework-interim.md`
**Requested by:** AK

This is the interim framework document capturing everything built and learned during the AKCoach project. It is intended to be a universal, sector-agnostic, model-agnostic starting point for any future project.

**What I need from you:**

1. **Completeness** — what is missing that should be here? What gap exists that would cause a future project to fail?
2. **Consistency** — are there internal contradictions between sections? Any place where two sections give conflicting instructions?
3. **Clarity** — any section that would confuse a model reading it for the first time in a fresh session?
4. **BA and compliance layer** — does Section 9 cover the research and compliance responsibility adequately? What would you add?
5. **Audit log** — is the Thread ID mechanism sufficient as a common link? What edge cases does it miss?
6. **Security model** — are the five questions in Section 13 sufficient? What is missing from the hard rules?
7. **Your honest assessment** — where will this framework break down in practice? What is the highest-risk assumption it makes?

Use the finding format from Section 10 for any specific issues. Plain English summary at the end.

Write your response below this line.

---
FINDING-ID: RVW-001
Task:          FRAMEWORK-INT-001
Sprint:        interim
Type:          design-risk
Severity:      high
Disposition:   must-fix
Confidence:    high
Scope reviewed:Sections 3, 4, 5, 14, 16
Blocking?:     yes
Expected:      Role boundaries, workflow, and starter-kit artifacts should describe the same operating model.
Actual / Risk: The document says the framework is model-agnostic and seat-based, but the execution model still depends on project-role personas like Architect, BA, QA, Junior Developer plus separate Builder and Reviewer seats. In practice this creates an unresolved control question: who is the real actor for build and review decisions in a session, the persona or the seat? Future projects will drift because different readers will interpret authority differently.
Evidence:      Section 3 defines permanent personas; Section 5 defines Builder/Reviewer as separate seats; Section 14 still requires Architect code review before task completion; Section 16 exports both persona skill files and seat-based review flow.
Recommended next step: Collapse the framework into one primary operating model. Either keep personas as the main execution roles and describe Builder/Reviewer as temporary assignments across those personas, or make Builder/Reviewer the main model seats and move Architect/BA/QA into functional responsibilities rather than separate always-on terminals.
Status:        open
Thread ID:     FRAMEWORK-INT-001

FINDING-ID: RVW-002
Task:          FRAMEWORK-INT-001
Sprint:        interim
Type:          consistency
Severity:      high
Disposition:   must-fix
Confidence:    high
Scope reviewed:Sections 2, 4, 7, 11, 14
Blocking?:     yes
Expected:      File lifecycle rules should be internally consistent so models know what is permanent, what is cleared, and what must be archived.
Actual / Risk: The document says only execution queues and channel are cleared, but later says `work/current-session.md` is cleared at session end while also requiring it to hold session state at all times. The audit log is append-only, but the channel also records handoffs that are then cleared, which creates ambiguity about what must be copied into audit history and when. This will create inconsistent hygiene and lost context between sessions.
Evidence:      Section 2 Principle 3; Section 7 File Ownership table marks `work/current-session.md` as cleared; Section 11 requires all actions to be logged in `audit-log.md`; Section 14 requires session audit completeness.
Recommended next step: Define file classes explicitly: permanent, per-sprint archive, per-session working file, and ephemeral transport. For each class, state when it is updated, when it is archived, and what audit entry is mandatory before it is cleared.
Status:        open
Thread ID:     FRAMEWORK-INT-001

FINDING-ID: RVW-003
Task:          FRAMEWORK-INT-001
Sprint:        interim
Type:          clarity
Severity:      medium
Disposition:   should-fix
Confidence:    high
Scope reviewed:Sections 4, 5, 6
Blocking?:     no
Expected:      A fresh-session reader should be able to tell exactly what packet each role must read and in what order.
Actual / Risk: The framework is explicit about the review packet, but not about the builder packet or the minimum session-start read order for each role. It says "every session reads memory before doing anything else," but does not specify the exact mandatory files for Architect, Builder, Reviewer, BA, and QA. This makes compliance with the framework hard to verify and encourages selective reading.
Evidence:      Section 2 Principle 2; Section 5 Review Packet is defined; no equivalent Builder Packet or per-role read sequence appears in Sections 3-5.
Recommended next step: Add a mandatory "Session Start Packet" table for each role listing required files in order, plus a smaller fast-path packet for trivial changes.
Status:        open
Thread ID:     FRAMEWORK-INT-001

FINDING-ID: RVW-004
Task:          FRAMEWORK-INT-001
Sprint:        interim
Type:          compliance-gap
Severity:      medium
Disposition:   should-fix
Confidence:    high
Scope reviewed:Sections 2, 8, 9, 13
Blocking?:     no
Expected:      The BA and compliance layer should distinguish legal facts, policy decisions, assumptions, and jurisdiction-specific applicability.
Actual / Risk: Section 9 is strong, but it lacks a dedicated research log format, source quality standard, and review cadence for changing regulations. "Pre-populated with universal regulations" is risky because many regulations are conditional, jurisdiction-bound, and change over time. Without fields for source, last verified date, and counsel-needed flag, teams may treat stale or over-generalized compliance entries as settled truth.
Evidence:      Section 8 references `memory/research-log.md` but the file is not defined in Section 7 or Section 9; Section 8 says compliance register is pre-populated with GDPR/basic data protection; Section 9 compliance format lacks source provenance and legal-review escalation.
Recommended next step: Add `memory/research-log.md`, define its schema, and extend compliance entries with `Source`, `Last verified`, `Requires counsel`, and `Confidence`. Also state that pre-populated compliance entries are advisory starting points, not legal conclusions.
Status:        open
Thread ID:     FRAMEWORK-INT-001

FINDING-ID: RVW-005
Task:          FRAMEWORK-INT-001
Sprint:        interim
Type:          design-risk
Severity:      medium
Disposition:   should-fix
Confidence:    high
Scope reviewed:Sections 10, 11, 12
Blocking?:     no
Expected:      The Thread ID system should cleanly handle multi-task work, cross-cutting decisions, and findings that span more than one thread.
Actual / Risk: Thread IDs are useful, but the current design assumes one dominant thread per action. In practice a single change can touch multiple tasks, one finding can apply to several tasks, and one decision can resolve multiple findings. Forcing a single Thread ID will either duplicate audit entries or hide important cross-links.
Evidence:      Section 11 says each activity carries a Thread ID and describes task IDs as the thread for all related actions; Section 10 requires one Thread ID per finding; Section 12 requires one Thread ID per reconciliation entry.
Recommended next step: Keep one primary Thread ID, but add `Related Threads` to findings, audit entries, and reconciliation records. Also define when a new umbrella thread should be created for cross-cutting work.
Status:        open
Thread ID:     FRAMEWORK-INT-001

FINDING-ID: RVW-006
Task:          FRAMEWORK-INT-001
Sprint:        interim
Type:          security
Severity:      medium
Disposition:   should-fix
Confidence:    high
Scope reviewed:Section 13
Blocking?:     no
Expected:      The security model should cover authorization, input trust, side effects, secrets, and abuse controls for both internal and external interfaces.
Actual / Risk: The five questions in Section 13 are a good baseline, but they do not explicitly ask about idempotency, rate limiting, replay protection, third-party calls, or trust boundaries for derived identifiers coming from clients. Those are common failure modes in modern app workflows and should be called out directly.
Evidence:      Section 13 questions cover access, data boundaries, sensitive data, auditability, and malformed input, but not abuse-rate controls or client-supplied foreign identifiers.
Recommended next step: Add at least three explicit checks: "Can this action be replayed or duplicated?", "What anti-abuse or rate controls are needed?", and "Which identifiers must be derived server-side rather than trusted from the client?"
Status:        open
Thread ID:     FRAMEWORK-INT-001

FINDING-ID: RVW-007
Task:          FRAMEWORK-INT-001
Sprint:        interim
Type:          design-risk
Severity:      medium
Disposition:   should-fix
Confidence:    medium
Scope reviewed:Sections 2, 4, 6, 11
Blocking?:     no
Expected:      Human authority should remain in control without becoming the operational bottleneck for routine work.
Actual / Risk: The framework says AK triggers every transition, carries every packet, reads findings, decides outcomes, and receives 30-minute check-ins. This preserves control, but on larger projects it will create a throughput bottleneck and encourage shortcuts around the process. The highest-risk assumption in the framework is that human mediation remains scalable as project complexity rises.
Evidence:      Section 2 Principle 6; Section 4 30-Minute Check-in Protocol; Section 5 Review Packet handoff; Section 6 AK Is the Bridge.
Recommended next step: Define which handoffs require explicit AK action and which can be pre-authorized through templates or standing rules. Keep AK approval for scope, disputes, and risk acceptance, but allow routine packet assembly and archival steps to be delegated to the active role.
Status:        open
Thread ID:     FRAMEWORK-INT-001

Plain-English summary:

This is a strong interim draft. It is much closer to a usable framework than to a thought experiment, and the security and review sections are materially better than the earlier versions. The main issues are structural, not conceptual.

What is missing or needs tightening:
- define one primary operating model: persona-driven or seat-driven
- define file lifecycle classes and archive rules more precisely
- add a builder/session-start packet, not just a review packet
- formalize `memory/research-log.md` and add source-verification fields to compliance
- extend Thread ID with cross-links for multi-task or cross-cutting work
- expand the security questions to cover replay, abuse, and client-trusted identifiers
- reduce the risk that AK becomes the bottleneck for every routine transition

My honest assessment:
- The framework is viable.
- The BA/compliance layer is directionally strong but still under-specified on evidence quality and legal-change handling.
- The audit log design is useful, but a single-thread model is too simple for real multi-task delivery.
- The highest-risk assumption is operational scalability: the framework assumes AK can remain the bridge for every meaningful transition without slowing the system enough that people start bypassing it.

If you fix the seat-vs-persona ambiguity and the file lifecycle rules first, the rest becomes much easier to operate consistently.
