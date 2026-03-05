---
description: Blameless post-incident report — 5 Whys root cause, impact, timeline, action items
argument-hint: "<incident title or brief summary>"
---

# /postmortem

> **Human-in-the-loop mode**: This command generates a structured post-mortem proposal from the information you provide. No data is transmitted externally. All analysis is based solely on what you share here.

> If you see unfamiliar placeholders or need to check which tools are connected, see [CONNECTORS.md](../CONNECTORS.md).

Generate a structured, blameless post-mortem report from an incident. Follows the 5 Whys method for root cause analysis and outputs a complete, publishable incident report with specific, assignable action items.

## Usage

```
/postmortem $ARGUMENTS
```

## What I Need From You

- **Incident summary**: What broke, when, for how long, who was affected
- **Timeline**: Key events with timestamps — minute-level precision preferred (vague times produce useless timelines)
- **Contributing factors**: What conditions allowed this to happen (process gaps, tooling failures, monitoring blind spots)
- **Mitigation taken**: What action stopped the bleeding, and exactly when
- **Status**: Fully resolved, or is ongoing risk present?

## Output Format

```markdown
## Post-Mortem: [Incident Title] — [Date]

> **Blameless.** The goal is to learn from the system, not to assign fault to individuals.
> Systems create the conditions for failure; people operate within those systems.

---

### Impact
- **Duration**: [HH:MM UTC start] → [HH:MM UTC resolution] ([total minutes/hours of impact])
- **Users affected**: [scope — number, region, feature set, or % of traffic]
- **Severity**: P[0–3] — [one-line justification]
- **SLO impact**: [Was an error budget consumed? How many minutes of the monthly budget? Will this trigger a review?]

---

### Timeline

| Time (UTC) | Event |
|------------|-------|
| HH:MM | Incident begins — [first observable symptom] |
| HH:MM | First automated alert fires (or: no alert fired — detection gap) |
| HH:MM | First human becomes aware |
| HH:MM | On-call engineer acknowledges and begins investigation |
| HH:MM | Root cause hypothesized |
| HH:MM | Mitigation applied |
| HH:MM | Service restored / incident resolved |
| HH:MM | This post-mortem initiated |

**Detection lag**: [Time between incident start and first human awareness — and why]

---

### Root Cause — 5 Whys

> Stop at the answer that is a system condition you can change. Blaming a person is not a root cause.

1. **Why did [observable symptom] happen?** → [immediate technical cause]
2. **Why did [cause 1] happen?** → [contributing technical condition]
3. **Why did [cause 2] happen?** → [process or design gap]
4. **Why did [cause 3] happen?** → [organizational or architectural condition]
5. **Why did [cause 4] happen?** → [**root cause** — the deepest preventable condition in the system]

**Root cause summary**: [One sentence a non-technical stakeholder can understand]

---

### Contributing Factors
- **System condition**: [What architectural weakness or design assumption allowed this to occur]
- **Process gap**: [What human or team process was absent, unclear, or failed]
- **Monitoring blind spot**: [What alert did not fire that should have, and at what threshold]
- **Detection lag cause**: [Why was the gap between incident start and awareness as long as it was]
- **Response gap**: [If applicable — what slowed mitigation once the incident was known]

---

### Action Items

> Action items must be **specific, assignable, and verifiable**. "Improve monitoring" is not an action item.

| # | Action | Owner | Due Date | Prevents |
|---|--------|-------|----------|----------|
| 1 | [Specific fix: e.g. "Add circuit breaker with 5-failure threshold to PaymentService → BankAPI call"] | [team/person] | [YYYY-MM-DD] | [Specific recurrence scenario this prevents] |
| 2 | [Add alert: e.g. "Fire PagerDuty when error rate on /checkout exceeds 2% for 3 consecutive minutes"] | [team] | [YYYY-MM-DD] | [Reduces detection lag from N minutes to <3 minutes] |
| 3 | [Update runbook: e.g. "Add step 4.b: check DB connection pool exhaustion before restarting app"] | [team] | [YYYY-MM-DD] | [Reduces mitigation time for this class of failure] |
| 4 | [Add test: e.g. "Add /qa-plan coverage for null cart state in CartTotal.render"] | [team] | [YYYY-MM-DD] | [Prevents this regression from shipping undetected] |

---

### Lessons Learned
- **What the system revealed**: [Architectural assumption that was wrong or never validated]
- **What our tests missed**: [Test category that would have caught this — reference /qa-plan or /mutation for follow-up]
- **What our alerts missed**: [Monitoring gap — reference /chaos for follow-up resilience planning]
- **What we did well**: [What part of the incident response worked — reinforce it]
```

## Active MCP Connectors

**source-control (GitHub MCP):**
- Pull the specific commit or PR that introduced the change correlated with the incident onset
- Cross-reference the timeline against recent deploy history using git log to confirm causation vs. coincidence

**monitoring (Sentry MCP):**
- Pull the error rate chart and alert history for the incident window to fill the timeline with precise, evidence-based timestamps
- Confirm detection lag and resolution time from monitoring data, not from memory

**project-tracker (Linear MCP):**
- Search for prior incidents with the same contributing factors — recurring root causes indicate systemic debt
- Create one task per action item directly from the Action Items table, linked to this post-mortem

## Tips

1. **Blameless means systemic** — if the root cause names a person ("Alice deployed a bad config"), keep asking why the system allowed it. The system created the conditions.
2. **Timeline precision matters** — "around 3pm" is not a timeline. Use logs, alerts, and monitoring data to get minute-level accuracy.
3. **Run after `/archive-error`** — use `/postmortem` for P0/P1 incidents once the error is archived and root cause is confirmed.
4. **Action items must be verifiable** — for every action item, ask: "How would we prove this was completed?" If you cannot write a test or alert that answers that question, the item is too vague.
5. **Detection lag is always an action item** — if the incident started before any alert fired, that gap is a non-negotiable priority to close.
