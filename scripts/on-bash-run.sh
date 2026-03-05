#!/usr/bin/env bash
# PostToolUse — Bash
# Logs diagnostic Bash command outputs to the active session trace.
# Only logs commands that match known read-only diagnostic patterns.
# Exits silently for all other commands.

set -euo pipefail

# Rule: always read from stdin first — never use env vars
INPUT=$(cat)

LOG_DIR="${CLAUDE_PLUGIN_ROOT}/logs"
SESSION_LOG="$LOG_DIR/diagnostic-session.jsonl"

mkdir -p "$LOG_DIR"

# Extract command and output from the tool payload
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || true)
OUTPUT=$(echo "$INPUT" | jq -r '.tool_response.output // ""' 2>/dev/null || true)

# Silent exit if command could not be resolved
[ -z "$COMMAND" ] && exit 0

# Only log read-only diagnostic patterns — never log writes, deployments, or mutations
DIAGNOSTIC_PATTERNS=(
  "git log"
  "git diff"
  "git show"
  "git status"
  "git bisect"
  "cat "
  "grep "
  "find "
  "tail "
  "head "
  "less "
  "jq "
  "curl "
  "wget "
  "ping "
  "traceroute"
  "nslookup"
  "dig "
  "ps "
  "top "
  "df "
  "du "
  "lsof"
  "netstat"
  "ss "
  "npm list"
  "npm audit"
  "pip list"
  "pip show"
  "pytest"
  "python -"
  "node -"
  "Get-"
  "Select-"
  "Where-Object"
)

MATCHED=false
for pattern in "${DIAGNOSTIC_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern"; then
    MATCHED=true
    break
  fi
done

# Silent exit if not a diagnostic command
[ "$MATCHED" = false ] && exit 0

# Write structured JSONL entry to the session log
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

printf '{"timestamp":"%s","command":%s,"output":%s}\n' \
  "$TIMESTAMP" \
  "$(echo "$COMMAND" | jq -Rs '.')" \
  "$(echo "$OUTPUT" | head -c 2000 | jq -Rs '.')" \
  >> "$SESSION_LOG"

exit 0
