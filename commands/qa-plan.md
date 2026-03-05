---
description: Pessimistic QA test plan — negative, boundary, fuzz, and stress cases (proposals only)
argument-hint: "<feature name or function to test>"
---

# /qa-plan

> **Human-in-the-loop mode**: This command generates test PROPOSALS only. No tests are executed automatically. All output is a structured plan for you to review and hand to your test runner.

> If you see unfamiliar placeholders or need to check which tools are connected, see [CONNECTORS.md](../CONNECTORS.md).

Generate a full pessimistic QA test plan for a given feature or function. Covers negative, boundary, fuzz, and stress cases as a structured Markdown checklist and JSON test vector schema.

## Usage

```
/qa-plan $ARGUMENTS
```

## How It Works

```
┌──────────────────────────────────────────────────────────────────┐
│                   QA PLAN WORKFLOW                               │
├──────────────────────────────────────────────────────────────────┤
│  Step 1: UNDERSTAND THE FEATURE                                  │
│  ✓ Identify inputs, outputs, and expected behavior              │
│  ✓ Map the happy path and known edge cases                      │
│  ✓ Note external dependencies (APIs, DBs, queues)               │
│                                                                  │
│  Step 2: NEGATIVE CASES                                          │
│  ✓ Invalid inputs (wrong types, null, empty, malformed)         │
│  ✓ Missing required fields                                       │
│  ✓ Out-of-range values                                          │
│                                                                  │
│  Step 3: BOUNDARY CASES                                          │
│  ✓ Min/max values                                               │
│  ✓ Empty collections and single-element collections             │
│  ✓ Oversized payloads and truncation thresholds                 │
│                                                                  │
│  Step 4: FUZZ PLAN                                               │
│  ✓ Format-level variations (encoding, whitespace, special chars) │
│  ✓ Schema-level mutations (extra fields, missing fields, reorder)│
│  ✓ No exploit payloads — format stress only                     │
│                                                                  │
│  Step 5: STRESS / LOAD PLAN                                      │
│  ✓ Timeboxed and env-gated simulations                          │
│  ✓ Rate-limited and concurrency scenarios                        │
│  ✓ Resource exhaustion and timeout handling                      │
└──────────────────────────────────────────────────────────────────┘
```

## What I Need From You

- **Feature or function name** — what you want to test
- **Inputs and outputs** — what goes in, what comes out
- **Dependencies** — external services, databases, or APIs involved
- **Known constraints** — rate limits, size limits, auth requirements

## Output Format

```markdown
## QA Plan: [Feature / Function Name]

> All items below are PROPOSALS. Nothing is auto-executed.
> Hand this checklist to your test runner or paste into your test suite.

### Happy Path (baseline)
- [ ] [Nominal input → expected output]

---

### Negative Cases
- [ ] [Invalid type for field X] → expect [error code / message]
- [ ] [Null / missing required field Y] → expect [rejection with reason]
- [ ] [Out-of-range value for Z] → expect [boundary enforcement behavior]

---

### Boundary Cases
- [ ] [Minimum valid value for X] → expect [behavior]
- [ ] [Maximum valid value for X] → expect [behavior]
- [ ] [Empty collection input] → expect [behavior]
- [ ] [Single-element collection] → expect [behavior]
- [ ] [Oversized payload at N bytes] → expect [truncation / rejection]

---

### Fuzz Plan
- [ ] [Unicode / special characters in string fields] → expect [safe handling]
- [ ] [Extra unexpected fields in request body] → expect [ignored / rejected]
- [ ] [Fields in wrong order] → expect [still parsed correctly]
- [ ] [Deeply nested or circular structures] → expect [depth limit enforced]

---

### Stress / Load Plan (timeboxed — run only in dedicated load env)
- [ ] [N concurrent requests for T seconds] → expect [degradation curve / no crash]
- [ ] [Sustained load at X RPS for Y minutes] → expect [p99 latency stays under Z ms]
- [ ] [Rapid-fire duplicate requests] → expect [idempotency / deduplication]
- [ ] [Connection timeout / network drop mid-request] → expect [clean error, no partial state]
```

```json
{
  "feature": "",
  "generated_at": "",
  "test_vectors": [
    {
      "id": "neg-001",
      "category": "negative",
      "description": "",
      "input": {},
      "expected_behavior": "",
      "expected_status": ""
    },
    {
      "id": "bnd-001",
      "category": "boundary",
      "description": "",
      "input": {},
      "expected_behavior": "",
      "expected_status": ""
    },
    {
      "id": "fuz-001",
      "category": "fuzz",
      "description": "",
      "input": {},
      "expected_behavior": "",
      "expected_status": ""
    },
    {
      "id": "str-001",
      "category": "stress",
      "description": "",
      "config": {
        "duration_seconds": 0,
        "concurrency": 0,
        "rps": 0,
        "env": "load-test-only"
      },
      "expected_behavior": ""
    }
  ]
}
```

## Active MCP Connectors

**source-control (GitHub MCP):**
- Pull the function or module source to derive inputs and constraints automatically
- Check existing tests to avoid duplication

**project-tracker (Linear MCP):**
- Search for previously filed bugs against this feature to seed negative cases
- Attach the generated plan as a ticket or checklist

## Tips

1. **Start with the happy path** — know what correct looks like before inverting it.
2. **Check existing tests first** — use `/qa-plan` to fill gaps, not to duplicate coverage.
3. **Gate stress tests to isolated envs** — never run load scenarios against production or shared staging.
