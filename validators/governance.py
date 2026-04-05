"""
validators/governance.py — Validates Phase 10 governance artifacts.

Checks:
  1-5. Phase 10 governance docs exist (role-taxonomy, role-design-rules,
       change-policy, versioning-policy, release-policy) — WARN if missing.
  6.   .ak-cogos-version exists and matches semver pattern — WARN if absent,
       FAIL if malformed.
  7.   framework-improvements.md exists — WARN if absent.
  8.   No governance doc contains placeholder markers — FAIL if found.

Python 3.8+ stdlib only.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import List

from validators.base import ValidatorResult, has_placeholder_markers


_GOVERNANCE_DOCS = [
    "framework/governance/role-taxonomy.md",
    "framework/governance/role-design-rules.md",
    "framework/governance/change-policy.md",
    "framework/governance/versioning-policy.md",
    "framework/governance/release-policy.md",
]

_SEMVER_RE = re.compile(r"^\d+\.\d+\.\d+\s*$")


def validate(project_dir: Path) -> ValidatorResult:
    issues: List[str] = []
    status = "PASS"

    # Checks 1-5: governance doc presence — WARN if any are missing
    for rel_path in _GOVERNANCE_DOCS:
        doc = project_dir / rel_path
        if not doc.is_file():
            issues.append(f"governance doc missing: {rel_path}")
            if status == "PASS":
                status = "WARN"

    # Check 6: .ak-cogos-version — WARN if absent, FAIL if content is malformed
    version_file = project_dir / ".ak-cogos-version"
    if not version_file.is_file():
        issues.append(".ak-cogos-version not found — version stamp missing")
        if status == "PASS":
            status = "WARN"
    else:
        try:
            content = version_file.read_text(encoding="utf-8").strip()
            if not _SEMVER_RE.match(content):
                issues.append(
                    f".ak-cogos-version content does not match semver "
                    f"(got: {content!r})"
                )
                status = "FAIL"
        except OSError as exc:
            issues.append(f"could not read .ak-cogos-version: {exc}")
            status = "FAIL"

    # Check 7: framework-improvements.md — WARN if absent
    improvements = project_dir / "framework-improvements.md"
    if not improvements.is_file():
        issues.append("framework-improvements.md not found — change log missing")
        if status == "PASS":
            status = "WARN"

    # Check 8: no placeholder markers in any existing governance doc
    for rel_path in _GOVERNANCE_DOCS:
        doc = project_dir / rel_path
        if not doc.is_file():
            continue
        try:
            text = doc.read_text(encoding="utf-8")
        except OSError:
            continue
        markers = has_placeholder_markers(text)
        if markers:
            issues.append(
                f"{rel_path} contains placeholder markers: "
                + ", ".join(markers)
            )
            status = "FAIL"

    return ValidatorResult(name="governance", status=status, issues=issues)
