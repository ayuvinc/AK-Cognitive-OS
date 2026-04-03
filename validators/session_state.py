"""
validators/session_state.py — Validates SESSION STATE consistency across files.

Checks:
- tasks/todo.md SESSION STATE and channel.md agree on session status
- Session IDs match between the two files
- If CLOSED, Active task should be "none"

Python 3.8+ stdlib only.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Dict, List, Optional

from validators.base import ValidatorResult, read_session_state


def _parse_channel_state(channel_path: Path) -> Dict[str, str]:
    """Parse session-related fields from *channel.md*.

    Looks for the ``Current Status`` code block with lines like
    ``session: S-003`` and ``active_persona: Architect``.
    """
    if not channel_path.is_file():
        return {}

    try:
        text = channel_path.read_text(encoding="utf-8")
    except OSError:
        return {}

    # Find the Current Status code block.
    heading = re.search(r"##\s+Current\s+Status", text)
    if not heading:
        return {}

    rest = text[heading.end():]
    block = re.search(r"```\s*\n(.*?)\n```", rest, re.DOTALL)
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


def _normalise_status(raw: str) -> str:
    """Normalise status values for comparison.

    Maps common representations to a canonical form:
    ``OPEN``, ``CLOSED``, or the original lowered string.
    """
    s = raw.strip().upper()
    if s in ("OPEN", "ACTIVE", "IN_PROGRESS"):
        return "OPEN"
    if s in ("CLOSED", "NONE", ""):
        return "CLOSED"
    return s


def _extract_session_id(raw: str) -> Optional[str]:
    """Extract a session identifier like ``S-003`` from a string."""
    m = re.search(r"S-\d+", raw)
    return m.group(0) if m else None


def validate(project_dir: Path) -> ValidatorResult:
    issues: List[str] = []
    has_fail = False
    has_warn = False

    todo_path = project_dir / "tasks" / "todo.md"
    channel_path = project_dir / "channel.md"

    # ------------------------------------------------------------------
    # 1. Parse both sources
    # ------------------------------------------------------------------
    todo_state = read_session_state(todo_path)
    channel_state = _parse_channel_state(channel_path)

    if not todo_state and not channel_state:
        issues.append("WARN: Neither tasks/todo.md nor channel.md have parseable session state")
        return ValidatorResult(
            name="session_state", status="WARN", issues=issues
        )

    if not todo_state:
        issues.append("WARN: Could not parse SESSION STATE from tasks/todo.md")
        has_warn = True

    if not channel_state:
        issues.append("WARN: Could not parse session state from channel.md")
        has_warn = True

    # If only one source is available, we can only do limited checks.
    if not todo_state or not channel_state:
        # Check CLOSED → Active_task = none in whichever we have.
        state = todo_state or channel_state
        status_raw = state.get("Status", "") or state.get("session_status", "")
        if _normalise_status(status_raw) == "CLOSED":
            active = state.get("Active_task", "") or state.get("active_persona", "")
            if active and active.lower() not in ("none", "", "\u2014"):
                issues.append(
                    f"WARN: Session is CLOSED but active task/persona is '{active}'"
                )
                has_warn = True
        return ValidatorResult(
            name="session_state",
            status="WARN" if has_warn else "PASS",
            issues=issues,
        )

    # ------------------------------------------------------------------
    # 2. Cross-check status
    # ------------------------------------------------------------------
    todo_status_raw = todo_state.get("Status", "")
    # channel.md uses "session:" as the key for the session ID/status
    channel_session_raw = channel_state.get("session", "")

    # In the template, the channel.md "session" field holds the session ID
    # (e.g., "S-003") or "none".  The todo.md "Status" field holds OPEN/CLOSED.
    # We derive closed/open from channel: "none" means CLOSED.
    todo_norm = _normalise_status(todo_status_raw)

    # channel.md "session: none" means CLOSED; anything else means OPEN.
    channel_norm = "CLOSED" if channel_session_raw.lower() in ("none", "", "\u2014") else "OPEN"

    if todo_norm != channel_norm:
        issues.append(
            f"FAIL: Status mismatch — todo.md says '{todo_status_raw}' "
            f"({todo_norm}), channel.md session='{channel_session_raw}' "
            f"({channel_norm})"
        )
        has_fail = True

    # ------------------------------------------------------------------
    # 3. Cross-check session IDs
    # ------------------------------------------------------------------
    # todo.md may have Session_ID or we infer from Last_updated.
    todo_sid = None
    if "Session_ID" in todo_state:
        todo_sid = _extract_session_id(todo_state["Session_ID"])
    if not todo_sid and "Last_updated" in todo_state:
        todo_sid = _extract_session_id(todo_state["Last_updated"])

    channel_sid = _extract_session_id(channel_session_raw)

    if todo_sid and channel_sid and todo_sid != channel_sid:
        issues.append(
            f"FAIL: Session ID mismatch — todo.md references {todo_sid}, "
            f"channel.md references {channel_sid}"
        )
        has_fail = True

    # ------------------------------------------------------------------
    # 4. If CLOSED, Active task should be "none"
    # ------------------------------------------------------------------
    if todo_norm == "CLOSED":
        active_task = todo_state.get("Active_task", "")
        if active_task and active_task.lower() not in ("none", "", "\u2014"):
            issues.append(
                f"FAIL: Session is CLOSED but Active_task is '{active_task}'"
            )
            has_fail = True

        active_persona = todo_state.get("Active_persona", "")
        if active_persona and active_persona.lower() not in ("none", "", "\u2014"):
            issues.append(
                f"WARN: Session is CLOSED but Active_persona is '{active_persona}'"
            )
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

    return ValidatorResult(name="session_state", status=status, issues=issues)
