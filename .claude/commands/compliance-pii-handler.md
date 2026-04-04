# Compliance Sub-Persona: PII Handler

## FORMAT: reference-doc


## ROUTER CONTEXT

**Router:** `/compliance` (default entry point — use the router when domain is unclear)
**This sub-persona is a direct specialist shortcut.** Invoke directly only when you already know
the domain applies. Otherwise, start with `/compliance` and let it select this sub-persona.

Domain: PII identification, classification, retention, handling rules
Trigger signals: PII classification, data retention policies, handling requirements


# Parent: compliance

last_reviewed: 2026-03-21
owner: pii-handler
jurisdiction: Cross-jurisdiction (PII definition varies — see below)
advisory_only: true
not_legal_advice: This document is a framework reference, not legal advice.
                   Always consult a qualified legal professional for compliance decisions.
coverage: PII identification, classification, handling rules, data minimisation, field-level protection
out_of_scope: PHI (see phi-handler), financial data (PCI-DSS — separate framework), sector-specific PII rules

---

## What Is PII

Personally Identifiable Information — any data that can identify a specific individual, directly or indirectly.

### Direct Identifiers (always PII)

- Full name
- Government ID / National ID / Passport / Driver's licence number
- Social Security Number (US) / National Insurance Number (UK) / SIN (Canada)
- Email address
- Phone number
- Physical address (home or work)
- Date of birth combined with any other identifier
- IP address (in most jurisdictions)
- Biometric data (fingerprint, facial scan, voice print)
- Device identifiers tied to an individual

### Indirect / Quasi-Identifiers (PII when combined)

- Gender + age + zip code can uniquely identify in small populations
- Job title + employer + location
- Behavioural data linked to an account

### Not PII (standalone)

- Aggregated, anonymised statistics (no re-identification risk)
- Public business information (company name, public address)
- Truly random identifiers (UUID with no linkage)

---

## Handling Rules

| PII Category | Minimum handling requirement |
|---|---|
| Direct identifiers | Encrypted at rest; access-controlled; not logged in plaintext |
| Government IDs | Field-level encryption; access audit trail; justify collection |
| Email / Phone | Encrypted; unsubscribe / deletion mechanism required |
| Behavioural / Tracking | Consent required; purpose limitation applies |
| IP addresses | Treat as PII in EU/UK; handle accordingly |

---

## Data Minimisation Checklist

For every PII field collected:
- [ ] Is this field necessary for the stated purpose?
- [ ] Is there a less sensitive alternative?
- [ ] Is there a retention limit and deletion path?
- [ ] Is collection disclosed in the privacy policy?

---

## S0 Triggers (PII)

- Direct identifiers stored in plaintext in the database
- PII logged to application logs without masking
- PII exported in bulk without access control
- Direct identifier fields accessible without authentication

---

## S1 Triggers (PII)

- PII field collected without being disclosed in privacy policy
- Retention period not defined for a PII field
- PII in a field that does not require it (over-collection — minimise)
- IP addresses not treated as PII in EU/UK context
