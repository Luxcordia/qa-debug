---
description: Consumer-driven contract test design — schema drift detection, violation scenarios, pact definition
argument-hint: "<consumer service> → <provider service>"
---

# /contract

> **Human-in-the-loop mode**: All contract validation steps are PROPOSED as a test design plan. No requests are sent to any external service automatically. Consumer-driven contract patterns only — no third-party scanning or unsolicited probing of APIs you do not own.

> If you see unfamiliar placeholders or need to check which tools are connected, see [CONNECTORS.md](../CONNECTORS.md).

Design a consumer-driven contract test plan to prevent integration failures caused by API schema drift between services you own and control. Catches breaking changes at the contract boundary before they reach production.

## Usage

```
/contract $ARGUMENTS
```

## What I Need From You

- **Consumer service**: The service making the API call
- **Provider service**: The service being called
- **Current contract**: Known request/response schema (paste a sample payload, OpenAPI excerpt, or field list)
- **Concern**: What specific breaking change are you worried about? (field removal, type narrowing, version bump, new required field, enum expansion)

## Output Format

```markdown
## Contract Plan: [Consumer] → [Provider]

### 1. Current Contract Snapshot
- **Endpoint**: [HTTP method + path + version, e.g. POST /api/v2/orders]
- **Request schema**:
  ```json
  { "field": "type (required|optional)", ... }
  ```
- **Response schema**:
  ```json
  { "field": "type (nullable|required)", ... }
  ```
- **Breaking change risk zones**:
  - Fields that are currently nullable (could become required without notice)
  - Fields typed as `string` (could be narrowed to a specific enum)
  - Versioned paths (v1 → v2 migration may not be communicated in advance)
  - Undocumented fields the consumer currently relies on silently

---

### 2. Pessimistic Contract Violations to Test

| # | Violation Scenario | How to Simulate | Expected Consumer Behavior |
|---|-------------------|-----------------|---------------------------|
| 1 | Provider removes required response field | Mock response omits the field entirely | Consumer throws a typed, named error — not an unhandled crash |
| 2 | Provider changes field type (string → integer) | Mock returns wrong type | Consumer validates at boundary and rejects gracefully |
| 3 | Provider adds new required request field | Old consumer sends request without new field | Provider returns HTTP 400; consumer handles it with a clear error |
| 4 | Provider renames a field (`id` → `uuid`) | Mock uses new name only | Consumer does not silently receive `undefined`; fails loudly |
| 5 | Provider returns empty array instead of object | Mock changes response shape | Consumer does not crash on `.property` access against array |
| 6 | Provider expands an enum with an unknown value | Mock returns new enum value | Consumer's switch/match has a default/fallthrough case — no unhandled branch |
| 7 | Provider returns HTTP 204 instead of 200 with body | Mock omits body on success | Consumer does not assume a body exists on all 2xx responses |

---

### 3. Execution Plan (Awaiting Approval)
*All testing is mock/stub-based — no real provider is contacted.*

| # | Goal | Step | Safe? |
|---|------|------|-------|
| 1 | Stand up provider mock at current schema | [Configure WireMock / msw / nock with current contract] | ✅ Local/CI only |
| 2 | Run consumer test suite against mock | `[test command]` | ✅ No real service contacted |
| 3 | Mutate mock to violation scenario #N | [Edit mock to introduce the schema violation] | ✅ Controlled, isolated |
| 4 | Verify consumer fails with a typed error (not a crash) | `[test command — expect specific failure]` | ✅ Expected failure, validated |

⚠️ **STOP** — Await approval before configuring any mock server or starting test runs.

---

### 4. Formal Contract Definition (Pact-Style)
*Use this as the basis for a contract test in CI. Commit to the consumer's repository.*

```json
{
  "consumer": "[consumer-service]",
  "provider": "[provider-service]",
  "interactions": [
    {
      "description": "[action being tested, e.g. 'place order']",
      "request": {
        "method": "POST",
        "path": "/api/v1/orders",
        "headers": { "Content-Type": "application/json" },
        "body": { "field": "value" }
      },
      "response": {
        "status": 200,
        "body": {
          "id": "(type) string",
          "status": "(enum) active | inactive",
          "total": "(type) number"
        }
      }
    }
  ]
}
```

---

### 5. CI Integration Recommendation
- Add this contract test as a **required gate** on the provider's repository, not just the consumer's
- Run the consumer pact against every provider commit — fail the build if the contract breaks
- Recommended tools by use case:
  - **[Pact.io](https://pact.io)** — language-agnostic, broker-hosted, best for microservice meshes
  - **[Schemathesis](https://schemathesis.readthedocs.io)** — OpenAPI-driven, property-based contract fuzzing
  - **[Dredd](https://dredd.org)** — API Blueprint / OpenAPI, good for REST-first teams
```

## Active MCP Connectors

**source-control (GitHub MCP):**
- Pull the current OpenAPI spec or schema definition from the provider repository to populate the Contract Snapshot automatically
- Check recent provider commits for schema-changing PRs that may have already introduced undetected drift

**project-tracker (Linear MCP):**
- Search for previously filed integration failures between this consumer and provider
- Create one tracking task per unresolved contract violation found in Step 2

## Tips

1. **Consumer defines the contract, not the provider** — the consumer declares what it needs; the provider commits to honoring it in CI.
2. **Silent nulls are the most dangerous violations** — a missing field resolving to `undefined` causes crashes deep in logic, not at the API boundary where they are easy to catch.
3. **Add contract tests before versioning, not after** — retroactive contracts are much harder to enforce and often miss pre-existing violations.
4. **Run after `/qa-plan`** — use `/contract` specifically for integration-layer boundaries. `/qa-plan` covers unit-level behavior; this command covers service-to-service trust.
