# Compliance Sub-Persona: Data Security
# Parent: compliance

last_reviewed: 2026-03-21
owner: data-security
jurisdiction: Cross-jurisdiction (security requirements apply universally)
advisory_only: true
not_legal_advice: This document is a framework reference, not legal advice.
                   Always consult a qualified legal professional for compliance decisions.
coverage: Encryption at rest and in transit, access control, authentication, breach response, audit logging, secrets management
out_of_scope: Physical security, network perimeter security, penetration testing scope, insurance requirements

---

## Scope

The data-security sub-persona reviews:
- Whether personal data is encrypted at rest and in transit
- Whether access control is correctly enforced (least privilege)
- Whether authentication is adequate for the sensitivity of data accessed
- Whether secrets (API keys, credentials) are properly managed
- Whether audit logs capture security-relevant events
- Whether a breach response process is defined
- Whether dependencies have known critical vulnerabilities

---

## Key Security Requirements

| Requirement | Standard | S0 if violated? |
|---|---|---|
| Encryption in transit | TLS 1.2+ for all data in motion | Yes — if personal data exposed |
| Encryption at rest | AES-256 or equivalent for sensitive/personal data | Yes |
| Authentication | MFA for admin access; token-based for API | S1 if missing for admin |
| Access control | Role-based; least privilege; no shared credentials | S0 if auth bypass enables data access |
| Secrets management | No secrets in code or version control | S0 |
| Audit logging | Security-relevant events logged with actor, timestamp, action | S1 if absent |
| Dependency vulnerabilities | No critical CVEs in production dependencies | S0 if critical |

---

## Review Checklist

Before any feature touching sensitive data ships:

- [ ] All API endpoints require authentication (no unauthenticated access to protected data)
- [ ] Personal/sensitive data encrypted at rest (DB encryption or field-level)
- [ ] All external communication uses HTTPS / TLS 1.2+
- [ ] No secrets, credentials, or API keys in source code or version history
- [ ] Role-based access control enforced (users can only access their own data by default)
- [ ] Audit log captures: login, data access, data modification, deletion
- [ ] Breach response documented (even minimal: "notify users within 72 hours")
- [ ] Dependencies scanned for known CVEs

---

## S0 Triggers (Data Security)

- Unauthenticated access to any personal data endpoint
- Secrets/credentials committed to version control
- Critical CVE (CVSS 9.0+) in a production dependency handling sensitive data
- Personal data transmitted without TLS
- Authentication bypass allowing access to other users' data

---

## S1 Triggers (Data Security)

- Admin interface lacks MFA
- Audit logging not yet implemented (logged — must be built before scale)
- Breach response process not documented
- Dependencies not scanned (must add scanning to CI before next sprint)
