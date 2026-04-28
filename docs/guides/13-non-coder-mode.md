# Guide 13 — Non-Coder Mode

## When to Use This Guide

Use this guide if you are working in AK Cognitive OS without a software engineering background —
product manager, designer, domain expert, or business stakeholder. The framework is designed to keep
you in control of product decisions while ensuring technical work is handled safely.

---

## Your Tier

Non-coder projects always run at **MVP tier**.

MVP tier means:
- Enforcement hooks are active (session state, persona boundaries, audit trail)
- Planning docs are encouraged but not gate-blocking
- Compliance and security gates are advisory, not mandatory
- You can iterate quickly without pre-approving every artifact

See `guides/14-risk-tier-selection.md` if your project handles sensitive data, regulated industries,
or has production users — you may need a higher tier and technical oversight before proceeding.

---

## What You CAN Do Alone

The following commands are safe to run without an engineer present:

| Command | What it does |
|---|---|
| `/ba` | Clarify business logic, define requirements, document edge cases |
| `/ux` | Design user flows, interaction states, and wireframe behavior |
| `/designer` | Define visual direction, brand rules, and component look-and-feel |
| `/researcher` | Research competitors, policies, news, or technical topics |
| `/teach-me` | Get plain-language explanations of framework concepts |
| `/session-open` | Open a session and get a standup summary |
| `/session-close` | Close a session and write the audit entry |
| `/check-channel` | Review what the last agent did |

---

## What You CANNOT Do Without Technical Oversight

The following commands involve decisions that require engineering judgment. Running them alone
risks building the wrong thing, breaking existing code, or creating untrackable technical debt:

| Command | Why oversight is needed |
|---|---|
| `/architect` | Defines system structure, data models, and API contracts — errors propagate everywhere |
| `/junior-dev` | Writes production code — incorrect implementation is hard to reverse |
| `/qa-run` | Validates code correctness — only meaningful when an engineer has built to spec |
| `/compliance` | Legal and regulatory decisions require domain expertise context |
| `/security-sweep` | Findings require engineering judgment to remediate correctly |

---

## Decision Table — Can I Do This Alone?

| Task | Alone? | Who to involve |
|---|---|---|
| Define what the product does | Yes | — |
| Map user flows and screens | Yes | — |
| Write requirements and edge cases | Yes | — |
| Research domain, policy, competitors | Yes | — |
| Define acceptance criteria | Yes (with /qa) | /qa |
| Approve the final deliverable | Yes | AK (you) |
| Choose data models and architecture | Escalate | /architect |
| Write or review code | No | /architect + /junior-dev |
| Validate code correctness | No | /architect + /qa-run |
| Assess security or compliance risk | Escalate | /compliance + /architect |

---

## When to Escalate

Escalate to an engineer (activate `/architect`) when:
- The scope involves writing, editing, or reviewing code
- You are unsure whether a design decision has technical implications
- A QA check fails and the fix requires code changes
- You are integrating with an external API, database, or auth system
- A `BOUNDARY_FLAG` appears in any persona output

---

## Safe Starting Point

If you are unsure where to begin, run these commands in order:

```
/session-open → /ba → /ux → /check-channel
```

This grounds your session in business logic and user experience before any technical decisions
are made. Bring in `/architect` when you are ready to move to implementation.

---

*See `guides/14-risk-tier-selection.md` for tier selection guidance.*
*See `guides/02-session-flow.md` for the full session lifecycle.*
*See `framework/governance/role-taxonomy.md` for the complete command classification.*
