---
name: error-taxonomy
description: >
  This skill should be used when the user asks to "classify an error",
  "triage this stack trace", "archive this bug", "generate an error fingerprint",
  "identify the type of bug", "what kind of error is this", "is this a regression",
  or needs to parse, categorize, structure, or deduplicate information from
  error logs, stack traces, exception reports, or incident summaries.
  Also activate when running /triage or /archive-error commands.
version: 1.1.0
---

# Error Taxonomy Reference

## Classification Matrix

| Type | Primary Signal | Common Root Cause | Fastest First Diagnostic |
|------|----------------|-------------------|--------------------------|
| **Build** | Compile error, missing module, import failure | Dependency version mismatch, broken import path, lock file drift | `pip install` / `npm ci`, check lock file diff |
| **Runtime** | NullPointerException, TypeError, AttributeError, KeyError | Unguarded nullable, wrong type assumption, missing key | Stack trace → first non-library frame |
| **Performance** | p99 spike, request timeout, slow query log entry | N+1 query, missing DB index, unbounded loop, memory leak | Query plan, profiler output, heap snapshot |
| **Network** | Connection refused, ECONNRESET, DNS resolution failure | Service down, firewall rule, certificate expiry, port mismatch | `ping`, `curl -v`, check service health endpoint |
| **Flaky** | Passes 9/10 CI runs, fails non-deterministically | Race condition, hardcoded timing, shared/polluted test state | Run 20× in complete CI isolation; add timing instrumentation |
| **Config** | 500 on deploy, works in local/staging | Missing env var in production, secret rotation gap, feature flag state | Diff env vars between local and production environments |
| **Regression** | Worked before this commit/PR, broke on deploy | Unintended side effect of refactor, dependency bump | `git bisect` on failure window; compare behavior before/after PR |
| **Data** | Corrupt state, partial write, unexpected null in DB | Missing transaction boundary, write race condition, migration gap | Inspect DB state at failure timestamp; check migration log |

---

## Fingerprint Generation

A stable fingerprint enables deduplication — the same error recurring 50 times should produce one ticket, not fifty.

**Normalization steps before hashing:**
1. Remove all line numbers from the stack trace
2. Remove memory addresses and object IDs (`0x7f3a...` → `<addr>`)
3. Remove timestamps from the error message
4. Remove dynamic values from parameterized error messages (`"user 1234 not found"` → `"user <id> not found"`)
5. SHA-256 the normalized string → this is your `error_hash`

**Required fingerprint fields for `/archive-error`:**

| Field | How to Populate |
|-------|----------------|
| `error_hash` | SHA-256 of normalized stack trace (after steps above) |
| `component` | `service-name::module::function` — first non-library frame |
| `first_seen` | ISO 8601 timestamp of the earliest known occurrence |
| `last_seen` | ISO 8601 timestamp of most recent occurrence |
| `frequency` | Occurrence count in rolling 24h window |
| `status` | `new` \| `known` \| `regression` \| `resolved` |

---

## Severity Assignment (P0–P3)

| Severity | Condition | Expected Response |
|----------|-----------|-------------------|
| **P0** | Production down, active data loss, security breach, >10% users affected | Immediate all-hands; escalate out-of-hours |
| **P1** | Major feature broken, no workaround exists, SLO breach imminent | On-call response within 15 minutes |
| **P2** | Degraded functionality, workaround exists, <5% users affected | Next-business-day response |
| **P3** | Minor issue, cosmetic, or low-traffic code path | Backlog — prioritize in next sprint |

**P0 vs P1 discriminator**: Is there a workaround that unblocks the user? If yes, P1. If no, P0.

---

## Stack Trace Parsing Protocol

1. Find the **first non-library frame** — that is almost always the relevant application code
2. Extract: file path, function name, line number (before normalizing for fingerprint)
3. Check if the error type maps to a known root cause in the Classification Matrix before hypothesizing novel causes
4. If the trace is truncated, request the full trace — partial fingerprints produce false deduplication matches
5. Check the frame immediately **below** the first non-library frame for context — the calling function often reveals the precondition that was violated

See `references/taxonomy.md` for regex patterns for common error formats across Python, Node.js, Java, and Go.
