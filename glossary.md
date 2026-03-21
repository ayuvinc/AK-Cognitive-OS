# Glossary -- AK Cognitive OS

This glossary defines every key term used across the AK Cognitive OS framework. Terms are listed
in the order a new user is most likely to encounter them. Each definition is written in plain
English with analogies where helpful. If you are new, read from top to bottom once before your
first sprint.

---

## Persona

A persona is a named role that tells an AI agent what job it is doing right now. Think of it like
handing a staff member a specific job description: the same person can be a Researcher in the
morning and a Developer in the afternoon, but they behave differently based on which hat they are
wearing. In this framework each persona has its own file that spells out its purpose, the skills
it is allowed to call, and the output format it must follow.

---

## Skill

A skill is a self-contained, reusable task that an agent can perform. If a persona is a job title,
a skill is one specific procedure in that job's playbook -- for example, /sprint-packager bundles
artifacts into a review packet, and /codex-intake-check validates that a Codex review can begin.
Skills are invoked with a slash command and always return a structured output envelope so the next
step can be automated.

---

## Schema

A schema is the agreed-upon shape of a document or data structure. It defines exactly which fields
are required, what type of value each field must contain, and which fields are optional. A schema
acts like a contract between the agent producing output and the human or agent consuming it -- if
the output does not match the schema, the framework raises a SCHEMA_VIOLATION and stops rather
than passing bad data downstream.

---

## Harness

A harness is a test wrapper that runs a skill or persona in a controlled environment to confirm it
behaves correctly. Think of it as a flight simulator for your AI agent: you feed it scripted
inputs, observe the outputs, and check them against expected results -- all without touching a
live project. Harnesses live in the /harnesses directory and are run before any skill is deployed.

---

## BOUNDARY_FLAG

BOUNDARY_FLAG is a signal that an agent has reached the edge of its permitted scope and must stop.
It works like a physical fence on a construction site: the agent can see past the fence but is not
allowed to cross it. When an agent sets BOUNDARY_FLAG it must explain what boundary was hit, why,
and what the human operator should do next. It never silently ignores the boundary or works around
it on its own.

---

## Output Envelope (the 10-field YAML every agent returns)

The output envelope is the standard 10-field YAML block that every agent response must include.
Think of it as the shipping label on every package that leaves the factory: no matter what is
inside, the outside always carries the same fields so any downstream process can read it without
guessing. The 10 required fields are: session_id, sprint_id, persona, skill, status, findings,
next_action, artifacts, flags, and origin.

---

## Codex Prompt (codex-prompt.md)

codex-prompt.md is the instruction file loaded into Codex (or any secondary AI agent) at the
start of a code-generation session. It is the equivalent of the briefing document you hand a
contractor before they start work: it tells them the project context, the constraints, the output
format expected, and the exact task. This file must be regenerated or updated every sprint so it
reflects the current state of the project.

---

## Claude Command (claude-command.md slash command)

claude-command.md is the file that defines a custom slash command for Claude. When you type a
slash command like /sprint-packager in a Claude session, Claude looks up the matching
claude-command.md file to understand what steps to execute. It is analogous to a macro in a
spreadsheet: one short command triggers a defined sequence of actions.

---

## Session

A session is one continuous conversation with an AI agent (Claude or Codex) that begins with a
clear goal and ends with a session-close. Think of it like a focused work meeting: it has an
agenda, produces documented outputs, and ends with a written summary so the next meeting can
pick up exactly where this one left off. Sessions should not run open-ended -- they end when the
agreed task is done or a blocker is hit.

---

## Sprint

A sprint is a fixed unit of planned work made up of one or more sessions. Where a session is a
single conversation, a sprint is the container that groups related sessions together toward a
milestone. For example, Sprint 4 might contain three Claude sessions (planning, implementation,
review) and one Codex session (code generation). A sprint ends when all its sessions are closed
and the Codex review gate has been passed.

---

## SESSION STATE

SESSION STATE is the snapshot of everything that is true about a session at any given moment: what
has been completed, what is blocked, what the next action is, and which artifacts exist. It is
written to channel.md at the end of every session so that the next session -- even if it is a
different agent -- can read it and continue without needing a verbal handoff from the human. Think
of it as the shift-change report a nurse writes before leaving the ward.

---

## channel.md

channel.md is the shared communication file that both Claude and Codex can read and write. It
acts as the message board between the two agents: Claude writes a task or a summary to channel.md,
Codex reads it and writes back its output, and Claude reads that output to continue planning. No
verbal relay from the human is needed because everything flows through this file.

---

## audit-log.md

audit-log.md is the append-only record of every significant action taken during the project. Every
time a skill runs, a finding is raised, or a session closes, a timestamped entry is added to this
file. It is never edited, only appended. Its purpose is accountability: if something breaks or a
decision needs to be revisited, the audit log provides the evidence trail.

---

## next-action.md

next-action.md is a single-file instruction that tells the next agent or human operator exactly
what to do when they pick up the work. It is written at the end of every session or when a
BOUNDARY_FLAG is set. Think of it as the sticky note on the keyboard that says "run this command
next and check that file." It should be specific enough that the next session can start without a
briefing call.

---

## COMBINED mode

COMBINED mode is the operating mode where both Claude and Codex are active in the same sprint and
work together through channel.md. Claude handles planning, architecture, and review; Codex handles
code generation. The two agents pass work back and forth via channel.md without needing the human
to relay messages. This is the recommended mode for active development sprints.

---

## SOLO_CLAUDE mode

SOLO_CLAUDE mode is the operating mode where only Claude is active and Codex is not used. Claude
handles planning, analysis, documentation, and any code review that does not require code
generation. This mode is appropriate for research sprints, architecture planning, writing tasks,
and situations where Codex access is unavailable.

---

## SOLO_CODEX mode

SOLO_CODEX mode is the operating mode where Codex operates from a pre-written codex-prompt.md
without live Claude involvement. The human hands the prompt to Codex and Codex executes it. This
mode is used when the task is clearly defined, the prompt is complete, and there is no need for
mid-task planning from Claude. It is faster but less adaptive than COMBINED mode.

---

## Review Packet (7 required artifacts for Codex entry)

A review packet is the set of 7 artifacts that must exist before Codex is allowed to start a code
generation task. The 7 required artifacts are: the sprint brief, the BA logic document, the UX
spec, the definition of done, the codex-prompt.md, the updated channel.md, and the audit log
entry for the sprint. The /codex-intake-check skill verifies all 7 are present and complete before
Codex is given the green light.

---

## Codex Intake Check (/codex-intake-check skill)

/codex-intake-check is the skill that runs before every Codex session to verify the review packet
is complete and the sprint is ready for code generation. It reads the 7 required artifacts, checks
each one against its schema, and returns a pass or fail result. If any artifact is missing or
malformed the skill returns status: BLOCKED and lists what must be fixed before Codex can proceed.

---

## Sprint Packager (/sprint-packager skill)

/sprint-packager is the skill that collects all session outputs from a sprint, formats them into
the standard review packet, and writes the codex-prompt.md ready for Codex entry. Think of it as
the production supervisor who gathers all the parts at the end of a shift, checks them against the
parts list, and packages them for the next stage of the assembly line.

---

## S0 Finding

An S0 finding is a critical issue that blocks the sprint from proceeding. It represents a defect,
ambiguity, or missing requirement severe enough that writing or merging code would be incorrect or
unsafe until it is resolved. An S0 finding requires an immediate human decision before any further
work happens. No artifacts from the current session should be accepted while an S0 is open.

---

## S1 Finding

An S1 finding is a significant issue that must be fixed before the sprint closes, but does not
block all work from continuing. It typically represents a logic gap, a missing schema field, or a
non-trivial ambiguity that will cause problems later if ignored. S1 findings must be addressed and
resolved within the current sprint before the session-close is written.

---

## S2 Finding

An S2 finding is a minor issue or improvement suggestion that should be noted but does not block
progress. It is the equivalent of a code comment saying "this works but could be cleaner." S2
findings are logged in the audit log and added to the backlog for a future sprint. They do not
prevent session-close or Codex entry.

---

## Normalization

Normalization is the process of converting an agent output that does not match the schema into a
form that does match it, without losing meaning. Think of it as translating a handwritten note
into a standardized form. The framework normalizes output automatically where it can, but raises a
SCHEMA_VIOLATION if the gap is too large to normalize safely without human judgment.

---

## Forbidden Literal

A forbidden literal is a hard-coded value that must never appear in a template or prompt file
because it breaks portability. Examples include absolute file paths like /Users/someone/project or
machine-specific identifiers. Forbidden literals are replaced with placeholders in square brackets
such as [PROJECT_ROOT] so the template works on any machine for any project.

---

## [AUDIT_LOG_PATH]

[AUDIT_LOG_PATH] is the placeholder used in templates and prompts to represent the absolute path
to the project's audit-log.md file. Before running any skill that reads or writes the audit log,
this placeholder must be replaced with the real path. Using a placeholder instead of a hard-coded
path ensures the framework can be moved between machines and projects without editing every file.

---

## [PROJECT_ROOT]

[PROJECT_ROOT] is the placeholder for the absolute path to the root directory of the project being
built. It appears in codex-prompt.md, CLAUDE.md, and skill files wherever a path needs to
reference the project. Replacing [PROJECT_ROOT] with the real path is one of the first steps in
the setup checklist.

---

## [FRAMEWORK_ROOT]

[FRAMEWORK_ROOT] is the placeholder for the absolute path to the AK Cognitive OS framework
directory itself. It is distinct from [PROJECT_ROOT] because a single machine may have the
framework installed in one location and multiple different projects in other locations. Skills that
need to read framework files use [FRAMEWORK_ROOT] as their reference point.

---

## Definition of Done

The definition of done is a plain-language checklist that specifies exactly what conditions must
be true before a task or sprint is considered complete. It removes ambiguity about whether
something is "good enough." A typical definition of done includes: all acceptance criteria met, no
open S0 or S1 findings, all tests passing, and the audit log updated. It is one of the 7 required
artifacts in a review packet.

---

## BA Logic

BA logic (Business Analyst logic) is the document that translates a product requirement into
specific rules, conditions, and data flows that a developer or agent can implement. It answers
questions like: what happens when a user does X, what are the edge cases, and what data must be
validated. BA logic sits between the product requirement (what the business wants) and the UX spec
(how it looks) as the layer that defines how it works.

---

## UX Spec

The UX spec (User Experience specification) describes how a feature looks and behaves from the
user's point of view. It includes screen states, user flows, component names, and any interaction
details that affect what Codex must build. It does not include code -- it describes the intended
experience so that code generation produces the right UI without guessing.

---

## SCHEMA_VIOLATION

SCHEMA_VIOLATION is the error status returned when an agent output does not conform to the
required schema and cannot be automatically normalized. It is raised by the output envelope
validation step. When SCHEMA_VIOLATION appears, the session is halted, the violation is logged
in the audit log, and a human must decide whether to correct the output manually or re-run the
skill with better inputs.

---

## MISSING_INPUT

MISSING_INPUT is the status returned when a skill cannot execute because one or more required
inputs were not provided. It is distinct from SCHEMA_VIOLATION (which means the output is wrong)
-- MISSING_INPUT means the skill never ran because the inputs were incomplete. The skill returns a
list of which inputs are missing so the operator knows exactly what to supply before retrying.

---

## Regression Evidence

Regression evidence is the documented proof that a feature or behavior that previously worked
still works after a change was made. In this framework it typically means: a test was run before
the change, the same test was run after the change, and both results are recorded in the audit log.
Without regression evidence, a Codex session cannot be marked as passing the definition of done.

---

## RAG (Retrieval-Augmented Generation)

RAG is a technique where an AI agent searches a knowledge base for relevant information and
includes that information in its prompt before generating a response. Instead of relying only on
what the model learned during training, the agent retrieves up-to-date or project-specific
documents and uses them as context. In this framework RAG is used when skills need to reference
project documentation, prior session outputs, or external knowledge that the base model does not
contain.
