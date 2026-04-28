#!/usr/bin/env python3
"""
memory_server.py — MCP Server for AK Cognitive OS persistent memory layer.

Exposes three tools:
  write()    — append a memory entry to index.json and MEMORY.md
  query()    — filtered retrieval from index.json (type, tags, outcome, limit)
  summary()  — dense 20-line digest for session-open context load

Storage layout (all under PROJECT_ROOT/memory/):
  index.json  — machine-readable manifest; source of truth for all entries
  MEMORY.md   — human-readable digest; last 50 entries (trimmed by session-close)

Transport: stdio
Env:
  PROJECT_ROOT — path to project root (default: ".")

Security:
  - Local process only, no network calls.
  - Content field is capped at 500 chars to discourage raw data dumps.
  - Entry content should contain task IDs and outcome codes only — not raw user
    data or PII. This is a convention enforced by documentation, not code.
  - All writes are also logged by auto-audit-log.sh via the existing hook.
"""

import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

try:
    import mcp.server.stdio
    from mcp.server import Server
    from mcp.types import Tool, TextContent
except ImportError:
    sys.stderr.write("ERROR: mcp package not installed. Run: pip install mcp>=1.0.0\n")
    sys.exit(1)

PROJECT_ROOT = Path(os.environ.get("PROJECT_ROOT", ".")).resolve()
MEMORY_DIR = PROJECT_ROOT / "memory"
INDEX_PATH = MEMORY_DIR / "index.json"
MARKDOWN_PATH = MEMORY_DIR / "MEMORY.md"

VALID_TYPES = {"decision", "outcome", "lesson", "task_history", "audit_event"}
VALID_OUTCOMES = {"PASS", "FAIL", "PARTIAL", "DEFERRED"}
VALID_SEVERITIES = {"S0", "S1", "S2"}
CONTENT_MAX_CHARS = 500
SUMMARY_MAX_ENTRIES = 20
MARKDOWN_MAX_ENTRIES = 50


# --------------------------------------------------------------------------- #
# Index helpers
# --------------------------------------------------------------------------- #

def _load_index() -> dict:
    """Load memory/index.json; return empty structure if missing or malformed."""
    if not INDEX_PATH.exists():
        return {"entries": [], "last_updated": "", "total": 0}
    try:
        data = json.loads(INDEX_PATH.read_text(encoding="utf-8"))
        if not isinstance(data.get("entries"), list):
            raise ValueError("entries field is not a list")
        return data
    except (json.JSONDecodeError, ValueError, OSError):
        return {"entries": [], "last_updated": "", "total": 0}


def _save_index(data: dict) -> None:
    MEMORY_DIR.mkdir(parents=True, exist_ok=True)
    INDEX_PATH.write_text(json.dumps(data, indent=2, ensure_ascii=False), encoding="utf-8")


def _next_entry_id(entries: list) -> str:
    """Generate next MEM-NNN id using max(existing numeric IDs) + 1.

    Using max rather than len avoids collision when entries are manually removed
    or reordered — the next ID is always higher than any existing one.
    """
    if not entries:
        return "MEM-001"
    nums = []
    for e in entries:
        eid = e.get("entry_id", "")
        parts = eid.split("-")
        if len(parts) == 2:
            try:
                nums.append(int(parts[1]))
            except ValueError:
                pass
    n = (max(nums) + 1) if nums else (len(entries) + 1)
    return f"MEM-{n:03d}"


def _entry_to_digest_line(entry: dict) -> str:
    """Format one entry as a single dense line for MEMORY.md and summary tool."""
    date = entry.get("timestamp_utc", "")[:10]  # YYYY-MM-DD
    etype = entry.get("type", "")
    task = entry.get("task_id") or "-"
    outcome = entry.get("outcome") or "-"
    persona = entry.get("persona") or "-"
    tags = ",".join(entry.get("tags") or []) or "-"
    entry_id = entry.get("entry_id", "")
    # Format: MEM-001 | 2026-04-28 | outcome | TASK-042 | FAIL | architect | auth,boundary
    return f"{entry_id} | {date} | {etype} | {task} | {outcome} | {persona} | {tags}"


def _rebuild_markdown(entries: list) -> None:
    """Write MEMORY.md from the last MARKDOWN_MAX_ENTRIES entries in index."""
    MEMORY_DIR.mkdir(parents=True, exist_ok=True)
    recent = entries[-MARKDOWN_MAX_ENTRIES:] if len(entries) > MARKDOWN_MAX_ENTRIES else entries
    now = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    lines = [
        f"# Memory Index — AK-Cognitive-OS",
        f"Last updated: {now}",
        f"Total entries: {len(entries)}",
        f"Showing: last {len(recent)}",
        "",
    ]
    for e in reversed(recent):  # most recent first in the file
        lines.append(_entry_to_digest_line(e))
    MARKDOWN_PATH.write_text("\n".join(lines) + "\n", encoding="utf-8")


# --------------------------------------------------------------------------- #
# Tool implementations
# --------------------------------------------------------------------------- #

def write(
    type: str,
    content: str,
    tags: list = None,
    task_id: str = None,
    outcome: str = None,
    persona: str = None,
    session: str = None,
    severity: str = None,
    linked_entries: list = None,
) -> dict:
    """Append a new memory entry to index.json and update MEMORY.md."""
    if not type:
        return {"success": False, "error": "type is required"}
    if type not in VALID_TYPES:
        return {"success": False, "error": f"type must be one of: {', '.join(sorted(VALID_TYPES))}"}
    if not content:
        return {"success": False, "error": "content is required"}
    if len(content) > CONTENT_MAX_CHARS:
        return {"success": False, "error": f"content exceeds {CONTENT_MAX_CHARS} chars — summarise to task IDs and outcome codes only"}
    if outcome and outcome not in VALID_OUTCOMES:
        return {"success": False, "error": f"outcome must be one of: {', '.join(sorted(VALID_OUTCOMES))}"}
    if severity and severity not in VALID_SEVERITIES:
        return {"success": False, "error": f"severity must be one of: {', '.join(sorted(VALID_SEVERITIES))}"}

    index = _load_index()
    entry_id = _next_entry_id(index["entries"])
    timestamp = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    entry = {
        "entry_id": entry_id,
        "session": session or "",
        "timestamp_utc": timestamp,
        "type": type,
        "persona": persona or "",
        "task_id": task_id or None,
        "content": content,
        "tags": tags or [],
        "outcome": outcome or None,
        "severity": severity or None,
        "linked_entries": linked_entries or [],
    }

    index["entries"].append(entry)
    index["last_updated"] = timestamp
    index["total"] = len(index["entries"])

    try:
        _save_index(index)
        _rebuild_markdown(index["entries"])
    except OSError as e:
        return {"success": False, "error": f"WRITE_FAILED: {e}"}

    return {"success": True, "entry_id": entry_id, "total": index["total"]}


def query(
    type: str = None,
    tags: list = None,
    outcome: str = None,
    persona: str = None,
    limit: int = 20,
) -> list:
    """Return filtered entries from index.json, most recent first."""
    index = _load_index()
    entries = index.get("entries", [])

    if type:
        entries = [e for e in entries if e.get("type") == type]
    if outcome:
        entries = [e for e in entries if e.get("outcome") == outcome]
    if persona:
        entries = [e for e in entries if e.get("persona") == persona]
    if tags:
        # All specified tags must be present (intersection filter)
        tag_set = set(tags)
        entries = [e for e in entries if tag_set.issubset(set(e.get("tags") or []))]

    # Most recent first
    entries = list(reversed(entries))
    return entries[:limit]


def summary(limit: int = SUMMARY_MAX_ENTRIES) -> list:
    """Return a dense list of digest lines, most recent first, capped at limit."""
    limit = min(limit, SUMMARY_MAX_ENTRIES)
    index = _load_index()
    entries = index.get("entries", [])
    recent = list(reversed(entries))[:limit]
    return [_entry_to_digest_line(e) for e in recent]


# --------------------------------------------------------------------------- #
# MCP server wiring
# --------------------------------------------------------------------------- #

server = Server("ak-memory")


@server.list_tools()
async def list_tools():
    return [
        Tool(
            name="write",
            description=(
                "Append a memory entry to index.json and MEMORY.md. "
                "Content must contain task IDs and outcome codes only — no raw user data, no PII. "
                "Returns {success, entry_id, total, error?}."
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "type": {
                        "type": "string",
                        "description": "Entry type: decision | outcome | lesson | task_history | audit_event",
                    },
                    "content": {
                        "type": "string",
                        "description": f"Structured description — task IDs and outcome codes only. Max {CONTENT_MAX_CHARS} chars.",
                    },
                    "tags": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "Searchable labels (e.g. ['auth', 'qa-fail', 'boundary'])",
                    },
                    "task_id": {
                        "type": "string",
                        "description": "Related task ID (e.g. TASK-042) or null",
                    },
                    "outcome": {
                        "type": "string",
                        "description": "Outcome: PASS | FAIL | PARTIAL | DEFERRED (or omit)",
                    },
                    "persona": {
                        "type": "string",
                        "description": "Persona that produced this entry (e.g. architect, qa)",
                    },
                    "session": {
                        "type": "string",
                        "description": "Session identifier (e.g. session-25)",
                    },
                    "severity": {
                        "type": "string",
                        "description": "Risk severity if relevant: S0 | S1 | S2 (or omit)",
                    },
                    "linked_entries": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "Related entry IDs (e.g. ['MEM-003', 'MEM-007'])",
                    },
                },
                "required": ["type", "content"],
            },
        ),
        Tool(
            name="query",
            description=(
                "Retrieve memory entries filtered by type, tags, outcome, or persona. "
                "Returns list of full entry objects, most recent first."
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "type": {
                        "type": "string",
                        "description": "Filter by entry type (optional)",
                    },
                    "tags": {
                        "type": "array",
                        "items": {"type": "string"},
                        "description": "All specified tags must be present (intersection filter)",
                    },
                    "outcome": {
                        "type": "string",
                        "description": "Filter by outcome: PASS | FAIL | PARTIAL | DEFERRED",
                    },
                    "persona": {
                        "type": "string",
                        "description": "Filter by persona (e.g. architect, qa)",
                    },
                    "limit": {
                        "type": "integer",
                        "description": "Max results to return (default: 20)",
                        "default": 20,
                    },
                },
                "required": [],
            },
        ),
        Tool(
            name="summary",
            description=(
                f"Return a dense digest of the last {SUMMARY_MAX_ENTRIES} memory entries "
                "as a list of single-line strings. Each line: "
                "MEM-NNN | YYYY-MM-DD | type | task_id | outcome | persona | tags. "
                "Designed for session-open context load — stays under context budget."
            ),
            inputSchema={
                "type": "object",
                "properties": {
                    "limit": {
                        "type": "integer",
                        "description": f"Max entries to return (default: {SUMMARY_MAX_ENTRIES}, hard cap: {SUMMARY_MAX_ENTRIES})",
                        "default": SUMMARY_MAX_ENTRIES,
                    },
                },
                "required": [],
            },
        ),
    ]


@server.call_tool()
async def call_tool(name: str, arguments: dict):
    if name == "write":
        result = write(
            type=arguments.get("type", ""),
            content=arguments.get("content", ""),
            tags=arguments.get("tags"),
            task_id=arguments.get("task_id"),
            outcome=arguments.get("outcome"),
            persona=arguments.get("persona"),
            session=arguments.get("session"),
            severity=arguments.get("severity"),
            linked_entries=arguments.get("linked_entries"),
        )
    elif name == "query":
        result = query(
            type=arguments.get("type"),
            tags=arguments.get("tags"),
            outcome=arguments.get("outcome"),
            persona=arguments.get("persona"),
            limit=int(arguments.get("limit", 20)),
        )
    elif name == "summary":
        result = summary(limit=int(arguments.get("limit", SUMMARY_MAX_ENTRIES)))
    else:
        result = {"error": f"Unknown tool: {name}"}

    return [TextContent(type="text", text=json.dumps(result, indent=2))]


async def main():
    async with mcp.server.stdio.stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, server.create_initialization_options())


if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
