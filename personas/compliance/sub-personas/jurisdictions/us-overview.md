# Jurisdiction: United States — Privacy Overview
# Parent: compliance/data-privacy

last_reviewed: 2026-03-21
owner: data-privacy
jurisdiction: United States
advisory_only: true
not_legal_advice: This document is a framework reference, not legal advice.
                   Always consult a qualified legal professional for compliance decisions.
coverage: CCPA/CPRA (California), HIPAA (federal health), COPPA (children's privacy), FERPA (education), federal FTC Act privacy enforcement, state-level overview
out_of_scope: State laws not covered here (Virginia VCDPA, Colorado CPA, Connecticut CTDPA, etc. — add as needed), sector-specific federal laws beyond those listed, employment privacy law

---

## US Privacy Landscape Overview

Unlike the EU's omnibus approach (GDPR), the United States has a sectoral and state-based
privacy framework. There is no single federal general privacy law (as of early 2026).
Key federal laws apply to specific sectors; state laws fill the gaps.

---

## California Consumer Privacy Act (CCPA) / CPRA

**Applies to:** For-profit businesses that:
- Have annual gross revenues >$25 million; OR
- Buy, sell, or share personal information of ≥100,000 consumers/households per year; OR
- Derive ≥50% of annual revenue from selling consumers' personal information

And do business in California (including businesses outside California with CA customers).

**Key rights:**
- Right to know (what personal information is collected, sold, shared)
- Right to delete
- Right to opt-out of sale/sharing of personal information
- Right to correct
- Right to limit use of sensitive personal information
- Right to non-discrimination (cannot penalise for exercising rights)

**Key requirements:**
- Privacy policy with specific disclosures
- "Do Not Sell or Share My Personal Information" link (if selling/sharing)
- Respond to rights requests within 45 days
- Sensitive PI requires opt-in (children) or opt-out (adults) depending on category

**Enforcement:** California Privacy Protection Agency (CPPA) + CA Attorney General.

---

## HIPAA (Health Insurance Portability and Accountability Act)

See `sub-personas/phi-handler.md` for full PHI handling reference.

**Applies to:** Covered entities (healthcare providers, health plans, clearinghouses) and their business associates.
**Key rules:** Privacy Rule, Security Rule, Breach Notification Rule, Enforcement Rule.
**Enforcement:** HHS Office for Civil Rights (OCR).

---

## COPPA (Children's Online Privacy Protection Act)

**Applies to:** Operators of websites or online services directed to children under 13, or with actual knowledge of collecting personal information from children under 13.

**Key requirements:**
- Verifiable parental consent before collecting personal information from children under 13
- Privacy policy with specific disclosures
- Right for parents to review, delete, or stop further collection of child's data
- No conditioning of participation on providing more personal information than necessary

**Enforcement:** Federal Trade Commission (FTC).

**S0 trigger:** Collecting personal information from users under 13 without verifiable parental consent.

---

## FERPA (Family Educational Rights and Privacy Act)

**Applies to:** Educational institutions receiving federal funding (schools, universities).
**Key provisions:** Parents/students have right to access and correct education records.
Records cannot be shared without consent (with exceptions for school officials, etc.).

Only relevant if product handles education records for a covered institution.

---

## FTC Act Section 5

The FTC can take enforcement action against "unfair or deceptive acts or practices."
Practically: companies must follow their own stated privacy policies. Failing to do so
is an "unfair or deceptive practice" even without a specific privacy law violation.

**Implication:** Your privacy policy is a contract with the FTC. Do not overstate or understate
what you collect, share, or do with personal data.

---

## State Privacy Laws (Summary — Not Exhaustive)

Multiple US states have passed privacy laws modelled loosely on GDPR / CCPA.
Key states: Virginia (VCDPA), Colorado (CPA), Connecticut (CTDPA), Texas (TDPSA), Montana, Oregon, and others.
Common threads: consumer rights (access, delete, correct, opt-out of sale), privacy notice requirements.

**If your product has US customers beyond California:** review applicable state laws
and add jurisdiction-specific files as needed using `legal-summary-template.md`.

---

## Framework Reference Checklist (US)

- [ ] CCPA threshold check — does the business meet applicability criteria?
- [ ] Privacy policy includes CCPA-required disclosures (if applicable)
- [ ] Rights request mechanism in place (45-day response window)
- [ ] "Do Not Sell/Share" opt-out present (if selling/sharing PI)
- [ ] HIPAA assessment — is the product a covered entity or business associate?
- [ ] COPPA assessment — does product collect data from or target children under 13?
- [ ] FERPA assessment — does product handle education records?
- [ ] Privacy policy accurately reflects actual data practices (FTC Act compliance)
