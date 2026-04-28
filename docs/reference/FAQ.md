# FAQ -- AK Cognitive OS

Quick answers to the most common questions about setting up and using the AK Cognitive OS
framework. For deeper definitions of any term used here, see glossary.md.

---

## Q: Do I need to know how to code to use this framework?

**A:** No. The framework is designed so that a non-coder acting as a Product Manager can run the
process end to end. Your job is to write requirements, answer intake questions, and make decisions
when a finding is raised. The agents (Claude and Codex) produce the code. You approve or redirect.
The more precisely you describe what you want, the better the output will be -- but that is a
writing skill, not a coding skill.

---

## Q: Can I skip Codex entirely and just use Claude?

**A:** Yes. SOLO_CLAUDE mode exists for exactly this reason. Claude can handle planning,
documentation, architecture, and lightweight code review without Codex. The tradeoff is that Claude
will not write large blocks of production code as reliably as Codex does in an agentic session.
For documentation sprints, research sprints, or early-stage planning, SOLO_CLAUDE mode is the
right choice. Switch to COMBINED mode when you are ready to generate real code.

---

## Q: What is the difference between a persona and a skill?

**A:** A persona is a role -- it defines what kind of agent is active and what its overall
purpose is. A skill is a specific task that persona can perform. Think of it this way: the
Developer persona is like a software engineer on your team. The /sprint-packager skill is like one
specific procedure in that engineer's job description. A single persona can have many skills, but
each skill is only available to the personas listed in its definition.

---

## Q: When is the Compliance persona mandatory?

**A:** The Compliance persona must be active any time the work involves regulated data, legal
requirements, or security controls. This includes HIPAA-relevant health data, financial
transaction records, authentication and authorization logic, and any feature that stores personally
identifiable information. When in doubt, run /codex-intake-check -- it will flag whether
Compliance review is required based on the sprint brief.

---

## Q: How do I start my very first sprint?

**A:** Follow the QUICKSTART.md file step by step. At a high level: (1) copy the project template
into your project folder, (2) replace all placeholders in CLAUDE.md with your real project paths,
(3) answer the intake questions for Sprint 1, (4) let Claude generate the sprint brief and BA
logic, (5) run /codex-intake-check to confirm the review packet is ready, then (6) hand the
codex-prompt.md to Codex. Do not skip the intake questions -- they are what prevent ambiguity from
entering the sprint.

---

## Q: What do I do if a skill returns status: BLOCKED?

**A:** Read the findings field in the output envelope. A BLOCKED status always includes a list of
what is missing or what decision is needed. Resolve each item in the list, then re-run the skill.
Do not try to proceed past a BLOCKED status by ignoring it -- the framework is designed so that
downstream steps will also fail or produce incorrect output if the blocker is not cleared first.

---

## Q: What if I forget to run /session-close?

**A:** The next session will not have a reliable SESSION STATE to start from. Claude will not know
what was completed, what was blocked, or what the next action is, and will have to reconstruct
context from prior files -- which takes time and risks missing something. Always run /session-close
before ending a conversation. If you genuinely forgot, open a new session and run
/session-close retroactively before starting new work: describe what was done, what was decided,
and what the next action is.

---

## Q: Can I use this framework with Python projects (not just Next.js)?

**A:** Yes. The framework is stack-agnostic. The DECISION_MATRIX.md file covers FastAPI, Django,
and Python-first architectures alongside Next.js. The personas, skills, schemas, and operating
modes work the same regardless of the language. The only difference is that your BA logic and UX
spec will reference Python modules and API routes instead of Next.js components, and your
definition of done may include Python-specific test commands like pytest instead of vitest.

---

## Q: How do I add a new persona I invented?

**A:** Create a new file in the /personas directory following the naming convention
persona-[name].md. Copy the structure from an existing persona file. Fill in: purpose, allowed
skills, output envelope requirements, and any domain-specific rules. Then add the persona name to
CLAUDE.md under the available personas list. Run /codex-intake-check on a test sprint to confirm
the new persona's output envelope passes schema validation before using it in production sprints.

---

## Q: What does BOUNDARY_FLAG mean in practice?

**A:** BOUNDARY_FLAG means the agent has encountered something it is not permitted to decide on
its own and has stopped. In practice this usually means one of three things: the task requires a
decision that has business, legal, or security implications; the inputs are too ambiguous for the
agent to proceed without guessing; or the task would affect something outside the defined project
scope. When you see BOUNDARY_FLAG in an output, read the explanation in the flags field, make the
decision described, and resume the session with that decision as an explicit input.

---

## Q: How many sessions should a sprint have?

**A:** There is no fixed number. A simple sprint might be one planning session and one Codex
session. A complex sprint might have four or five sessions covering research, BA logic, UX spec,
implementation, and review. The right number is whatever it takes to reach the definition of done
without cramming too much into a single session. A good rule of thumb: if a session is running
longer than 90 minutes of active work, split the remaining tasks into a new session.

---

## Q: Can multiple people use this framework on the same project?

**A:** Yes, but you need to establish who owns which roles. The framework assumes one Product
Manager directing the agents. If two people are sharing that role, agree on who reviews findings
and who approves sprint-close before starting. channel.md and audit-log.md are the shared record,
so all collaborators must read those files before starting any session. Concurrent sessions writing
to the same channel.md at the same time will create conflicts -- only one session should write at
a time.

---

## Q: What is the difference between COMBINED and SOLO_CLAUDE mode?

**A:** In COMBINED mode Claude and Codex both participate in the sprint and communicate through
channel.md. Claude plans and reviews; Codex generates code. In SOLO_CLAUDE mode only Claude is
active and Codex is not involved. SOLO_CLAUDE is faster to set up and good for non-code work, but
it cannot produce the volume or consistency of code that Codex delivers in a dedicated agentic
session. Use COMBINED mode for any sprint where the primary output is production code.

---

## Q: When should I use the Researcher persona?

**A:** Use the Researcher persona when you need the agent to investigate options, compare
approaches, or gather information before a decision is made -- but you do not yet want it to plan
or build anything. Good examples: evaluating which vector database to use, understanding the
tradeoffs between two authentication approaches, or summarizing how a third-party API works.
Research outputs feed into BA logic and sprint briefs; they are not themselves deliverables.

---

## Q: What happens if Codex review returns S0 findings?

**A:** All work stops until the S0 finding is resolved. S0 means something is wrong that makes
the current output unsafe or incorrect to use. Do not merge code, do not mark the sprint as done,
and do not start a new sprint that depends on this one. Read the S0 finding description, make the
human decision required, update the affected artifact, and re-run /codex-intake-check to confirm
the fix is valid before resuming.

---

## Q: How do I know when a session is truly done?

**A:** A session is done when every item on the definition of done checklist is checked, there are
no open S0 or S1 findings, and /session-close has been run successfully. The session-close output
will include a status of CLOSED -- that is the authoritative signal. If the status is anything
other than CLOSED, the session is not done regardless of how it feels subjectively.

---

## Q: Do I need to fill in every placeholder in CLAUDE.md before starting?

**A:** Yes. Unfilled placeholders like [PROJECT_ROOT] or [AUDIT_LOG_PATH] will cause skills to
fail or produce incorrect paths. The setup checklist in QUICKSTART.md walks through every
placeholder that must be replaced. This is a one-time task per project. Once CLAUDE.md is
configured for your project, you do not need to edit it again unless the project structure changes.

---

## Q: What is channel.md for?

**A:** channel.md is the communication file between Claude and Codex. Because the two agents
cannot talk to each other directly, channel.md acts as the shared whiteboard they both read and
write. Claude writes the task brief, context, and review notes to channel.md. Codex reads it,
executes the task, and writes its output back to the same file. Claude then reads that output to
continue planning. The human's job is to copy content between agents when needed, not to translate
it.

---

## Q: How do I handle a mid-sprint blocker?

**A:** Set BOUNDARY_FLAG in the current session output, document the blocker clearly in the flags
field, and run /session-close with status: BLOCKED rather than CLOSED. Write the decision needed
in next-action.md. When you have resolved the blocker -- through research, a stakeholder decision,
or clarifying requirements -- open a new session, reference the prior session's next-action.md,
and continue from where the sprint was paused.

---

## Q: Is the framework opinionated about cloud provider or tech stack?

**A:** No. The framework is agnostic about cloud provider and programming language. The
DECISION_MATRIX.md file provides guidance for common choices, but it does not mandate any of them.
The default project template uses Next.js and Supabase because those are the stack AK is currently
building with, but every reference to those technologies is a template default, not a requirement.
Any stack can be substituted as long as the personas, skills, and envelope schema are followed.

---

## Q: How do I update the framework when a new version releases?

**A:** Check RELEASE_NOTES.md for the list of files added or changed in the new version. Pull the
new files from the framework repository into your [FRAMEWORK_ROOT] directory. Do not overwrite
your CLAUDE.md or your project-specific files -- those are yours. Only update the framework-owned
files in /personas, /skills, /schemas, /harnesses, and /guides. After updating, re-run any
harnesses that cover the updated skills to confirm nothing regressed.

---

## Q: What is the audit log used for?

**A:** The audit log is the permanent record of what happened and when. It answers questions like:
which session introduced this change, what decision was made when that S1 finding was raised, and
what was the state of the project before this sprint started. It is not read during normal
operation -- it exists so that any future session, human reviewer, or debugging effort can
reconstruct the history of the project without relying on memory or verbal explanation. It should
be treated as write-once: append entries, never edit or delete them.
