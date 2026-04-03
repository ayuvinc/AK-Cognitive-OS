"""
validators/base.py — Shared utilities for AK-Cognitive-OS ground-truth validators.

All helpers operate on pathlib.Path objects and parse the markdown formats
defined in the project-template directory of the framework.

Python 3.8+ stdlib only.
"""

from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path
from typing import Dict, List, Optional


# ---------------------------------------------------------------------------
# ValidatorResult — return type for every validate() function
# ---------------------------------------------------------------------------

@dataclass
class ValidatorResult:
    """Outcome of a single validator run."""
    name: str
    status: str  # "PASS", "WARN", or "FAIL"
    issues: List[str] = field(default_factory=list)


# ---------------------------------------------------------------------------
# Metadata header parsing
# ---------------------------------------------------------------------------

_HEADER_RE = re.compile(r"^---\s*\n(.*?)\n---", re.DOTALL)


def parse_metadata_header(filepath: Path) -> Dict[str, str]:
    """Read the YAML-like metadata block between ``---`` markers.

    Returns a dict whose keys are normalised (spaces replaced with
    underscores, leading/trailing whitespace stripped).  An empty dict
    is returned when the file does not exist or has no header.
    """
    if not filepath.is_file():
        return {}

    try:
        text = filepath.read_text(encoding="utf-8")
    except OSError:
        return {}

    match = _HEADER_RE.match(text)
    if not match:
        return {}

    result: Dict[str, str] = {}
    for line in match.group(1).splitlines():
        line = line.strip()
        if not line or ":" not in line:
            continue
        key, _, value = line.partition(":")
        key = key.strip().replace(" ", "_")
        value = value.strip()
        result[key] = value
    return result


# ---------------------------------------------------------------------------
# SESSION STATE parsing from tasks/todo.md
# ---------------------------------------------------------------------------

_SESSION_STATE_RE = re.compile(
    r"```\s*\n(.*?)\n```",
    re.DOTALL,
)


def read_session_state(todo_path: Path) -> Dict[str, str]:
    """Parse the SESSION STATE code block from *tasks/todo.md*.

    Expected keys: Status, Session_ID, Active_task, Active_persona,
    Blocking_issue, Last_updated.  Missing keys are omitted.
    """
    if not todo_path.is_file():
        return {}

    try:
        text = todo_path.read_text(encoding="utf-8")
    except OSError:
        return {}

    # Locate the SESSION STATE heading, then grab the first code block after it.
    state_heading = re.search(r"##\s+SESSION\s+STATE", text)
    if not state_heading:
        return {}

    rest = text[state_heading.end():]
    block = _SESSION_STATE_RE.search(rest)
    if not block:
        return {}

    result: Dict[str, str] = {}
    for line in block.group(1).splitlines():
        line = line.strip()
        if not line or ":" not in line:
            continue
        key, _, value = line.partition(":")
        key = key.strip().replace(" ", "_")
        value = value.strip()
        result[key] = value
    return result


# ---------------------------------------------------------------------------
# Task line parsing from tasks/todo.md
# ---------------------------------------------------------------------------

# Matches lines like:
#   - [ ] TASK-105 | READY_FOR_QA | Junior Dev | Description text
#   - [x] TASK-102 | ARCHIVED | Junior Dev | Description text
_TASK_LINE_RE = re.compile(
    r"^-\s+\[(?P<check>[xX ])\]\s+"
    r"(?P<id>TASK-\d+)\s*\|\s*"
    r"(?P<status>[^|]+?)\s*\|\s*"
    r"(?P<assignee>[^|]+?)\s*\|\s*"
    r"(?P<description>.+?)\s*$"
)


def parse_todo_tasks(todo_path: Path) -> List[Dict[str, object]]:
    """Parse task lines from *tasks/todo.md*.

    Returns a list of dicts with keys: id, status, assignee, description,
    checked (bool).
    """
    if not todo_path.is_file():
        return []

    try:
        lines = todo_path.read_text(encoding="utf-8").splitlines()
    except OSError:
        return []

    tasks: List[Dict[str, object]] = []
    for line in lines:
        m = _TASK_LINE_RE.match(line.strip())
        if m:
            tasks.append({
                "id": m.group("id"),
                "status": m.group("status").strip(),
                "assignee": m.group("assignee").strip(),
                "description": m.group("description").strip(),
                "checked": m.group("check").lower() == "x",
            })
    return tasks


# ---------------------------------------------------------------------------
# Project root discovery
# ---------------------------------------------------------------------------


def find_project_root(start_path: Path) -> Optional[Path]:
    """Walk up from *start_path* until a directory containing ``CLAUDE.md`` is
    found.  Returns that directory, or ``None``.
    """
    current = start_path.resolve()
    while True:
        if (current / "CLAUDE.md").is_file():
            return current
        parent = current.parent
        if parent == current:
            return None
        current = parent


# ---------------------------------------------------------------------------
# Placeholder / hallucination marker detection
# ---------------------------------------------------------------------------

_PLACEHOLDER_PATTERNS: List[re.Pattern[str]] = [
    re.compile(r"\[PLACEHOLDER\]", re.IGNORECASE),
    re.compile(r"\[TODO\]", re.IGNORECASE),
    re.compile(r"\[TBD\]", re.IGNORECASE),
    re.compile(r"<FILL\s+IN>", re.IGNORECASE),
    re.compile(r"YYYY-MM-DD"),
]


def has_placeholder_markers(content: str) -> List[str]:
    """Return a list of placeholder / hallucination markers found in *content*."""
    found: List[str] = []
    for pat in _PLACEHOLDER_PATTERNS:
        matches = pat.findall(content)
        if matches:
            # Deduplicate identical matches but keep the first occurrence text.
            for m in matches:
                if m not in found:
                    found.append(m)
    return found


# ---------------------------------------------------------------------------
# Markdown section parser
# ---------------------------------------------------------------------------

_HEADING_RE = re.compile(r"^(#{1,6})\s+(.+)$", re.MULTILINE)


def load_markdown_sections(filepath: Path) -> Dict[str, str]:
    """Parse a markdown file into ``{heading_text: body_content}`` pairs.

    The heading text is stripped of the ``#`` prefix.  The body is the text
    between one heading and the next (or end-of-file).  A leading section
    before any heading is keyed as ``"_preamble"``.
    """
    if not filepath.is_file():
        return {}

    try:
        text = filepath.read_text(encoding="utf-8")
    except OSError:
        return {}

    sections: Dict[str, str] = {}
    headings = list(_HEADING_RE.finditer(text))

    if not headings:
        sections["_preamble"] = text.strip()
        return sections

    # Capture text before the first heading.
    preamble = text[: headings[0].start()].strip()
    if preamble:
        sections["_preamble"] = preamble

    for i, match in enumerate(headings):
        heading_text = match.group(2).strip()
        start = match.end()
        end = headings[i + 1].start() if i + 1 < len(headings) else len(text)
        body = text[start:end].strip()
        sections[heading_text] = body
    return sections
