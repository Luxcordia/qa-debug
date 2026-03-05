#!/usr/bin/env bash
# PreToolUse — Write|Edit|MultiEdit
# Protects core plugin configuration files from accidental overwrites.
# Rule 2: uses hookSpecificOutput.permissionDecision (not top-level decision).
# Uses "ask" so the user gets a confirmation prompt rather than a silent block.

set -euo pipefail

# Rule: always read from stdin — never use env vars
INPUT=$(cat)

# Extract file path from the tool's input payload
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null || true)

# Silent allow if file path could not be determined
[ -z "$FILE_PATH" ] && exit 0

# Core plugin files that must not be overwritten without explicit user confirmation
PROTECTED_PATTERNS=(
  "plugin.json"
  "hooks/hooks.json"
  "hooks.json"
  ".claude/settings"
  "CONNECTORS.md"
)

for pattern in "${PROTECTED_PATTERNS[@]}"; do
  if echo "$FILE_PATH" | grep -qi "$pattern"; then
    # Rule 2: correct PreToolUse output schema
    jq -n \
      --arg path "$FILE_PATH" \
      --arg reason "⚠️ PROTECTED FILE: Writing to '${FILE_PATH}' will modify plugin core configuration. Confirm with the user before proceeding — this may affect hook behavior, connectors, or plugin loading." \
      '{
        hookSpecificOutput: {
          hookEventName: "PreToolUse",
          permissionDecision: "ask",
          permissionDecisionReason: $reason
        }
      }'
    exit 0
  fi
done

# Not a protected file — allow silently
exit 0
