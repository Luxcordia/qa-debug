#!/usr/bin/env bash
# Stop event
# Checks for unresolved debug sessions before allowing Claude to stop.
# Confirmed correct schema: top-level {"decision": "block", "reason": "..."}
# (Stop event does NOT use hookSpecificOutput — top-level decision is correct here.)

set -euo pipefail

# Drain stdin — not used but required to prevent broken pipe in hook system
INPUT=$(cat 2>/dev/null || true)

LOG_DIR="${CLAUDE_PLUGIN_ROOT}/logs"
DIAG_LOG="$LOG_DIR/diagnostic-session.jsonl"
AUDIT_LOG="$LOG_DIR/archive-audit.log"

# Nothing to check if no diagnostic activity this session
[ ! -f "$DIAG_LOG" ] && exit 0

STEP_COUNT=$(wc -l < "$DIAG_LOG" 2>/dev/null | tr -d ' ' || echo "0")
ARCHIVE_COUNT=$([ -f "$AUDIT_LOG" ] && wc -l < "$AUDIT_LOG" 2>/dev/null | tr -d ' ' || echo "0")

# Block if diagnostic steps were run but no archive record was written and no resolution logged
if [ "$STEP_COUNT" -gt 0 ] && [ "$ARCHIVE_COUNT" -eq 0 ]; then
  jq -n '{
    decision: "block",
    reason: "Unresolved debug session detected: diagnostic steps were executed this session but no error archive record was written and no fix was confirmed. Before stopping: (1) summarize the open items, (2) run /archive-error to close the loop, or (3) explicitly mark this session as deferred."
  }'
  exit 0
fi

# All resolved — allow stop silently
exit 0
