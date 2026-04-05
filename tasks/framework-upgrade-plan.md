# AK Cognitive OS — v3.0 Delivery Plan
# Owner: AK (Product Manager)
# Architect: Claude Sonnet 4.6
# Goal: Every project runs v3.0 when Claude Code starts — enforced, not advisory
# Started: 2026-04-05
# Ends when: All 5 active projects are running v3.0 and verified

---

## Status Key
```
[ ] PENDING       — not started
[>] IN_PROGRESS   — actively being worked
[x] DONE          — complete and verified
[!] BLOCKED       — cannot proceed, reason noted
[~] SKIPPED       — consciously skipped, reason noted
```

---

## What This Plan Delivers

When complete, every project will start Claude Code with:
- **20 rationalized commands** — clean, purposeful, no duplicates
- **Full SDLC enforcement** — planning gates, build gates, Codex gate, release gate
- **Operating tier awareness** — MVP / Standard / High-Risk, each with different gate requirements
- **Canonical lifecycle** — 11 stages with formal stage-gate docs Claude can reference
- **Artifact ownership** — every file has an owner; personas are blocked from touching what isn't theirs
- **Self-governing framework** — change policy, versioning rules, deprecation rules

---

## Final Command Set (20) — Unchanged from v2.2

```
Session:      /session-open  /session-close  /compact-session
Personas:     /architect  /ba  /junior-dev  /qa  /ux  /designer
Quality:      /qa-run  /security-sweep  /compliance
Research:     /researcher
Codex:        /codex-prep  /codex-read
Intelligence: /teach-me  /lessons-extractor  /risk-manager
Utility:      /audit-log  /check-channel
```

---

## Architecture: How v3.0 "Runs" in Claude Code

v3.0 is not a new UI. It runs through three layers already in Claude Code:

```
Layer 1 — Hooks (settings.json)
  Claude Code runtime executes these. Claude cannot bypass.
  Enforces: stage gates, persona boundaries, session state, Codex gates

Layer 2 — Commands (.claude/commands/)
  20 commands loaded by the project. Claude reads and follows these.
  Enforces: WHO YOU ARE, CAN/CANNOT, manual_action, override rules

Layer 3 — Governance Docs (framework/governance/)
  Referenced by commands and CLAUDE.md.
  Defines: lifecycle stages, stage gates, artifact ownership, operating tiers
  Claude reads these to know WHAT to enforce and WHEN
```

For v3.0 to "run" when Claude starts: all 3 layers must be installed and consistent.
Phases 1–13 build the source. Phases 14–18 deploy it to all 5 projects.

---

## PHASE 1 — New Commands (Source) ✓ COMPLETE

- [x] STEP-01  Write /teach-me command (v2-FULL, auto-triggered)
- [x] STEP-02  Write /risk-manager command (v2-FULL, owns tasks/risk-register.md)
- [x] STEP-03  Write /codex-prep command (v2-FULL, pre-flight gate + token-efficient)
- [x] STEP-04  Write /codex-read command (v2-FULL, routes PASS→READY_FOR_QA FAIL→REVISION_NEEDED)

---

## PHASE 2 — New Hook Scripts (Source) ✓ COMPLETE

- [x] STEP-05  Write auto-teach.sh (UserPromptSubmit, blocking, exit 2)
- [x] STEP-06  Write auto-codex-prep.sh (UserPromptSubmit, blocking, exit 2)
- [x] STEP-07  Write auto-codex-read.sh (UserPromptSubmit, blocking, exit 2)
- [x] STEP-08  Update guard-git-push.sh — Codex PASS gate added

---

## PHASE 3 — Upgrade v2-partial Persona Commands ✓ COMPLETE

- [x] STEP-09  Upgrade /architect to v2-FULL
- [x] STEP-10  Upgrade /ba to v2-FULL
- [x] STEP-11  Upgrade /junior-dev to v2-FULL
- [x] STEP-12  Upgrade /qa to v2-FULL
- [x] STEP-13  Upgrade /ux to v2-FULL

---

## PHASE 4 — Schema + Infrastructure ✓ COMPLETE

- [x] STEP-14  Update schemas/output-envelope.md — 12-field envelope (manual_action + override)
- [x] STEP-15  Trim .claude/commands/ to exactly 20 files
- [x] STEP-16  Update settings.json template — 11 hooks total
- [x] STEP-17  Update remediate-project.sh — explicit 20-command deploy, project files protected
- [x] STEP-18  Add .ak-cogos-version = 2.2.0

---

## PHASE 5 — Source Validation ✓ COMPLETE

- [x] STEP-19  validate-framework.sh — PASS (16 structural checks + semantic lint)
- [~] STEP-20  validators/runner.py — SKIPPED (project-level tool, not applicable to framework source)
- [x] STEP-21  Manual source audit — all 20 commands v2-FULL, codex-prep pre-flight gap closed

---

## PHASE 6 — Operating Model (v3.0 WS1)
> Deliverable: Canonical 11-stage lifecycle + stage-gate rules Claude can reference at runtime

- [x] STEP-22  Write framework/governance/delivery-lifecycle.md
               Content: 11 stages — intake → discovery → scope → architecture → design →
                        implementation → QA → security/compliance → release → lessons → framework-improvement
               Each stage: definition, entry conditions, exit conditions, persona responsible, artifacts produced
               Success: File exists, covers all 11 stages with entry/exit conditions
               Depends on: nothing

- [x] STEP-23  Write framework/governance/stage-gates.md
               Content: For each stage transition, the exact conditions that must be true before progressing.
               Machine-readable format: stage, gate condition, artifact required, persona that owns the gate,
               what happens on failure (BLOCK / WARN / ESCALATE)
               Success: Every stage transition has an explicit gate entry
               Depends on: STEP-22

- [x] STEP-24  Write framework/governance/default-workflows.md
               Content: Standard execution paths per project type
               Include: greenfield SaaS, AI/RAG, regulated app, internal tool
               Each path: which stages are required vs optional, which gates are hard vs soft
               Success: 4 workflow types documented with stage maps
               Depends on: STEP-23

---

## PHASE 7 — Artifact System (v3.0 WS5)
> Deliverable: Every artifact has a formal owner, downstream dependencies, and a gate rule

- [x] STEP-25  Write framework/governance/artifact-map.md
               Content: All framework artifacts — path, what it contains, who creates it, who consumes it
               Must include: problem-definition.md, scope-brief.md, hld.md, lld/*.md, todo.md,
                             ba-logic.md, ux-specs.md, design-system.md, risk-register.md,
                             next-action.md, release-truth.md, codex-review.md, teaching-log.md,
                             audit-log.md, lessons.md, channel.md
               Success: All 16+ artifacts mapped with owner and consumers
               Depends on: STEP-22

- [x] STEP-26  Write framework/governance/artifact-ownership.md
               Content: Ownership rules — which persona CAN write, which can read-only, which are blocked
               Format: artifact → owner → readers → blocked personas
               Success: Matches and formalises existing CAN/CANNOT rules in persona commands
               Depends on: STEP-25

- [x] STEP-27  Add tasks/design-system.md to project-template
               Content: Placeholder for design tokens, component naming, visual rules (UX/designer artifact)
               Success: project-template/tasks/design-system.md exists with correct header and section stubs
               Depends on: STEP-26

---

## PHASE 8 — Enforcement Layer Completion (v3.0 WS6)
> Deliverable: Hard gates on the full SDLC — planning → build → QA → security → release

- [x] STEP-28  Write guard-planning-artifacts.sh (new PreToolUse hook)
               Trigger: PreToolUse — Write/Edit matcher on any source code file (not tasks/, not docs/)
               Gate: Block Junior Dev from writing code if docs/problem-definition.md or
                     docs/scope-brief.md are missing (for Standard + High-Risk tiers)
               Action: exit 2 with message naming which planning doc is missing
               Success: Script exists, blocks code writes when planning docs absent
               Depends on: STEP-23 (stage-gates defines what's required per tier)

- [x] STEP-29  Update guard-git-push.sh — add security + compliance gate
               Current: blocks unless Architect + QA_APPROVED + Codex PASS
               New: also check channel.md for security-sweep sign-off on Standard/High-Risk tiers
               Success: Push blocked when security-sweep has unresolved HIGH findings
               Depends on: STEP-28

- [x] STEP-30  Update session-integrity-check.sh — full closeout validation
               Current: warns if SESSION STATE is OPEN
               New: also warn if:
                 - tasks/codex-review.md has VERDICT: without Status: PROCESSED
                 - tasks/todo.md has open BOUNDARY_FLAG entries
                 - tasks/risk-register.md has unresolved S0 risks
               Success: Script catches all 4 closeout conditions
               Depends on: nothing (independent improvement)

- [x] STEP-31  Update settings.json template — add guard-planning-artifacts.sh
               Add to PreToolUse Write/Edit block
               Success: settings.json has 12 hook entries total
               Depends on: STEP-28

---

## PHASE 9 — Operating Tiers (v3.0 WS8)
> Deliverable: MVP / Standard / High-Risk tier system — each tier has different gate requirements

- [x] STEP-32  Write framework/governance/operating-tiers.md
               Tiers:
                 MVP: minimal gates — no planning docs required, QA optional, no compliance gate
                 Standard: planning docs required, Codex gate, QA required, security-sweep on release
                 High-Risk: all Standard gates + compliance gate + risk-register required at every stage
               Each tier: required artifacts, required gates, allowed shortcuts, release constraints
               Success: 3 tiers defined with explicit gate tables
               Depends on: STEP-23, STEP-25

- [x] STEP-33  Write guides/14-risk-tier-selection.md
               Content: How to choose a tier, worked examples per project type, how to change tier mid-project
               Success: Guide covers all 3 tiers with decision criteria
               Depends on: STEP-32

- [x] STEP-34  Add project tier to project-template/CLAUDE.md
               Add a Tier field near top of CLAUDE.md template (defaults to Standard)
               Hooks and commands read this field to determine which gates are active
               Success: project-template/CLAUDE.md has Tier: Standard field with instructions
               Depends on: STEP-32

- [x] STEP-35  Update bootstrap-project.sh — tier-aware + v3.0 intake
               Changes:
                 - Ask project tier during intake (MVP/Standard/High-Risk)
                 - Prefill Tier field in CLAUDE.md
                 - Create design-system.md placeholder
                 - Deploy 3 new hooks from v2.2 (auto-teach, auto-codex-prep, auto-codex-read)
                 - Update VERSION to 3.0.0
               Success: Bootstrap creates a v3.0-ready project with correct tier on first run
               Depends on: STEP-34
               AK APPROVED: 2026-04-05 Session 13

---

## PHASE 10 — Role Taxonomy + Governance Policies (v3.0 WS2 + WS10)
> Deliverable: Self-governing framework — rules for how it evolves

- [x] STEP-36  Write framework/governance/role-taxonomy.md
               Classify all 20 commands:
                 delivery persona: architect, ba, junior-dev, qa, ux
                 router persona: researcher, compliance
                 specialist persona: designer, risk-manager
                 mechanical skill: session-open, session-close, compact-session, audit-log
                 advisory/meta skill: teach-me, lessons-extractor, check-channel
                 quality skill: qa-run, security-sweep, codex-prep, codex-read
               Success: All 20 commands classified with rationale
               Depends on: nothing

- [x] STEP-37  Write framework/governance/role-design-rules.md
               Content: When to add a new persona vs skill, router vs specialist pattern rules,
               maximum command set size, deprecation rules
               Success: New additions can be evaluated against explicit criteria
               Depends on: STEP-36

- [x] STEP-38  Write framework/governance/change-policy.md
               Content: How the framework changes — proposal format, review process,
               how repeated failures become framework changes (framework-delta-log pattern)
               Success: Framework evolution has a documented process
               Depends on: STEP-37

- [x] STEP-39  Write framework/governance/versioning-policy.md
               Content: What constitutes a major/minor/patch version,
               version stamp locations (.ak-cogos-version), compatibility guarantees
               Success: Version bumps follow documented rules
               Depends on: STEP-38

- [x] STEP-40  Write framework/governance/release-policy.md
               Content: How framework releases are packaged, tested, and deployed to projects
               Ties to remediation modes (--audit-only / --safe-remediate / --full-remediate)
               Success: Release process is documented end-to-end
               Depends on: STEP-39

---

## PHASE 10.5 — Governance Enforcement (unplanned, delivered Session 14)
> Deliverable: Phase 10 governance rules are machine-enforced at push time and session close

- [x] STEP-40.5  Wire governance validator + hook enforcement
                  Deliverables:
                    validators/governance.py — 8 checks (doc presence, version stamp, placeholder scan)
                    scripts/hooks/guard-git-push.sh — governance FAIL blocks main push (exit 2)
                    scripts/hooks/session-integrity-check.sh — Advisory check 4 (governance WARN/FAIL)
                  Success: governance.py auto-discovered by runner.py; push to main blocked on FAIL;
                           session exit warns on WARN or FAIL (advisory only)
                  Depends on: STEP-36..40 (governance docs must exist for checks to pass)

---

## PHASE 11 — Non-Coder Mode + Docs (v3.0 WS9 + WS12)
> Deliverable: Framework explains itself; non-coders have an explicit safe path

- [x] STEP-41  Write guides/13-non-coder-mode.md
               Content: What non-coders can safely build, minimum workflow,
               when to escalate for technical oversight, which gates apply
               Tier: maps to MVP tier (non-coder projects are always MVP)
               Success: Guide covers decision criteria and safe workflow clearly
               Depends on: STEP-32

- [x] STEP-42  Update README.md and QUICKSTART.md
               Changes: reflect v3.0 lifecycle, tier system, 20-command set, hook enforcement
               Remove: references to retired commands or old framework version
               Success: A new user reading README can start a v3.0 project correctly
               Depends on: STEP-36, STEP-32

---

## PHASE 12 — Validation Hardening (v3.0 WS7 completion)
> Deliverable: validate-framework.sh catches structural inconsistencies across the full v3.0 surface

- [x] STEP-43  Add tier consistency check to validate-framework.sh
               Check: project-template/CLAUDE.md has Tier: field
               Check: settings.json has guard-planning-artifacts.sh in PreToolUse block
               Success: Missing tier or hook is flagged as FAIL
               Depends on: STEP-34, STEP-31

- [x] STEP-44  Add artifact-map consistency check to validate-framework.sh
               Check: all artifacts listed in artifact-map.md exist as paths in project-template or tasks/
               Check: every persona CAN list matches artifact-ownership.md owner entries
               Success: Ownership inconsistencies caught automatically
               Depends on: STEP-25, STEP-26

- [x] STEP-45  Add governance completeness check to validate-framework.sh
               Check: all 8 governance docs exist in framework/governance/
               Check: all 14 guides exist in guides/
               Success: Missing governance artifacts caught before project deployment
               Depends on: STEP-40, STEP-42

---

## PHASE 13 — v3.0 Source Sign-off
> Deliverable: Framework validated at v3.0 standard, version stamped, AK approval to deploy

- [x] STEP-46  Run validate-framework.sh — must PASS with all v3.0 checks active
               Command: bash scripts/validate-framework.sh
               Success: Exit 0, no FAIL lines
               Depends on: STEP-45

- [x] STEP-47  Update .ak-cogos-version to 3.0.0
               Also update VERSION variable in remediate-project.sh and bootstrap-project.sh
               Success: .ak-cogos-version reads 3.0.0
               Depends on: STEP-46

- [x] STEP-48  Update remediate-project.sh — v3.0 additions
               Changes:
                 - Deploy design-system.md placeholder (STEP-27)
                 - Add guard-planning-artifacts.sh to hook deployment
                 - Update settings.json template reference (now 12 hooks)
                 - Tier detection: read existing CLAUDE.md Tier field, warn if missing
                 - Add --audit-only mode: reports gaps without writing
               Success: Dry run against any project shows correct v3.0 additions
               Depends on: STEP-47

- [x] STEP-49  Manual v3.0 source audit (AK approval gate)
               Check: all governance docs written (STEP-22–27, 32–40)
               Check: all enforcement hooks present and wired (STEP-28–31)
               Check: bootstrap and remediate scripts at v3.0
               Check: validate-framework.sh PASS
               AK APPROVAL REQUIRED: Approve source before any project is touched

---

## PHASE 14 — Remediate Pharma-Base
> First project — clean baseline, best smoke test for v3.0 deployment

- [x] STEP-50  Pre-check Pharma-Base
               Check: SESSION STATE must be CLOSED, note active tasks
               Depends on: STEP-49
               Result: SESSION STATE=CLOSED. 33 commands (→20), 5 hook entries (→12), version=2.0.0 (→3.0.0).
                       2 governance docs (→8+), design-system.md absent. TASK-003..011 in-flight (project work, safe).

- [x] STEP-51  Dry run Pharma-Base
               Command: bash scripts/remediate-project.sh /Users/akaushal011/Pharma-Base --dry-run --force
               Success: Shows correct 20 commands, new hooks, retired commands removed, design-system.md added
               Depends on: STEP-50
               Result: 99 changes shown. Clean. AK approved.

- [x] STEP-52  Live run Pharma-Base
               Command: bash scripts/remediate-project.sh /Users/akaushal011/Pharma-Base --force
               Success: Exit 0, version stamp = 3.0.0
               Depends on: STEP-51
               Result: Exit 0. All 99 changes applied. Version 3.0.0 stamped.

- [x] STEP-53  Verify Pharma-Base
               Check: .claude/commands/ has exactly 20 files — PASS (20)
               Check: scripts/hooks/ has guard-planning-artifacts.sh — PASS
               Check: settings.json has 14 hook scripts (6 matchers) — PASS
               Check: framework/governance/ has 13 governance docs — PASS (≥8)
               Check: tasks/design-system.md exists — PASS
               Check: .ak-cogos-version = 3.0.0 — PASS
               Check: CLAUDE.md Tier: Standard added — PASS
               Baseline: validators/runner.py — ALL PASS (5/5)
               Fixes applied: governance.py path bug (docs/ → framework/governance/);
                              remediate-project.sh now deploys channel.md in Step 6
               Depends on: STEP-52

---

## PHASE 15 — Remediate forensic-ai

- [x] STEP-54  Pre-check forensic-ai
               Note: Python personas/ dir is app code — do not touch
               Depends on: STEP-53

- [x] STEP-55  Dry run forensic-ai
               Command: bash scripts/remediate-project.sh /Users/akaushal011/forensic-ai --dry-run --force
               Depends on: STEP-54

- [x] STEP-56  Live run forensic-ai
               Command: bash scripts/remediate-project.sh /Users/akaushal011/forensic-ai --force
               Depends on: STEP-55

- [x] STEP-57  Verify forensic-ai (same checks as STEP-53)
               Depends on: STEP-56

---

## PHASE 16 — Remediate policybrain

- [x] STEP-58  Pre-check policybrain
               Note: skills/designer.md duplicate present — delete after live run
               Depends on: STEP-57

- [x] STEP-59  Dry run policybrain
               Command: bash scripts/remediate-project.sh /Users/akaushal011/policybrain --dry-run --force
               Depends on: STEP-58

- [x] STEP-60  Live run policybrain
               Command: bash scripts/remediate-project.sh /Users/akaushal011/policybrain --force
               Depends on: STEP-59

- [x] STEP-61  Delete policybrain/skills/designer.md
               AK APPROVAL REQUIRED: Confirm deletion of duplicate file
               Depends on: STEP-60

- [x] STEP-62  Verify policybrain (same checks as STEP-53, plus skills/designer.md gone)
               Depends on: STEP-61

---

## PHASE 17 — Remediate mission-control
> Special handling — SESSION STATE was OPEN at last diagnostic

- [x] STEP-63  Investigate mission-control open session
               Read: tasks/todo.md SESSION STATE + tasks/next-action.md
               Determine: accidental or in-progress work?
               AK APPROVAL REQUIRED: Close or preserve state
               Depends on: STEP-57

- [x] STEP-64  Dry run mission-control
               Command: bash scripts/remediate-project.sh /Users/akaushal011/mission-control --dry-run --force
               Depends on: STEP-63

- [x] STEP-65  Live run mission-control
               Command: bash scripts/remediate-project.sh /Users/akaushal011/mission-control --force
               Depends on: STEP-64

- [x] STEP-66  Verify mission-control (same checks as STEP-53)
               Depends on: STEP-65

---

## PHASE 18 — Remediate Transplant-workflow
> Largest project — 50 active tasks, no structural blockers

- [x] STEP-67  Pre-check Transplant-workflow
               Check: SESSION STATE, verify tasks/todo.md not corrupted at 50 tasks
               Depends on: STEP-66

- [x] STEP-68  Dry run Transplant-workflow
               Command: bash scripts/remediate-project.sh /Users/akaushal011/Transplant-workflow --dry-run --force
               Depends on: STEP-67

- [x] STEP-69  Live run Transplant-workflow
               Command: bash scripts/remediate-project.sh /Users/akaushal011/Transplant-workflow --force
               Depends on: STEP-68

- [x] STEP-70  Verify Transplant-workflow (same checks as STEP-53)
               Depends on: STEP-69

---

## PHASE 19 — Global Command Cleanup
> Remove (user)/(project) duplicates from Claude Code command picker

- [x] STEP-71  Backup ~/.claude/commands/
               Command: cp -r ~/.claude/commands/ ~/.claude/commands-backup-20260405/
               Depends on: STEP-70

- [x] STEP-72  Delete stale global commands
               Command: rm ~/.claude/commands/*.md
               AK APPROVAL REQUIRED: Confirm deletion of all global commands
               Depends on: STEP-71

- [x] STEP-73  Verify no duplicates
               Test: open Claude Code in any project, type / — only project-level commands appear
               Success: No (user) label on any command
               Depends on: STEP-72

---

## PHASE 20 — End-to-End v3.0 Verification
> Confirm the full system runs as v3.0 across all 5 projects

- [x] STEP-74  Smoke test /session-open in each project
               Success: SESSION STATE transitions to OPEN, MCP state machine call succeeds
               Depends on: STEP-73

- [x] STEP-75  Auto-hook smoke test
               Test A: Mark task IN_PROGRESS → /teach-me fires automatically
               Test B: Mark task READY_FOR_REVIEW → /codex-prep fires (with pre-flight check)
               Test C: Write VERDICT: PASS to codex-review.md → /codex-read fires
               Test D: Try writing code without planning docs → guard-planning-artifacts.sh blocks
               Success: All 4 hooks fire correctly
               Depends on: STEP-74

- [x] STEP-76  Final v3.0 audit — all 5 projects
               Check: Each project has exactly 20 .claude/commands/*.md files
               Check: No retired commands in any project
               Check: All .ak-cogos-version files read 3.0.0
               Check: All framework/governance/ docs deployed
               Check: All projects have Tier: field in CLAUDE.md
               AK SIGN-OFF: APPROVED 2026-04-05
               Depends on: STEP-75

---

## Progress Tracker

| Phase | Steps | Done | Remaining |
|---|---|---|---|
| Phase 1 — New Commands | 4 | 4 | 0 |
| Phase 2 — New Hooks | 4 | 4 | 0 |
| Phase 3 — Upgrade v2-partial | 5 | 5 | 0 |
| Phase 4 — Schema + Infrastructure | 5 | 5 | 0 |
| Phase 5 — Source Validation | 3 | 3 | 0 |
| Phase 6 — Operating Model | 3 | 3 | 0 |
| Phase 7 — Artifact System | 3 | 3 | 0 |
| Phase 8 — Enforcement Completion | 4 | 4 | 0 |
| Phase 9 — Operating Tiers | 4 | 4 | 0 |
| Phase 10 — Taxonomy + Governance | 5 | 5 | 0 |
| Phase 10.5 — Governance Enforcement | 1 | 1 | 0 |
| Phase 11 — Non-Coder + Docs | 2 | 2 | 0 |
| Phase 12 — Validation Hardening | 3 | 3 | 0 |
| Phase 13 — v3.0 Source Sign-off | 4 | 4 | 0 |
| Phase 14 — Pharma-Base | 4 | 4 | 0 ✓ |
| Phase 15 — forensic-ai | 4 | 4 | 0 ✓ |
| Phase 16 — policybrain | 5 | 5 | 0 ✓ |
| Phase 17 — mission-control | 4 | 4 | 0 ✓ |
| Phase 18 — Transplant-workflow | 4 | 4 | 0 ✓ |
| Phase 19 — Global Cleanup | 3 | 3 | 0 ✓ |
| Phase 20 — Verification | 3 | 3 | 0 ✓ |
| **TOTAL** | **77** | **77** | **0 — COMPLETE** |

---

## AK Approval Gates

| Gate | Step | Decision needed |
|---|---|---|
| Bootstrap intake flow review | STEP-35 | Review tier-aware intake before enabling for new projects |
| v3.0 source approved for project rollout | STEP-49 | All governance docs written, hooks wired, validation PASS |
| policybrain skills/designer.md deletion | STEP-61 | Confirm delete of duplicate file |
| mission-control session state | STEP-63 | Close accidentally-open session or preserve state |
| Global ~/.claude/commands/ deletion | STEP-72 | Confirm removing all global commands |
| v3.0 delivery complete | STEP-76 | Final audit passed, all 5 projects on v3.0 |

---

## Notes

- Phases 6–13 are the v3.0 build — Claude builds these, AK reviews governance docs
- Each project remediation phase (14–18) is strictly sequential — verify one before starting next
- Project files (docs/, tasks/todo.md content) are never overwritten by remediation
- Remediation only touches: commands, hooks, settings.json, MCP servers, new placeholders
- If any STEP fails → [!] BLOCKED — do not proceed to dependent steps
- Last updated: 2026-04-05
