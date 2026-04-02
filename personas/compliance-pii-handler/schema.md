# Compliance PII Handler Schema
# validation: markdown-contract-only | machine-validated

## Extra Fields

```yaml
compliance_findings:
  - id: string              # e.g. COMP-PII-001-01
    severity: S0 | S1 | S2
    sub_persona: "pii-handler"
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
sub_personas_activated: ["pii-handler"]
ak_decision_required: true|false
```

## Severity Contract

| Severity | Compliance meaning | Status rule |
|---|---|---|
| S0 | Hard block — critical PII exposure or handling violation | status must be BLOCKED |
| S1 | Significant PII handling gap — AK decision required | status must be FAIL; ak_decision_required: true |
| S2 | Advisory — log and defer | status may be PASS; warning added |

## S0 Examples

- PII logged in plaintext in application logs
- PII returned in API responses to unauthorised callers
- No deletion mechanism for user data when account deleted
- PII stored without any access control
- Full credit card numbers or SSNs persisted in plaintext

## S1 Examples

- PII stored longer than stated retention period
- Email addresses visible in URLs or query strings
- PII in error messages returned to the client
- Masking not applied to PII in non-production environments
- PII export endpoint lacks rate limiting

## S2 Examples

- Anonymisation not applied to analytics data yet
- PII audit trail not fully implemented
- Data minimisation review pending
- PII field inventory not documented
- Pseudonymisation could be applied to reduce exposure in reporting

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
- `review_scope` — what is being reviewed (data models, API responses, storage, logs)
- `jurisdictions` — which jurisdictions apply (from project CLAUDE.md)

## Advisory

All compliance findings are framework references, not legal advice.
Always consult a qualified legal professional for PII handling decisions.
