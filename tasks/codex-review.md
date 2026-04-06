## Codex Review — TASK-FIX-001 + TASK-FIX-002
Prepared: 2026-04-06T00:35:00Z
Status: PROCESSED

### Diff
```diff
diff --git a/scripts/hooks/guard-git-push.sh b/scripts/hooks/guard-git-push.sh
@@ -42,9 +42,32 @@ if targets_main "$COMMAND"; then
-  PERSONA="${ACTIVE_PERSONA:-unknown}"
+  PERSONA="$(python3 -c "
+import re, sys
+try:
+    with open('tasks/todo.md', 'r') as f:
+        content = f.read()
+    m = re.search(r'^Active persona:\s*(.+)$', content, re.MULTILINE)
+    print(m.group(1).strip() if m else '')
+except Exception:
+    print('')
+" 2>/dev/null || echo "")"
+
+  if [[ -z "$PERSONA" ]]; then
+    echo "BLOCKED: Could not read Active persona from tasks/todo.md." >&2
+    exit 2
+  fi
+  if [[ "$PERSONA" == "none" ]]; then
+    echo "BLOCKED: No active session — Active persona is 'none'." >&2
+    exit 2
+  fi
   if [[ "$PERSONA" != "architect" ]]; then
     echo "BLOCKED: Only the Architect persona may push to main/master." >&2
     exit 2
   fi

diff --git a/scripts/hooks/guard-session-state.sh b/scripts/hooks/guard-session-state.sh
@@ -32,10 +36 @@
+LOCK_FILE="tasks/.session-transition-lock"
+STALE_THRESHOLD_SECONDS=1800  # 30 minutes
+
 if [[ "$FILE_PATH" != *"tasks/todo.md" ]]; then exit 0; fi
+if [[ "$FILE_PATH" == *"project-template"* ]]; then exit 0; fi

-if echo "$CONTENT" | grep -qi "SESSION STATE\|^Status:"; then
-  ALLOWED_SKILLS="session-open session-close"
-  CURRENT="${ACTIVE_SKILL:-unknown}"
-  for skill in $ALLOWED_SKILLS; do
-    if [[ "$CURRENT" == "$skill" ]]; then exit 0; fi
-  done
-  echo "BLOCKED: ... Active skill: ${CURRENT}" >&2; exit 2
-fi
+if ! echo "$CONTENT" | grep -qi "SESSION STATE\|^Status:"; then exit 0; fi
+
+if [[ ! -f "$LOCK_FILE" ]]; then
+  echo "BLOCKED: ..." >&2; exit 2
+fi
+
+LOCK_AGE_SECONDS="$(python3 -c "
+import os, time
+mtime = os.path.getmtime('${LOCK_FILE}')
+print(int(time.time() - mtime))
+" 2>/dev/null || echo "9999")"
+
+if [[ "$LOCK_AGE_SECONDS" -gt "$STALE_THRESHOLD_SECONDS" ]]; then
+  echo "BLOCKED: STALE_LOCK_FLAG ..." >&2; exit 2
+fi
+
+LOCK_CONTENT="$(cat "$LOCK_FILE" 2>/dev/null | tr -d '[:space:]')"
+if [[ "$LOCK_CONTENT" != "session-open" && "$LOCK_CONTENT" != "session-close" ]]; then
+  echo "BLOCKED: unexpected lock content ..." >&2; exit 2
+fi
+exit 0
```

### What this code must do
These are PreToolCall hooks (bash scripts) that receive JSON on stdin before every Edit/Write or Bash tool call in Claude Code. guard-session-state.sh must block any direct write to SESSION STATE in tasks/todo.md unless a valid lock file is present — created and deleted by session-open and session-close skills bracketing the write. guard-git-push.sh must block git push to main unless the active persona is "architect", read from SESSION STATE in tasks/todo.md.

### Constraints
- Lock file (`tasks/.session-transition-lock`) is the sole auth signal for fallback writes — MCP path bypasses hooks entirely and does not use this file
- `ACTIVE_SKILL` and `ACTIVE_PERSONA` env vars must NOT be used — Claude Code's skill loader never sets them
- guard-git-push.sh must not break existing downstream gates (QA_APPROVED, codex-review, security risk checks) — persona check is just one of several gates in sequence
- Both hooks must exit 0 (allow) or exit 2 (block) — no other exit codes

### Questions
1. **guard-session-state.sh line ~60**: `LOCK_AGE_SECONDS` is computed by passing `${LOCK_FILE}` into a python3 heredoc via bash variable expansion inside double-quotes. If `LOCK_FILE` contains spaces or special characters, does this break the python3 string literal? Is the quoting safe?

2. **guard-session-state.sh**: The `project-template` exclusion (`if [[ "$FILE_PATH" == *"project-template"* ]]`) uses a substring match. Could a legitimate live project path contain "project-template" as a directory component, accidentally bypassing the guard for that project's tasks/todo.md?

3. **guard-git-push.sh**: The python3 regex `^Active persona:\s*(.+)$` with `re.MULTILINE` will match the FIRST occurrence of `Active persona:` in the entire file — including any inside task descriptions or comments. If a task block contains `Active persona: architect` in its text, could a non-architect session pass the guard?

4. **guard-session-state.sh**: The `^Status:` grep pattern in the CONTENT check (line ~54) uses `grep -qi "SESSION STATE\|^Status:"`. The `^` anchor works in grep multiline input, but the content is a bash variable expanded via `echo "$CONTENT"`. If CONTENT contains a line starting with "Status:" anywhere (e.g. in a task's `- Status: QA_APPROVED` line), would the guard incorrectly treat a non-SESSION-STATE edit as requiring the lock?

5. **guard-git-push.sh**: If `tasks/todo.md` does not exist (new project, pre-first-session), the python3 block catches the FileNotFoundError and prints `''`. The empty string check `[[ -z "$PERSONA" ]]` then blocks the push. Is this the correct behavior for a brand-new project where no session has ever been opened, or should it be a warning-only?

### Respond with
VERDICT: PASS | FAIL
FINDINGS:
- Q1: [one line]
- Q2: [one line]
- Q3: [one line]
- Q4: [one line]
- Q5: [one line]
CRITICAL: [anything not covered above that must be fixed — or NONE]

VERDICT: FAIL
FINDINGS:
- Q1: Unsafe in the general case: spaces are fine, but embedding `${LOCK_FILE}` into a Python single-quoted literal breaks on `'`, `\`, or newlines.
- Q2: Yes; `[[ "$FILE_PATH" == *"project-template"* ]]` can bypass the guard for any real path containing that substring, not just the template copy.
- Q3: Yes; `re.search(r'^Active persona:\s*(.+)$', ..., re.MULTILINE)` returns the first line-start match anywhere in the file, so a stray `Active persona: architect` line outside SESSION STATE could authorize a non-architect push.
- Q4: Yes; any edited text containing a line that starts with `Status:` will trigger the lock requirement even outside SESSION STATE, so unrelated task edits can be blocked.
- Q5: Blocking is the safer and likely correct behavior for `git push` to `main` on a brand-new project, because there is no verifiable active architect session.
CRITICAL: `guard-session-state.sh` can be bypassed by any edit to `tasks/todo.md` that changes SESSION STATE without including the literal `SESSION STATE` marker or a bare `Status:` line in `content/new_string/old_string`; the guard is matching diff text heuristically instead of locating the protected block in the target file.
