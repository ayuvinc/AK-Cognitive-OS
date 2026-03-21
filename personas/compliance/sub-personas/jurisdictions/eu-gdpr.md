# Jurisdiction: European Union — GDPR
# Parent: compliance/data-privacy

last_reviewed: 2026-03-21
owner: data-privacy
jurisdiction: European Union
advisory_only: true
not_legal_advice: This document is a framework reference, not legal advice.
                   Always consult a qualified legal professional for compliance decisions.
coverage: GDPR core articles, lawful basis, data subject rights, DPO requirements, international transfers, breach notification, DPIA
out_of_scope: ePrivacy Regulation (cookie law — supplement separately), sector-specific EU law (MiCA, AI Act data provisions), national GDPR implementations (member state variations)

---

## Overview

The General Data Protection Regulation (GDPR) — Regulation (EU) 2016/679 — applies to:
- Any organisation established in the EU/EEA, regardless of where processing occurs
- Any organisation outside the EU that offers goods/services to EU data subjects, or monitors their behaviour

Effective: 25 May 2018. Enforced by national Data Protection Authorities (DPAs).

---

## Lawful Bases (Article 6)

| Basis | When applicable | Key condition |
|---|---|---|
| Consent | Freely given, specific, informed, unambiguous | Must be withdrawable at any time |
| Contract | Processing necessary for contract with data subject | Not for processing beyond contract scope |
| Legal obligation | Complying with EU/member state law | Must identify the specific law |
| Vital interests | Protecting life — rare in software products | Not for routine processing |
| Public task | Public authority functions | Rarely applicable to private companies |
| Legitimate interests | Balancing test — company interest vs individual rights | Must document balancing test; not for public authorities |

---

## Data Subject Rights (Articles 15–22)

| Right | What it means |
|---|---|
| Access (Art 15) | Data subject can request a copy of all personal data held about them |
| Rectification (Art 16) | Data subject can correct inaccurate data |
| Erasure (Art 17) | "Right to be forgotten" — delete data when no longer necessary (subject to exceptions) |
| Restriction (Art 18) | Pause processing while a dispute is resolved |
| Portability (Art 20) | Data provided in machine-readable format when processing based on consent or contract |
| Objection (Art 21) | Object to processing based on legitimate interests |
| Not subject to automated decisions (Art 22) | No solely automated decisions with legal/significant effect without human review |

Response time: within one calendar month (extendable to 3 months for complex requests).

---

## DPO Requirement (Article 37)

Required when:
- Public authority or body
- Large-scale systematic monitoring of individuals
- Large-scale processing of special category data or criminal conviction data

If not required: still recommended for high-volume personal data processing.

---

## International Transfers (Chapter V)

Transfer of personal data outside EU/EEA requires one of:
- Adequacy decision (UK, Canada, Japan, others — check current list)
- Standard Contractual Clauses (SCCs) — current version: June 2021
- Binding Corporate Rules (BCR) — for intra-group transfers
- Specific derogations (explicit consent, contract performance, etc. — narrow)

Schrems II (2020): Privacy Shield invalid. US transfers require SCCs + Transfer Impact Assessment.

---

## Breach Notification (Articles 33–34)

- Notify supervisory authority (national DPA): within 72 hours of becoming aware
- Notify affected individuals: without undue delay if high risk to their rights/freedoms
- Document all breaches (even those not reported)

---

## DPIA (Article 35)

Data Protection Impact Assessment required when:
- Large-scale processing of special category data
- Systematic and extensive automated profiling
- Large-scale monitoring of public areas

---

## Special Category Data (Article 9)

Higher protection required for:
Health, racial/ethnic origin, political opinions, religious beliefs, trade union membership,
genetic data, biometric data (for unique identification), sex life/sexual orientation, criminal data.

Lawful basis alone is insufficient for special category data — additional condition required.

---

## Framework Reference Checklist

- [ ] Lawful basis identified for each processing activity
- [ ] Privacy notice covers all required elements (identity of controller, purposes, legal basis, retention, rights)
- [ ] Consent mechanism granular, freely given, and withdrawable
- [ ] Data subject rights mechanisms implemented
- [ ] International transfer mechanism in place if transferring outside EU/EEA
- [ ] Breach notification procedure documented
- [ ] DPIA completed if required
- [ ] DPO appointed if required
- [ ] Records of Processing Activities (RoPA) maintained
