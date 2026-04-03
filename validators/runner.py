#!/usr/bin/env python3
"""
validators/runner.py — CLI entry point for AK-Cognitive-OS ground-truth validators.

Usage
-----
    python -m validators.runner /path/to/project
    python -m validators.runner /path/to/project --only planning_docs,session_state
    python -m validators.runner /path/to/project --format json --strict

Python 3.8+ stdlib only.
"""

from __future__ import annotations

import argparse
import importlib
import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path
from types import ModuleType
from typing import Callable, Dict, List, Optional, Tuple

# Ensure the package root is importable when invoked as a script.
_VALIDATORS_DIR = Path(__file__).resolve().parent
if str(_VALIDATORS_DIR.parent) not in sys.path:
    sys.path.insert(0, str(_VALIDATORS_DIR.parent))

from validators.base import ValidatorResult  # noqa: E402


# ---------------------------------------------------------------------------
# Colour helpers (degrade gracefully to plain text)
# ---------------------------------------------------------------------------

_SUPPORTS_COLOUR: bool = (
    hasattr(sys.stdout, "isatty")
    and sys.stdout.isatty()
    and os.environ.get("NO_COLOR") is None
    and os.environ.get("TERM") != "dumb"
)

_COLOURS: Dict[str, str] = {
    "PASS":  "\033[32m",   # green
    "WARN":  "\033[33m",   # yellow
    "FAIL":  "\033[31m",   # red
    "RESET": "\033[0m",
    "BOLD":  "\033[1m",
}


def _c(label: str) -> str:
    if not _SUPPORTS_COLOUR:
        return ""
    return _COLOURS.get(label, "")


# ---------------------------------------------------------------------------
# Validator discovery
# ---------------------------------------------------------------------------

_SKIP_MODULES = {"__init__", "base", "runner"}


def _discover_validators() -> List[Tuple[str, Callable[[Path], ValidatorResult]]]:
    """Import every ``.py`` module in the validators package that exposes a
    ``validate(project_dir: Path) -> ValidatorResult`` callable.

    Returns a list of ``(module_name, validate_fn)`` tuples sorted by name.
    """
    found: List[Tuple[str, Callable[[Path], ValidatorResult]]] = []

    for py_file in sorted(_VALIDATORS_DIR.glob("*.py")):
        mod_name = py_file.stem
        if mod_name in _SKIP_MODULES:
            continue
        qualified = f"validators.{mod_name}"
        try:
            mod: ModuleType = importlib.import_module(qualified)
        except Exception as exc:  # noqa: BLE001
            print(
                f"{_c('WARN')}[WARN]{_c('RESET')} Could not import "
                f"{qualified}: {exc}",
                file=sys.stderr,
            )
            continue

        fn = getattr(mod, "validate", None)
        if callable(fn):
            found.append((mod_name, fn))

    return found


# ---------------------------------------------------------------------------
# Result rendering
# ---------------------------------------------------------------------------


def _render_text(results: List[ValidatorResult], overall: str) -> str:
    lines: List[str] = []
    lines.append("")
    lines.append(f"{_c('BOLD')}AK-Cognitive-OS Validator Report{_c('RESET')}")
    lines.append("=" * 40)

    for r in results:
        colour = _c(r.status)
        reset = _c("RESET")
        lines.append(f"  {colour}[{r.status}]{reset} {r.name}")
        for issue in r.issues:
            lines.append(f"         - {issue}")

    lines.append("-" * 40)
    colour = _c(overall)
    reset = _c("RESET")
    lines.append(f"  Overall: {colour}{overall}{reset}")
    lines.append("")
    return "\n".join(lines)


def _render_json(
    results: List[ValidatorResult],
    overall: str,
    project_dir: Path,
) -> str:
    report = {
        "run_id": datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ"),
        "project": str(project_dir.resolve()),
        "timestamp_utc": datetime.now(timezone.utc).isoformat(),
        "overall": overall,
        "results": [
            {
                "name": r.name,
                "status": r.status,
                "issues": r.issues,
            }
            for r in results
        ],
    }
    return json.dumps(report, indent=2)


# ---------------------------------------------------------------------------
# Aggregation
# ---------------------------------------------------------------------------


def _aggregate(results: List[ValidatorResult]) -> str:
    statuses = {r.status for r in results}
    if "FAIL" in statuses:
        return "FAIL"
    if "WARN" in statuses:
        return "WARN"
    return "PASS"


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------


def _build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="validators",
        description="AK-Cognitive-OS ground-truth validators",
    )
    parser.add_argument(
        "project_dir",
        type=Path,
        help="Path to the project root (directory containing CLAUDE.md)",
    )
    parser.add_argument(
        "--only",
        type=str,
        default=None,
        help="Comma-separated list of validator names to run (e.g. planning_docs,session_state)",
    )
    parser.add_argument(
        "--warn-only",
        action="store_true",
        default=False,
        help="Downgrade all FAIL results to WARN (useful during early project stages)",
    )
    parser.add_argument(
        "--strict",
        action="store_true",
        default=False,
        help="Treat WARN as a failure (exit code 1)",
    )
    parser.add_argument(
        "--format",
        choices=["text", "json"],
        default="text",
        dest="output_format",
        help="Output format (default: text)",
    )
    return parser


def main(argv: Optional[List[str]] = None) -> int:
    parser = _build_parser()
    args = parser.parse_args(argv)

    project_dir: Path = args.project_dir.resolve()
    if not project_dir.is_dir():
        print(f"Error: {project_dir} is not a directory.", file=sys.stderr)
        return 1

    # Discover validators
    all_validators = _discover_validators()
    if not all_validators:
        print("No validators found.", file=sys.stderr)
        return 1

    # Filter by --only
    if args.only:
        requested = {n.strip() for n in args.only.split(",")}
        available_names = {name for name, _ in all_validators}
        unknown = requested - available_names
        if unknown:
            print(
                f"Warning: unknown validators ignored: {', '.join(sorted(unknown))}",
                file=sys.stderr,
            )
        all_validators = [(n, fn) for n, fn in all_validators if n in requested]
        if not all_validators:
            print("No matching validators to run.", file=sys.stderr)
            return 1

    # Run validators
    results: List[ValidatorResult] = []
    for name, fn in all_validators:
        try:
            result = fn(project_dir)
        except Exception as exc:  # noqa: BLE001
            result = ValidatorResult(
                name=name,
                status="FAIL",
                issues=[f"Validator crashed: {exc}"],
            )
        results.append(result)

    # --warn-only: downgrade FAIL -> WARN
    if args.warn_only:
        for r in results:
            if r.status == "FAIL":
                r.status = "WARN"

    overall = _aggregate(results)

    # Render output
    if args.output_format == "json":
        print(_render_json(results, overall, project_dir))
    else:
        print(_render_text(results, overall))

    # Exit code
    if overall == "FAIL":
        return 1
    if overall == "WARN" and args.strict:
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
