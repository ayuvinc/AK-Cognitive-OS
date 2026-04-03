"""
validators/planning_docs.py — Validates existence and quality of planning documents.

Checks:
- Required planning docs exist (problem-definition, scope-brief, hld, etc.)
- Metadata headers are present and have required fields
- Confirmed docs do not contain placeholder markers
- Critical docs are confirmed before sprint work begins
- LLD README exists

Python 3.8+ stdlib only.
"""

from __future__ import annotations

from pathlib import Path
from typing import List

from validators.base import (
    ValidatorResult,
    has_placeholder_markers,
    parse_metadata_header,
    parse_todo_tasks,
)


# Files that MUST exist for the project to proceed.
_CRITICAL_FILES = [
    "docs/problem-definition.md",
    "docs/scope-brief.md",
]

# Files that SHOULD exist once the project has active tasks.
_RECOMMENDED_FILES = [
    "docs/hld.md",
    "docs/assumptions.md",
    "docs/decision-log.md",
]

# Metadata fields that every planning doc must have.
_REQUIRED_META_KEYS = {"Status", "Source", "Owner"}


def validate(project_dir: Path) -> ValidatorResult:
    issues: List[str] = []
    has_fail = False
    has_warn = False

    todo_path = project_dir / "tasks" / "todo.md"
    tasks = parse_todo_tasks(todo_path)
    non_archived = [t for t in tasks if t["status"] != "ARCHIVED"]
    in_progress = [
        t for t in tasks if t["status"] in ("IN_PROGRESS", "READY_FOR_QA")
    ]

    # ------------------------------------------------------------------
    # 1. Critical files must exist
    # ------------------------------------------------------------------
    for rel in _CRITICAL_FILES:
        fpath = project_dir / rel
        if not fpath.is_file():
            issues.append(f"FAIL: Required file missing: {rel}")
            has_fail = True

    # ------------------------------------------------------------------
    # 2. Recommended files — WARN if missing
    # ------------------------------------------------------------------
    for rel in _RECOMMENDED_FILES:
        fpath = project_dir / rel
        if not fpath.is_file():
            issues.append(f"WARN: Recommended file missing: {rel}")
            has_warn = True

    # ------------------------------------------------------------------
    # 3. Metadata header checks on all existing planning docs
    # ------------------------------------------------------------------
    all_doc_rels = _CRITICAL_FILES + _RECOMMENDED_FILES
    for rel in all_doc_rels:
        fpath = project_dir / rel
        if not fpath.is_file():
            continue

        header = parse_metadata_header(fpath)
        if not header:
            issues.append(f"WARN: No metadata header found in {rel}")
            has_warn = True
            continue

        missing_keys = _REQUIRED_META_KEYS - set(header.keys())
        if missing_keys:
            issues.append(
                f"WARN: {rel} metadata missing fields: {', '.join(sorted(missing_keys))}"
            )
            has_warn = True

        # If status is "confirmed", check for placeholder markers.
        status = header.get("Status", "").lower()
        if status == "confirmed":
            try:
                content = fpath.read_text(encoding="utf-8")
            except OSError:
                continue
            markers = has_placeholder_markers(content)
            if markers:
                issues.append(
                    f"FAIL: {rel} has Status: confirmed but contains "
                    f"placeholders: {', '.join(markers)}"
                )
                has_fail = True

    # ------------------------------------------------------------------
    # 4. Critical docs must be confirmed before IN_PROGRESS work
    # ------------------------------------------------------------------
    if in_progress:
        for rel in _CRITICAL_FILES:
            fpath = project_dir / rel
            if not fpath.is_file():
                continue  # already flagged above
            header = parse_metadata_header(fpath)
            status = header.get("Status", "").lower()
            if status != "confirmed":
                issues.append(
                    f"FAIL: {rel} must have Status: confirmed when tasks "
                    f"are IN_PROGRESS (current: {header.get('Status', 'unknown')})"
                )
                has_fail = True

    # ------------------------------------------------------------------
    # 5. HLD required when >3 non-ARCHIVED tasks exist
    # ------------------------------------------------------------------
    hld_path = project_dir / "docs" / "hld.md"
    if len(non_archived) > 3 and not hld_path.is_file():
        issues.append(
            f"WARN: docs/hld.md missing but {len(non_archived)} active tasks exist"
        )
        has_warn = True

    # ------------------------------------------------------------------
    # 6. LLD README must exist
    # ------------------------------------------------------------------
    lld_readme = project_dir / "docs" / "lld" / "README.md"
    if not lld_readme.is_file():
        issues.append("WARN: docs/lld/README.md missing")
        has_warn = True

    # ------------------------------------------------------------------
    # Determine overall status
    # ------------------------------------------------------------------
    if has_fail:
        status = "FAIL"
    elif has_warn:
        status = "WARN"
    else:
        status = "PASS"

    return ValidatorResult(name="planning_docs", status=status, issues=issues)
