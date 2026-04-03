"""
validators/task_traceability.py — Validates task-to-design traceability.

Checks:
- Every IN_PROGRESS / READY_FOR_QA task appears in the traceability matrix
- Every LLD file referenced in the matrix exists on disk
- Matrix should exist once the project has enough active tasks

Python 3.8+ stdlib only.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Dict, List, Set, Tuple

from validators.base import ValidatorResult, parse_todo_tasks


# Matches a markdown table row and captures pipe-delimited cells.
_TABLE_ROW_RE = re.compile(r"^\|(.+)\|$")
# Separator row like | --- | --- | --- |
_SEPARATOR_RE = re.compile(r"^\|[\s\-:|]+\|$")


def _parse_matrix_table(filepath: Path) -> List[Dict[str, str]]:
    """Parse the traceability matrix table from *filepath*.

    Returns a list of row dicts keyed by header column names.
    """
    if not filepath.is_file():
        return []

    try:
        lines = filepath.read_text(encoding="utf-8").splitlines()
    except OSError:
        return []

    # Find the table header row (first row matching the table pattern
    # that is followed by a separator row).
    header_idx = -1
    for i, line in enumerate(lines):
        stripped = line.strip()
        if _TABLE_ROW_RE.match(stripped):
            # Check if next line is a separator row.
            if i + 1 < len(lines) and _SEPARATOR_RE.match(lines[i + 1].strip()):
                header_idx = i
                break

    if header_idx < 0:
        return []

    header_cells = [
        c.strip()
        for c in _TABLE_ROW_RE.match(lines[header_idx].strip()).group(1).split("|")  # type: ignore[union-attr]
    ]

    rows: List[Dict[str, str]] = []
    for line in lines[header_idx + 2:]:  # skip header + separator
        stripped = line.strip()
        m = _TABLE_ROW_RE.match(stripped)
        if not m:
            break  # table ended
        if _SEPARATOR_RE.match(stripped):
            continue
        cells = [c.strip() for c in m.group(1).split("|")]
        row: Dict[str, str] = {}
        for idx, key in enumerate(header_cells):
            row[key] = cells[idx] if idx < len(cells) else ""
        rows.append(row)

    return rows


def _extract_task_ids(cell: str) -> Set[str]:
    """Extract TASK-NNN identifiers from a comma/space separated cell."""
    return set(re.findall(r"TASK-\d+", cell))


def _extract_lld_files(cell: str) -> List[str]:
    """Extract LLD file paths from a table cell.

    Accepts paths like ``docs/lld/feature.md`` or bare filenames like
    ``feature.md`` (assumed under ``docs/lld/``).
    """
    paths: List[str] = []
    # Strip markdown link syntax if present: [text](path)
    for raw in re.findall(r"[^\s,;]+\.md", cell):
        raw = raw.strip("`")
        paths.append(raw)
    return paths


def validate(project_dir: Path) -> ValidatorResult:
    issues: List[str] = []
    has_fail = False
    has_warn = False

    todo_path = project_dir / "tasks" / "todo.md"
    tasks = parse_todo_tasks(todo_path)
    non_archived = [t for t in tasks if t["status"] != "ARCHIVED"]
    active_statuses = {"IN_PROGRESS", "READY_FOR_QA"}
    active_tasks: List[Dict[str, object]] = [
        t for t in tasks if t["status"] in active_statuses
    ]

    matrix_path = project_dir / "docs" / "traceability-matrix.md"

    # ------------------------------------------------------------------
    # 1. If matrix does not exist
    # ------------------------------------------------------------------
    if not matrix_path.is_file():
        if len(non_archived) > 5:
            issues.append(
                f"WARN: docs/traceability-matrix.md missing but "
                f"{len(non_archived)} non-archived tasks exist"
            )
            has_warn = True
        return ValidatorResult(
            name="task_traceability",
            status="WARN" if has_warn else "PASS",
            issues=issues,
        )

    # ------------------------------------------------------------------
    # 2. Parse matrix
    # ------------------------------------------------------------------
    rows = _parse_matrix_table(matrix_path)
    if not rows:
        issues.append("WARN: Traceability matrix table could not be parsed")
        return ValidatorResult(
            name="task_traceability", status="WARN", issues=issues
        )

    # Collect all task IDs mentioned in the matrix.
    matrix_task_ids: Set[str] = set()
    lld_refs: List[Tuple[str, str]] = []  # (row_label, lld_path)

    for row in rows:
        # Try common column names for task IDs.
        task_cell = row.get("Task ID(s)", "") or row.get("Task IDs", "") or row.get("Task ID", "")
        matrix_task_ids |= _extract_task_ids(task_cell)

        # LLD file references.
        lld_cell = row.get("LLD File", "") or row.get("LLD", "")
        row_label = row.get("User Problem", "") or row.get("Scope Item", "") or "unknown row"
        for lld in _extract_lld_files(lld_cell):
            lld_refs.append((row_label, lld))

    # ------------------------------------------------------------------
    # 3. Check every active task appears in matrix
    # ------------------------------------------------------------------
    for task in active_tasks:
        tid = str(task["id"])
        if tid not in matrix_task_ids:
            issues.append(
                f"WARN: {tid} ({task['status']}) not found in traceability matrix"
            )
            has_warn = True

    # ------------------------------------------------------------------
    # 4. Check every referenced LLD file exists
    # ------------------------------------------------------------------
    for row_label, lld_rel in lld_refs:
        # Normalise path: if it does not start with docs/lld/, prepend it.
        if not lld_rel.startswith("docs/lld/") and not lld_rel.startswith("docs\\lld\\"):
            lld_rel = f"docs/lld/{lld_rel}"
        lld_full = project_dir / lld_rel
        if not lld_full.is_file():
            issues.append(
                f"FAIL: LLD file referenced in matrix but missing: {lld_rel} "
                f"(row: {row_label})"
            )
            has_fail = True

    # ------------------------------------------------------------------
    # Determine overall status
    # ------------------------------------------------------------------
    if has_fail:
        status = "FAIL"
    elif has_warn:
        status = "WARN"
    else:
        status = "PASS"

    return ValidatorResult(
        name="task_traceability", status=status, issues=issues
    )
