#!/usr/bin/env bash
# auto-signal-check.sh — UserPromptSubmit hook (advisory, non-blocking)
#
# Runs signal engine in generate mode, then surfaces HIGH severity signals
# as stdout hints to the active persona.
#
# SAFETY CONTRACT: This hook MUST exit 0 in every possible execution path.
# A non-zero exit blocks Claude's response entirely — unacceptable for an
# advisory hook. Every command that could fail uses || true or || return 0.
# There is NO set -e, NO set -o pipefail, NO set -u anywhere in this file.
#
# Exit 0 always. Never exits 2. No exceptions.

# Drain stdin (UserPromptSubmit passes prompt JSON on stdin — not needed here)
cat > /dev/null 2>&1 || true

_signal_check() {
    # Guards: if prerequisites are absent, return 0 silently.
    # || return 0 means: test fails → return from function with code 0.
    [[ -f "validators/signal_engine.py" ]] || return 0
    [[ -d "signals" ]] || return 0

    # Run signal engine in generate mode to refresh signals/active.json.
    # Stdout and stderr suppressed. || true: failure never aborts the hook.
    python3 "validators/signal_engine.py" --generate . > /dev/null 2>&1 || true

    # Guard: active.json must exist (generate mode creates it, but may fail silently)
    [[ -f "signals/active.json" ]] || return 0

    # Read signals/active.json and print HIGH+ACTIVE signals.
    # Inline Python — no eval, no shell exec from JSON content.
    # All field values are cast to str and truncated before printing.
    # All exceptions are caught — Python always exits 0 from this block.
    python3 - "signals/active.json" 2>/dev/null <<'PYEOF' || true
import json, sys
try:
    with open(sys.argv[1], encoding="utf-8") as f:
        data = json.load(f)
    if not isinstance(data, dict):
        sys.exit(0)
    signals = data.get("signals")
    if not isinstance(signals, list):
        sys.exit(0)
    for sig in signals:
        if not isinstance(sig, dict):
            continue
        if sig.get("severity") == "HIGH" and sig.get("status") == "ACTIVE":
            stype  = str(sig.get("signal_type",        ""))[:50]
            area   = str(sig.get("affected_area",       ""))[:100]
            action = str(sig.get("recommended_action", ""))[:200]
            print(f"[SIGNAL] {stype} (HIGH) — {area}: {action}")
except Exception:
    pass
PYEOF
}

# Call the function. || true: even if the function somehow exits non-zero,
# this line continues and exit 0 below runs.
_signal_check || true

# This is the ONLY exit in the script. Always 0.
exit 0
