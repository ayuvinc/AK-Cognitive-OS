#!/usr/bin/env python3
"""
validators/feedback.py — AK Cognitive OS v4 feedback entry validator.

Checks type-specific required fields for feedback entries written by Phase 2
sources (qa-run → type="outcome", risk-manager → type="decision") in
memory/index.json.

Checks:
  1. For each type="outcome" entry: task_id non-empty, outcome in VALID_OUTCOMES,
     persona non-empty.
  2. For each type="decision" entry: task_id non-empty, persona non-empty.
  3. Other entry types are skipped without warning.

Severity: WARNING in v4.0 (status=WARN, exits 0 via runner). FAIL in v4.1.

Auto-discovered by validators/runner.py — exposes validate(project_root) -> ValidatorResult.
"""

from __future__ import annotations

import json
import sys
from pathlib import Path

# Allow direct execution as well as import by runner.py
_pkg_root = Path(__file__).resolve().parent.parent
if str(_pkg_root) not in sys.path:
    sys.path.insert(0, str(_pkg_root))

from validators.base import ValidatorResult  # noqa: E402

# Must match VALID_OUTCOMES in mcp-servers/memory_server.py exactly.
VALID_OUTCOMES = {"PASS", "FAIL", "PARTIAL", "DEFERRED"}


def validate(project_root: Path) -> ValidatorResult:
    """Check feedback entry fields in memory/index.json.

    Returns PASS or WARN (never FAIL in v4.0). Returns PASS immediately
    if index.json is missing or contains no entries.
    """
    result = ValidatorResult(name="feedback", status="PASS")

    index_path = project_root / "memory" / "index.json"

    # ------------------------------------------------------------------
    # Early exit: no index or empty — nothing to validate
    # ------------------------------------------------------------------
    if not index_path.exists():
        return result

    try:
        data = json.loads(index_path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        # Malformed index is caught by memory.py; skip here to avoid double-warn
        return result

    entries = data.get("entries", [])
    if not entries:
        return result

    # ------------------------------------------------------------------
    # Check each feedback entry type
    # ------------------------------------------------------------------
    for entry in entries:
        etype = entry.get("type", "")
        entry_id = entry.get("entry_id", "UNKNOWN")

        if etype == "outcome":
            _check_outcome(entry, entry_id, result)
        elif etype == "decision":
            _check_decision(entry, entry_id, result)
        # All other types are not feedback entries — skip silently

    return result


def _check_outcome(entry: dict, entry_id: str, result: ValidatorResult) -> None:
    """Validate required fields for type='outcome' entries (written by qa-run)."""
    if not entry.get("task_id"):
        result.status = "WARN"
        result.issues.append(
            f"outcome entry {entry_id}: task_id is empty — expected a TASK-ID"
        )

    outcome = entry.get("outcome")
    if not outcome:
        result.status = "WARN"
        result.issues.append(
            f"outcome entry {entry_id}: outcome field is missing or empty"
        )
    elif outcome not in VALID_OUTCOMES:
        result.status = "WARN"
        result.issues.append(
            f"outcome entry {entry_id}: outcome '{outcome}' not in VALID_OUTCOMES "
            f"({', '.join(sorted(VALID_OUTCOMES))})"
        )

    if not entry.get("persona"):
        result.status = "WARN"
        result.issues.append(
            f"outcome entry {entry_id}: persona is empty — expected 'QA'"
        )


def _check_decision(entry: dict, entry_id: str, result: ValidatorResult) -> None:
    """Validate required fields for type='decision' entries (written by risk-manager)."""
    if not entry.get("task_id"):
        result.status = "WARN"
        result.issues.append(
            f"decision entry {entry_id}: task_id is empty — expected a TASK-ID "
            f"or 'cross-cutting'"
        )

    if not entry.get("persona"):
        result.status = "WARN"
        result.issues.append(
            f"decision entry {entry_id}: persona is empty — expected 'risk-manager'"
        )


def main() -> None:
    """Allow direct execution: python3 validators/feedback.py [project_root]"""
    project_root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")
    project_root = project_root.resolve()

    print(f"Validating feedback entries at: {project_root}/memory/index.json")
    result = validate(project_root)

    if result.status == "PASS":
        print("[PASS] feedback: all checks passed")
    else:
        for issue in result.issues:
            print(f"[WARN] feedback: {issue}")

    # v4.0: exit 0 regardless — advisory only
    sys.exit(0)


if __name__ == "__main__":
    main()
