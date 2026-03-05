#!/usr/bin/env bash
# TaskCompleted event
# Rule 3: TaskCompleted has NO JSON decision control.
# Block completion with exit code 2 and write reason to stderr only.
# No jq output. No JSON. stderr is fed back as feedback to Claude.

set -euo pipefail

# Drain stdin — not used but required to prevent broken pipe in hook system
INPUT=$(cat 2>/dev/null || true)

LOG_DIR="${CLAUDE_PLUGIN_ROOT}/logs"
DIAG_LOG="$LOG_DIR/diagnostic-session.jsonl"
AUDIT_LOG="$LOG_DIR/archive-audit.log"

# Nothing to check if no diagnostic activity this session
if [ ! -f "$DIAG_LOG" ]; then
  exit 0
fi

STEP_COUNT=$(wc -l < "$DIAG_LOG" 2>/dev/null | tr -d ' ' || echo "0")
ARCHIVE_COUNT=$([ -f "$AUDIT_LOG" ] && wc -l < "$AUDIT_LOG" 2>/dev/null | tr -d ' ' || echo "0")

# Block task completion if diagnostic steps were run without a confirmed resolution
if [ "$STEP_COUNT" -gt 0 ] && [ "$ARCHIVE_COUNT" -eq 0 ]; then
  echo "Task cannot be marked complete: diagnostic steps were executed this session but no fix was confirmed and no error archive record was written. Resolve or explicitly defer before completing." >&2
  exit 2
fi

# All resolved — allow completion
exit 0
