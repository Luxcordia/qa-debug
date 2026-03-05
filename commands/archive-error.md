---
description: Emit a structured JSON error archive record from a raw error — stack trace, logs, or repro steps
argument-hint: "<stack trace or raw error text>"
---

# /archive-error

> **Human-in-the-loop mode**: This command produces a structured record proposal only. Nothing is stored or transmitted automatically. Review the output and store it where appropriate.

> If you see unfamiliar placeholders or need to check which tools are connected, see [CONNECTORS.md](../CONNECTORS.md).

Takes a raw error (stack trace, logs, repro steps) and emits a clean, structured JSON error archive record with fingerprint, metadata, taxonomy, and recommended fix. Ready to store in your error database or attach to a project tracker ticket.

## Usage

```
/archive-error $ARGUMENTS
```

## How It Works

```
┌──────────────────────────────────────────────────────────────────┐
│                  ARCHIVE-ERROR WORKFLOW                          │
├──────────────────────────────────────────────────────────────────┤
│  Step 1: PARSE RAW INPUT                                         │
│  ✓ Extract error text, stack trace, and context                 │
│  ✓ Identify runtime, environment, and version from signals      │
│                                                                  │
│  Step 2: GENERATE FINGERPRINT                                    │
│  ✓ Normalize error text (strip line numbers, addresses)         │
│  ✓ Produce a stable ID for deduplication                        │
│                                                                  │
│  Step 3: CLASSIFY & ENRICH                                       │
│  ✓ Identify suspected component from stack trace                │
│  ✓ Assign status: new / known / regression                      │
│  ✓ Suggest root cause and fix summary if determinable           │
│                                                                  │
│  Step 4: EMIT ARCHIVE RECORD                                     │
│  ✓ Output structured JSON ready for storage or ticketing        │
└──────────────────────────────────────────────────────────────────┘
```

## What I Need From You

- **Raw error** — paste the full stack trace or error message verbatim
- **Repro steps** — the sequence that triggered the error (if known)
- **Environment** — OS, runtime version, app version, deployment target
- **Status** — is this new, a known issue, or a regression?

## Output Format

```json
{
  "timestamp": "[ISO 8601 — fill in or leave blank to stamp on save]",
  "fingerprint": "[normalized hash or slug for deduplication]",
  "app_version": "[semantic version or commit SHA]",
  "environment": "[production | staging | local | region]",
  "error_text": "[exact first line of the error message]",
  "stack_trace": "[full stack trace, verbatim]",
  "repro_steps": [
    "[step 1]",
    "[step 2]",
    "[step 3]"
  ],
  "suspected_component": "[service / module / function]",
  "root_cause": "[confirmed or hypothesized explanation]",
  "fix_summary": "[one-sentence description of the fix, or 'pending investigation']",
  "tests_to_add": [
    "[test case 1 to prevent regression]",
    "[test case 2]"
  ],
  "status": "new | known | regression"
}
```

## Active MCP Connectors

**project-tracker (Linear MCP):**
- Search for an existing ticket with a matching fingerprint before creating a new one
- Attach the JSON record to a new or existing bug ticket automatically

**source-control (GitHub MCP):**
- Cross-reference the stack trace against recent commits to identify the introducing change
- Populate `app_version` from the latest tag or commit SHA automatically

**monitoring (Sentry MCP):**
- Pull the error rate and first-occurrence timestamp to populate `timestamp` accurately
- Check if the fingerprint matches any existing alert or known issue in your monitoring system

## Tips

1. **Paste the full stack trace** — truncated traces produce incomplete fingerprints and miss the real component.
2. **Set status accurately** — `regression` means it worked before; `known` means it's tracked; `new` means first sighting.
3. **Run after `/debug`** — use `/archive-error` to close the loop once root cause is confirmed and a fix is proposed.
