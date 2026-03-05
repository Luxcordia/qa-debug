---
description: Test suite quality audit via mutation analysis — surviving mutants, assertion gaps, kill score
argument-hint: "<module name or file path>"
---

# /mutation

> **Human-in-the-loop mode**: All mutation testing steps are PROPOSED as a plan only. No mutation framework runs automatically. All suggestions target owned test suites in local or CI environments. Requires explicit approval at every execution step.

> If you see unfamiliar placeholders or need to check which tools are connected, see [CONNECTORS.md](../CONNECTORS.md).

Audit the quality of your existing test suite by designing a mutation testing plan — deliberately introducing small, targeted code faults and measuring whether your tests detect them. A test suite that cannot kill mutations does not actually verify behavior; it only verifies execution.

## Usage

```
/mutation $ARGUMENTS
```

## What I Need From You

- **Language/stack**: Python, Node.js, TypeScript, Go, Java, etc.
- **Test framework**: pytest, Jest, Vitest, go test, JUnit, etc.
- **Target module**: The specific file or function to audit (mutate narrowly — not the whole codebase)
- **Current test coverage %**: If known — note that line coverage alone is insufficient; mutation score reveals assertion quality

## Output Format

```markdown
## Mutation Audit Plan: [Module Name]

### 1. Current Baseline Assessment
- **Coverage %**: [line / branch / function — all three if available]
- **Known weak spots**: [functions with no assertions, tests that only assert no-exception, happy-path-only suites]
- **Recommended scope**: [single file or function — mutating the entire codebase is slow and produces unactionable noise]

---

### 2. Mutation Strategy

**Recommended tool**: [Mutmut (Python) | Stryker (JS/TS) | go-mutesting (Go) | PIT/Pitest (Java)]

**Mutation operators to apply** (in priority order — highest signal first):

| # | Operator | Example | Why It Matters |
|---|----------|---------|---------------|
| 1 | Boundary shift | `> 0` → `>= 0` | Most tests miss off-by-one errors |
| 2 | Boolean negation | `True` → `False`, `&&` → `\|\|` | Catches reversed logic |
| 3 | Return value replacement | `return result` → `return None` | Reveals unasserted return values |
| 4 | Arithmetic substitution | `+` → `-`, `*` → `/` | Catches purely execution-asserting tests |
| 5 | Statement deletion | Remove a guard clause entirely | Exposes unchecked defensive code paths |

---

### 3. Execution Plan (Awaiting Approval)

| # | Goal | Command | Safe? |
|---|------|---------|-------|
| 1 | Confirm test suite passes cleanly (baseline) | `[test command — all tests green]` | ✅ Local only |
| 2 | Run mutation engine scoped to target file | `[mutmut run --paths-to-mutate path/to/file.py]` | ✅ No production side effects |
| 3 | Display surviving mutants | `[mutmut results]` | ✅ Read-only |

⚠️ **STOP** — Paste back the mutation score and full surviving mutants list before proceeding to analysis.

---

### 4. Surviving Mutants Analysis (after results)
*Each surviving mutant is a behavior your test suite does NOT verify.*

| Mutant ID | What Changed | Why It Survived | Test to Add |
|-----------|-------------|-----------------|-------------|
| M-001 | `> 0` → `>= 0` | No test exercises zero as input | Assert `fn(0)` raises `ValueError` or returns defined fallback |
| M-002 | `return result` → `return None` | Tests call function but never assert return value | Add `assertIsNotNone(result)` and assert specific value |
| M-003 | Removed guard clause `if x is None` | No null-input test exists | Add test with `None` argument, assert typed error |

---

### 5. Test Suite Health Report

- **Mutation score**: X% killed (target: >80% for critical business logic, >60% for utilities and adapters)
- **Risk zones**: [functions with lowest kill rate that carry the highest business risk]
- **Priority tests to write**: [ranked by mutation kill impact, not by line coverage gap]
- **False confidence zones**: [areas with 100% line coverage but <50% mutation score — these are the most dangerous]
```

## Active MCP Connectors

**source-control (GitHub MCP):**
- Pull the target module source directly to derive mutation candidates from the actual production code
- Check CI configuration for existing mutation testing steps to avoid duplication

**project-tracker (Linear MCP):**
- Search for bugs previously filed against the target module — surviving mutants often correspond exactly to real production bugs
- Create one task per priority test identified in the Health Report

## Tips

1. **Mutate narrowly** — run mutation on one file or function at a time; full-suite mutation is slow and produces unactionable noise.
2. **Line coverage is not test quality** — 100% line coverage with zero typed assertions scores 0% mutation kill rate.
3. **Surviving mutants are behavior specifications your tests don't enforce** — each one is a risk, not just a gap.
4. **Run after `/qa-plan`** — use `/mutation` to verify that the tests proposed in `/qa-plan` would actually kill the right mutants. If they wouldn't, the test designs need strengthening.
