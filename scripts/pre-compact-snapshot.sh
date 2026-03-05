#!/usr/bin/env bash
# PreCompact
# Writes a snapshot of active session state before context compaction.
# Preserves diagnostic steps and archive entries so they survive compaction.
# Snapshot is used by session-start.sh on the subsequent resume.

set -euo pipefail

# Rule: always read from stdin first — never use env vars
INPUT=$(cat 2>/dev/null || true)

LOG_DIR="${CLAUDE_PLUGIN_ROOT}/logs"
DIAG_LOG="$LOG_DIR/diagnostic-session.jsonl"
AUDIT_LOG="$LOG_DIR/archive-audit.log"

mkdir -p "$LOG_DIR"
SESSION_ID=$(echo "$INPUT" | jq -r '.session_id // "unknown"' 2>/dev/null || echo "unknown")
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

SNAPSHOT_FILE="$LOG_DIR/compact-snapshot-${SESSION_ID}.json"

# Build diagnostic_steps array from JSONL log (empty array if log absent)
if [ -f "$DIAG_LOG" ] && [ -s "$DIAG_LOG" ]; then
  DIAG_STEPS=$(jq -s '.' "$DIAG_LOG" 2>/dev/null || echo "[]")
else
  DIAG_STEPS="[]"
fi

# Build archive_entries string from audit log (empty string if log absent)
if [ -f "$AUDIT_LOG" ] && [ -s "$AUDIT_LOG" ]; then
  ARCHIVE_ENTRIES=$(cat "$AUDIT_LOG")
else
  ARCHIVE_ENTRIES=""
fi

# Write the snapshot JSON
jq -n \
  --arg session "$SESSION_ID" \
  --arg ts "$TIMESTAMP" \
  --argjson diag "$DIAG_STEPS" \
  --arg archive "$ARCHIVE_ENTRIES" \
  '{
    session_id: $session,
    snapshot_time: $ts,
    diagnostic_steps: $diag,
    archive_entries: $archive
  }' \
  > "$SNAPSHOT_FILE"

exit 0
