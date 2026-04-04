# Gating Cluster Boundary Model — AK Cognitive OS
# Defines distinct scope for the four adjacent gating skills
# Reference: TASK-002 (Phase 5 boundary tightening)

---

## The Four Gating Skills

| Skill | Trigger | Input | Output | Blocks if |
|---|---|---|---|---|
| `/codex-intake-check` | Before sending to Codex | Task block, artifacts | Readiness verdict | Task incomplete or ambiguous |
| `/handoff-validator` | Before any cross-agent handoff | Artifact set for handoff | Completeness verdict | Required artifacts missing |
| `/review-packet` | Before Architect code review | All task artifacts | Assembled review packet | Review materials absent |
| `/sprint-packager` | At sprint close | QA_APPROVED tasks | Archive package | Tasks not all QA_APPROVED |

---

## Boundary Definitions

### `/codex-intake-check`
**When:** Immediately before dispatching work to Codex (not Claude).
**What it checks:**
- Task has complete spec, BA sign-off, and acceptance criteria
- No open BOUNDARY_FLAGs in the task block
- Architecture constraints are written and unambiguous
- Codex can execute the task with the provided context alone (no mid-task clarification loops)

**Does NOT check:** Code quality, test results, or UX spec completeness — those are post-build concerns.

**Gate type:** Pre-dispatch readiness. Blocks Codex dispatch only.

---

### `/handoff-validator`
**When:** Before any artifact is handed off from one persona to the next in the delivery chain.
**What it checks:**
- All artifacts listed as required for the receiving persona are present
- Status fields are set correctly (e.g., READY_FOR_QA before QA picks up)
- No open items that would block the receiving persona from starting

**Does NOT check:** Whether the content of artifacts is correct (that is the receiving persona's job) or whether the build passes (that is /qa-run).

**Gate type:** Artifact completeness gate. Fires at any handoff point.

---

### `/review-packet`
**When:** Before the Architect conducts a code review pass on completed work.
**What it checks:**
- Changed files list is present
- Task spec and acceptance criteria are accessible
- QA findings (if any) are attached
- Diff or branch reference is provided

**Does NOT check:** Whether the code is correct (that is the Architect's review job) or whether tests pass (that is /qa-run).

**Gate type:** Review preparation. Assembles materials; does not make a pass/fail determination itself.

---

### `/sprint-packager`
**When:** At sprint close, after all tasks in the sprint are QA_APPROVED.
**What it checks:**
- All planned sprint tasks are in QA_APPROVED status
- Session archive (releases/session-N.md) has entries for each completed task
- audit-log.md has corresponding entries
- next-action.md is written for the next session

**Does NOT check:** Code quality, individual task correctness, or compliance status (those are checked earlier in the chain).

**Gate type:** Sprint closure gate. Produces the sprint archive package.

---

## Decision Guide

```
Task is about to go to Codex?
  └─ /codex-intake-check

Passing artifacts from one persona to the next?
  └─ /handoff-validator

Architect is about to do a code review?
  └─ /review-packet

Sprint is closing and all tasks are QA_APPROVED?
  └─ /sprint-packager
```

No two of these skills have overlapping trigger conditions. Each fires at a distinct lifecycle moment.

---

*Added: Session 5, TASK-002 — gating cluster boundary tightening*
