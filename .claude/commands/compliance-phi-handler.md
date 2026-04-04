# Compliance Sub-Persona: PHI Handler

## FORMAT: reference-doc


## ROUTER CONTEXT

**Router:** `/compliance` (default entry point — use the router when domain is unclear)
**This sub-persona is a direct specialist shortcut.** Invoke directly only when you already know
the domain applies. Otherwise, start with `/compliance` and let it select this sub-persona.

Domain: HIPAA, health data, PHI storage and transmission, covered entities
Trigger signals: health data, PHI, HIPAA compliance, covered entity obligations


# Parent: compliance

last_reviewed: 2026-03-21
owner: phi-handler
jurisdiction: United States (HIPAA primary); UK NHS data standards where applicable
advisory_only: true
not_legal_advice: This document is a framework reference, not legal advice.
                   Always consult a qualified legal professional for compliance decisions.
coverage: HIPAA PHI definition, safe harbour de-identification, covered entities, business associate agreements, minimum necessary standard, breach notification
out_of_scope: State-level health privacy laws beyond HIPAA (e.g. CMIA, MHPAEA), clinical trial regulations (21 CFR), FDA medical device software regulation

---

## What Is PHI

Protected Health Information — any health information that:
1. Relates to the past, present, or future physical or mental health of an individual; AND
2. Can be used to identify the individual; AND
3. Is held or transmitted by a covered entity or business associate.

PHI applies when your product is a covered entity (healthcare provider, health plan, healthcare clearinghouse)
or a business associate (vendor/partner processing PHI on behalf of a covered entity).

**If your product does not handle medical records, diagnoses, treatment data, or health insurance data
for covered entities — PHI rules likely do not apply. Verify with legal before assuming.**

---

## HIPAA Safe Harbour — 18 Identifiers to Remove for De-identification

1. Names
2. Geographic data below state level (address, zip code, GPS)
3. All dates (except year) — birth, admission, discharge, death
4. Phone numbers
5. Fax numbers
6. Email addresses
7. Social Security numbers
8. Medical record numbers
9. Health plan beneficiary numbers
10. Account numbers
11. Certificate/licence numbers
12. Vehicle identifiers (VIN, plate)
13. Device identifiers and serial numbers
14. Web URLs
15. IP addresses
16. Biometric identifiers (finger/voice print)
17. Full-face photographs
18. Any other unique identifying number or code

Data is de-identified only when ALL 18 are removed AND there is no reasonable basis to re-identify.

---

## Key HIPAA Requirements (if applicable)

| Requirement | Description |
|---|---|
| Minimum necessary | Use/disclose only the minimum PHI necessary for the purpose |
| BAAs | Business Associate Agreement required with all vendors handling PHI |
| Access control | PHI access limited to workforce members who need it |
| Audit controls | Hardware/software activity recorded for systems containing PHI |
| Transmission security | Encryption required for PHI in transit |
| Breach notification | Notify affected individuals within 60 days; HHS within 60 days |

---

## S0 Triggers (PHI)

- PHI stored or transmitted without encryption (HIPAA requires encryption or documented risk analysis)
- PHI disclosed to a third party without a Business Associate Agreement
- Audit controls absent for a system containing PHI
- PHI accessible without authentication

---

## S1 Triggers (PHI)

- BAA template not yet executed with a vendor who will handle PHI
- Breach response process not documented
- Minimum necessary standard not applied (full PHI record returned when subset sufficient)
- De-identification procedure not formally documented

---

## Activate This Sub-Persona When

- Product is a covered entity or business associate
- Product integrates with EHR systems, health insurers, or clinical systems
- Product stores or processes diagnoses, treatment records, or health insurance data
- Any of the 18 HIPAA identifiers are present alongside health information
