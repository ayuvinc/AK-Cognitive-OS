# Guide 15 — Microservices Architecture Assessment
# AK Cognitive OS — v3.1
# Validated against: Transplant-workflow production HLD (Session 23, 2026-04-11)

---

## Purpose

This guide answers two questions before any architecture decision is made:

1. **Should this project use microservices, a modular monolith, or a hybrid?**
2. **Which specific patterns from the validated microservices template apply to this project type?**

Three project types are covered in detail: **greenfield**, **pharma-based**, and **forensic AI**.
All three derive from the same core pattern set but apply it differently based on regulatory
requirements, failure cost, and team capacity.

---

## The Core Rule

**Service count must emerge from domain complexity and team capacity — never chosen upfront.**

The transplant-workflow arrived at 9 services because it has 6 distinct domain clusters with
independent failure modes, a hard medical regulatory requirement, and time-critical events where
failure has patient-level consequences. Another project arriving at the same count without those
conditions has over-engineered.

The correct starting position for any project is a **modular monolith with clear service
boundaries** — then extract only when the load, team, or regulatory requirement demands it.

---

## Decision Framework

| Project characteristic | Architecture choice |
|---|---|
| Single tenant, low event frequency, internal tool | Modular monolith only. No extraction. |
| Multi-tenant, moderate event volume, SaaS | 3–5 services. Strangler-fig from monolith. |
| Time-critical events, regulated domain, audit-mandatory | Full EDA. 6–9 services by domain complexity. |
| Forensic or legal evidence handling | Append-only EDA. Immutable audit mandatory. CQRS read-side. |
| Pharma / clinical trial / GxP | Full EDA with 21 CFR Part 11 / GxP overlay. Validation documentation required. |

### Service Count Decision Rules

```
Domain clusters with independent failure modes  →  one service per cluster
Shared infrastructure concerns                  →  one shared service (Document, Notification)
External integration adapter                    →  one gateway service
Time-critical schedulers (timers, jobs)         →  isolated from business logic services
Audit / compliance                              →  always isolated (append-only, never in a domain service)
```

Never put more than one aggregate in a service unless you can demonstrate that the aggregates
share a transaction boundary that cannot be split. When in doubt, split.

---

## Core Patterns — Always Adopt (Validated)

These seven patterns are validated from the Transplant-workflow production architecture.
They apply regardless of project type.

### 1. Strangler-Fig Migration Path
Start as a modular monolith. Route groups map 1:1 to future service boundaries from day one.
Extract services when load, team, or regulation requires it. Never rewrite — extract.

```
Phase A — Monolith         All modules in one process. Route groups as service boundaries.
Phase B — First extract    Most cross-cutting concerns first (Notification, Audit).
Phase C — Domain extract   Extract by domain cluster. API Gateway in front.
Phase D — Full services    Dedicated DB per service. Managed message broker.
```

### 2. Adapter Pattern for Infrastructure
Every infrastructure dependency behind an interface with a factory. No domain service imports
a vendor SDK directly.

```typescript
// Always this pattern:
interface MessageBus { publish, subscribe, assertExchange, assertQueue, close }
interface StorageClient { upload, download, delete, list }
interface NotificationClient { sendSMS, sendPush, sendEmail }

// Factory selects implementation at startup via env var.
// Swap vendor = change env var only. Zero code changes.
```

### 3. Tenant Partition Key from Day One
Whatever the tenant unit is (hospital_id, org_id, client_id, case_id) — it goes in every DB
row, every event routing key, every JWT claim, every API Gateway filter from day one.
Retrofitting partition keys is expensive. There is no acceptable reason to defer this.

### 4. Schema-Per-Service Isolation
Pilot: shared DB instance, separate schemas, separate DB users per service (no cross-schema access).
Production: dedicated DB instance per service. No migration required — schema isolation is already in place.

### 5. CQRS Read Models for Cross-Domain Data
Services that need data from another service's domain maintain a local read model built from
consumed events. They never query another service's DB or call another service's API for reads.
This eliminates the most common source of coupling in microservices.

### 6. Audit-by-Consumption
The compliance/audit service binds to all domain exchanges via wildcard and writes an audit
entry for every state-change event. Domain services never call an audit API for state changes.
The audit trail cannot be bypassed because it does not depend on domain services cooperating.

### 7. Correlation ID Propagation from Day One
Inject a correlation ID at the API Gateway. Every service forwards it in all event payloads
and all log lines. Required for distributed trace reconstruction. Retrofitting this is expensive.
It ships in v1 or it ships never.

---

## Mandatory Pre-Production Checklist (All Project Types)

Before any service extraction (Phase B onward):

- [ ] Correlation ID propagation defined and implemented (G-01)
- [ ] Event payload schemas defined with versioning contract (G-02)
- [ ] Degraded-mode behaviour documented for each infrastructure dependency (G-03)
- [ ] Service boundary review: each service owns exactly one aggregate cluster
- [ ] Distributed tracing stack selected (OpenTelemetry → Jaeger / CloudWatch X-Ray)
- [ ] Event schema versioning strategy selected (version field in envelope OR versioned routing key)

---

## Project Type: Greenfield

### What Greenfield Means Here
A new project with no existing codebase, no migration burden, and architecture decisions
made before a line of code is written.

### Architecture Starting Point

```
Greenfield always starts as a modular monolith (Phase A).
Service boundaries are defined as folder/module structure.
Route groups map to future service boundaries.
The MessageBus interface ships in the monolith even if only one in-process handler uses it.
```

The most common greenfield mistake: choosing 8 services on day one because the domain map
looks complex in a whiteboard session. Domain complexity observed in planning is always an
overestimate. The actual service count emerges after the first sprint when real coupling
patterns appear.

### Service Count Guidelines for Greenfield

| Domain size | Recommended starting architecture |
|---|---|
| 1–3 domain entities | Single module in monolith. No service split. |
| 4–6 domain entities | Monolith with 2–3 clear module boundaries. |
| 7–12 domain entities | 3–5 services in Phase B after monolith confirms boundaries. |
| 13+ domain entities | Full service map, but still start monolith. Extract in phases. |

### Greenfield-Specific Rules

**Define event schemas before the second service exists.**
The moment a second service is introduced, a shared event contract is required. If it is not
defined before extraction, every team writes their own interpretation and the integration
layer becomes the hardest thing to fix.

**The monolith is not a failure mode — it is Phase A.**
Frame the modular monolith to stakeholders as the intentional pilot architecture, not a
temporary hack. This prevents premature pressure to "break into microservices" before
the domain is understood.

**Schema `.describe()` annotations are mandatory from v1.**
Every API schema field ships with a clinical or domain description. This feeds documentation,
training materials, and onboarding. Retrofitting is expensive.

---

## Repo: Pharma-Base

**Repo:** `~/Pharma-Base`
**Current state:** Early build. API structure, DB models, and ingestion pipeline exist. BA logic confirmed.
**Stack:** Python, Alembic, Docker.
**What it is:** Standalone independent drug interactions microservice for India. Clinical decision
support for safe prescribing — comprehensive drug database, India-specific formularies, generic
drug names, local prescribing patterns. Independent now. Dhara integration is a future phase —
not a current coupling. Owns its own auth, gateway, and database.

### Microservices Adoption Verdict: YES — Selective Apply

Pharma-Base is a single independent service, not part of a larger platform. The
Transplant-workflow patterns apply at the service-design level (schema isolation, adapter
pattern, audit, correlation ID) but NOT at the platform-integration level (no shared
gateway, no shared event bus, no shared partition key with Transplant-workflow).

### What Transfers from Transplant-workflow

**Partition key — own tenant unit, not hospital_id.**
Pharma-Base is independent. Its tenant unit depends on who consumes it: if hospitals
subscribe directly, the key is `hospital_id`. If pharmaceutical companies or health
systems subscribe, it may be `org_id` or `client_id`. This must be decided at HLD.
The rule is the same as Transplant-workflow: whatever the tenant unit is, it goes in
every DB row, every API response, and every event routing key from day one.

**Schema-per-service isolation.**
Pharma-Base owns its own Postgres instance and schema via Alembic. No sharing with
any other service. Own DB user. This is non-negotiable.

**Adapter pattern for infrastructure.**
If Pharma-Base uses a message broker for formulary update events, it goes behind a
`MessageBus` interface + factory. If it integrates with an external drug database
(CDSCO, NLM RxNorm), that client goes behind an interface too. No vendor SDK imported
directly into domain logic.

**Own audit trail.**
Pharma-Base owns its own append-only audit log. It does not contribute to any other
system's audit trail. Every formulary change, every interaction rule update, every
API call that modifies data writes an audit entry to its own store.

**Correlation ID.**
Every inbound request carries a correlation ID. Every outbound event payload and every
log line forwards it. Consuming systems (whatever they are) can trace a call end-to-end.

### What Does NOT Transfer

| Transplant-workflow pattern | Why it does not apply to Pharma-Base |
|---|---|
| AyuVinc JWT / Platform Gateway | Pharma-Base has its own auth. API key or its own JWT — decided at HLD. |
| Shared RabbitMQ with Transplant-workflow | Independent event bus or no event bus. No shared exchanges. |
| Strangler-fig migration | Starts greenfield as a single service. No monolith to extract from. |
| CQRS read models | No cross-domain reads needed. It is the reference data source, not a consumer of other services' state. |
| Audit-by-consumption (platform-wide) | Pharma-Base owns its own audit. No platform-level compliance service. |

### Architecture Decision Required at HLD Stage

**Is Pharma-Base request-response only, or does it also publish events?**

Drug interaction data is largely static (formulary, interaction matrix, contraindication
rules). Queries are synchronous — a consumer asks "does Drug A interact with Drug B?"
and gets an immediate response.

Formulary updates (new drug approved, interaction rule revised) are state changes.
If any consumer needs to react to those changes without polling, events are required.
If all consumers are fine polling or pulling on demand, a pure REST service is sufficient.

This is an open architecture decision. Both are valid. Decide at HLD based on confirmed
consumer requirements.

```
Option A — Pure REST (simpler, correct if consumers poll):
  GET /interactions?drug_a=X&drug_b=Y
  GET /formulary/{tenantId}/drugs
  POST /formulary/{tenantId}/drugs      ← admin write
  PATCH /interactions/{id}              ← rule update

Option B — REST + event tail (if consumers need push on formulary changes):
  Same REST surface +
  {tenantId}.formulary-drug-added       ← published on write
  {tenantId}.formulary-drug-removed
  {tenantId}.interaction-rule-updated
```

### Single Service — No Decomposition Needed

One bounded context: the drug interaction knowledge base and the rules engine.
- Drug catalogue (generic names, brand names, ATC codes)
- Interaction matrix (drug-drug, drug-food, drug-condition)
- Formulary per tenant (which drugs are in scope)
- Interaction check API

One service. One schema. No further decomposition warranted.

### BA Logic — Confirmed (tasks/ba-logic.md, 2026-04-04)

Core business rules are confirmed. These are the domain foundation:

**Four check types per prescription validation call:**
- Drug × Drug — always runs
- Drug × Dosage — always runs
- Drug × Prior Medication — runs only when prior meds list is passed by consumer
- Drug × Allergy — runs only when allergy list is passed by consumer

**Three severity tiers:** Critical / Moderate / Mild. All three returned in every API response.
UI rendering (colour, prominence) is the consumer's responsibility — not Pharma-Base's.

**Override:** Doctor can override any flag. Override must be explicitly acknowledged.
Audit log records: drug name, flag ID, severity, doctor ID, prescription reference ID,
timestamp, decision. No patient identifiers stored — ever.

**Drug not found:** Return a warning. Unknown ≠ safe. Never silently pass a missing drug as clean.

**Alternatives:** At least one alternative returned per flagged interaction where one exists.
Drug name only — no dosage, no clinical rationale. Empty list + note if none exists.

**Patient data boundary (hard constraint):**
Pharma-Base stores zero patient data. No names, IDs, Aadhaar numbers, medical record numbers.
All patient context (prior meds, allergies) is passed at call time by the consumer and not
persisted. This boundary is non-negotiable. Future Dhara integration must not require
Pharma-Base to store patient identifiers.

**Drug database:** Comprehensive — all drugs. Not a subset.

### Architecture Decisions — Confirmed (AK, 2026-04-11)

**D1 — Tenant unit: API key scoped**
The API key is the partition key. Each consumer (Dhara, a hospital system, a prescribing app)
gets its own API key. Formulary configuration, audit records, and event routing are all scoped
to `api_key_id`. No `hospital_id` or `org_id` in the schema — the API key carries the tenant
boundary.

```
Every DB row:    api_key_id  (partition key)
Every event:     {api_key_id}.formulary-drug-added
Every audit log: api_key_id + actor + action + timestamp
```

**D2 — Auth: API key + JWT (both)**
Two auth paths, one service:
- **API key** — service-to-service. Dhara or any programmatic consumer passes the key in
  the request header. No user identity required.
- **JWT** — user-facing roles. A pharmacist admin managing the formulary via a UI
  authenticates with a JWT. JWT payload: `userId`, `role`, `api_key_id` (links the user
  to their tenant). Pharma-Base issues its own JWTs — it does not depend on AyuVinc or
  any external identity provider.

The API Gateway validates both patterns:
```
Service-to-service:   Authorization: ApiKey {key}   → resolve api_key_id → route
User-facing:          Authorization: Bearer {JWT}   → validate + extract api_key_id → route
```

**D3 — Integration: REST + event tail**
Synchronous REST for all four check types (the critical path — must be low latency).
Async events via RabbitMQ for formulary state changes (consumers subscribe to stay current).

```
Synchronous (REST — always):
  POST /v1/check
    body: { drugs[], priorMedications[]?, allergies[]?, dosages[]? }
    response: { checks[], severity, alternatives[], warnings[] }

  GET  /v1/formulary              ← list drugs in this tenant's formulary
  POST /v1/formulary/drugs        ← admin: add drug
  DELETE /v1/formulary/drugs/{id} ← admin: remove drug
  PATCH /v1/interactions/{id}     ← admin: update interaction rule

Async (events — on every formulary write):
  {api_key_id}.formulary-drug-added     { drugId, name, addedBy, timestamp }
  {api_key_id}.formulary-drug-removed   { drugId, name, removedBy, timestamp }
  {api_key_id}.interaction-rule-updated { ruleId, change, updatedBy, timestamp }
```

**Future Dhara integration contract — already defined by the patient data boundary:**
Dhara calls `POST /v1/check` with patient context (prior meds, allergies) at call time.
Pharma-Base returns flags and alternatives. Nothing is stored. No contract change needed
on either side when Dhara integration goes live — the API is already designed for it.

**Operating tier:** Standard.

---

## Repo: Forensic-AI (GoodWork)

**Repo:** `~/forensic-ai`
**Current state:** Built. Running. Python CLI application.
**What it is:** A local-install, single-user Python CLI tool that simulates a forensic
consulting firm's internal review pipeline for Maher (solo practitioner, UAE). Produces
FRM risk registers, investigation reports, due diligence memos, sanctions screenings,
SOPs, and client proposals via a three-agent pipeline (Junior Analyst → PM → Partner)
backed by the Anthropic Claude API.

### Microservices Adoption Verdict: NOT APPLICABLE — Wrong Architecture Class

Forensic-AI is not a web service. It has no REST API, no database, no multi-tenancy,
no concurrent users, and no network-facing components. It is a local Python process
that runs on Maher's machine, stores case files on his filesystem, and calls external
APIs (Anthropic, Tavily, UAE regulatory sites) outbound.

Applying Transplant-workflow microservices patterns here would be like decomposing
a Word document into distributed services. The architecture is correct for its scope.

**Do not impose microservices on Forensic-AI in its current form.**

### What Forensic-AI Already Has That Is Correct

The patterns it has built are the right ones for its architecture class:

| Pattern | Forensic-AI implementation | Assessment |
|---|---|---|
| Schema validation | Pydantic models in `schemas/` | Correct |
| State machine | `core/state_machine.py` — CaseStatus + VALID_TRANSITIONS | Correct |
| Audit trail | `append_audit_event` → `cases/{id}/audit_log.jsonl` | Correct for local |
| Hook engine | `core/hook_engine.py` — pre/post hook chain | Correct |
| Agent pipeline | Junior → PM → Partner with revision loops | Correct |
| Tool isolation | `core/tool_registry.py` — ALLOWED_TOOLS per manifest | Correct |
| Research trust hierarchy | authoritative vs general sources, clearly separated | Correct |

None of these need to change. The architecture is appropriate for the problem.

### When Would Microservices Become Relevant for Forensic-AI?

Only if the scope changes to one of these:

| Scope change | Architecture implication |
|---|---|
| Multi-user (team of analysts, not just Maher) | User auth, case-level access control, web API |
| SaaS (multiple client firms using the platform) | Multi-tenancy, `firm_id` partition key, web service |
| Real-time collaboration (multiple analysts on one case) | WebSocket, event-driven state sync |
| Enterprise deployment (on-premise at a firm) | Containerisation, API gateway, DB persistence |

If any of these happen, the architecture assessment becomes: extract the orchestrator
and agent pipeline as services, add a web API layer in front, introduce a proper DB
for case state instead of filesystem JSON. The core pipeline logic does not change —
only the delivery mechanism.

**Until one of those scope changes is confirmed by AK, Forensic-AI stays as a local CLI.
No microservices work is needed or appropriate.**

### What Is Worth Improving in Forensic-AI (Not Microservices)

These are gaps in the current architecture that matter regardless of microservices:

- **Resume reliability:** If the pipeline crashes mid-revision loop, the resume logic
  depends on filesystem state. A structured state.json checkpoint per agent turn would
  make resume more robust.
- **Model cost tracking:** No per-case token/cost logging. For a consulting firm, knowing
  the API cost per deliverable matters for pricing.
- **Conflict between agents:** No formal escalation when PM and Partner disagree. Currently
  Partner has final say — this is correct, but the disagreement is not logged as a finding.

These are agent pipeline improvements, not architectural ones. They belong in a Forensic-AI
session, not in this guide.

---

## Repo Comparison — Microservices Adoption

| Repo | Verdict | Reason |
|---|---|---|
| Transplant-workflow | YES — built | Medical EDA, multi-tenant, time-critical, validated |
| Pharma-Base | YES — apply directly | Same Dhara ecosystem, same partition key, same patterns |
| Forensic-AI | NO — wrong class | Local CLI, single user, no web layer, correct as-is |

---

## Anti-Patterns — All Types

**Do not do these regardless of project type:**

- Choosing service count before the domain is understood (premature decomposition)
- Putting the audit/compliance service inside a domain service (compliance capture risk)
- Cross-service DB queries or synchronous reads for cross-domain data (coupling)
- Applying microservices to a local single-user tool (wrong architecture class)
- Client-supplied timestamps on any record
- Skipping correlation IDs until "later" — there is no later
- Skipping event schema versioning until a service needs to change — by then it is too late

---

## Checklist — Architecture Review Before First Service Extract

- [ ] Domain map reviewed — service count derived from aggregate clusters, not whiteboard intuition
- [ ] Partition key defined and present in all tables, events, JWT claims, and routing keys
- [ ] MessageBus interface + factory implemented in monolith (adapter pattern)
- [ ] Event payload schemas defined in `src/shared/schemas/events/` with correlationId and version
- [ ] Correlation ID propagation implemented at API Gateway
- [ ] Audit service isolated from all domain services (append-only, no domain service owns it)
- [ ] Distributed tracing stack selected and wired
- [ ] Degraded-mode runbook written for every infrastructure dependency
- [ ] For Pharma-Base: BA sign-off on interaction check rules before HLD
- [ ] For Pharma-Base: India drug database source confirmed before schema design
- [ ] For Forensic-AI: only reassess if scope changes to multi-user or SaaS
