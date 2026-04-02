# Compliance Data Privacy Schema
# validation: markdown-contract-only | machine-validated

## Extra Fields

```yaml
compliance_findings:
  - id: string              # e.g. COMP-DP-001-01
    severity: S0 | S1 | S2
    sub_persona: "data-privacy"
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
sub_personas_activated: ["data-privacy"]
ak_decision_required: true|false
```

## Severity Contract

| Severity | Compliance meaning | Status rule |
|---|---|---|
| S0 | Hard block — legal/regulatory privacy violation or critical risk | status must be BLOCKED |
| S1 | Significant privacy gap — AK decision required | status must be FAIL; ak_decision_required: true |
| S2 | Advisory — log and defer | status may be PASS; warning added |

## S0 Examples

- No consent mechanism for personal data collection (GDPR Art. 6/7)
- User data sent to third party without legal basis
- Personal data stored without retention policy and no deletion mechanism
- Cross-border data transfer without adequate safeguards (GDPR Art. 46)
- Unauthenticated access to records containing personal data

## S1 Examples

- Missing privacy policy page before launch
- Cookie banner absent but no active tracking yet
- Data retention period undefined but no user data stored yet
- No data processing agreement with a data processor
- DSAR (data subject access request) flow not implemented

## S2 Examples

- Privacy policy wording outdated
- Cookie categories not granular enough
- DPA template needs annual review
- Cookie policy references outdated regulation version
- Consent withdrawal flow exists but UI could be clearer

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
- `jurisdictions` — which jurisdictions apply (e.g. EU/GDPR, US/CCPA, UK/UK-GDPR)

## Advisory

All compliance findings are framework references, not legal advice.
Always consult a qualified legal professional for privacy compliance decisions.
