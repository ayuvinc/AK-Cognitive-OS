# Claude Start Guide
# AK Cognitive OS -- Project Template
# Read this before your first session. Every step matters.

---

## Before You Type Anything

Run through every item in this list before opening Claude. Missing even one will cause a
BLOCKED output and you will lose time diagnosing it mid-session.

### Prechecks

- [ ] CLAUDE.md exists in the project root AND all placeholders are filled in
      (search for [OWNER_NAME], [PROJECT_NAME], [STACK] -- none of these should remain)
- [ ] tasks/ directory exists and contains all four required files:
      - tasks/todo.md
      - tasks/ba-logic.md
      - tasks/ux-specs.md
      - tasks/lessons.md
      - tasks/next-action.md
- [ ] releases/audit-log.md exists (it can be empty, but the file must exist)
- [ ] channel.md exists in the project root (copy from project-template/channel.md if missing)

If any of these are missing, do not open Claude yet. Create the missing file first.
An empty file is fine. A missing file will BLOCK the session at the first command.

---

## Before Building — Planning First

Core planning documents are conversation-derived artifacts. The AI must:
1. Begin with a structured conversation
2. Summarize the user's answers
3. Ask for confirmation
4. Then create documents

The AI must NOT:
- Infer the whole project and start writing planning docs immediately
- Treat its own inferences as user-confirmed facts
- Skip the discovery conversation for non-trivial projects

See `guides/11-conversation-first-planning.md` for the full workflow.

---

## Greenfield First Flow

Use this when starting a brand new project from scratch.

```
Stage 0: Discovery conversation (8 questions)
Stage 1: /ba → confirm problem-definition.md + scope-brief.md
Stage 2: /architect → draft + confirm hld.md
Stage 3: /architect + /junior-dev → create LLD for first feature
Stage 4: /architect → derive tasks from HLD + LLD
Stage 5: /qa → add acceptance criteria
Stage 6: /junior-dev → build
Stage 7: /session-close
```

---

## Mid-Build Recovery Flow

Use this when joining a project that already has code but is missing planning artifacts.

```
Stage 0: Recovery conversation (7 questions) + code inspection
Stage 1: Generate current-state.md
Stage 2: Backfill problem-definition, scope-brief, hld
Stage 3: LLD for active + next features
Stage 4: Realign tasks
Stage 5: Resume normal build flow
```

---

## First Run Sequence

Follow these steps exactly. Do not skip step 2 -- launching from the wrong directory means
CLAUDE.md will not load and the persona commands will not be available.

### Step 1 -- Open your terminal in the project root

Make sure your working directory is the root of your project (where CLAUDE.md lives),
not a subdirectory.

### Step 2 -- Launch Claude from the project root

```
cd /path/to/your-project && claude
```

Do not run `claude` first and then `cd` inside the session. CLAUDE.md is read at launch
time. If you launch from the wrong folder, the slash commands will not be found.

### Step 3 -- Open a session

Type the following when Claude starts:

```
/session-open
session_id: 1
sprint_id: 1
persona: architect
```

Claude will confirm the session is OPEN, read the session state, and state the Architect
Role Card aloud. If it does not do this, something is wrong -- check the failures[] list
in the output.

---

## Recommended First Flow

Use this persona chain for a typical first session. Run each command in order.
Each persona hands off to the next via channel.md.

```
/ba          -- Business Analyst: confirms what you are building and why.
               Writes decisions to tasks/ba-logic.md.

/ux          -- UX Designer: defines user flows and interaction rules.
               Writes specs to tasks/ux-specs.md.

/architect   -- Architect: reads BA + UX outputs, designs the implementation,
               writes tasks to tasks/todo.md, gets AK approval.

/qa          -- QA: adds acceptance criteria to every PENDING task in tasks/todo.md.

/junior-dev  -- Junior Developer: builds tasks one at a time, marks READY_FOR_QA.

/qa-run      -- QA Run: verifies each built task against acceptance criteria.
               Returns QA_APPROVED or QA_REJECTED.

/session-close -- Closes the session, writes tasks/next-action.md, logs to audit-log.md.
```

You do not have to run all seven in a single session. A short session might just be
/ba -> /architect. The chain is a guide, not a constraint. Always close with /session-close
regardless of how far you got.

---

## Always Close With /session-close

This is not optional. If you close the Claude window without running /session-close:

- SESSION STATE remains OPEN in CLAUDE.md
- The next persona to run will read a stale session state and may act on outdated context
- tasks/next-action.md will not be updated -- the next session will have no clear starting point
- releases/audit-log.md will not have a SESSION_CLOSED entry
- Any open BOUNDARY_FLAGs will persist silently into the next session

You will then need to manually clean up these files before the next session starts.
It takes two minutes to close properly. It takes twenty minutes to recover from not closing.

---

## Output Envelope Reminder

Every agent output from every persona and skill produces exactly 10 fields.
These are defined in schemas/output-envelope.md. Here is what each field means
in plain language:

| Field            | What it means                                                        |
|------------------|----------------------------------------------------------------------|
| run_id           | A unique ID for this specific run. Format: agent-sessionid-sprintid-timestamp |
| agent            | Which persona or skill produced this output (e.g. "architect", "qa") |
| origin           | Which AI stack ran it: claude-core, codex-core, or combined          |
| status           | Did it pass? PASS = all good. FAIL = ran but found problems. BLOCKED = could not run. |
| timestamp_utc    | When it ran, in ISO-8601 format (e.g. 2026-03-21T14:00:00Z)         |
| summary          | One sentence describing what happened                                |
| failures[]       | List of problems found. Empty if status is PASS.                     |
| warnings[]       | Non-blocking concerns. The run can continue, but you should note these. |
| artifacts_written[] | Which files were created or updated during this run               |
| next_action      | One sentence telling you what to do next                             |

If you see an output that is missing any of these 10 fields, the output is invalid.
The agent should have returned status: BLOCKED with SCHEMA_VIOLATION. If it did not,
file a BOUNDARY_FLAG and do not proceed.

---

## BOUNDARY_FLAG Reminder

A BOUNDARY_FLAG is a hard stop. It means a persona detected something that prevents
safe continuation -- a missing input, an out-of-scope request, an unresolved decision,
or a security concern.

When you see status: BLOCKED in any output:

1. Do not ignore it.
2. Read the failures[] list in the output. It will tell you exactly what is missing.
3. Fix the missing item (create the file, provide the input, resolve the question).
4. Re-run the same command.

Do not try to proceed past a BLOCKED status. The persona stopped for a reason.
Forcing past a BOUNDARY_FLAG is the most common source of broken sessions.

BOUNDARY_FLAGs also appear inline in tasks/todo.md using this format:

```
#### BOUNDARY_FLAG: [TASK-ID]-BF-01
- Filed by: [persona]
- Request received: [one sentence]
- Out-of-role because: [which rule was violated]
- Needs: [which persona must handle it]
- Action required: [one sentence]
- Status: OPEN
```

Only the Architect resolves BOUNDARY_FLAGs. They must be resolved before any new work
starts in a session.

---

## Common First-Run Problems

Quick fixes for the five most common issues new users hit. For the full list of 15
failure patterns and detailed fixes, see guides/07-common-failures.md.

**1. "Command not found: /architect"**
You launched Claude from the wrong directory. CLAUDE.md was not loaded.
Fix: Close Claude. Run: cd /path/to/your-project && claude

**2. "releases/audit-log.md not found"**
The audit log file was never created during project bootstrap.
Fix: Create the file manually (it can be empty). Then re-run your command.

**3. "status: BLOCKED -- MISSING_INPUT: session_id"**
You ran a command without providing required inputs.
Fix: Re-run the command and include session_id, sprint_id, and persona in your message.

**4. "Session left OPEN from last time"**
A previous session was never closed with /session-close.
Fix: Run /session-close now to close it, then open a new session normally.

**5. "channel.md is missing or stale"**
The channel file was not created or still has a completed handoff from last session.
Fix: Copy project-template/channel.md to your project root. Clear the contents.

For detailed fixes on all 15 known failure patterns: guides/07-common-failures.md
