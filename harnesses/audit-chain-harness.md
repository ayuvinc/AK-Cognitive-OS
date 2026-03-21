# Harness: audit-chain
# AK Cognitive OS

**What this tests:** A full session audit chain is valid — entries are sequential, unique, append-only, and use correct event_types.
**Pass condition:** All entries have unique run_ids, valid event_types, correct origin fields, and the chain is complete for the session.
**Fail condition:** Duplicate run_id, invalid event_type, missing origin, entries out of expected sequence for the mode.

---

## What the Audit Chain Is

For a complete COMBINED mode session, the audit log must contain entries
in the correct sequence for the declared execution mode:

```
SESSION_OPENED
ARCHITECTURE_COMPLETE
BUILD_COMPLETE
REGRESSION_GUARD_PASSED (or BLOCKED/SKIPPED)
SPRINT_PACKAGED
CODEX_INTAKE_PASSED (or BLOCKED)
CODEX_VERDICT
VERDICT_DISPOSITION (if S1 findings)
QA_APPROVED
SESSION_CLOSED
```

Missing entries = incomplete chain.
Entries out of sequence = process deviation.

---

## Preconditions

Before running this harness:
- [ ] [AUDIT_LOG_PATH] exists with entries from a completed session
- [ ] Session mode is known (COMBINED, SOLO_CLAUDE, etc.)

---

## Harness Checks

### Check 1 — All entries have required fields

For each entry in [AUDIT_LOG_PATH]:
- [ ] `entry_id` present and unique
- [ ] `timestamp_utc` valid ISO-8601
- [ ] `actor` present
- [ ] `event_type` is from the exhaustive list in `schemas/audit-log-schema.md`
- [ ] `origin` present (claude-core | codex-core | combined)
- [ ] `status` present (PASS | FAIL | BLOCKED)

### Check 2 — No duplicate run_ids

- [ ] All `entry_id` values are unique in the log

### Check 3 — Event types are valid

- [ ] Every `event_type` matches an entry in the exhaustive list
- [ ] No invented event types present

### Check 4 — Origin is consistent with mode

For SOLO_CLAUDE sessions:
- [ ] No entries with `origin: codex-core`
- [ ] All entries use `origin: claude-core`

For COMBINED sessions:
- [ ] CODEX_VERDICT entry has `origin: codex-core`
- [ ] Session-open/close entries have `origin: claude-core`

For degraded sessions:
- [ ] All entries have `[DEGRADED: {mode}]` note in summary

### Check 5 — Chain completeness (COMBINED mode)

For a COMBINED mode session, verify these event_types are present:
- [ ] SESSION_OPENED
- [ ] ARCHITECTURE_COMPLETE
- [ ] BUILD_COMPLETE
- [ ] REGRESSION_GUARD_PASSED or REGRESSION_GUARD_BLOCKED
- [ ] SPRINT_PACKAGED
- [ ] CODEX_INTAKE_PASSED or CODEX_INTAKE_BLOCKED
- [ ] CODEX_VERDICT
- [ ] QA_APPROVED or QA_REJECTED
- [ ] SESSION_CLOSED

---

## Running This Harness

1. After a completed session, open [AUDIT_LOG_PATH].
2. Run each check above manually.
3. Flag any failures with the entry_id of the offending line.
4. Record result below.

---

## Result Record

```
harness: audit-chain
run_date: YYYY-MM-DD
session_id: [session being validated]
mode: COMBINED | SOLO_CLAUDE | SOLO_CODEX
result: PASS | FAIL | PARTIAL
check_1_fields: PASS | FAIL
check_2_unique_ids: PASS | FAIL
check_3_event_types: PASS | FAIL
check_4_origin_consistency: PASS | FAIL
check_5_chain_completeness: PASS | FAIL
failures: []
notes: ""
```
