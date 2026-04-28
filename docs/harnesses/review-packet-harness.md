# Harness: review-packet
# AK Cognitive OS

**What this tests:** The `/review-packet` skill assembles a complete Codex review packet and reports packet_ready true only when all mandatory artifacts are present.
**Pass condition:** All envelope fields present, packet_ready true, all mandatory artifacts listed in packet_artifacts.
**Fail condition:** packet_ready true with missing artifacts, or packet_ready false with no failures listed.

---

## Preconditions

Before running this harness:
- [ ] Sprint summary exists for the current sprint
- [ ] `tasks/ux-specs.md` exists if UI was changed
- [ ] `tasks/todo.md` exists with acceptance criteria
- [ ] `channel.md` exists

---

## Input Fixture (Complete — expect PASS)

```
session_id: S-TEST-01
sprint_id: SP-TEST-01
changed_files_manifest: [components/AssigneeDropdown.tsx, app/api/team/route.ts, types/index.ts]
acceptance_criteria_map:
  TASK-001:
    - AC-001: Dropdown renders with team members list
    - AC-002: Selecting member updates assignee_id via PATCH
    - AC-003: Unassigned state shows "No assignee"
    - AC-004: Usable at 375px

Sprint summary: Sprint 1 added assignee dropdown. 3 files changed.
Tests: 14 pass. Build: clean. Lint: 0 errors.
UX specs: present in tasks/ux-specs.md.
Architecture constraints: RLS enforced, server-side validation on assignee_id.
Security sign-off: PASS from /security-sweep run S-TEST-01-SP-TEST-01.
```

Expected: status PASS, packet_ready true, packet_artifacts lists all included items.

---

## Input Fixture (Incomplete — expect FAIL)

```
session_id: S-TEST-01
sprint_id: SP-TEST-01
changed_files_manifest: [components/AssigneeDropdown.tsx]
acceptance_criteria_map: (missing)

Sprint summary: (missing)
Security sign-off: (missing)
```

Expected: status FAIL, packet_ready false, failures[] lists missing sprint summary, criteria map, and security sign-off.

---

## Expected Output Contract

### Envelope checks
- [ ] `run_id` present, matches `review-packet-*` pattern
- [ ] `agent` = "review-packet"
- [ ] `status` is PASS | FAIL | BLOCKED
- [ ] `timestamp_utc` is valid ISO-8601
- [ ] `summary` is a single sentence
- [ ] `failures[]` is present
- [ ] `warnings[]` is present
- [ ] `artifacts_written[]` includes channel.md
- [ ] `next_action` is a single sentence

### Extra fields checks
- [ ] `packet_ready` is true | false
- [ ] `packet_artifacts` is present (non-empty when packet_ready true)

### Business logic checks
- [ ] Complete fixture → packet_ready true, next_action points to Codex review
- [ ] Incomplete fixture → packet_ready false, failures[] names each missing item specifically
- [ ] UI change without ux-specs.md → packet_ready false (UI changed, specs required)

---

## BLOCKED Scenario

```
session_id: (missing)
sprint_id: (missing)
```

Expected:
- [ ] `status: BLOCKED`
- [ ] `failures[]` includes missing inputs

---

## Running This Harness

1. Open review-packet using `/review-packet`.
2. Run the complete fixture — verify packet_ready true.
3. Run the incomplete fixture — verify packet_ready false with specific failures.
4. Run the BLOCKED Scenario.
5. Record result below.

---

## Result Record

```
harness: review-packet
run_date: YYYY-MM-DD
result: PASS | FAIL | PARTIAL
failures: []
notes: ""
```
