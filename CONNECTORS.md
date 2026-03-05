# MCP Connectors

## How MCP integrations work

This plugin uses three pre-configured MCP servers defined in `.mcp.json`. Each server unlocks additional automation in specific commands. If a server is not connected, the command still works — it operates in proposal-only mode without the live data queries.

To verify connection status: run `claude mcp list` and confirm each server shows `Connected`.

## Configured MCP servers

| Category | Server name | Product | Required env var(s) |
|---|---|---|---|
| Source control | `source-control` | GitHub | `GITHUB_TOKEN` |
| Project tracker | `project-tracker` | Linear | `LINEAR_API_KEY` |
| Monitoring | `monitoring` | Sentry | `SENTRY_AUTH_TOKEN`, `SENTRY_ORG` |

## What each server unlocks

### `source-control` (GitHub MCP)
- `/debug` — propose `git log` / `git bisect` ranges targeting the suspected commit window
- `/debug` — cross-reference error timeline against recent PRs
- `/qa-plan` — pull source for the target function to derive inputs automatically
- `/qa-plan` — check existing tests to avoid duplication
- `/archive-error` — populate `app_version` from the latest tag or commit SHA
- `/chaos` — pull the dependency graph for the target component

### `monitoring` (Sentry MCP)
- `/triage` — pull recent error rates and alert history to confirm scope and onset
- `/debug` — propose queries for logs, latency spikes, and metrics at the failure timestamp
- `/debug` — highlight correlated config or deployment changes
- `/archive-error` — populate `timestamp` from first-occurrence data
- `/chaos` — pull current p99 latency and error rate baselines

### `project-tracker` (Linear MCP)
- `/triage` — search for duplicate issues before classifying as new
- `/debug` — search for related bug reports or known issues
- `/debug` — draft a post-mortem or bug ticket once root cause is confirmed
- `/archive-error` — search for an existing ticket matching the fingerprint
- `/archive-error` — attach the JSON record to a new or existing ticket
- `/chaos` — create hardening tickets from the Recommendations section

## Using alternative MCP servers

The plugin is product-agnostic at the schema level. You can substitute any MCP server in the same category:

- **Source control**: GitHub, GitLab, Bitbucket
- **Project tracker**: Linear, Jira, Shortcut, ClickUp, Asana
- **Monitoring**: Sentry, Datadog, New Relic, Grafana, Splunk

To switch: update `.mcp.json` with the new server's `command`/`args`, set the required env vars, and restart Claude Code.
