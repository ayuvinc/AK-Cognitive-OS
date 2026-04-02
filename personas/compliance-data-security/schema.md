# Compliance Data Security Schema
# validation: markdown-contract-only | machine-validated

## Extra Fields

```yaml
compliance_findings:
  - id: string              # e.g. COMP-DS-001-01
    severity: S0 | S1 | S2
    sub_persona: "data-security"
    jurisdiction: string    # e.g. European Union | United States | United Kingdom
    location: string        # file:line | n/a
    finding: string         # one sentence
    legal_basis: string     # regulation/article | n/a
    blocking: "YES | AK_DECISION | NO"
    recommended_fix: string
    advisory: "This is a compliance flag, not legal advice."

s0_count: 0
s1_count: 0
s2_count: 0
sub_personas_activated: ["data-security"]
ak_decision_required: true|false
```

## Severity Contract

| Severity | Compliance meaning | Status rule |
|---|---|---|
| S0 | Hard block — critical security violation or data exposure risk | status must be BLOCKED |
| S1 | Significant security gap — AK decision required | status must be FAIL; ak_decision_required: true |
| S2 | Advisory — log and defer | status may be PASS; warning added |

## S0 Examples

- PHI or PII exposed without encryption at rest or in transit
- Authentication bypass exposing protected records
- API endpoint returning data without auth check
- Secrets or credentials committed to source code
- Encryption keys stored in plaintext alongside encrypted data

## S1 Examples

- Encryption at rest not yet configured (no sensitive data stored yet)
- Rate limiting absent on sensitive endpoints
- Session timeout not enforced
- Key rotation policy not defined
- Audit logging not enabled for sensitive operations

## S2 Examples

- Security headers not fully configured
- Audit log retention period not formally defined
- Penetration test not yet scheduled
- TLS version could be upgraded to latest
- CORS policy overly permissive but no sensitive endpoints exposed yet

## Validation Rules

- `s0_count > 0` -> status must be BLOCKED
- `s1_count > 0` -> status must be FAIL and ak_decision_required must be true
- `s0_count == 0` and `s1_count == 0` and `s2_count > 0` -> status PASS with warnings
- `s0_count == 0` and `s1_count == 0` and `s2_count == 0` -> status PASS, clean
- Downgrading S0 to S1 -> SCHEMA_VIOLATION: severity_downgrade_prohibited
- Missing `advisory` field on any finding -> finding is rejected

## Artifacts Written

- Inline compliance review note (required)
- Optional: `channel.md` update if S0 or S1 found
- `[AUDIT_LOG_PATH]` entry: COMPLIANCE_S0_BLOCKED or COMPLIANCE_S1_DECISION

## Activation Inputs Required

- `session_id` — current session identifier
- `review_scope` — what is being reviewed (sprint artifacts, specific files, data flows)
- `jurisdictions` — which jurisdictions apply (from project CLAUDE.md)

## Advisory

All compliance findings are framework references, not legal advice.
Always consult a qualified security professional for data security decisions.
