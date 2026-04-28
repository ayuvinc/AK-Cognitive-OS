#!/usr/bin/env python3
"""
validators/signal_engine.py — AK Cognitive OS v4 Signal Engine.

Two modes:
  Validate mode (auto-discovered by runner.py):
    validate(project_root) -> ValidatorResult
    Checks signals/active.json schema — required fields, enum values, non-empty evidence.

  Generate mode (invoked by auto-signal-check.sh or directly):
    python3 validators/signal_engine.py --generate [project_root]
    Runs 6 detectors against current inputs, upserts signals/active.json.

6 Detectors:
  DEBT_ACCUMULATION  — S1+ OPEN risk in risk-register.md identified > 14 days ago
  LESSON_RECURRENCE  — lesson tag appearing 3+ times in tasks/lessons.md
  FAILURE_PATTERN    — same persona with 3+ type=outcome outcome=FAIL in memory
  RISK_HOTSPOT       — 3+ FAIL entries concentrated in same session in memory
  VELOCITY_DROP      — 2+ consecutive DEFERRED task_history entries in memory
  COVERAGE_GAP       — >=5 task_history entries but 0 outcome entries in memory

Input sources (never reads content field from memory entries):
  memory/index.json       — outcome, decision, task_history entries (structural keys only)
  tasks/risk-register.md  — Status, Severity, Identified fields
  tasks/lessons.md        — [TAG] pattern extraction only

Severity: EXIT 0 always — advisory only in v4.0. FAIL enforcement in v4.1.
"""

from __future__ import annotations

import json
import re
import sys
from datetime import date, datetime, timezone
from pathlib import Path
from typing import Any, Dict, List

_pkg_root = Path(__file__).resolve().parent.parent
if str(_pkg_root) not in sys.path:
    sys.path.insert(0, str(_pkg_root))

from validators.base import ValidatorResult  # noqa: E402

# ---------------------------------------------------------------------------
# Module-level constants — must match v4 architecture doc exactly
# ---------------------------------------------------------------------------

VALID_SIGNAL_TYPES = {
    "RISK_HOTSPOT",
    "FAILURE_PATTERN",
    "VELOCITY_DROP",
    "DEBT_ACCUMULATION",
    "COVERAGE_GAP",
    "LESSON_RECURRENCE",
}

VALID_SEVERITIES = {"HIGH", "MEDIUM", "LOW"}
VALID_STATUSES = {"ACTIVE", "RESOLVED", "ACKNOWLEDGED"}

# Detection thresholds — lower these in v4.1 once data volume justifies it
DEBT_ACCUMULATION_DAYS = 14   # S1+ open longer than this → DEBT_ACCUMULATION
RECURRENCE_THRESHOLD = 3      # tag appearances → LESSON_RECURRENCE
FAILURE_THRESHOLD = 3         # FAIL entries per persona → FAILURE_PATTERN
HOTSPOT_THRESHOLD = 3         # FAIL entries per session → RISK_HOTSPOT
VELOCITY_DROP_THRESHOLD = 2   # consecutive DEFERRED sessions → VELOCITY_DROP
COVERAGE_MIN_TASKS = 5        # min task_history entries before COVERAGE_GAP can fire
EVIDENCE_CAP = 10             # max evidence items per signal

# Required fields on every signal entry
REQUIRED_SIGNAL_FIELDS = {
    "signal_id", "signal_type", "severity", "evidence",
    "affected_area", "recommended_action", "persona_to_notify",
    "auto_escalate", "status", "generated_at",
}


# ---------------------------------------------------------------------------
# Validate mode — auto-discovered by runner.py
# ---------------------------------------------------------------------------

def validate(project_root: Path) -> ValidatorResult:
    """Check signals/active.json schema.

    Returns PASS immediately if active.json is absent (normal for new projects).
    Returns WARN for schema violations — never FAIL in v4.0.
    """
    result = ValidatorResult(name="signal_engine", status="PASS")
    signals_path = project_root / "signals" / "active.json"

    if not signals_path.exists():
        return result

    try:
        data = json.loads(signals_path.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        result.status = "WARN"
        result.issues.append("signals/active.json is not valid JSON")
        return result

    if not isinstance(data, dict):
        result.status = "WARN"
        result.issues.append("signals/active.json: top-level value must be a JSON object")
        return result

    signals = data.get("signals", [])
    if not isinstance(signals, list):
        result.status = "WARN"
        result.issues.append("signals/active.json: 'signals' field must be an array")
        return result

    for sig in signals:
        if not isinstance(sig, dict):
            result.status = "WARN"
            result.issues.append("signals/active.json: signal entry is not a JSON object")
            continue
        _validate_signal_entry(sig, result)

    return result


def _validate_signal_entry(sig: Dict[str, Any], result: ValidatorResult) -> None:
    """Check one signal entry — appends WARN issues to result."""
    sig_id = sig.get("signal_id", "UNKNOWN")

    for required_field in REQUIRED_SIGNAL_FIELDS:
        if required_field not in sig:
            result.status = "WARN"
            result.issues.append(
                f"signal {sig_id}: missing required field '{required_field}'"
            )

    stype = sig.get("signal_type", "")
    if stype and stype not in VALID_SIGNAL_TYPES:
        result.status = "WARN"
        result.issues.append(
            f"signal {sig_id}: signal_type '{stype}' not in VALID_SIGNAL_TYPES "
            f"({', '.join(sorted(VALID_SIGNAL_TYPES))})"
        )

    severity = sig.get("severity", "")
    if severity and severity not in VALID_SEVERITIES:
        result.status = "WARN"
        result.issues.append(
            f"signal {sig_id}: severity '{severity}' not in VALID_SEVERITIES"
        )

    status_val = sig.get("status", "")
    if status_val and status_val not in VALID_STATUSES:
        result.status = "WARN"
        result.issues.append(
            f"signal {sig_id}: status '{status_val}' not in VALID_STATUSES"
        )

    # Active signals must have evidence
    evidence = sig.get("evidence", [])
    if sig.get("status") == "ACTIVE" and isinstance(evidence, list) and len(evidence) == 0:
        result.status = "WARN"
        result.issues.append(
            f"signal {sig_id}: ACTIVE signal has empty evidence array"
        )


# ---------------------------------------------------------------------------
# Generate mode — runs all 6 detectors and upserts signals/active.json
# ---------------------------------------------------------------------------

def generate(project_root: Path) -> None:
    """Run all detectors and write signals/active.json.

    Creates signals/ and signals/history/ if they do not exist.
    Upserts by (signal_type, affected_area) — no duplicate signals.
    """
    signals_dir = project_root / "signals"
    history_dir = signals_dir / "history"
    signals_path = signals_dir / "active.json"

    signals_dir.mkdir(exist_ok=True)
    history_dir.mkdir(exist_ok=True)

    # Load existing signals (start fresh on malformed file or unexpected shape)
    existing: List[Dict[str, Any]] = []
    if signals_path.exists():
        try:
            parsed = json.loads(signals_path.read_text(encoding="utf-8"))
            if isinstance(parsed, dict):
                raw = parsed.get("signals", [])
                existing = [s for s in raw if isinstance(s, dict)] if isinstance(raw, list) else []
        except (json.JSONDecodeError, OSError):
            existing = []

    # Run all 6 detectors
    triggered: List[Dict[str, Any]] = []
    triggered.extend(_detect_debt_accumulation(project_root))
    triggered.extend(_detect_lesson_recurrence(project_root))
    triggered.extend(_detect_failure_pattern(project_root))
    triggered.extend(_detect_risk_hotspot(project_root))
    triggered.extend(_detect_velocity_drop(project_root))
    triggered.extend(_detect_coverage_gap(project_root))

    updated = _upsert_signals(existing, triggered)

    now = _now_utc()
    output: Dict[str, Any] = {
        "signals": updated,
        "generated_at": now,
        "schema_version": "4.0",
    }
    signals_path.write_text(json.dumps(output, indent=2), encoding="utf-8")


def _upsert_signals(
    existing: List[Dict[str, Any]],
    triggered: List[Dict[str, Any]],
) -> List[Dict[str, Any]]:
    """Merge triggered signals into existing list.

    Rules:
    - Same (signal_type, affected_area) already in existing → update evidence + timestamp.
    - New combination → assign next sequential SIG-NNN id.
    - Existing ACTIVE signal no longer triggered → set status=RESOLVED.
    - RESOLVED/ACKNOWLEDGED signals not re-triggered → kept as-is.
    """
    triggered_keys = {
        (s["signal_type"], s["affected_area"]) for s in triggered
    }

    # Find the highest existing signal number for sequential ID assignment
    max_id = 0
    for sig in existing:
        try:
            max_id = max(max_id, int(sig.get("signal_id", "SIG-0").split("-")[1]))
        except (IndexError, ValueError):
            pass

    existing_by_key: Dict[tuple, Dict[str, Any]] = {
        (s.get("signal_type", ""), s.get("affected_area", "")): s
        for s in existing
    }

    result: List[Dict[str, Any]] = []

    # Add or update triggered signals
    for new_sig in triggered:
        key = (new_sig["signal_type"], new_sig["affected_area"])
        if key in existing_by_key:
            merged = existing_by_key[key].copy()
            merged["evidence"] = new_sig["evidence"]
            merged["generated_at"] = new_sig["generated_at"]
            merged["recommended_action"] = new_sig["recommended_action"]
            merged["status"] = "ACTIVE"
            result.append(merged)
        else:
            max_id += 1
            new_sig["signal_id"] = f"SIG-{max_id:03d}"
            result.append(new_sig)

    # Preserve existing signals not re-triggered
    for key, sig in existing_by_key.items():
        if key not in triggered_keys:
            if sig.get("status") == "ACTIVE":
                resolved = sig.copy()
                resolved["status"] = "RESOLVED"
                result.append(resolved)
            else:
                result.append(sig)

    return result


# ---------------------------------------------------------------------------
# Detector: DEBT_ACCUMULATION
# Reads: tasks/risk-register.md (Status, Severity, Identified fields only)
# ---------------------------------------------------------------------------

def _detect_debt_accumulation(project_root: Path) -> List[Dict[str, Any]]:
    """S1/S0 OPEN risks identified more than DEBT_ACCUMULATION_DAYS ago."""
    register_path = project_root / "tasks" / "risk-register.md"
    if not register_path.exists():
        return []

    try:
        text = register_path.read_text(encoding="utf-8")
    except OSError:
        return []

    today = date.today()
    signals: List[Dict[str, Any]] = []

    # Split on risk block headers — each starts with ### RISK-NNN
    blocks = re.split(r"(?=^### RISK-)", text, flags=re.MULTILINE)
    for block in blocks:
        risk_id_match = re.search(r"(RISK-\d+)", block)
        if not risk_id_match:
            continue
        risk_id = risk_id_match.group(1)

        status_m = re.search(r"^-\s+Status:\s+(\S+)", block, re.MULTILINE)
        severity_m = re.search(r"^-\s+Severity:\s+(\S+)", block, re.MULTILINE)
        identified_m = re.search(r"^-\s+Identified:\s+(\d{4}-\d{2}-\d{2})", block, re.MULTILINE)

        if not (status_m and severity_m and identified_m):
            continue

        if status_m.group(1).strip() != "OPEN":
            continue
        severity = severity_m.group(1).strip()
        if severity not in ("S0", "S1"):
            continue

        try:
            identified_date = date.fromisoformat(identified_m.group(1).strip())
        except ValueError:
            continue

        age_days = (today - identified_date).days
        if age_days > DEBT_ACCUMULATION_DAYS:
            signals.append(_make_signal(
                signal_type="DEBT_ACCUMULATION",
                severity="HIGH",
                evidence=[{
                    "source": "risk-register",
                    "entry_id": risk_id,
                    "detail": f"{severity} OPEN {age_days} days",
                }],
                affected_area=risk_id,
                recommended_action=(
                    f"Resolve or formally accept {risk_id} — "
                    f"{severity} risk open {age_days} days"
                ),
                persona_to_notify="architect",
            ))

    return signals


# ---------------------------------------------------------------------------
# Detector: LESSON_RECURRENCE
# Reads: tasks/lessons.md ([TAG] pattern only — no lesson text)
# ---------------------------------------------------------------------------

def _detect_lesson_recurrence(project_root: Path) -> List[Dict[str, Any]]:
    """Tags appearing RECURRENCE_THRESHOLD+ times across lesson entries."""
    lessons_path = project_root / "tasks" / "lessons.md"
    if not lessons_path.exists():
        return []

    try:
        text = lessons_path.read_text(encoding="utf-8")
    except OSError:
        return []

    # Extract [TAG] markers from lesson lines only (lines starting with "- ")
    # Does not read lesson text content.
    tag_counts: Dict[str, int] = {}
    tag_evidence: Dict[str, List[Dict[str, Any]]] = {}

    for line in text.splitlines():
        stripped = line.strip()
        if not stripped.startswith("- "):
            continue
        # Matches [HOOK], [PROCESS], [MCP], [ARCHITECTURE], etc. (uppercase only)
        tags = re.findall(r"\[([A-Z][A-Z_]+)\]", stripped)
        date_m = re.match(r"-\s+(\d{4}-\d{2}-\d{2}):", stripped)
        entry_date = date_m.group(1) if date_m else "unknown"

        for tag in tags:
            tag_counts[tag] = tag_counts.get(tag, 0) + 1
            if tag not in tag_evidence:
                tag_evidence[tag] = []
            if len(tag_evidence[tag]) < EVIDENCE_CAP:
                tag_evidence[tag].append({
                    "source": "lessons",
                    "entry_id": entry_date,
                    "detail": f"[{tag}] occurrence #{tag_counts[tag]}",
                })

    return [
        _make_signal(
            signal_type="LESSON_RECURRENCE",
            severity="LOW",
            evidence=tag_evidence[tag],
            affected_area=tag,
            recommended_action=(
                f"[{tag}] lesson repeated {count}x — "
                "consider structural fix to prevent recurrence"
            ),
            persona_to_notify="architect",
        )
        for tag, count in tag_counts.items()
        if count >= RECURRENCE_THRESHOLD
    ]


# ---------------------------------------------------------------------------
# Detector: FAILURE_PATTERN
# Reads: memory/index.json (type, outcome, persona, entry_id, session — not content)
# ---------------------------------------------------------------------------

def _detect_failure_pattern(project_root: Path) -> List[Dict[str, Any]]:
    """Same persona with FAILURE_THRESHOLD+ type=outcome outcome=FAIL entries."""
    entries = _load_memory_entries(project_root)
    fail_entries = [
        e for e in entries
        if e.get("type") == "outcome" and e.get("outcome") == "FAIL"
    ]
    if not fail_entries:
        return []

    persona_counts: Dict[str, int] = {}
    persona_evidence: Dict[str, List[Dict[str, Any]]] = {}

    for e in fail_entries:
        persona = e.get("persona", "unknown")
        persona_counts[persona] = persona_counts.get(persona, 0) + 1
        if persona not in persona_evidence:
            persona_evidence[persona] = []
        if len(persona_evidence[persona]) < EVIDENCE_CAP:
            persona_evidence[persona].append({
                "source": "memory",
                "entry_id": e.get("entry_id", "UNKNOWN"),
                "detail": f"FAIL by {persona} in {e.get('session', 'unknown')}",
            })

    return [
        _make_signal(
            signal_type="FAILURE_PATTERN",
            severity="HIGH",
            evidence=persona_evidence[persona],
            affected_area=persona,
            recommended_action=(
                f"Investigate recurring FAIL pattern for {persona} "
                f"— {count} failures in memory"
            ),
            persona_to_notify="architect",
        )
        for persona, count in persona_counts.items()
        if count >= FAILURE_THRESHOLD
    ]


# ---------------------------------------------------------------------------
# Detector: RISK_HOTSPOT
# Reads: memory/index.json (type, outcome, session, entry_id — not content)
# ---------------------------------------------------------------------------

def _detect_risk_hotspot(project_root: Path) -> List[Dict[str, Any]]:
    """HOTSPOT_THRESHOLD+ FAIL entries concentrated in same session."""
    entries = _load_memory_entries(project_root)
    fail_entries = [
        e for e in entries
        if e.get("outcome") == "FAIL" and e.get("type") in ("outcome", "decision")
    ]
    if not fail_entries:
        return []

    session_counts: Dict[str, int] = {}
    session_evidence: Dict[str, List[Dict[str, Any]]] = {}

    for e in fail_entries:
        session = e.get("session", "unknown")
        session_counts[session] = session_counts.get(session, 0) + 1
        if session not in session_evidence:
            session_evidence[session] = []
        if len(session_evidence[session]) < EVIDENCE_CAP:
            session_evidence[session].append({
                "source": "memory",
                "entry_id": e.get("entry_id", "UNKNOWN"),
                "detail": f"FAIL ({e.get('type', 'unknown')}) in {session}",
            })

    return [
        _make_signal(
            signal_type="RISK_HOTSPOT",
            severity="HIGH",
            evidence=session_evidence[session],
            affected_area=session,
            recommended_action=(
                f"Concentrated failures in {session} ({count} FAIL entries) "
                "— review for systemic issue"
            ),
            persona_to_notify="risk-manager",
        )
        for session, count in session_counts.items()
        if count >= HOTSPOT_THRESHOLD
    ]


# ---------------------------------------------------------------------------
# Detector: VELOCITY_DROP
# Reads: memory/index.json (type, outcome, session, timestamp_utc — not content)
# ---------------------------------------------------------------------------

def _detect_velocity_drop(project_root: Path) -> List[Dict[str, Any]]:
    """VELOCITY_DROP_THRESHOLD+ consecutive DEFERRED task_history entries."""
    entries = _load_memory_entries(project_root)
    history_entries = sorted(
        [e for e in entries if e.get("type") == "task_history"],
        key=lambda e: e.get("timestamp_utc", ""),
    )
    if not history_entries:
        return []

    # Count trailing consecutive DEFERRED entries
    consecutive = 0
    deferred_tail: List[Dict[str, Any]] = []
    for e in history_entries:
        if e.get("outcome") == "DEFERRED":
            consecutive += 1
            deferred_tail.append(e)
        else:
            consecutive = 0
            deferred_tail = []

    if consecutive < VELOCITY_DROP_THRESHOLD:
        return []

    evidence = [
        {
            "source": "memory",
            "entry_id": e.get("entry_id", "UNKNOWN"),
            "detail": f"DEFERRED in {e.get('session', 'unknown')}",
        }
        for e in deferred_tail[:EVIDENCE_CAP]
    ]
    return [_make_signal(
        signal_type="VELOCITY_DROP",
        severity="MEDIUM",
        evidence=evidence,
        affected_area="task-delivery",
        recommended_action=(
            f"Velocity drop: {consecutive} consecutive DEFERRED sessions "
            "— review scope or blockers"
        ),
        persona_to_notify="architect",
    )]


# ---------------------------------------------------------------------------
# Detector: COVERAGE_GAP
# Reads: memory/index.json (type, entry_id, session — not content)
# ---------------------------------------------------------------------------

def _detect_coverage_gap(project_root: Path) -> List[Dict[str, Any]]:
    """>=COVERAGE_MIN_TASKS task_history entries but 0 outcome entries."""
    entries = _load_memory_entries(project_root)
    task_history_count = sum(1 for e in entries if e.get("type") == "task_history")
    outcome_count = sum(1 for e in entries if e.get("type") == "outcome")

    if task_history_count < COVERAGE_MIN_TASKS or outcome_count > 0:
        return []

    evidence = [
        {
            "source": "memory",
            "entry_id": e.get("entry_id", "UNKNOWN"),
            "detail": f"task_history in {e.get('session', 'unknown')}, no outcome entries",
        }
        for e in entries
        if e.get("type") == "task_history"
    ][:EVIDENCE_CAP]

    return [_make_signal(
        signal_type="COVERAGE_GAP",
        severity="MEDIUM",
        evidence=evidence,
        affected_area="qa-feedback",
        recommended_action=(
            "No QA outcome entries in memory despite task history "
            "— check qa-run feedback write path"
        ),
        persona_to_notify="qa",
    )]


# ---------------------------------------------------------------------------
# Shared helpers
# ---------------------------------------------------------------------------

def _load_memory_entries(project_root: Path) -> List[Dict[str, Any]]:
    """Read entries from memory/index.json. Accesses structural keys only — never content."""
    index_path = project_root / "memory" / "index.json"
    if not index_path.exists():
        return []
    try:
        parsed = json.loads(index_path.read_text(encoding="utf-8"))
        if not isinstance(parsed, dict):
            return []
        raw = parsed.get("entries", [])
        if not isinstance(raw, list):
            return []
        return [e for e in raw if isinstance(e, dict)]
    except (json.JSONDecodeError, OSError):
        return []


def _make_signal(
    signal_type: str,
    severity: str,
    evidence: List[Dict[str, Any]],
    affected_area: str,
    recommended_action: str,
    persona_to_notify: str,
) -> Dict[str, Any]:
    """Build a signal dict. signal_id is set to SIG-PENDING and replaced in _upsert_signals."""
    return {
        "signal_id": "SIG-PENDING",
        "signal_type": signal_type,
        "severity": severity,
        "evidence": evidence[:EVIDENCE_CAP],
        "affected_area": affected_area,
        "recommended_action": recommended_action,
        "persona_to_notify": persona_to_notify,
        "auto_escalate": False,
        "status": "ACTIVE",
        "generated_at": _now_utc(),
    }


def _now_utc() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


# ---------------------------------------------------------------------------
# CLI entry point — supports validate and generate modes
# ---------------------------------------------------------------------------

def main() -> None:
    """Direct execution.

    Validate mode (default):
      python3 validators/signal_engine.py [project_root]

    Generate mode:
      python3 validators/signal_engine.py --generate [project_root]
    """
    args = sys.argv[1:]
    generate_mode = "--generate" in args
    path_args = [a for a in args if not a.startswith("--")]
    project_root = Path(path_args[0]).resolve() if path_args else Path(".").resolve()

    if generate_mode:
        print(f"Generating signals for: {project_root}")
        try:
            generate(project_root)
            print("[PASS] signal_engine: signals/active.json updated")
        except Exception as exc:  # noqa: BLE001 — advisory; never crashes the hook
            print(f"[WARN] signal_engine: generate failed — {exc}")
    else:
        print(f"Validating signals at: {project_root}/signals/active.json")
        try:
            result = validate(project_root)
        except Exception as exc:  # noqa: BLE001 — advisory; never crashes the hook
            print(f"[WARN] signal_engine: validate failed — {exc}")
            sys.exit(0)
        if result.status == "PASS":
            print("[PASS] signal_engine: all checks passed")
        else:
            for issue in result.issues:
                print(f"[WARN] signal_engine: {issue}")

    sys.exit(0)


if __name__ == "__main__":
    main()
