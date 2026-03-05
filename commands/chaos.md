---
description: Controlled fault injection planning — blast radius, mock scenarios, resilience verdict
argument-hint: "<component or service to stress>"
---

# /chaos

> **Human-in-the-loop mode**: All fault injection scenarios are PROPOSED ONLY as mock/toggle-based test designs for systems you own and control. No commands execute automatically. No real infrastructure is targeted or attacked. Requires explicit approval at every step.

> If you see unfamiliar placeholders or need to check which tools are connected, see [CONNECTORS.md](../CONNECTORS.md).

Design a controlled chaos engineering test plan to validate system resilience through deliberate, safe fault simulation. Targets owned environments only — local, staging, or purpose-built chaos labs.

## Usage

```
/chaos $ARGUMENTS
```

## What I Need From You

- **Target component**: Which service, function, or integration to stress
- **Environment**: Local / staging / controlled test env (never production without explicit gating)
- **Dependencies**: List of external services, DBs, APIs this component relies on
- **Current failure behavior**: What happens today when a dependency goes down?
- **Acceptable degradation**: What is the expected graceful fallback?

## Output Format

```markdown
## Chaos Plan: [Component Name]

### 1. Blast Radius Assessment
- **Target**: [component]
- **Upstream dependencies**: [list]
- **Downstream consumers**: [list]
- **Single points of failure**: [any dependency with no fallback — highest priority]
- **Estimated blast radius if failure cascades**: [description of worst-case propagation]

---

### 2. Fault Injection Scenarios (Proposal Only — Mock/Toggle-Based)

| # | Scenario | Injection Method | Expected Graceful Behavior | Failure Signal |
|---|----------|-----------------|---------------------------|----------------|
| 1 | DB connection timeout | Mock timeout at ORM layer | Retry with exponential backoff | 500 after N retries, logged |
| 2 | API rate limit exceeded | Return HTTP 429 from mock | Queue + retry with jitter | Alert fires, no data loss |
| 3 | Null/empty payload from upstream | Inject null at adapter boundary | Default value or schema rejection | No panic/crash |
| 4 | Upstream latency spike (5× p99) | Add artificial delay in mock | Request timeout fires cleanly | User sees degraded UX, not crash |
| 5 | Partial response (truncated body) | Mock returns incomplete JSON | Parsing failure handled explicitly | Error logged, no silent data corruption |
| 6 | Dependency cold start (first request after restart) | Block mock for 5s before responding | Caller retries with backoff | No timeout cascade to other callers |

---

### 3. Execution Plan (Awaiting Approval)
*Read-only setup + mock configuration steps only. No live system is modified.*

| # | Goal | Step | Safe? |
|---|------|------|-------|
| 1 | Confirm environment is fully isolated | [env check command] | ✅ Read-only |
| 2 | Verify no production routing is reachable | [network/env validation] | ✅ Read-only |
| 3 | Enable fault toggle for scenario #1 | [feature flag or mock config path] | ✅ Local/staging only |
| 4 | Run target component under fault | [test run command, scoped] | ✅ Controlled |

⚠️ **STOP** — Await explicit approval before any mock is enabled or fault toggle is flipped.

---

### 4. Resilience Verdict (after results)
- **Passes**: [scenarios where fallback worked exactly as designed]
- **Failures**: [scenarios where the system did NOT degrade gracefully]
- **Silent failures**: [scenarios that produced no error but left corrupted or partial state]
- **Cascades**: [scenarios where one fault propagated to a second component]
- **Remediation required**: [specific pattern needed — circuit breaker / retry / fallback / bulkhead]

---

### 5. Hardening Recommendations
- [Specific code pattern: circuit breaker, bulkhead, timeout, retry with jitter — not vague advice]
- [Observability gap: what metric or alert is absent that would detect this failure mode in production]
- [Runbook gap: what on-call procedure does not yet exist for this scenario]
```

## Active MCP Connectors

**source-control (GitHub MCP):**
- Pull the dependency graph for the target component to auto-generate the blast radius section
- Check for existing retry or circuit-breaker patterns to avoid duplicating work

**monitoring (Sentry MCP):**
- Pull current p99 latency and error rate baselines to calibrate "acceptable degradation" thresholds precisely
- Identify which failure modes already have alerts and which are currently blind spots

**project-tracker (Linear MCP):**
- Search for previously filed resilience, timeout, or cascading failure issues against this component
- Create hardening tickets directly from the Recommendations section once the plan is approved

## Tips

1. **Never target production** — chaos tests belong in isolated environments with no shared state, queues, or databases.
2. **Define blast radius before injecting** — know what can cascade before you pull the fault lever.
3. **Instrument first, inject second** — if you cannot observe the failure, you cannot validate the recovery.
4. **Run after `/qa-plan`** — use `/chaos` to stress the system at the integration layer once unit-level tests are green.
5. **Silent failures are worse than crashes** — a crash is loud; a silent data corruption is invisible until it's catastrophic.
