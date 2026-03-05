#!/usr/bin/env bash
# SessionStart
# Restores QA debug session context when resuming after compaction or a prior session.
# On fresh start: exits silently.
# On resume/compact: injects recent archive entries as context into the new session.

set -euo pipefail

# Rule: always read from stdin first — never use env vars
INPUT=$(cat 2>/dev/null || true)

LOG_DIR="${CLAUDE_PLUGIN_ROOT}/logs"
AUDIT_LOG="$LOG_DIR/archive-audit.log"

mkdir -p "$LOG_DIR"
SOURCE=$(echo "$INPUT" | jq -r '.source // "startup"' 2>/dev/null || echo "startup")

# Only inject context on resume or post-compaction — not on fresh starts
if [ "$SOURCE" != "resume" ] && [ "$SOURCE" != "compact" ]; then
  exit 0
fi

# Nothing to restore if audit log is empty or absent
if [ ! -f "$AUDIT_LOG" ] || [ ! -s "$AUDIT_LOG" ]; then
  exit 0
fi

RECENT=$(tail -5 "$AUDIT_LOG")
ENTRY_COUNT=$(wc -l < "$AUDIT_LOG" | tr -d ' ')

# Output context as additionalContext for the session
jq -n \
  --arg count "$ENTRY_COUNT" \
  --arg recent "$RECENT" \
  '{
    hookSpecificOutput: {
      hookEventName: "SessionStart",
      additionalContext: ("=== QA Debug Session Restored ===\nTotal archive records this project: " + $count + "\nMost recent 5 entries:\n" + $recent + "\n=== End of restored context ===")
    }
  }'

exit 0
