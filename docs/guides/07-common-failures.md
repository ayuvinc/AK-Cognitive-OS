# Guide 07 -- Common Failures and Fixes
# AK Cognitive OS
# Last reviewed: 2026-03-21

---

## How to Use This Guide

When a command fails, find the failure name that matches what you are seeing, read the
root cause, and follow the exact fix steps. Each entry is self-contained -- you do not
need to read the whole guide. If your failure is not listed here, check the output
envelope's failures[] field for the error code, then search the schemas/ directory
for the relevant validation rule. If still stuck, open a fresh session, describe the
BLOCKED output to the Architect, and ask it to diagnose.

---

## Failure 1 -- Command not found: /architect

**Symptom:**
You type /architect (or any slash command) and Claude responds with something like
"I don't have a command called /architect" or returns a generic answer instead of
activating the persona.

**Root cause:**
Claude's slash commands are loaded from .claude/commands/ at launch time. If you
launched Claude from a directory that is not the project root, CLAUDE.md was not
found and the commands directory was not registered. The commands simply do not exist
in this session.

**Fix:**
1. Close the current Claude session entirely.
2. In your terminal, navigate to the project root: cd /path/to/your-project
3. Confirm CLAUDE.md is present in that directory.
4. Run: cd /path/to/your-project && claude
5. Once Claude opens, try the command again.
Note: you cannot fix this mid-session by running cd inside Claude. The commands
directory is set at launch, not on cd.

---

## Failure 2 -- releases/audit-log.md not found

**Symptom:**
A persona or skill returns status: BLOCKED with failures[] containing something like
"MISSING_INPUT: audit-log" or an error referencing [AUDIT_LOG_PATH] not found.

**Root cause:**
The audit log file was not created during project bootstrap. The framework expects
this file to exist even if empty. Several skills (session-open, session-close,
compliance) write to it and will not proceed if it is absent.

**Fix:**
1. Without closing Claude, open a second terminal window.
2. Run: touch /path/to/your-project/releases/audit-log.md
3. Return to Claude and re-run the command that blocked.
The file can be completely empty at first -- the skill will write the first entry.

---

## Failure 3 -- channel.md is missing or stale

**Symptom:**
A persona reads channel.md and either reports it missing, or reads the wrong handoff
(a completed handoff from a previous session that was never cleared).

**Root cause:**
channel.md was not copied from the template during project setup, or it was left with
a completed handoff from a previous session. A stale channel.md causes the next persona
to act on old information -- it may think the previous task passed when it actually failed,
or that a different persona is expected next.

**Fix:**
If missing:
1. Copy project-template/channel.md to your project root.
2. Clear the contents (leave the file but empty it).
3. Re-run your command.

If stale (previous session's data still there):
1. Open channel.md in a text editor.
2. Delete the old handoff content.
3. If a new handoff is needed, write the correct from/to/status/message now.
4. Re-run your command.

---

## Failure 4 -- Session left OPEN

**Symptom:**
You open a new session and the Architect (or any persona) reports that SESSION STATE
is already OPEN, or it finds a SESSION_OPENED entry in audit-log.md with no matching
SESSION_CLOSED entry.

**Root cause:**
The previous session was closed by closing the terminal window or browser tab without
running /session-close. The session state was never updated to CLOSED, so the framework
treats it as still active.

**Fix:**
1. Run /session-close to formally close the abandoned session.
2. Provide the session_id of the abandoned session when prompted.
3. If tasks were incomplete, the session-close skill will document them as abandoned.
4. Once closed, run /session-open to start a new session normally.
Do not skip this step and start new work on top of an open session -- it corrupts the
audit log and makes it impossible to trace what happened in each sprint.

---

## Failure 5 -- status: BLOCKED -- MISSING_INPUT: session_id

**Symptom:**
You run a skill (such as /session-open, /session-close, or /architect) and the output
immediately returns status: BLOCKED with failures[] listing MISSING_INPUT: session_id
(or sprint_id, or objective).

**Root cause:**
Skill activation requires specific input fields in your message. If you just type
"/architect" with no context, the skill has nothing to work with and must block
rather than proceed on assumptions.

**Fix:**
Re-run the command and include the required fields in your message. Example:

```
/session-open
session_id: 4
sprint_id: 1
persona: architect
```

For /architect, you also need objective. For /qa-run, you need the task_id being
verified. Check the persona's schema.md file (personas/{name}/schema.md) for the
full list of required activation inputs.

---

## Failure 6 -- Missing origin field in output

**Symptom:**
An agent produces output that passes all other checks but the output envelope is
missing the origin field, or origin is set to a value not in [claude-core, codex-core,
combined].

**Root cause:**
An older version of the persona or skill file was used -- one written before the
origin field was added to the output envelope schema. This can also happen if someone
manually wrote a custom agent without checking schemas/output-envelope.md first.

**Fix:**
1. Open the persona file (.claude/commands/{name}.md or personas/{name}/codex-prompt.md).
2. Find the output envelope section.
3. Add the origin field if missing:
   - claude-core if this persona runs in Claude
   - codex-core if this persona runs in Codex
   - combined if this runs in both
4. Save the file and re-run the persona.
If this is a custom agent you built, cross-check every field in schemas/output-envelope.md
to ensure all 10 are present before running again.

---

## Failure 7 -- No BOUNDARY_FLAG -- persona proceeded past invalid state

**Symptom:**
A persona completed work that it should not have done -- for example, Junior Dev wrote
code without an architecture design, or QA approved a task that had open questions.
There is no BOUNDARY_FLAG in the output.

**Root cause:**
The persona file is missing its BOUNDARY_FLAG rules, or the rules are present but
were not enforced. This can happen if a persona file was modified and the out-of-role
detection block was accidentally removed, or if a completely new persona was added
without including boundary logic.

**Fix:**
1. Open the persona file.
2. Find the "When Out of Role" section (or equivalent).
3. Verify the BOUNDARY_FLAG format block is present and matches the format in
   .claude/commands/architect.md as the canonical example.
4. Add the BOUNDARY_FLAG block if missing.
5. Re-run validate-framework.sh to confirm the file now passes the check.
For the work that was already done incorrectly: review it manually and flag any
concerns in a new BOUNDARY_FLAG entry in tasks/todo.md.

---

## Failure 8 -- Codex review BLOCKED -- missing sprint summary

**Symptom:**
You start a Codex review session and Codex immediately returns status: BLOCKED with
failures[] referencing a missing sprint summary or missing changed-files manifest.

**Root cause:**
The Codex reviewer intake check requires a sprint summary describing what was built,
including a list of changed files and regression evidence (build, lint, test results).
Without this, Codex cannot perform a meaningful review -- it does not know what scope
to review or whether the baseline is stable.

**Fix:**
1. Write a sprint summary (a few sentences is enough) covering:
   - What was built or changed
   - Which files were modified (list them explicitly)
   - Build, lint, and test status
2. Include the sprint summary in your Codex user message.
3. Re-paste the system prompt and re-run.
See CODEX_START.md for the Sample Kickoff Block format.

---

## Failure 9 -- Wrong mode: COMBINED used for docs-only session

**Symptom:**
A session is running in COMBINED mode (using both Claude and Codex) but the session
only involves writing documentation, updating task files, or planning. No code is
being produced or reviewed. The overhead is unnecessary and the origin field will be
incorrect.

**Root cause:**
COMBINED mode is designed for sessions where Claude handles planning and coordination
while Codex handles code creation or review. Using COMBINED for documentation-only
work introduces unnecessary complexity and sets origin: combined on outputs that were
entirely produced by Claude.

**Fix:**
Use SOLO_CLAUDE mode for any session that does not involve Codex running actual code
tasks. In practice: if you are not pasting a codex-prompt.md into a Codex session
during this sprint, it is a SOLO_CLAUDE sprint.
Update the origin field in any outputs from this session to claude-core.
See guides/08-mode-selection-cheatsheet.md for the full decision table.

---

## Failure 10 -- Unresolved BOUNDARY_FLAG in channel.md blocking next agent

**Symptom:**
A persona reads channel.md on startup and finds a BOUNDARY_FLAG entry with status: OPEN.
The persona refuses to start new work and reports the flag as a blocker.

**Root cause:**
A BOUNDARY_FLAG was written to channel.md in a previous step and was never resolved.
The flag is blocking the handoff chain. The next persona correctly refuses to proceed
because unresolved flags represent known unknowns that could invalidate any work done
on top of them.

**Fix:**
1. Only the Architect resolves BOUNDARY_FLAGs.
2. Activate /architect.
3. The Architect will read the flag, identify what is missing or ambiguous, and either:
   a. Resolve it by providing the missing decision or input, or
   b. Escalate to AK if a product/priority decision is needed.
4. Once resolved, the Architect marks the flag Status: RESOLVED and removes it from
   channel.md.
5. The next persona can then proceed.
Do not manually delete a BOUNDARY_FLAG without resolving the underlying issue.

---

## Failure 11 -- SCHEMA_VIOLATION: envelope missing required field

**Symptom:**
An output is returned but the validate step (or the receiving persona) reports
SCHEMA_VIOLATION with a specific field name -- for example, SCHEMA_VIOLATION: warnings
or SCHEMA_VIOLATION: artifacts_written.

**Root cause:**
A custom agent or a modified persona was built without including all 10 required
output envelope fields. The framework's validation rules treat any missing field as
a SCHEMA_VIOLATION and block the output from being accepted downstream.

**Fix:**
1. Open schemas/output-envelope.md and review the full list of 10 required fields.
2. Open the persona or skill file that produced the invalid output.
3. Find the output template section and add the missing field.
4. Even if the field is always empty (such as warnings: [] on a simple skill),
   it must be present in the output.
5. Save, re-run validate-framework.sh, and re-run the task.

---

## Failure 12 -- tasks/ba-logic.md not cleared after sprint

**Symptom:**
The Architect or a downstream persona reads tasks/ba-logic.md and finds entries from
a previous sprint still marked PENDING or INCORPORATED (but not deleted). This causes
confusion about which decisions apply to the current sprint.

**Root cause:**
The session-close checklist requires that all ba-logic.md entries are either deleted
(after being INCORPORATED) or explicitly carried forward. A session was closed without
completing this step.

**Fix:**
1. Open tasks/ba-logic.md.
2. For each entry marked INCORPORATED: delete it -- it has already been used.
3. For each entry marked PENDING: decide whether it still applies to the current sprint.
   If yes, keep it and make sure the Architect addresses it before finalising design.
   If no, delete it and note the deletion in tasks/lessons.md.
4. The file should be empty at the end of every session. If it is not empty, the session
   was not closed properly.

---

## Failure 13 -- Normalization grep finding forbidden literal

**Symptom:**
The normalization or lint check reports a forbidden literal -- typically an absolute
file path hard-coded in a persona file, a schema, or a task file. Example:
"/Users/yourname/projects/myapp/releases/audit-log.md" instead of [AUDIT_LOG_PATH].

**Root cause:**
Someone wrote an absolute path directly into a framework file. Framework files use
placeholders like [AUDIT_LOG_PATH], [PROJECT_NAME], and [OWNER_NAME] so they can
be reused across different machines and projects. An absolute path breaks portability
and will cause failures when the framework is used on any machine other than the
original author's.

**Fix:**
1. Open the file flagged by the grep check.
2. Find the absolute path.
3. Replace it with the appropriate placeholder from CLAUDE.md.
   Common replacements:
   - Any path to releases/audit-log.md -> [AUDIT_LOG_PATH]
   - Any path to the project root -> [PROJECT_ROOT]
   - The project name -> [PROJECT_NAME]
4. Run the normalization check again to confirm the literal is gone.

---

## Failure 14 -- Compliance S0 blocking sprint close -- not caught early

**Symptom:**
You reach /session-close and the Architect reports that it cannot close the session
because a Compliance S0 finding is blocking. The sprint built a feature that handles
personal data, but /compliance was not run until the very end.

**Root cause:**
Compliance review was treated as a final check rather than an early check. S0 findings
(legal violations or blocking compliance issues) require architectural changes, not just
code tweaks. Running compliance last means the entire sprint may need to be reworked.

**Fix:**
Immediate fix for the current sprint:
1. Run /compliance now with the affected feature in scope.
2. Review the S0 findings in failures[].
3. Escalate to AK -- S0 findings require a product decision (fix, scope-reduce, or defer).
4. Do not close the sprint until S0 is resolved or explicitly deferred with AK sign-off.

Process fix for future sprints:
Add /compliance to your workflow immediately after /architect, before Junior Dev starts.
Any sprint that involves personal data collection, storage, or transmission should run
compliance before a single line of code is written. See guides/08-mode-selection-cheatsheet.md
for when to trigger compliance automatically.

---

## Failure 15 -- validate-framework.sh fails: missing BOUNDARY_FLAG

**Symptom:**
You run validate-framework.sh (the framework integrity check) and it reports that
one or more persona or skill files are missing the BOUNDARY_FLAG section.

**Root cause:**
A new persona or skill was added to the framework without including the required
BOUNDARY_FLAG block. The validation script checks every file in .claude/commands/
and personas/ for the presence of this block. It is a mandatory section.

**Fix:**
1. Open the file flagged by the script.
2. Find the "When Out of Role" or boundary behavior section.
3. If it is missing entirely, add it using the canonical format from
   .claude/commands/architect.md as the reference.
4. The block must include: Filed by, Request received, Out-of-role because, Needs,
   Action required, and Status fields.
5. Save the file and re-run validate-framework.sh.
6. If multiple files are flagged, fix them all before re-running -- the script checks
   the whole framework, not just one file.
