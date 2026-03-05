# Changelog

All notable changes to the qa-debug plugin are documented here.

---

### v1.3.1 (2026-03-05)

- fix: hooks.json path resolution — moved to .claude-plugin/hooks.json
- fix: removed stale qa-debug.plugin bundle artifact (ENOTDIR fix)
- fix: MCP package names — @linear/mcp-server → @linear/mcp, @modelcontextprotocol/server-sentry → @sentry/mcp-server
- fix: removed unsupported SubagentStop/TeammateIdle events (v2.1.51 schema)
- fix: CI plugin validation — pass explicit plugin path to ensure workflows run green on new environments
- docs: generalized marketplace name from github-local → local-marketplace

### v1.3.0 — 2026-03-05

- `.mcp.json`: Wired source-control (GitHub MCP), project-tracker (Linear MCP), and monitoring (Sentry MCP) — all `~~` conditional placeholders across 8 command files are now unconditional, always-active tool calls
- `agents/qa-sentinel.md`: Auto-invoked debug loop agent — activates on pasted stack traces or failing test output; runs full IDEAL loop with human-in-the-loop at every step
- `agents/archive-curator.md`: Error archive deduplication and ticket sync agent — activates when archive exceeds 10 entries or user requests review; cross-references Linear for existing tickets
- `agents/ci-advisor.md`: CI failure triage agent — activates on CI log output or GitHub Actions failure URLs; diagnoses before suggesting retry; correlates with Sentry production errors
- `settings.json`: Enabled subagent auto-invocation (`enableSubagents: true`)
- `hooks.json`: Removed `SubagentStop` and `TeammateIdle` — not valid event types in Claude Code v2.1.51 (caused entire hooks object to fail validation); retained for future version compatibility in documentation only

**Installation fixes discovered during v1.3.0 deployment (applied to source):**
- `.claude-plugin/hooks.json`: Hooks file moved from `hooks/hooks.json` into `.claude-plugin/` directory — Claude Code v2.1.51 resolves the `hooks` path relative to `.claude-plugin/` (where `plugin.json` lives), not the plugin root; path reference in `plugin.json` updated to `"./hooks.json"`
- `qa-debug.plugin`: Stale bundle file removed — Claude Code plugin scanner attempts to enter `.plugin` files as directories, causing `ENOTDIR` errors on every install and marketplace scan

---

### v1.2.1

- `on-archive-write.sh`: stdin-only, path filtering inside script, `decision:block` feedback
- `pre-bash-guard.sh`: `hookSpecificOutput.permissionDecision: "ask"` — no longer a silent block
- `pre-write-guard.sh`: New guard for Write|Edit|MultiEdit with same schema
- `on-session-stop.sh`: New Stop command hook, top-level `decision:block` (correct for Stop event)
- `on-task-completed.sh`: New TaskCompleted handler, exit 2 + stderr only, zero JSON
- `hooks/hooks.json`: All bad matchers removed, TaskCompleted without matcher field, Stop is a command hook
