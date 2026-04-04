# BA Logic — [PROJECT_NAME]

<!--
FORMAT — one block per business logic decision:

## [BL-001] Short topic title
- Status: PENDING
- Decision: [BA recommendation]
- Rationale: [why — grounded in domain knowledge]
- Caveats: [edge cases or exceptions]
- Open questions: [what must be resolved before build]

STATUS LIFECYCLE:
PENDING → INCORPORATED → [deleted]

RULES:
- BA writes here only
- Architect reads PENDING entries before finalising any design touching that topic
- Architect sets INCORPORATED, then deletes after AK approves
- End of session: file is empty
- Max 80 lines
-->

## [BL-001] Role taxonomy and contract normalization — Codex strategic feedback
- Status: INCORPORATED
- Decision: Halt new surface-area work. Pivot Session 5 to: (1) explicit classification layer
  across all artifacts, (2) boundary tightening on overlapping pairs, (3) router-family
  normalization, (4) contract hygiene pass + semantic lint extension to validate-framework.sh.
- Rationale: Framework has enough coverage (~33 commands). Risk is now overlap/ambiguity/drift,
  not missing features. Phase 4 hook/SDK work deferred to Session 6 (still valid, lower priority).
- Classifications to apply:
    Delivery personas: architect, ba, ux, designer, junior-dev, qa
    Router personas: researcher, compliance
    Specialist personas: researcher-{business,legal,news,policy,technical},
                         compliance-{data-privacy,data-security,phi-handler,pii-handler}
    Mechanical skills: session-open, session-close, audit-log, regression-guard,
                       review-packet, codex-intake-check, handoff-validator, sprint-packager,
                       qa-run, codex-delta-verify, compact-session
    Advisory/meta skills: check-channel, lessons-extractor, framework-delta-log, codex-creator
- Boundary pairs to tighten:
    designer: narrow to visual/brand direction (not interaction behavior)
    ux: own interaction behavior, states, breakpoints, accessibility
    qa: acceptance-criteria design + quality intent (pre/post-build)
    qa-run: execution skill — runs build/lint/test/mobile checks against qa criteria
    security-sweep: engineering review (auth, abuse, replay, rate limits, trust boundaries)
    compliance-data-security: compliance/risk lens over security controls (not duplicate audit)
    gating cluster: review-packet, sprint-packager, handoff-validator, codex-intake-check —
                    document single boundary model distinguishing their adjacent territories
- Router normalization: parent persona = default entry; sub-personas = specialist shortcuts.
  Must be explicit, not implied.
- Caveats: designer/ux boundary edit must also resolve CF-1 (designer integration audit).
  Audit path canonicalization (CF-2: releases/session-N.md vs tasks/audit-log.md) is a
  separate concern — resolve as part of contract hygiene pass.
- Open questions: Should design expand to design-systems/accessibility after boundary is explicit?
  Codex says defer until designer/ux boundary is settled first. Architect agrees.
