#!/usr/bin/env bash
# PostToolUse — Write
# Fires on every Write tool use. Filters by file path and content from stdin.
# Exits silently if not an error-archive record. Logs valid records and
# emits a decision:block feedback message so Claude offers project tracker filing.

set -euo pipefail

# Rule: always read from stdin first — never use env vars
INPUT=$(cat)

LOG_DIR="${CLAUDE_PLUGIN_ROOT}/logs"
AUDIT_LOG="$LOG_DIR/archive-audit.log"

mkdir -p "$LOG_DIR"

# Extract file path from the Write tool's input payload
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null || true)

# Silent exit if file path could not be resolved
[ -z "$FILE_PATH" ] && exit 0

# Rule 1 fix: file-path filtering lives here, not in the matcher
# Exit silently if path does not match error-archive*.json
if ! echo "$FILE_PATH" | grep -qi "error-archive"; then
  exit 0
fi
if ! echo "$FILE_PATH" | grep -qi "\.json$"; then
  exit 0
fi

# Extract written content from the tool input payload
CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // ""' 2>/dev/null || true)

# Exit silently if content is empty or not valid JSON
[ -z "$CONTENT" ] && exit 0
if ! echo "$CONTENT" | jq empty > /dev/null 2>&1; then
  exit 0
fi

# Validate all required archive fields — exit silently if any are missing
REQUIRED_FIELDS=("fingerprint" "error_text" "status" "suspected_component")
for field in "${REQUIRED_FIELDS[@]}"; do
  if ! echo "$CONTENT" | jq -e ".$field" > /dev/null 2>&1; then
    exit 0  # Not a valid archive record — skip silently
  fi
done

# All required fields present — extract values for the audit entry
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
STATUS=$(echo "$CONTENT" | jq -r '.status // "unknown"')
COMPONENT=$(echo "$CONTENT" | jq -r '.suspected_component // "unknown"')
FINGERPRINT=$(echo "$CONTENT" | jq -r '.fingerprint // "unknown"')
ERROR_TEXT=$(echo "$CONTENT" | jq -r '.error_text // ""' | head -c 120)

# Append to rolling audit log (one line per record, human-readable)
printf '[%s] ARCHIVE WRITTEN | status=%-12s | component=%-30s | fingerprint=%s | error="%s"\n' \
  "$TIMESTAMP" "$STATUS" "$COMPONENT" "$FINGERPRINT" "$ERROR_TEXT" \
  >> "$AUDIT_LOG"

# Emit PostToolUse feedback to Claude: offer project tracker filing
# decision:block pauses Claude so it can prompt the user instead of continuing silently
jq -n \
  --arg comp "$COMPONENT" \
  --arg fp "$FINGERPRINT" \
  --arg st "$STATUS" \
  '{
    decision: "block",
    reason: ("Error archive record written — component: " + $comp + " | fingerprint: " + $fp + " | status: " + $st + ". Use project-tracker (Linear MCP) to search for an existing ticket with this fingerprint or create a new one. Confirm the record was saved and continue.")
  }'

exit 0
