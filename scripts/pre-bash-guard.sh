#!/usr/bin/env bash
# PreToolUse — Bash
# Intercepts every Bash command before execution.
# Rule 2 fix: uses hookSpecificOutput.permissionDecision (not top-level decision).
# Uses "ask" so the user receives a confirmation prompt instead of a silent block.

set -euo pipefail

# Rule: always read from stdin — never use env vars
INPUT=$(cat)

# Extract the command from the Bash tool's input payload
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || true)

# Silent allow if command could not be determined
[ -z "$COMMAND" ] && exit 0

# Patterns that require explicit user confirmation — ordered by blast radius
DESTRUCTIVE_PATTERNS=(
  "rm -rf"
  "rm -f"
  "git push --force"
  "git push -f"
  "DROP TABLE"
  "DELETE FROM"
  "TRUNCATE TABLE"
  "truncate "
  "kubectl delete"
  "kubectl drain"
  "systemctl stop"
  "systemctl disable"
  "pkill"
  "kill -9"
  "dd if="
  "> /dev/"
  "shred"
  "wipefs"
  "mkfs"
  "chmod -R 777"
  "chown -R"
  "service stop"
)

for pattern in "${DESTRUCTIVE_PATTERNS[@]}"; do
  if echo "$COMMAND" | grep -qi "$pattern"; then
    # Rule 2 fix: correct PreToolUse output schema
    # permissionDecision: "ask" triggers a user confirmation prompt
    jq -n \
      --arg reason "⚠️ DESTRUCTIVE PATTERN DETECTED: '${pattern}' — This command is potentially irreversible. Present the full command to the user and wait for explicit confirmation (yes/no) before proceeding. Do NOT execute until confirmed." \
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

# Non-destructive — allow silently
exit 0
