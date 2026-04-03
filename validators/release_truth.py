"""
validators/release_truth.py — Validates release-truth.md against actual code.

Checks:
- Features marked "real" in the release-truth feature status table have
  corresponding source files under src/.
- Feature name keywords are used to search for matching routes, components,
  or modules.

Python 3.8+ stdlib only.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Dict, List, Set

from validators.base import ValidatorResult


# Matches a markdown table row.
_TABLE_ROW_RE = re.compile(r"^\|(.+)\|$")
_SEPARATOR_RE = re.compile(r"^\|[\s\-:|]+\|$")


def _parse_feature_table(filepath: Path) -> List[Dict[str, str]]:
    """Parse the Feature Status table from *release-truth.md*.

    Returns a list of row dicts.
    """
    if not filepath.is_file():
        return []

    try:
        text = filepath.read_text(encoding="utf-8")
    except OSError:
        return []

    lines = text.splitlines()

    # Look for table header containing "Feature" and "Status"
    header_idx = -1
    for i, line in enumerate(lines):
        stripped = line.strip()
        m = _TABLE_ROW_RE.match(stripped)
        if m and "Feature" in m.group(1) and "Status" in m.group(1):
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
    for line in lines[header_idx + 2:]:
        stripped = line.strip()
        m = _TABLE_ROW_RE.match(stripped)
        if not m:
            break
        if _SEPARATOR_RE.match(stripped):
            continue
        cells = [c.strip() for c in m.group(1).split("|")]
        row: Dict[str, str] = {}
        for idx, key in enumerate(header_cells):
            row[key] = cells[idx] if idx < len(cells) else ""
        rows.append(row)

    return rows


def _feature_keywords(feature_name: str) -> List[str]:
    """Derive search keywords from a feature name.

    Splits on whitespace and common punctuation, lowercases, and filters out
    very short or common stopwords.
    """
    stopwords = {
        "a", "an", "the", "and", "or", "of", "for", "to", "in", "on",
        "with", "is", "at", "by", "from", "&", "+", "-",
    }
    tokens = re.split(r"[\s/\-_&+,]+", feature_name.lower())
    return [t for t in tokens if len(t) > 2 and t not in stopwords]


def _scan_src_for_keywords(src_dir: Path, keywords: List[str]) -> bool:
    """Return True if any source file under *src_dir* contains at least one keyword
    in its path or content.

    Uses a two-pass approach: first check filenames, then check file content
    for the first 100 candidate files to keep runtime bounded.
    """
    if not src_dir.is_dir():
        return False

    # Collect source files (common extensions).
    extensions = {".ts", ".tsx", ".js", ".jsx", ".py", ".prisma", ".sql"}
    source_files: List[Path] = []
    try:
        for fpath in src_dir.rglob("*"):
            if fpath.suffix in extensions and fpath.is_file():
                source_files.append(fpath)
    except OSError:
        return False

    if not source_files:
        return False

    # Pass 1: filename match
    for fpath in source_files:
        name_lower = fpath.stem.lower()
        for kw in keywords:
            if kw in name_lower:
                return True

    # Pass 2: content match (bounded to first 200 files)
    for fpath in source_files[:200]:
        try:
            content = fpath.read_text(encoding="utf-8", errors="replace").lower()
        except OSError:
            continue
        for kw in keywords:
            if kw in content:
                return True

    return False


def validate(project_dir: Path) -> ValidatorResult:
    issues: List[str] = []
    has_fail = False

    release_truth = project_dir / "docs" / "release-truth.md"

    # If release-truth.md doesn't exist, that is fine (not yet needed).
    if not release_truth.is_file():
        return ValidatorResult(
            name="release_truth",
            status="PASS",
            issues=["docs/release-truth.md not present (not required yet)"],
        )

    rows = _parse_feature_table(release_truth)
    if not rows:
        return ValidatorResult(
            name="release_truth",
            status="PASS",
            issues=["No parseable feature table found in release-truth.md"],
        )

    # Locate src directory.
    src_dir = project_dir / "src"

    real_features = [
        r for r in rows
        if r.get("Status", "").strip().lower() == "real"
    ]

    if not real_features:
        return ValidatorResult(
            name="release_truth",
            status="PASS",
            issues=[],
        )

    if not src_dir.is_dir():
        # All features marked real but no src/ directory.
        for feat in real_features:
            name = feat.get("Feature", "unknown")
            issues.append(
                f"FAIL: Feature '{name}' marked as 'real' but src/ directory "
                f"does not exist"
            )
        return ValidatorResult(
            name="release_truth",
            status="FAIL",
            issues=issues,
        )

    for feat in real_features:
        name = feat.get("Feature", "unknown")
        keywords = _feature_keywords(name)
        if not keywords:
            continue
        if not _scan_src_for_keywords(src_dir, keywords):
            issues.append(
                f"FAIL: Feature '{name}' marked as 'real' but no matching "
                f"source files found in src/ (searched for: {', '.join(keywords)})"
            )
            has_fail = True

    if has_fail:
        status = "FAIL"
    else:
        status = "PASS"

    return ValidatorResult(name="release_truth", status=status, issues=issues)
