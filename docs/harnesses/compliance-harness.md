# Harness: compliance
# AK Cognitive OS

**What this tests:** The `/compliance` persona correctly applies S0/S1/S2 severity, blocks on S0, and produces valid envelope + extra fields.
**Pass condition:** S0 scenario returns BLOCKED; S1 scenario returns FAIL with ak_decision_required; S2-only scenario returns PASS with warnings.
**Fail condition:** S0 not blocked, S1 not flagged for AK decision, severity downgraded, advisory disclaimer missing.

---

## Preconditions

Before running this harness:
- [ ] A project context with personal data collection is available (or use the fixture below)
- [ ] Jurisdiction specified (EU for this harness)

---

## Scenario 1 — S0 Trigger (must return BLOCKED)

### Input Fixture

```
Session: S-TEST-01
Review scope: New user registration feature. Collects email, name, date of birth.
Data is stored in the database in plaintext. No privacy policy exists. No consent mechanism.
Jurisdictions: European Union
Sub-personas: data-privacy, pii-handler
```

### Expected Output

- [ ] `status: BLOCKED`
- [ ] `s0_count` ≥ 1
- [ ] `compliance_findings` includes at least one S0 finding
- [ ] S0 finding has `blocking: YES`
- [ ] S0 finding includes `advisory: "This is a compliance flag, not legal advice."`
- [ ] `ak_decision_required: true` (implied by S0)
- [ ] `failures[]` contains S0 finding reference
- [ ] `artifacts_written[]` includes [AUDIT_LOG_PATH] (COMPLIANCE_S0_BLOCKED entry)

---

## Scenario 2 — S1 Only (must return FAIL with AK decision)

### Input Fixture

```
Session: S-TEST-01
Review scope: App collects email for newsletter. Consent checkbox is present and opt-in.
Data is encrypted. No privacy policy page has been published yet. Jurisdiction: European Union.
Sub-personas: data-privacy
```

### Expected Output

- [ ] `status: FAIL`
- [ ] `s0_count: 0`
- [ ] `s1_count` ≥ 1
- [ ] `ak_decision_required: true`
- [ ] S1 finding has `blocking: AK_DECISION`
- [ ] Advisory disclaimer on each finding
- [ ] `failures[]` contains S1 finding reference

---

## Scenario 3 — S2 Only (must return PASS with warnings)

### Input Fixture

```
Session: S-TEST-01
Review scope: Existing privacy policy — last updated 18 months ago. Wording references
an outdated GDPR article number. No active violations. Jurisdiction: European Union.
Sub-personas: data-privacy
```

### Expected Output

- [ ] `status: PASS`
- [ ] `s0_count: 0`
- [ ] `s1_count: 0`
- [ ] `s2_count` ≥ 1
- [ ] `warnings[]` non-empty
- [ ] `ak_decision_required: false`
- [ ] S2 finding has `blocking: NO`

---

## Severity Downgrade Test (must reject)

If you manually try to present an S0 scenario but label findings as S1:
- [ ] Compliance persona should not accept the downgrade
- [ ] Either re-flags as S0 or produces a SCHEMA_VIOLATION

---

## Running This Harness

1. Open compliance using `/compliance`.
2. Run Scenario 1 — verify BLOCKED.
3. Run Scenario 2 — verify FAIL + ak_decision_required.
4. Run Scenario 3 — verify PASS + warnings.
5. Record result below.

---

## Result Record

```
harness: compliance
run_date: YYYY-MM-DD
result: PASS | FAIL | PARTIAL
scenario_1: PASS | FAIL
scenario_2: PASS | FAIL
scenario_3: PASS | FAIL
notes: ""
```
