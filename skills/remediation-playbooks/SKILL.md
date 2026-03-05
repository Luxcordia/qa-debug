---
name: remediation-playbooks
description: >
  This skill should be used when the user asks to "fix this bug", "how do I prevent this
  from happening again", "design a rollback plan", "add a circuit breaker",
  "implement retry with backoff", "harden this service", "what pattern should I use
  to handle this failure", "how do I make this more resilient", "graceful degradation",
  or needs guidance on reliability engineering patterns, rollback strategies,
  architectural hardening decisions, or fail-safe design. Also activate when running
  /debug (step 4: propose fix) or /postmortem (action items) commands.
version: 1.1.0
---

# Remediation Playbook Library

## Pattern Selection Guide

Match the failure mode to the right pattern before proposing code:

| Failure Mode | Primary Pattern | Secondary Pattern |
|-------------|----------------|-------------------|
| External service goes down | Circuit Breaker | Fallback / Graceful Degradation |
| External service is slow | Timeout + Retry | Bulkhead |
| Burst traffic exceeds capacity | Rate Limiting + Queue | Bulkhead |
| Retry storms amplify outages | Exponential Backoff + Jitter | Circuit Breaker |
| Write fails mid-operation | Idempotency Key | Reversible Migration |
| Bad deploy corrupts state | Feature Flag | `git revert` + re-deploy |

---

## Core Reliability Patterns

### Circuit Breaker
Prevents cascading failure when a dependency is unhealthy:
- **Closed state**: requests pass through; count failures
- **Open state**: triggered after N consecutive failures (typically 5); all requests fail fast
- **Half-open probe**: after timeout (typically 30–60s), allow one request through; re-open if it fails, close if it succeeds
- Use when: calling any external service, database, or queue from application code

### Retry with Exponential Backoff + Jitter
```
wait = min(base * 2^attempt, max_wait) + random(0, base)
```
- Jitter is **non-optional** — without it, synchronized retries amplify the outage
- Always set a `max_attempts` ceiling (3–5 for synchronous; higher for async workers)
- Do not retry non-idempotent operations (POST creating resources) unless you add idempotency keys

### Timeout — Mandatory on All Network Calls
Never let a network call block indefinitely:
- Set **connect timeout** and **read timeout** separately
- Default starting point: connect = 2s, read = 10s — adjust to actual SLA requirements
- Document the timeout values; undocumented timeouts become incidents

### Bulkhead
Isolate resource pools per consumer to limit blast radius:
- Separate thread pools or connection pools for critical vs. non-critical callers
- When one consumer saturates its pool, others are unaffected
- Use when: multiple callers share a single downstream dependency with finite connection limits

### Fallback / Graceful Degradation
Return a safe default when the primary path fails:
- Return stale cached data (with staleness indicator) instead of an error
- Return a partial response (what you have) instead of blocking on what you don't
- Never return a plausible but wrong result silently — make the degradation observable

---

## Rollback Strategies by Change Type

| Change Type | Rollback Method | Estimated Time |
|------------|----------------|----------------|
| Code deploy | `git revert` + re-deploy, or feature flag → off | Minutes |
| DB migration | Run reversible `down()` migration | Minutes–hours (depends on row count) |
| Config change | Revert to previous value in version control | Seconds |
| Dependency bump | Pin to previous version in lock file; re-install | Minutes |
| Infrastructure change | Terraform `apply` previous state | Minutes–hours |

**Non-negotiable rollback rules:**
- Always write a `down()` migration — test it in CI before the PR merges
- Never drop a column in the same migration that stops writing to it (deploy in two steps: stop writing, then drop)
- Pin previous dependency versions in lock file before bumping; a revert should be one-line

---

## Escalation Decision Matrix

**Escalate if:**
- Blast radius affects more than one team's service boundary
- Data integrity is at risk (partial writes, corrupt state in production)
- There is a security implication (credential exposure, privilege escalation)
- The fix requires a production database migration with significant downtime

**Fix locally if:**
- Root cause is confirmed (not just hypothesized)
- The fix is isolated to a single component
- The fix is fully reversible with a clean rollback plan
- No user-facing data mutation is involved

See `references/playbooks.md` for extended patterns including distributed tracing, database-specific patterns, frontend resilience, and async/queue failure modes.
