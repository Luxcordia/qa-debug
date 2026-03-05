# qa-debug

![Version](https://img.shields.io/badge/version-v1.3.0-blue) ![License](https://img.shields.io/badge/license-Apache--2.0-green)

**qa-debug** is a Claude Code plugin that brings structured, pessimistic quality assurance and debugging methodology directly into your development workflow. It gives QA engineers, solo developers, and software teams a consistent, human-in-the-loop framework for triaging bugs, running structured debugging sessions, designing resilience tests, and archiving errors — all driven by Claude, with nothing executing automatically without your approval.

---

## What It Does

### The problem it solves

Most AI-assisted debugging is optimistic: the model proposes a fix and runs it. This is fast but dangerous. In production environments, unreviewed code execution causes more incidents than it prevents. qa-debug inverts this: **Claude proposes, you approve, nothing runs automatically.**

The plugin also solves the fragmentation problem. Triage, root cause analysis, chaos testing, mutation testing, contract testing, post-mortems, and error archiving are currently handled by different tools, processes, and team members with no shared vocabulary. qa-debug unifies them under a single plugin with a common output format and a shared error archive.

### Who benefits

- **QA engineers** who want structured, reproducible test planning and a blameless incident retrospective format
- **Backend developers** who need a systematic debugging framework that does not skip steps under pressure
- **Solo builders** who do not have a QA team and need to compensate with rigorous methodology
- **Team leads** who want a consistent debugging process that every team member follows the same way

---

## Requirements

- **Claude Code CLI** v2.1.51 or higher
- **Node.js** 18 or higher (required by MCP servers)
- **Active accounts**: GitHub, Linear, Sentry (required for MCP server authentication)
- **Shell**: bash or zsh (PowerShell for Windows users running the install commands)

---

## Installation

### Step 1 — Clone or download the plugin folder

```bash
# Clone from GitHub
git clone https://github.com/luxcordia/qa-debug.git

# Or download and extract the archive
tar -xzf qa-debug-v1.3.0.tar.gz -C /your/plugins/folder/
```

### Step 2 — Set environment variables

Add these to your shell profile (`.bashrc`, `.zshrc`, or PowerShell `$PROFILE`). Replace the placeholder values with your real tokens — never commit real tokens to version control.

**bash / zsh:**
```bash
# GitHub personal access token (repo + read:org scopes)
export GITHUB_TOKEN=ghp_YourTokenHere

# Linear API key (from Linear → Settings → API)
export LINEAR_API_KEY=lin_api_YourKeyHere

# Sentry auth token (from Sentry → Settings → Auth Tokens)
export SENTRY_AUTH_TOKEN=sntrys_YourTokenHere

# Sentry organization slug (the subdomain of your Sentry URL)
export SENTRY_ORG=your-org-slug
```

**PowerShell (Windows):**
```powershell
$env:GITHUB_TOKEN      = "ghp_YourTokenHere"
$env:LINEAR_API_KEY    = "lin_api_YourKeyHere"
$env:SENTRY_AUTH_TOKEN = "sntrys_YourTokenHere"
$env:SENTRY_ORG        = "your-org-slug"
```

Reload your shell (`source ~/.zshrc` or open a new terminal) before proceeding.

### Step 3 — Register the marketplace and install the plugin

**macOS / Linux:**
```bash
# Register the local marketplace (one-time setup)
claude plugin marketplace add github-local /path/to/qa-debug-parent-folder

# Install the plugin
claude plugin install qa-debug@github-local
```

**Windows (PowerShell):**
```powershell
# Register the local marketplace (one-time setup)
claude plugin marketplace add github-local "C:\path\to\qa-debug-parent-folder"

# Install the plugin
claude plugin install qa-debug@github-local
```

### Step 4 — Authorize Linear and Sentry via OAuth

```
/mcp
```

In the MCP panel, find `project-tracker` and `monitoring`, then follow the OAuth flow to authorize Linear and Sentry respectively. GitHub authenticates via the personal access token set in Step 2 — no additional OAuth step is required.

### Step 5 — Verify installation

```bash
claude mcp list
```

Expected output:
```
source-control    Connected
project-tracker   Connected
monitoring        Connected
```

If any server shows `Disconnected`, confirm the corresponding environment variable is set and non-empty, then restart Claude Code.

---

## Commands

All commands use the `/qa-debug:` prefix and are available immediately after installation.

| Command | Description | Example input |
|---------|-------------|---------------|
| `/qa-debug:triage` | Quick first-pass severity and ownership classification before a full debug session | `/qa-debug:triage 500 error in checkout after last deploy` |
| `/qa-debug:debug` | Human-in-the-loop IDEAL debugging — proposes steps, awaits your approval at each stage | `/qa-debug:debug TypeError: Cannot read properties of undefined (reading 'price') at cart.js:42` |
| `/qa-debug:qa-plan` | Pessimistic QA test plan — negative, boundary, fuzz, and stress cases (proposals only) | `/qa-debug:qa-plan checkout flow` |
| `/qa-debug:chaos` | Controlled fault injection planning — blast radius, mock scenarios, resilience verdict | `/qa-debug:chaos payment API integration` |
| `/qa-debug:contract` | Consumer-driven contract test design — schema drift detection, violation scenarios, pact definition | `/qa-debug:contract cart-service → checkout-service` |
| `/qa-debug:mutation` | Test suite quality audit via mutation analysis — surviving mutants, assertion gaps, kill score | `/qa-debug:mutation src/cart/CartTotal.js` |
| `/qa-debug:archive-error` | Emit a structured JSON error archive record from a raw error or stack trace | `/qa-debug:archive-error ZeroDivisionError: division by zero at views.py:8` |
| `/qa-debug:postmortem` | Blameless post-incident report — 5 Whys root cause, impact timeline, assignable action items | `/qa-debug:postmortem Sentry SDK setup crashed Django for 10 minutes` |

---

## Agents

Three autonomous agents are included. They activate automatically based on trigger conditions — no slash command required.

| Agent | Trigger condition | What it produces |
|-------|-------------------|-----------------|
| **qa-sentinel** | User pastes a stack trace or failing test output without invoking `/debug` | Runs the full IDEAL debug loop with human-in-the-loop approval at every proposed step |
| **archive-curator** | Archive log exceeds 10 entries, or user requests an error review or cleanup | Deduplicates records by fingerprint, ranks by frequency and recency, cross-references Linear for ticket sync |
| **ci-advisor** | User pastes CI log output or a failed GitHub Actions URL | Classifies the failure type, proposes a minimal targeted fix, correlates with Sentry production errors — never suggests re-run as a first response |

---

## MCP Integrations

| Service | Server name | What the plugin uses it for |
|---------|-------------|----------------------------|
| **GitHub** | `source-control` | `git log` / `git bisect` ranges for suspect commits; cross-referencing error timelines against recent PRs; populating `app_version` in archive records |
| **Linear** | `project-tracker` | Searching for duplicate tickets before filing; attaching archive records to bug tickets; creating action-item tasks from postmortem output |
| **Sentry** | `monitoring` | Pulling error rate and first-occurrence timestamps; confirming incident detection lag; identifying uncovered failure modes from existing alerts |

All commands work without MCP connections — they operate in proposal-only mode using only the information you provide. MCP connections add live data and automation on top of that baseline.

---

## Methodology

qa-debug is built on the **IDEAL debugging framework**: Identify and reproduce the problem, Diagnose using a structured evidence plan, Evaluate hypotheses against returned evidence, Act with a minimal proposed fix, and Learn by expanding test coverage to prevent regression. Every command follows this structure, and every step that could modify code or infrastructure is labeled as a proposal and requires your explicit approval before Claude proceeds. This is the human-in-the-loop principle: Claude reasons and proposes; you decide and execute. The plugin is intentionally conservative — it will never run a fix, file a ticket, or send a request without your review. This makes it slower than fully autonomous AI debugging, and that is a deliberate design choice.

---

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) for code standards, the process for adding commands, and pull request requirements.

---

## License

Copyright 2024 Luxcordia

Licensed under the Apache License, Version 2.0. See [LICENSE](LICENSE) for the full text.
