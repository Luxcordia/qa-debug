# Pessimistic QA Pattern Reference

Extended pattern library for negative, boundary, fuzz, and stress testing. Load this when designing a complete `/qa-plan` or `/chaos` scenario.

---

## Negative Test Catalog

### String Fields
| Input | What It Tests |
|-------|--------------|
| `""` | Empty string rejection |
| `" "` (whitespace only) | Trim + empty rejection |
| `"a"` | Minimum-length enforcement |
| `"a" * 10_001` | Max-length rejection |
| `"\x00"` | Null byte handling |
| `"\n\r\t"` | Control character handling |
| `"<script>alert(1)</script>"` | HTML/template injection at input boundary (does not escape — tests escaping at output) |
| `"'; DROP TABLE users; --"` | SQL-like syntax — tests ORM parameterization at input boundary only |
| `"𝕳𝖊𝖑𝖑𝖔"` | Unicode outside BMP (4-byte codepoints) |
| `"مرحبا"` + `"שלום"` | RTL text handling |
| `"A\u0300"` (A + combining grave) | Composed vs. decomposed Unicode (NFD vs NFC normalization) |

### Numeric Fields
| Input | What It Tests |
|-------|--------------|
| `0` | Zero (often causes division-by-zero or off-by-one) |
| `-1` | Negative where positive is required |
| `2^31 - 1` = `2147483647` | 32-bit signed max |
| `2^31` = `2147483648` | 32-bit signed overflow |
| `2^63 - 1` | 64-bit signed max |
| `float('nan')` | NaN propagation (NaN != NaN is true — breaks equality checks) |
| `float('inf')` | Infinity (breaks JSON serialization in Python) |
| `-0.0` | Negative zero (compares equal to 0 but serializes differently) |
| `0.1 + 0.2` | Float imprecision (`0.30000000000000004`) |

### Collection / Array Fields
| Input | What It Tests |
|-------|--------------|
| `[]` | Empty collection (often causes "index out of range" on `[0]` access) |
| `[item]` | Single-element (tests min-length and loop logic) |
| `[item] * 10_001` | Oversized collection (tests pagination, truncation, memory) |
| `[None]` | Collection containing null |
| `[item, item]` | Duplicate items (tests deduplication logic) |

### Object / Dict Fields
| Input | What It Tests |
|-------|--------------|
| `{}` | Empty object |
| `{"extra_key": "value", ...required_fields}` | Extra fields (should be ignored, not cause error) |
| Object with all optional fields omitted | Optional fields absence |
| `null` where object expected | Null object (most common crash pattern) |

---

## Boundary Value Analysis Templates

### The n-1 / n / n+1 Rule
For any constraint `x MUST be between MIN and MAX`:

```
Tests to write:
- input = MIN - 1   → expect rejection
- input = MIN       → expect acceptance
- input = MAX       → expect acceptance
- input = MAX + 1   → expect rejection
```

### Date / Time Boundary Cases
| Case | Value | Why It Matters |
|------|-------|---------------|
| Unix epoch | `1970-01-01T00:00:00Z` | Some systems treat 0 as null |
| 32-bit epoch overflow | `2038-01-19T03:14:07Z` | Affects systems using int32 for timestamps |
| Leap year Feb 29 | `2024-02-29`, `2100-02-29` (2100 is NOT a leap year) | Calendar edge |
| DST spring-forward | The clock skips 1 hour | Duration calculations can yield -1 hour |
| DST fall-back | The clock repeats 1 hour | Duplicate timestamps — which one is meant? |
| Far future | `9999-12-31` | UI and serialization overflow |
| Timezone midnight | `2024-03-01T00:00:00` in UTC-5 | Date comparisons shift by a day |

---

## Fuzz Vector Reference

### Encoding Attacks (Schema-Level — Not Security Testing)
```
\x00          # Null byte — truncates C strings
\xef\xbf\xbd  # UTF-8 replacement character (U+FFFD)
\ud800        # Surrogate half (invalid in UTF-8, valid in UTF-16)
\u202e        # Right-to-left override — reverses displayed text
\u200b        # Zero-width space — invisible but present in length checks
\ufeff        # BOM (byte order mark) — breaks parsers expecting clean start
```

### Structural Fuzzing
```python
# Deep nesting — test recursion limits
deeply_nested = {"a": {"a": {"a": ...}}}  # 100 levels

# Oversized array
large_array = [0] * 1_000_000

# Repeated keys (behavior is implementation-defined)
'{"key": 1, "key": 2}'  # Which value wins? Does parser error?

# Extra whitespace
"  value  "   # Does trim happen at boundary or deep in logic?
```

---

## Stress Test Scenario Templates

### Baseline Load (Verify Current Capacity)
```
Duration: 60 seconds
Ramp: 0 → target RPS over 10 seconds, hold 40 seconds, ramp down 10 seconds
Target: Current expected peak * 1.5
Measure: p50, p95, p99 latency + error rate
Accept if: p99 < SLA, error rate < 0.1%
```

### Spike Test (Sudden Traffic Burst)
```
Duration: 30 seconds
Pattern: 10s at baseline, 10s at 10× baseline (spike), 10s recovery
Measure: Time to first error, recovery time after spike ends
Accept if: System recovers within 30s, no data loss during spike
```

### Sustained Load (Memory Leak Detection)
```
Duration: 30 minutes (run in dedicated load env only)
Pattern: Constant load at 50% peak capacity
Measure: Memory growth over time (if linear, leak likely)
Accept if: Memory stabilizes after initial warmup
```

### Connection Exhaustion
```
Pattern: Open N connections simultaneously (N = pool limit * 1.5)
Measure: Does the (N+1)th connection fail fast or hang?
Accept if: Clean rejection with 429/503, not a hang or crash
```

---

## Tooling Reference by Stack

| Stack | Unit/Integration | Fuzz | Load |
|-------|-----------------|------|------|
| Python | pytest | Hypothesis | Locust |
| Node.js | Jest / Vitest | fast-check | k6 / Artillery |
| TypeScript | Vitest | fast-check | k6 |
| Go | go test | go-fuzz / dvyukov/go-fuzz | hey / vegeta |
| Java | JUnit 5 | jqwik | Gatling / JMeter |
| Rust | cargo test | cargo-fuzz (libFuzzer) | Criterion (benchmarks) |
