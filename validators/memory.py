#!/usr/bin/env python3
"""
memory.py — AK Cognitive OS v4 memory structure validator.

Checks:
  1. memory/MEMORY.md exists and has a valid header
  2. memory/index.json is valid JSON with required fields (entries, last_updated)
  3. Every entry in index.json has all required fields
  4. MEMORY.md entry count matches index.json total (within ±5 tolerance)

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

REQUIRED_ENTRY_FIELDS = {"entry_id", "session", "timestamp_utc", "type", "content", "tags"}
COUNT_TOLERANCE = 5


def validate(project_root: Path) -> ValidatorResult:
    """Check memory/ structure. Returns PASS or WARN (never FAIL in v4.0)."""
    result = ValidatorResult(name="memory", status="PASS")

    memory_dir = project_root / "memory"
    md_path = memory_dir / "MEMORY.md"
    index_path = memory_dir / "index.json"

    # ------------------------------------------------------------------
    # Check 1: memory/MEMORY.md exists and has a valid header
    # ------------------------------------------------------------------
    if not md_path.exists():
        result.status = "WARN"
        result.issues.append("memory/MEMORY.md not found — run session-close to initialise")
    else:
        text = md_path.read_text(encoding="utf-8")
        if not text.startswith("# Memory Index"):
            result.status = "WARN"
            result.issues.append(
                "memory/MEMORY.md missing valid header (expected '# Memory Index' on line 1)"
            )

    # ------------------------------------------------------------------
    # Check 2: memory/index.json is valid JSON with required top-level fields
    # ------------------------------------------------------------------
    if not index_path.exists():
        result.status = "WARN"
        result.issues.append("memory/index.json not found — memory layer not initialised")
        # Cannot continue entry checks without index.json
        return result

    try:
        data = json.loads(index_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        result.status = "WARN"
        result.issues.append(f"memory/index.json is not valid JSON: {e}")
        return result

    if not isinstance(data.get("entries"), list):
        result.status = "WARN"
        result.issues.append("memory/index.json missing 'entries' array field")

    if "last_updated" not in data:
        result.status = "WARN"
        result.issues.append("memory/index.json missing 'last_updated' field")

    if result.status == "WARN" and any("missing" in i for i in result.issues):
        return result

    # ------------------------------------------------------------------
    # Check 3: Every entry has required fields (reads structural fields only)
    # ------------------------------------------------------------------
    entries = data.get("entries", [])
    for entry in entries:
        missing = REQUIRED_ENTRY_FIELDS - set(entry.keys())
        if missing:
            result.status = "WARN"
            result.issues.append(
                f"entry {entry.get('entry_id', 'UNKNOWN')} missing required fields: {sorted(missing)}"
            )

    # ------------------------------------------------------------------
    # Check 4: MEMORY.md entry count vs index.json total (±5 tolerance)
    # ------------------------------------------------------------------
    if md_path.exists():
        md_text = md_path.read_text(encoding="utf-8")
        md_count = sum(1 for line in md_text.splitlines() if line.startswith("MEM-"))
        index_count = len(entries)
        diff = abs(md_count - index_count)
        if diff > COUNT_TOLERANCE:
            result.status = "WARN"
            result.issues.append(
                f"MEMORY.md entry count ({md_count}) differs from index.json total "
                f"({index_count}) by {diff} — exceeds ±{COUNT_TOLERANCE} tolerance"
            )

    return result


def main() -> None:
    """Allow direct execution: python3 validators/memory.py [project_root]"""
    project_root = Path(sys.argv[1]) if len(sys.argv) > 1 else Path(".")
    project_root = project_root.resolve()

    print(f"Validating memory layer at: {project_root}/memory/")
    result = validate(project_root)

    if result.status == "PASS":
        print("[PASS] memory: all checks passed")
    else:
        for issue in result.issues:
            print(f"[WARN] memory: {issue}")

    # v4.0: exit 0 regardless — advisory only
    sys.exit(0)


if __name__ == "__main__":
    main()
