# Role Taxonomy — AK Cognitive OS
# Classification of all personas and skills by functional class
# Authoritative reference — all SKILL.md files carry the role_class field defined here

---

## The Five Classes

Every artifact in AK Cognitive OS belongs to exactly one of these five classes:

| Class | Definition | Route through |
|---|---|---|
| **delivery_persona** | Owns a named role in the delivery chain. Has a BOUNDARY_FLAG, produces structured output, advances work through the workflow. | Invoked directly by AK or dispatched by Architect |
| **router_persona** | Default entry point for a domain family. Delegates to specialist sub-personas. Knows when to hand off and to whom. | Invoked when the lane is clear but the specific specialization isn't yet determined |
| **specialist_persona** | A narrowly-scoped sub-persona reachable via its router parent or directly when the user already knows the lane. | Invoked directly (shortcut) or delegated to by the router |
| **mechanical_skill** | Executes a defined, bounded procedure. Gate-based or execution-based. Deterministic in/out. | Invoked at specific lifecycle points (session open/close, gating steps, CI checks) |
| **advisory_meta_skill** | Supports framework health, introspection, or coaching. Does not directly produce or gate delivery artifacts. | Invoked on-demand for framework maintenance or meta-level queries |

---

## Classification Table

### Delivery Personas

| Command | Name | Role in delivery chain |
|---|---|---|
| `/architect` | Architect | Task graph, constraints, risks, acceptance breakdown |
| `/ba` | Business Analyst | Requirements, business logic, edge cases |
| `/ux` | UX Designer | Interaction behavior, states, breakpoints, accessibility |
| `/designer` | Designer | Visual direction, brand, component look-and-feel |
| `/junior-dev` | Junior Developer | Implementation — exact scope only |
| `/qa` | QA Engineer | Acceptance criteria design, quality intent, pre/post-build gate |

### Router Personas

| Command | Name | Delegates to |
|---|---|---|
| `/researcher` | Researcher | researcher-business, researcher-legal, researcher-news, researcher-policy, researcher-technical |
| `/compliance` | Compliance Reviewer | compliance-data-privacy, compliance-data-security, compliance-phi-handler, compliance-pii-handler |

> **Usage rule:** Always enter via the router unless you already know the specialist lane. The router determines which specialist to activate based on the query domain.

### Specialist Personas

| Command | Name | Parent router | Domain |
|---|---|---|---|
| `/researcher-business` | Business Researcher | `/researcher` | Market, competitor, business model |
| `/researcher-legal` | Legal Researcher | `/researcher` | Regulatory, contract, jurisdiction |
| `/researcher-news` | News Researcher | `/researcher` | Current events, recent developments |
| `/researcher-policy` | Policy Researcher | `/researcher` | Internal policy, governance, standards |
| `/researcher-technical` | Technical Researcher | `/researcher` | Technology, architecture, implementation patterns |
| `/compliance-data-privacy` | Data Privacy Reviewer | `/compliance` | GDPR, CCPA, consent, data subject rights |
| `/compliance-data-security` | Data Security Reviewer | `/compliance` | Security controls, risk posture (compliance lens, not engineering audit) |
| `/compliance-phi-handler` | PHI Handler | `/compliance` | HIPAA, health data, PHI boundary enforcement |
| `/compliance-pii-handler` | PII Handler | `/compliance` | PII identification, classification, handling rules |

### Mechanical Skills

Mechanical skills execute bounded, deterministic procedures. They are invoked at specific lifecycle points or gating stages.

| Command | Name | When to invoke |
|---|---|---|
| `/session-open` | Session Open | Start of every session — standup, state check, task load |
| `/session-close` | Session Close | End of every session — audit trail, state close, next-action write |
| `/audit-log` | Audit Log | After any significant agent action — append-only log entry |
| `/qa-run` | QA Run | Execution of build/lint/test/mobile checks against QA criteria |
| `/regression-guard` | Regression Guard | Pre-merge check — detects regressions against baseline |
| `/review-packet` | Review Packet | Assembles all artifacts for Architect code review |
| `/handoff-validator` | Handoff Validator | Validates artifact completeness before workflow hand-off |
| `/codex-intake-check` | Codex Intake Check | Gate before sending work to Codex — validates readiness |
| `/sprint-packager` | Sprint Packager | Packages completed sprint artifacts for archive or release |
| `/codex-delta-verify` | Codex Delta Verify | Verifies Codex output matches expected delta |
| `/compact-session` | Compact Session | Compresses session context to reduce token usage |
| `/security-sweep` | Security Sweep | Engineering security review: auth, abuse, replay, rate limits, trust boundaries |

### Advisory / Meta Skills

Advisory skills support framework health and introspection. They do not gate or produce delivery artifacts.

| Command | Name | Purpose |
|---|---|---|
| `/check-channel` | Check Channel | Inspect channel.md for inter-agent messages |
| `/lessons-extractor` | Lessons Extractor | Extract and format lessons-learned entries |
| `/framework-delta-log` | Framework Delta Log | Record framework-level changes and improvements |
| `/codex-creator` | Codex Creator | Scaffold or generate Codex-compatible prompt artifacts |

---

## Routing Logic

```
AK gives a request
  └─ Is it delivery work?
       └─ YES → delivery persona (architect / ba / ux / designer / junior-dev / qa)
       └─ NO — research needed?
            └─ YES → /researcher (router) → specialist if domain is clear
            └─ NO — compliance gate needed?
                 └─ YES → /compliance (router) → specialist if regulation is clear
                 └─ NO — lifecycle/gating?
                      └─ YES → mechanical skill
                      └─ NO → advisory/meta skill
```

---

## Adding a New Artifact

When adding a new persona or skill to the framework:

1. Assign a `role_class` from the five classes above.
2. Add the `role_class` field to the artifact's `SKILL.md` frontmatter.
3. Add a row to the appropriate table in this file.
4. If it is a specialist persona, update the parent router's delegation section.
5. Run `bash scripts/validate-framework.sh` — the semantic lint checks will verify the field is present.

---

*Last updated: Session 5 — TASK-001 implementation*
