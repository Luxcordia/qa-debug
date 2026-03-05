---
description: Human-in-the-loop debugging — IDEAL framework, proposal-only, approval required at each step
argument-hint: "<error text or problem description>"
---

# /debug

> **Human-in-the-loop mode**: This command ONLY proposes steps and waits for your approval. Nothing executes automatically. All diagnostics target systems and code you own and control. No exploitation or offensive security guidance is provided. Potentially destructive steps are explicitly labeled and require separate confirmation.

> If you see unfamiliar placeholders or need to check which tools are connected, see [CONNECTORS.md](../CONNECTORS.md).

Run a structured debugging and reliability QA session — from reproduction to root cause, fix, and pessimistic test expansion.

## Usage

```
/debug $ARGUMENTS
```

## How It Works (IDEAL Framework)

```
┌──────────────────────────────────────────────────────────────────┐
│                     DEBUG WORKFLOW                               │
├──────────────────────────────────────────────────────────────────┤
│  Step 1: IDENTIFY & REPRODUCE                                    │
│  ✓ Parse expected vs. actual behavior                            │
│  ✓ Classify issue type and severity                              │
│  ✓ Determine scope (environment, OS, affected users/versions)    │
│                                                                  │
│  Step 2: DIAGNOSE — Evidence Plan (Awaiting Approval)            │
│  ✓ Propose numbered, read-only diagnostic steps                  │
│  ✓ Label each step with its goal, command, and why it is safe    │
│  ✓ STOP and wait for approval + returned outputs                 │
│                                                                  │
│  Step 3: EVALUATE HYPOTHESES                                     │
│  ✓ Form 1–3 hypotheses based on returned evidence               │
│  ✓ Propose a minimal discriminating test for each               │
│  ✓ Confirm root cause before proposing any fix                   │
│                                                                  │
│  Step 4: ACTION & RESOLVE                                        │
│  ✓ Propose exact code/config fix with explanation                │
│  ✓ Include rollback strategy                                     │
│  ✓ Suggest regression tests to prevent recurrence               │
│                                                                  │
│  Step 5: PESSIMISTIC QA EXPANSION (proposal only)               │
│  ✓ Generate negative, boundary, fuzz, and stress test designs   │
│  ✓ Emit a structured JSON error archive record                   │
└──────────────────────────────────────────────────────────────────┘
```

## What I Need From You

- **Exact error text** — paste verbatim; do not paraphrase
- **Repro steps** — the exact sequence that triggers the issue
- **Expected vs. actual** — what should happen vs. what does
- **Environment** — OS, runtime version, WSL/container/local, branch
- **Recent changes** — commits, dependency bumps, config edits, deploys

## Output Format

```markdown
## Debug Report: [One-Line Issue Summary]

### 1. Intake & Current Assessment
- **Expected**: [what should happen]
- **Actual**: [what happens instead]
- **Environment**: [OS / runtime / branch / deploy target]
- **Repro steps**: [numbered sequence]
- **What changed recently**: [commits, packages, config]
- **Impact & severity**: [who is affected, how critical]
- **Initial working hypothesis**: [first instinct on root cause]

---

### 2. Evidence Plan (Awaiting Approval)
*Review and approve the following read-only diagnostic steps before executing.*

| # | Goal | Command / File to Inspect | Why Safe | Expected Output to Paste Back |
|---|------|--------------------------|----------|-------------------------------|
| 1 | [goal] | `[command]` | [read-only / local / non-destructive] | [description] |
| 2 | ...  | ...                       | ...      | ...                           |

⚠️ **STOP** — Paste back the outputs from the steps above before proceeding.

---

### 3. Hypotheses (after evidence)
*To be completed once outputs are returned.*

**Hypothesis A**: [description]
- Supporting signals: [what in the output supports this]
- Discriminating test: [minimal, safe test to confirm or refute]
- Expected outcome if true: [description]

**Hypothesis B**: [if applicable]

---

### 4. Proposed Fix (after root cause confirmed)
- **Root Cause**: [confirmed explanation]
- **Fix** (code / config):
  ```[language]
  [exact change]
  ```
- **Rollback Plan**: [how to revert safely if the fix causes regressions]
- **Regression Tests to Add**: [specific test cases]

---

### 5. Pessimistic QA Test Expansion (proposal only — not auto-executed)

- **Negative cases**: [invalid inputs, missing fields, wrong types]
- **Boundary cases**: [min/max values, empty collections, oversized payloads]
- **Fuzz plan**: [format-level and schema-level variations; no exploit payloads]
- **Stress/load plan**: [timeboxed, env-gated, rate-limited simulations]

---

### 6. Error Archive Record

\`\`\`json
{
  "timestamp": "",
  "fingerprint": "",
  "app_version": "",
  "environment": "",
  "error_text": "",
  "stack_trace": "",
  "repro_steps": [],
  "suspected_component": "",
  "root_cause": "",
  "fix_summary": "",
  "tests_to_add": [],
  "status": "new | known | regression"
}
\`\`\`
```

## Active MCP Connectors

**source-control (GitHub MCP):**
- Propose a `git log` or `git bisect` range targeting the suspected commit window
- Cross-reference the error timeline against recent PRs

**monitoring (Sentry MCP):**
- Propose queries to pull error rates, latency spikes, and metrics at the failure timestamp
- Highlight correlated config or deployment changes

**project-tracker (Linear MCP):**
- Search for duplicate or related bug reports
- Draft a post-mortem or bug ticket once root cause is confirmed

## Tips

1. **Paste errors verbatim** — exact text is critical; paraphrasing loses signal.
2. **Name what changed** — recent deploys, dependency bumps, and env var edits are the top suspects.
3. **Include environment context** — "works in WSL but not in Windows" or "only on large payloads" cuts investigation time in half.
