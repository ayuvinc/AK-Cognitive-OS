# Guide 14 — Risk Tier Selection

## When to Use This Guide

Use this guide when starting a new project or reassessing an existing one. The tier you select determines which gates, artifacts, and enforcement rules apply throughout delivery. Choosing the wrong tier creates either unnecessary overhead (too high) or dangerous gaps (too low).

---

## The Three Tiers

| Tier | Who it's for | Planning docs enforced | Compliance gate |
|---|---|---|---|
| MVP | Prototypes, experiments, internal tools | No | No |
| Standard | Most real-world projects (default) | Yes | No |
| High-Risk | Regulated, sensitive data, high-stakes | Yes | Yes (every stage) |

---

## Decision Questions

Answer these three questions in order. Stop at the first Yes.

### Question 1 — Is this a regulated or high-stakes project?

**Yes if any of these are true:**
- Subject to regulatory frameworks (HIPAA, GDPR with enforcement, SOC 2, FDA, financial compliance)
- Failure could result in patient harm, legal liability, financial loss, or public safety impact
- Handles sensitive personal data (health records, financial data, HR/employee data, biometrics)
- Requires formal audit trail by law or contract
- Contractually obligated compliance review before release

**→ If Yes: select High-Risk**

**→ If No: go to Question 2**

---

### Question 2 — Does this have real users or production impact?

**Yes if any of these are true:**
- External users (customers, clients, patients, the public) will use this
- Internal users depend on it for daily work and breakage causes material disruption
- Data is persisted and cannot be trivially reset if something goes wrong
- The project is headed toward a production release (even if not there yet)

**→ If Yes: select Standard**

**→ If No: go to Question 3**

---

### Question 3 — Is this a prototype, internal experiment, or throwaway build?

**Yes if any of these are true:**
- Purely exploratory — proof-of-concept, research spike, or prototype
- No external users; only the builder or a small internal team will see it
- Data is fake or disposable; resetting state is trivial
- Explicit intention to throw this away or rewrite before production

**→ If Yes: select MVP**

**→ If still unsure: default to Standard** — the cost of Standard over MVP is planning docs; the cost of under-governing a production system is much higher.

---

## Worked Examples

### Greenfield SaaS product

**Context:** Building a new subscription web app with user accounts, billing, and persistent data.

**Assessment:**
- Not regulated (Q1: No)
- Has real users, production-bound (Q2: Yes)

**→ Tier: Standard**

---

### AI / RAG application

**Context:** Building an AI assistant that retrieves from a knowledge base.

**Assessment depends on data sensitivity:**
- If the knowledge base contains public or internal-only non-sensitive content → Q2 Yes → **Tier: Standard**
- If the knowledge base contains patient records, legal case files, financial documents, or any regulated data → Q1 Yes → **Tier: High-Risk**

**→ Tier: Standard OR High-Risk — determined by what data the RAG pipeline touches**

Both outcomes are valid. Assess at project start and revisit if the data scope changes.

---

### Regulated application (healthcare, finance, legal)

**Context:** Pharma trial management system, financial reporting tool, or legal document processor.

**Assessment:**
- Subject to HIPAA / SOC 2 / regulatory framework (Q1: Yes)

**→ Tier: High-Risk**

---

### Internal tool

**Context:** A Slack bot, internal dashboard, or admin panel used by a small team with no external users and no sensitive data.

**Assessment:**
- Not regulated (Q1: No)
- Limited internal users, low breakage impact — could go either way (Q2: borderline)
- If it's a utility with disposable state: **Tier: MVP**
- If it handles real employee data or production workflows: **Tier: Standard**

**→ Tier: MVP or Standard — based on data sensitivity and operational impact**

---

## Setting the Tier

Add the `Tier:` field to your project's `CLAUDE.md` header (before the first `---`):

```
Tier: Standard   # MVP | Standard | High-Risk — controls which gates are active
```

This field is read automatically by enforcement hooks at runtime.

---

## Changing Tier Mid-Project

### Upgrading (e.g., MVP → Standard, Standard → High-Risk)

1. Edit `Tier:` field in `CLAUDE.md` — change the value to the new tier
2. Run `bash scripts/remediate-project.sh <project_path>` to redeploy hooks and settings
3. Architect reviews which now-required artifacts are missing and creates tasks to fill them
4. Do not proceed with build work until newly required planning docs exist

Upgrade at any time — applying more gates is always safe.

### Downgrading (e.g., Standard → MVP)

1. Confirm with Architect that the scope change justifies the downgrade
2. Edit `Tier:` field in `CLAUDE.md`
3. Run `bash scripts/remediate-project.sh <project_path>`

### Downgrading from High-Risk

**Warning: Downgrading from High-Risk to Standard requires AK explicit approval.**

A tier downgrade from High-Risk is a compliance and risk decision, not a technical one. The reason the project was classified High-Risk (regulatory obligation, data sensitivity, contractual requirement) must be formally resolved before the tier changes. Do not change `Tier: High-Risk` without AK sign-off on record.

---

*See `framework/governance/operating-tiers.md` for the full gate table for each tier.*
*See `framework/governance/default-workflows.md` for project-type workflow maps.*
