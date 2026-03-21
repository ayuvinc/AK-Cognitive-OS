# Codex Start Guide
# AK Cognitive OS -- Project Template
# Read this before running any Codex task in this framework.

---

## How Codex Works With This Framework

Codex operates differently from Claude. Understanding this distinction prevents the most
common mistakes.

**Codex does not use slash commands.** There is no /architect or /qa-run for Codex.
Slash commands are Claude-only features that map to .claude/commands/ files. Codex
does not load those files.

**Codex reads codex-prompt.md files pasted as the system prompt.** Every persona and
skill in this framework has a corresponding codex-prompt.md file. That file contains
the full instruction set for that persona. You paste the entire contents as the system
prompt before starting your task.

**Every persona and skill has its own codex-prompt.md.** You will find them at:
- personas/{name}/codex-prompt.md for each persona (architect, ba, ux, qa, junior-dev, etc.)
- skills/{name}/codex-prompt.md for each skill (session-open, session-close, etc.)

This means Codex tasks are explicit and portable. You choose the right prompt, paste it,
then describe your task. Codex returns a structured output matching the same 10-field
envelope that Claude uses. The output contract is identical. Only the activation method
is different.

---

## Startup Checklist

Complete every item before pasting anything into Codex. A missing item will cause Codex
to return status: BLOCKED. It is faster to check now than to debug mid-task.

- [ ] Sprint summary exists and is current (describes what was built this sprint)
- [ ] Changed-files manifest is included in the sprint summary (list of files modified)
- [ ] Acceptance criteria map is written (which task maps to which criterion)
- [ ] Regression evidence is ready: test results, build output, lint output
      (Codex reviewer will ask for these -- have them ready to paste)
- [ ] tasks/ux-specs.md has been reviewed if any UI was changed this sprint
- [ ] Architecture constraints are noted if any new types or routes were introduced
      (check personas/architect/schema.md for what counts as a constraint)
- [ ] Security sign-off from /security-sweep is available if the task touches auth,
      data access, or external APIs

---

## How to Pick the Right Prompt

Use this table to find the correct codex-prompt.md for your task.

| Task                                  | File to paste                                      |
|---------------------------------------|----------------------------------------------------|
| Code review of a completed sprint     | framework/codex-core/reviewer-contract.md          |
| Creating new code or a new feature    | framework/codex-core/creator-contract.md           |
| Compliance and regulatory check       | personas/compliance/codex-prompt.md                |
| Research task (market, legal, policy) | personas/researcher/codex-prompt.md                |
| Architecture review or design check   | personas/architect/codex-prompt.md                 |
| Business logic validation             | personas/ba/codex-prompt.md                        |
| UX review against wireframe           | personas/ux/codex-prompt.md                        |
| QA acceptance criteria check         | personas/qa/codex-prompt.md                        |

When in doubt between reviewer and creator: if code already exists and you want it
checked, use reviewer-contract. If you are starting from scratch, use creator-contract.

---

## Paste Protocol

Follow these steps in order every time you start a Codex task.

### Step 1 -- Open Codex
Open a new Codex session or thread. Do not reuse a session from a different task --
the system prompt will be wrong.

### Step 2 -- Open the relevant codex-prompt.md file
Find the correct file using the table above. Open it in a text editor or file viewer.

### Step 3 -- Paste the entire contents as the system prompt
Paste the full file contents into the system prompt field. Do not summarise it.
Do not paraphrase. Paste the whole thing. The prompt contains validation logic,
boundary rules, and output contracts that depend on every line being present.

### Step 4 -- Provide your task context as the user message
Write a clear user message describing what you need done. See the Sample Kickoff Block
below for the required fields.

### Step 5 -- Include all required context in the user message
The user message must include: session_id, sprint_id, objective, and files in scope.
Missing any of these will return status: BLOCKED with MISSING_INPUT.

---

## Sample Kickoff Block

Use this as a template for your user message. Fill in the actual values.

```
session_id: 5
sprint_id: 2
objective: Review authentication implementation for security issues
files_in_scope:
  - app/api/auth/route.ts
  - lib/auth.ts
  - middleware.ts

Context:
This sprint added email/password authentication using Supabase Auth.
The login route validates credentials and sets a session cookie.
No changes were made to the database schema.
Regression evidence: build passes, lint passes, 12/12 tests pass.
```

Adjust the files_in_scope list to match what was actually changed.
The more specific you are, the better the output quality.

---

## Output Contract Reminder

Codex outputs the same 10-field envelope as Claude. Every Codex output must contain
all 10 fields. If any field is missing, the output is invalid.

| Field            | What it means                                                        |
|------------------|----------------------------------------------------------------------|
| run_id           | Unique ID for this run. Format: agent-sessionid-sprintid-timestamp   |
| agent            | Which persona or skill produced the output                           |
| origin           | Must be "codex-core" for pure Codex runs                             |
| status           | PASS = all good. FAIL = ran, found problems. BLOCKED = could not run. |
| timestamp_utc    | When it ran, ISO-8601 format                                         |
| summary          | One sentence describing what happened                                |
| failures[]       | Problems found. Empty array if status is PASS.                       |
| warnings[]       | Non-blocking concerns to note                                        |
| artifacts_written[] | Files created or updated during this run                          |
| next_action      | One sentence: what to do next                                        |

If Codex returns partial output without all 10 fields, do not accept it.
Ask Codex to reformat its output to match the full envelope.

---

## Boundary Behavior

Codex follows the same BOUNDARY_FLAG rules as Claude. If required inputs are missing
or the task is outside the persona's scope, Codex will return status: BLOCKED.

**Do not override a BLOCKED status.** Do not add a follow-up message saying "just proceed
anyway." The BLOCKED status exists to prevent incomplete or unsafe work from continuing.

When Codex returns BLOCKED:
1. Read the failures[] list -- it will name the exact missing items
2. Provide the missing items in a follow-up message
3. Ask Codex to re-run with the complete inputs

The most common Codex BLOCKED cause is a missing sprint summary or incomplete
files_in_scope list. Check the Startup Checklist before assuming Codex made an error.

---

## Handoff to Claude via channel.md

When a Codex task completes and the result needs to be passed to a Claude persona
(for example, Codex did a review and the Architect needs to act on the findings),
write the handoff to channel.md using this exact format:

```
from: codex-core
to: architect
status: PASS
message: Review complete. 2 S1 findings in failures[]. See next_action.
```

Field definitions:
- from: always "codex-core" for Codex-originated handoffs
- to: the Claude persona that should act next
- status: the status from the Codex output envelope (PASS, FAIL, or BLOCKED)
- message: one sentence summarising what the receiving persona needs to know

The receiving Claude persona reads channel.md on startup. If the status is FAIL or
BLOCKED, the Claude persona will resolve the findings before proceeding to new work.

Do not leave channel.md with a stale handoff from a previous session. Clear it at
the start of each new session or it will confuse the next persona to run.
