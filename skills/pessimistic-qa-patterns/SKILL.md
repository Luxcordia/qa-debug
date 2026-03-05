---
name: pessimistic-qa-patterns
description: >
  This skill should be used when the user asks to "generate negative test cases",
  "design boundary tests", "plan fuzz testing", "design stress or load tests",
  "think pessimistically about testing", "assume the system will fail",
  or needs guidance on failure-first test design, chaos scenario planning,
  adversarial QA methodology, or any form of testing that starts from the
  assumption that inputs will be invalid, limits will be exceeded, or
  dependencies will be unavailable. Also activate when running /qa-plan or /chaos commands.
version: 1.1.0
---

# Pessimistic QA Pattern Library

## Core Philosophy

Assume the system **will** fail. Every test should answer: "What is the most damaging way this could break, and does the system fail gracefully?"

Optimistic testing asks: "Does the happy path work?" Pessimistic testing asks: "How badly does it fail when it doesn't, and can we tell the difference between a graceful degradation and a silent catastrophe?"

**The ordering principle**: Negative → Boundary → Fuzz → Stress. Catching failures early is cheaper than discovering them under load.

---

## Negative Test Patterns

Apply to every public function boundary and API endpoint:

- Null/undefined for every required field — separately, not all at once
- Empty string where non-empty is required
- Wrong type at every field (int where string expected, array where object expected, object where scalar expected)
- Oversized payload (10×, 100× expected max — test truncation and rejection, not just success)
- Undersized payload (0 bytes, 1 byte)
- Malformed encoding (UTF-8 violations, mixed line endings, null bytes `\x00`)

See `references/patterns.md` for the full negative pattern catalog with code-level examples.

---

## Boundary Value Analysis

Apply the **n-1, n, n+1** rule to every numeric constraint:

- Exactly at limit, one below, one above
- Integer overflow: `MAX_INT`, `MIN_INT`, `MAX_INT + 1`
- Float precision edges: `0.1 + 0.2 ≠ 0.3`, `NaN`, `Infinity`, `-0`, denormalized floats
- Date edges: leap year (Feb 29), DST transition midnight, timezone boundary, Unix epoch 0, far-future timestamps (year 9999, year 2038 for 32-bit timestamps)
- String length: 0 chars, 1 char, exactly at limit, limit+1

---

## Fuzz Strategy (Non-Exploitative, Schema-Level Only)

Format-level stress only — no exploit payloads, no security testing of systems you do not own:

- Random Unicode (emoji, RTL chars, zero-width joiners, combining diacritics, Hangul jamo)
- Deeply nested structures (50-level, 100-level JSON nesting — test depth limits)
- Extremely long strings (10K, 1M chars — test truncation and memory behavior)
- Repeated keys in JSON objects (parser behavior is implementation-defined)
- Circular reference simulation (detect and reject cleanly — do not crash)
- Whitespace-only strings where trimmed non-empty is required

---

## Stress Test Protocol

Always environment-gated — staging or dedicated load environment, **never production**:

1. Define the ceiling metric **before** starting (max RPS, max concurrent connections, max payload size)
2. Set a hard time limit (60 seconds default; extend only for sustained-load SLA scenarios)
3. Measure all four dimensions: p50, p95, p99 latency **and** error rate — throughput alone is misleading
4. Watch for: memory growth under sustained load (leak), connection pool exhaustion, graceful degradation vs. hard crash, recovery time after load ends

See `references/patterns.md` for stress scenario templates and tooling recommendations by stack.

---

## Failure Classification

| Failure Mode | Test Category | Most Dangerous If Missed |
|-------------|--------------|--------------------------|
| Crash on bad input | Negative | User-facing 500, data loss |
| Off-by-one in limit enforcement | Boundary | Allows data past quota silently |
| Encoding corruption | Fuzz | Silent data corruption in DB |
| Degradation under load | Stress | SLO breach, cascading failure |
| Silent null propagation | Negative | Wrong results returned as correct |
