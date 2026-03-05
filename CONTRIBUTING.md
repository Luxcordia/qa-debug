# Contributing to qa-debug

This project enforces a pessimistic, quality-first methodology. Every contribution must make the plugin more robust, not just functional. A command that works in the happy path is not done. A script that handles the common case is not done. Done means the failure modes are identified, guarded against, and tested.

---

## Before You Contribute

Complete these steps before touching any file:

1. **Read all 8 command files in `commands/` completely.** Not the headers — all of them. The commands share a design language (IDEAL framework, human-in-the-loop approval gates, MCP connector sections). Any change that breaks that consistency will be rejected.

2. **Read `CONNECTORS.md` in full.** Understand which MCP servers are configured, what each one unlocks per command, and what the plugin does when a server is not connected. Every command must degrade gracefully when MCP is absent.

3. **Run all 5 smoke tests locally and confirm they pass before opening a PR.** The smoke tests are not optional. If you cannot run them, do not open a PR.

Smoke test commands:
```
/qa-debug:triage A 500 error appeared in checkout after the last deploy
/qa-debug:debug TypeError: Cannot read properties of undefined reading 'price' at cart.js:42
/qa-debug:chaos The payment API integration
/qa-debug:archive-error ZeroDivisionError division by zero at views.py line 8
/qa-debug:postmortem A critical service crashed for 10 minutes after a config change
```

For each test, confirm: (a) the command responds without error, (b) the output is structured and complete, (c) no placeholder text remains in the output, and (d) MCP tools are referenced by name where expected.

---

## Code Standards

These are non-negotiable. Pull requests that violate these rules will not be merged regardless of what else they fix.

### Shell scripts

Every shell script must read input from stdin as its first executable line:

```bash
INPUT=$(cat)
```

For scripts that receive no meaningful stdin (Stop, SessionStart, PreCompact), use the drain form:

```bash
INPUT=$(cat 2>/dev/null || true)
```

No hardcoded paths. The only valid path reference is `${CLAUDE_PLUGIN_ROOT}` for the plugin root. No `/Users/`, no `/home/`, no `C:\` paths. Any script with a hardcoded absolute path will be rejected.

### Hook schemas

The hook event type determines the output schema. These are not interchangeable:

**`PreToolUse`** — use `hookSpecificOutput.permissionDecision`:
```json
{
  "hookSpecificOutput": {
    "permissionDecision": "ask",
    "permissionDecisionReason": "reason string"
  }
}
```
Never use top-level `"decision"` in a PreToolUse script. Never use `"deny"` or `"block"` as a `permissionDecision` value.

**`Stop`** — use top-level `decision`:
```json
{
  "decision": "block",
  "reason": "reason string"
}
```

**`TaskCompleted`** — use `exit 2` and write to stderr only. No JSON output. No stdout:
```bash
echo "Reason for blocking" >&2
exit 2
```

**`PostToolUse`** — use top-level `decision: "block"` only when a condition is met. Exit silently (`exit 0`) on all non-matching files and tool responses. Never fire on false positives.

**`SessionStart`** — use `hookSpecificOutput.additionalContext` for context injection:
```json
{
  "hookSpecificOutput": {
    "hookEventName": "SessionStart",
    "additionalContext": "context string"
  }
}
```

**`PostToolUse` matchers** — matcher strings are tool names only. No file path patterns in the matcher field.

**`TaskCompleted`** — has no matcher field. Applies to all task completions.

---

## Adding a New Command

Follow these steps exactly. Skipping any step is grounds for rejection.

1. **Create `commands/your-command.md`** with valid frontmatter:
   ```yaml
   ---
   description: One-line description of what this command does (under 100 characters)
   argument-hint: "<what to pass as the argument>"
   ---
   ```
   The `description` field must be under 100 characters. It is used as the skill trigger description in Claude Code.

2. **Follow the IDEAL framework structure used in `debug.md`.** Every command must include: a human-in-the-loop notice at the top, a usage example, a workflow diagram or step list, a "What I Need From You" section, and a structured output format block.

3. **Human-in-the-loop is mandatory.** Claude proposes, the user approves, nothing auto-executes. The command must include an explicit `⚠️ STOP — Await approval` gate before any step that reads from a live system, modifies state, or triggers a network call. If your command has no such gate, it does not belong in this plugin.

4. **Add an `## Active MCP Connectors` section** at the end of the command file. List what each configured server (`source-control`, `project-tracker`, `monitoring`) adds to this command's output. If the command gains nothing from a given server, omit that server. Do not use placeholder language — reference servers by their exact names.

5. **Add the command to the README commands table** with its `/qa-debug:` prefix, a one-line description, and an example input.

6. **Write one smoke test and confirm it passes** before submitting. Include the test input and expected output structure in the PR description.

---

## Adding a New MCP Integration

1. **Add the server to `.mcp.json`** using the standard format. Use `npx` with the official MCP package — no custom binaries. Reference credentials via environment variable substitution only (`${VAR_NAME}`), never inline:
   ```json
   "new-server": {
     "command": "npx",
     "args": ["-y", "@vendor/mcp-server-name"],
     "env": {
       "API_KEY": "${NEW_SERVER_API_KEY}"
     }
   }
   ```

2. **Update `CONNECTORS.md`** with the new server name, product name, required environment variable(s), and a list of which commands it enhances and how.

3. **Update every command file** that benefits from the new server. Add the server to the `## Active MCP Connectors` section with specific, non-vague language: not "can help with debugging" but "proposes `git log` ranges targeting the suspected commit window."

4. **Confirm `claude mcp list` shows `Connected`** for the new server before submitting. Do not submit a PR for an integration you cannot test.

---

## Pull Request Requirements

### Title format

```
[type] short description
```

Where `type` is one of: `fix`, `feat`, `refactor`, or `docs`. Examples:

```
[fix] add stdin drain to on-session-stop.sh
[feat] add /suggest-observability command
[refactor] consolidate archive fingerprint logic into shared function
[docs] update CONTRIBUTING.md with PostToolUse schema rules
```

### Required PR body

Every PR must answer all four of the following:

1. **What was changed** — list every file modified and describe the change at the line level, not the intent level.
2. **Why** — explain the problem this change solves. Link to a failing smoke test, a schema error, or an observed behavior gap. "Improvement" is not a reason.
3. **Which smoke tests were run** — list the exact commands you ran and state whether each passed or failed.
4. **What the failure mode is if this change is wrong** — if your change has a bug, what breaks and how would someone know? If you cannot answer this, the change is not ready.

### Merge requirements

- All 5 smoke tests pass on the PR branch
- No `~~` placeholder text in any file in `commands/`, `agents/`, `scripts/`, or `skills/`
- No hardcoded absolute paths anywhere in the plugin
- All shell scripts have `INPUT=$(cat)` as the first executable line
- All command `description` frontmatter fields are under 100 characters
- No PR will be merged that reduces the number of passing smoke tests, even if the change is otherwise correct

---

## Schema Reference Card

Memorize these. They are tested by the smoke tests and enforced at review.

| Hook event | Output schema | Key rule |
|-----------|---------------|----------|
| `PreToolUse` | `hookSpecificOutput.permissionDecision: "ask"` | Never top-level `decision`; never `"deny"` or `"block"` as value |
| `PostToolUse` | Top-level `{"decision": "block"}` if blocking | Exit 0 silently on non-matching inputs — never fire on false positives |
| `TaskCompleted` | `exit 2` + stderr only | No matcher field; no JSON output; no stdout |
| `Stop` | Top-level `{"decision": "block", "reason": "..."}` | Not `hookSpecificOutput` |
| `SessionStart` | `hookSpecificOutput.additionalContext` | Not top-level |
| `PreCompact` | No output — side effects only (snapshot) | Exit 0 silently always |
| `PostToolUse` matchers | Tool name only | No file path patterns in matcher strings |
