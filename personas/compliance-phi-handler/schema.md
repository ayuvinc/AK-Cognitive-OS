# Compliance PHI Handler Schema
# validation: markdown-contract-only | machine-validated

## Extra Fields

```yaml
compliance_findings:
  - id: string              # e.g. COMP-PHI-001-01
    severity: S0 | S1 | S2
    sub_persona: "phi-handler"
    jurisdiction: string    # e.g. United States (HIPAA) | European Union
    location: string        # file:line | n/a
    finding: string         # one sentence
    legal_basis: string     # regulation/article | n/a
    blocking: "YES | AK_DECISION | NO"
    recommended_fix: string
    advisory: "This is a compliance flag, not legal advice."

s0_count: 0
s1_count: 0
s2_count: 0
sub_personas_activated: ["phi-handler"]
ak_decision_required: true|false
```

## Severity Contract

| Severity | Compliance meaning | Status rule |
|---|---|---|
| S0 | Hard block — critical PHI/HIPAA violation or health data exposure risk | status must be BLOCKED |
| S1 | Significant PHI handling gap — AK decision required | status must be FAIL; ak_decision_required: true |
| S2 | Advisory — log and defer | status may be PASS; warning added |

## S0 Examples

- PHI exposed without encryption at rest or in transit
- PHI accessible without authentication
- PHI shared with third party without BAA or legal basis
- PHI logged in plaintext in application logs
- De-identification not applied when PHI leaves covered entity boundary

## S1 Examples

- Audit trail for PHI access not implemented
- PHI retention period not defined
- Role-based access control for PHI not enforced
- BAA not signed with a data processor handling PHI
- PHI backup encryption not verified

## S2 Examples

- PHI anonymisation for analytics not yet applied
- BAA template not yet reviewed for new vendors
- HIPAA training acknowledgement not logged
- PHI access audit reports not scheduled
- De-identification methodology documentation incomplete

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
- `jurisdictions` — which jurisdictions apply (e.g. US/HIPAA, state health privacy laws)

## Advisory

All compliance findings are framework references, not legal advice.
HIPAA compliance requires a qualified healthcare compliance professional.
This tool flags risks — it does not certify compliance.
