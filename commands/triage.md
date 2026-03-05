---
description: Quick first-pass severity and ownership classification before a full /debug session
argument-hint: "<error text or issue description>"
---

# /triage

> **Human-in-the-loop mode**: This command ONLY proposes a classification and recommendation. Nothing executes automatically. All analysis is based on the information you provide.

> If you see unfamiliar placeholders or need to check which tools are connected, see [CONNECTORS.md](../CONNECTORS.md).

Quick first-pass severity and ownership classification. Run this before `/debug` to focus the investigation or decide whether to escalate.

## Usage

```
/triage $ARGUMENTS
```

## How It Works

```
┌──────────────────────────────────────────────────────────────────┐
│                     TRIAGE WORKFLOW                              │
├──────────────────────────────────────────────────────────────────┤
│  Step 1: CLASSIFY ISSUE TYPE                                     │
│  ✓ build / runtime / performance / network /                     │
│    dependency / flaky-test / data / security                     │
│                                                                  │
│  Step 2: ASSIGN SEVERITY                                         │
│  ✓ P0 — Production down, data loss, security breach             │
│  ✓ P1 — Major feature broken, no workaround                     │
│  ✓ P2 — Degraded functionality, workaround exists               │
│  ✓ P3 — Minor issue, cosmetic, or low-traffic path              │
│                                                                  │
│  Step 3: IDENTIFY COMPONENT & OWNER                              │
│  ✓ Pinpoint the likely subsystem or service                     │
│  ✓ Suggest who should investigate                               │
│                                                                  │
│  Step 4: RECOMMEND NEXT STEP                                     │
│  ✓ Proceed with /debug, /qa-plan, or escalate immediately       │
└──────────────────────────────────────────────────────────────────┘
```

## What I Need From You

- **Error text or description** — paste verbatim if available
- **Affected area** — which feature, service, or user group
- **When it started** — first occurrence, frequency, trend
- **Environment** — production, staging, local, or specific region

## Output Format

```markdown
## Triage Report: [One-Line Summary]

### Classification
- **Issue type**: [build / runtime / performance / network / dependency / flaky-test / data / security]
- **Severity**: P[0–3] — [brief justification]
- **Likely component**: [service / module / layer]
- **Suggested owner**: [team or role]

### Summary
[One-paragraph assessment: what is happening, why it matters, what makes it hard or easy to diagnose]

### Recommended Next Step
- [ ] Proceed with `/debug [paste error here]` — [reason]
- [ ] Proceed with `/qa-plan [feature name]` — [reason]
- [ ] Escalate immediately — [reason and who to notify]
```

## Active MCP Connectors

**project-tracker (Linear MCP):**
- Search for duplicate or related issues before opening a new one
- Check if this is a known regression from a recent release

**monitoring (Sentry MCP):**
- Pull recent error rates and alert history to confirm scope and onset time
- Check if an anomaly correlates with a recent deploy or config change

**source-control (GitHub MCP):**
- Check recent merges to the affected service for likely culprits

## Tips

1. **Even a one-line description helps** — severity and type can often be estimated from minimal input.
2. **Mention the environment** — P0 in production is not the same as P0 in staging.
3. **Run this first** — triage takes seconds and prevents wasted investigation time on a P3 while a P0 is burning.
