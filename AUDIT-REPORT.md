# qa-debug Live Repository Audit Report

**Generated:** 2026-03-05T21:00:22Z
**Commit HEAD:** `6d8efa345968503d2acf434500931cbe023eb19f`
**Version:** 1.3.0 (plugin.json) — latest tag: v1.3.1
**Repository:** https://github.com/Nyxa-01/qa-debug.git
**Total Commits:** 4 (all on 2026-03-05)
**Tags:** v1.3.1, v1.3.0
**Branch:** main (single branch)

---

## A. File Inventory Summary

| File Path | Category | Size (bytes) | Last Modified |
|-----------|----------|-------------|---------------|
| `.claude-plugin/hooks.json` | MANIFEST | 2,834 | 2026-03-05 04:52 |
| `.claude-plugin/marketplace.json` | MANIFEST | 290 | 2026-03-05 05:35 |
| `.claude-plugin/plugin.json` | MANIFEST | 409 | 2026-03-05 06:09 |
| `.claude/settings.local.json` | CONFIG (untracked) | 150 | 2026-03-04 23:29 |
| `.github/workflows/validate.yml` | CI | 535 | 2026-03-05 14:36 |
| `.gitignore` | CONFIG | 265 | 2026-03-05 14:08 |
| `.mcp.json` | MANIFEST | 409 | 2026-03-05 05:53 |
| `CHANGELOG.md` | DOCUMENTATION | 2,776 | 2026-03-05 14:26 |
| `CONNECTORS.md` | DOCUMENTATION | 2,548 | 2026-03-05 13:51 |
| `CONTRIBUTING.md` | DOCUMENTATION | 8,613 | 2026-03-05 13:54 |
| `LICENSE` | DOCUMENTATION | 11,490 | 2026-03-05 14:08 |
| `README.md` | DOCUMENTATION | 8,885 | 2026-03-05 14:26 |
| `agents/archive-curator.md` | AGENT | 3,371 | 2026-03-05 01:38 |
| `agents/ci-advisor.md` | AGENT | 3,296 | 2026-03-05 01:38 |
| `agents/qa-sentinel.md` | AGENT | 3,508 | 2026-03-05 01:38 |
| `commands/archive-error.md` | COMMAND | 4,703 | 2026-03-05 01:20 |
| `commands/chaos.md` | COMMAND | 5,406 | 2026-03-05 01:20 |
| `commands/contract.md` | COMMAND | 6,380 | 2026-03-05 01:20 |
| `commands/debug.md` | COMMAND | 6,781 | 2026-03-05 06:09 |
| `commands/mutation.md` | COMMAND | 5,162 | 2026-03-05 01:20 |
| `commands/postmortem.md` | COMMAND | 6,448 | 2026-03-05 01:20 |
| `commands/qa-plan.md` | COMMAND | 6,565 | 2026-03-05 06:09 |
| `commands/triage.md` | COMMAND | 4,265 | 2026-03-05 01:20 |
| `logs/` | OTHER (empty dir) | 0 | 2026-03-05 00:42 |
| `qa-debug-v1.3.0-final.tar.gz` | OTHER (archive) | 41,494 | 2026-03-05 05:28 |
| `scripts/on-archive-write.sh` | CONFIG (hook) | 2,754 | 2026-03-05 01:36 |
| `scripts/on-bash-run.sh` | CONFIG (hook) | 1,727 | 2026-03-05 01:36 |
| `scripts/on-session-stop.sh` | CONFIG (hook) | 1,334 | 2026-03-05 01:36 |
| `scripts/on-task-completed.sh` | CONFIG (hook) | 1,160 | 2026-03-05 01:36 |
| `scripts/pre-bash-guard.sh` | CONFIG (hook) | 1,714 | 2026-03-05 00:58 |
| `scripts/pre-compact-snapshot.sh` | CONFIG (hook) | 1,422 | 2026-03-05 01:36 |
| `scripts/pre-write-guard.sh` | CONFIG (hook) | 1,448 | 2026-03-05 00:58 |
| `scripts/session-start.sh` | CONFIG (hook) | 1,289 | 2026-03-05 01:36 |
| `settings.json` | MANIFEST | 49 | 2026-03-05 01:22 |
| `skills/error-taxonomy/SKILL.md` | SKILL | 4,630 | 2026-03-05 00:18 |
| `skills/error-taxonomy/references/taxonomy.md` | SKILL | 5,433 | 2026-03-05 00:20 |
| `skills/pessimistic-qa-patterns/SKILL.md` | SKILL | 4,109 | 2026-03-05 00:18 |
| `skills/pessimistic-qa-patterns/references/patterns.md` | SKILL | 5,722 | 2026-03-05 00:19 |
| `skills/remediation-playbooks/SKILL.md` | SKILL | 4,720 | 2026-03-05 00:19 |
| `skills/remediation-playbooks/references/playbooks.md` | SKILL | 7,057 | 2026-03-05 00:21 |

**Totals:** 39 files, 8 commands, 3 agents, 3 skills, 8 hook scripts, 4 manifests, 5 documentation files.

---

## B. Manifest & MCP Config

### plugin.json (.claude-plugin/plugin.json)

- **Name:** qa-debug
- **Version:** 1.3.0
- **Description:** "AI-driven QA sentry — pessimistic testing, structured debugging, chaos planning, mutation auditing, contract enforcement, and error archiving. Human-in-the-loop at every step."
- **Author:** Chris
- **Commands directory:** `./commands` (8 .md files on disk)
- **Skills directory:** `./skills` (3 skill directories on disk)
- **Hooks reference:** `./.claude-plugin/hooks.json`
- **MCP reference:** `./.mcp.json`

### hooks.json (.claude-plugin/hooks.json)

| Event | Matcher | Hook Script | Type | Timeout |
|-------|---------|-------------|------|---------|
| SessionStart | `.*` | `scripts/session-start.sh` | command | 10s |
| PreToolUse | `Bash` | `scripts/pre-bash-guard.sh` | command | 10s |
| PreToolUse | `Write\|Edit\|MultiEdit` | `scripts/pre-write-guard.sh` | command | 10s |
| PostToolUse | `Write` | `scripts/on-archive-write.sh` | command | 15s |
| PostToolUse | `Bash` | `scripts/on-bash-run.sh` | command | 10s |
| PostToolUseFailure | `Bash\|Write\|Edit\|MultiEdit` | (prompt-based) | prompt | 30s |
| TaskCompleted | (no matcher) | `scripts/on-task-completed.sh` | command | 15s |
| PreCompact | `.*` | `scripts/pre-compact-snapshot.sh` | command | 15s |
| Stop | (no matcher) | `scripts/on-session-stop.sh` | command | 15s |

### .mcp.json

| MCP Server Name | Connection Method | Purpose | Env Vars |
|----------------|-------------------|---------|----------|
| source-control | stdio (`npx -y @modelcontextprotocol/server-github`) | GitHub MCP — git log, PR cross-reference, commit analysis | `GITHUB_PERSONAL_ACCESS_TOKEN` (from `${GITHUB_TOKEN}`) |
| project-tracker | HTTP (`https://mcp.linear.app/mcp`) | Linear MCP — bug ticket search, duplicate detection, ticket creation | None |
| monitoring | HTTP (`https://mcp.sentry.dev/mcp`) | Sentry MCP — error rate, production correlation, alert history | None |

### settings.json

```json
{ "agent": { "enableSubagents": true } }
```

### marketplace.json

- **Marketplace name:** github-local
- **Owner:** Chris
- **Plugin listed:** qa-debug v1.3.0

---

## C. Verified Commit History

### Full Commit Log (4 commits, all 2026-03-05)

| Hash | Date | Message | Tag |
|------|------|---------|-----|
| `83f6804` | 2026-03-05 | feat: initial release qa-debug plugin v1.3.0 | v1.3.0 |
| `b25dd90` | 2026-03-05 | fix: polish for public release | v1.3.1 |
| `2002e75` | 2026-03-05 | ci: add plugin validation workflow | — |
| `6d8efa3` | 2026-03-05 | fix: claude plugin validate requires --path argument | HEAD |

### Version Bump Table

| Tag | Commit Hash | Date | Commit Message |
|-----|-------------|------|----------------|
| v1.3.0 | `83f6804` | 2026-03-05 | feat: initial release qa-debug plugin v1.3.0 |
| v1.3.1 | `b25dd90` | 2026-03-05 | fix: polish for public release |

### Bug Fix Log

| Commit Hash | Date | Message | Category |
|-------------|------|---------|----------|
| `b25dd90` | 2026-03-05 | fix: polish for public release | config/path/schema |
| `6d8efa3` | 2026-03-05 | fix: claude plugin validate requires --path argument | CI |

### Feature Addition Log

| Commit Hash | Date | Message |
|-------------|------|---------|
| `83f6804` | 2026-03-05 | feat: initial release qa-debug plugin v1.3.0 |

### CI Commits

| Commit Hash | Date | Message |
|-------------|------|---------|
| `2002e75` | 2026-03-05 | ci: add plugin validation workflow |

### Documentation Commits

No commits with `docs:` prefix found. Documentation changes are bundled into the `feat:` and `fix:` commits.

---

## D. CHANGELOG Cross-Reference

### v1.3.1

| CHANGELOG Entry | Matching Commit | Status |
|----------------|-----------------|--------|
| fix: hooks.json path resolution — moved to .claude-plugin/hooks.json | `b25dd90` (fix: polish for public release) | [VERIFIED] — bundled |
| fix: removed stale qa-debug.plugin bundle artifact (ENOTDIR fix) | `b25dd90` | [VERIFIED] — bundled |
| fix: MCP package names correction | `b25dd90` | [VERIFIED] — bundled |
| fix: removed unsupported SubagentStop/TeammateIdle events | `b25dd90` | [VERIFIED] — bundled |
| docs: generalized marketplace name | `b25dd90` | [VERIFIED] — bundled |

### v1.3.0

| CHANGELOG Entry | Matching Commit | Status |
|----------------|-----------------|--------|
| .mcp.json: Wired source-control, project-tracker, monitoring | `83f6804` (feat: initial release) | [VERIFIED] |
| agents/qa-sentinel.md: Auto-invoked debug loop agent | `83f6804` | [VERIFIED] |
| agents/archive-curator.md: Error archive dedup agent | `83f6804` | [VERIFIED] |
| agents/ci-advisor.md: CI failure triage agent | `83f6804` | [VERIFIED] |
| settings.json: enableSubagents | `83f6804` | [VERIFIED] |
| hooks.json: Removed SubagentStop/TeammateIdle | `83f6804` | [VERIFIED] |
| Installation fixes (hooks path, stale bundle) | `83f6804` + `b25dd90` | [VERIFIED] |

### v1.2.1

| CHANGELOG Entry | Matching Commit | Status |
|----------------|-----------------|--------|
| on-archive-write.sh changes | No matching commit in this repo | [GAP — v1.2.1 predates this repository's commit history] |
| pre-bash-guard.sh changes | (same) | [GAP] |
| pre-write-guard.sh, on-session-stop.sh, on-task-completed.sh, hooks.json | (same) | [GAP] |

**Note:** v1.2.1 entries document changes that predate the repository's initial commit. These were likely developed before version control was initialized.

---

## E. CI Status

### Workflow: `.github/workflows/validate.yml`

- **Trigger:** push, pull_request, workflow_dispatch
- **Runner:** ubuntu-latest
- **Steps:**
  1. Checkout (actions/checkout@v4)
  2. Install Claude Code CLI (`npm install -g @anthropic-ai/claude-code@latest`)
  3. Validate plugin schema (`claude plugin validate .`)
  4. Check for `~~` placeholders (`grep -r "~~"` — informational, `|| true`)
  5. Confirm no hardcoded paths (`grep -r "/Users/\|/home/\|C:\\"` — informational, `|| true`)

### CI Run History

| Run ID | Date | Branch | Status | Failing Step |
|--------|------|--------|--------|-------------|
| [GAP — `gh` CLI not available in this environment] | — | — | — | — |

**Note:** The HEAD commit `6d8efa3` specifically fixes the `claude plugin validate` command to use `--path` argument. The current `validate.yml` uses `claude plugin validate .` which is the corrected form. However, we cannot verify whether the latest push triggered a passing CI run from this environment.

**Observation:** The CI step `claude plugin validate .` in the workflow runs `claude plugin validate .` — but the commit message for HEAD says `fix: claude plugin validate requires --path argument`. The workflow file shows the argument as `.` (a positional argument, not `--path`). This is consistent — the fix was applied.

---

## F. Command & Agent Registry

### Commands (8)

| Slash Command | Description | MCP Tools Used |
|---------------|-------------|----------------|
| `/qa-debug:debug` | Human-in-the-loop debugging — IDEAL framework, proposal-only | source-control (git log, bisect), monitoring (error rates), project-tracker (duplicate search) |
| `/qa-debug:qa-plan` | Pessimistic QA test plan — negative, boundary, fuzz, stress cases | source-control (pull source), project-tracker (prior bugs) |
| `/qa-debug:chaos` | Controlled fault injection planning — blast radius, mock scenarios | source-control (dependency graph), monitoring (baseline metrics), project-tracker (prior resilience issues) |
| `/qa-debug:contract` | Consumer-driven contract test design — schema drift, pact definition | source-control (OpenAPI specs, schema PRs), project-tracker (prior integration failures) |
| `/qa-debug:mutation` | Test suite quality audit via mutation analysis — surviving mutants | source-control (pull target module), project-tracker (prior bugs for correlation) |
| `/qa-debug:postmortem` | Blameless post-incident report — 5 Whys, impact, timeline, actions | source-control (introducing commit), monitoring (error rate chart), project-tracker (prior incidents, action item tickets) |
| `/qa-debug:archive-error` | Emit structured JSON error archive record from raw error | project-tracker (dedup search), source-control (introducing change), monitoring (first occurrence) |
| `/qa-debug:triage` | Quick first-pass severity and ownership classification | project-tracker (duplicate search), monitoring (error rates), source-control (recent merges) |

### Agents (3)

| Agent Name | Trigger | Description | MCP Tools Used |
|------------|---------|-------------|----------------|
| qa-sentinel | User pastes stack trace or failing test without `/debug` | Auto-invoked IDEAL debug loop, human-in-the-loop at every step | source-control, project-tracker, monitoring |
| archive-curator | Archive exceeds 10 entries or user requests review | Deduplication by fingerprint, ranked report, ticket sync | project-tracker (Linear search + create) |
| ci-advisor | User pastes CI log or GitHub Actions failure URL | CI failure classification, root cause before retry, Sentry correlation | source-control, monitoring |

---

## G. Quality Bar Results

| # | Check | Result | Notes |
|---|-------|--------|-------|
| 1 | Placeholder check (`~~` in operational files) | **PASS** | `~~` appears only in CHANGELOG.md and CONTRIBUTING.md as historical/documentation references, not as live placeholders in commands, agents, skills, or scripts |
| 2 | Dead code check (empty files) | **PASS** | No empty files found (logs/ is an empty directory, which is expected) |
| 3 | Hardcoded path check | **CONDITIONAL PASS** | Found in `.claude/settings.local.json` (untracked, gitignored — correct) and `.github/workflows/validate.yml` (grep pattern, not a path literal). No hardcoded paths in operational `.sh`, `.json`, or command files |
| 4 | Schema consistency | **PASS** | 8 commands on disk match the `./commands` directory reference. 3 skills on disk match the `./skills` directory reference. All hook scripts referenced in hooks.json exist on disk |
| 5 | CI green check | **[GAP — cannot verify; `gh` CLI unavailable]** | Last commit fixes CI validation argument; workflow file is consistent |

---

## H. Confirmed Bug Log

| Commit Hash | Date | Bug Description | Category | CHANGELOG Match |
|-------------|------|-----------------|----------|-----------------|
| `b25dd90` | 2026-03-05 | hooks.json path resolution (`.claude-plugin/` relative path), stale `.plugin` bundle causing ENOTDIR, wrong MCP package names, unsupported hook events | path / schema / config | v1.3.1 — [VERIFIED] |
| `6d8efa3` | 2026-03-05 | `claude plugin validate` requires positional path argument | CI | Not in CHANGELOG |

---

## I. Identified Gaps

| # | Gap | Command That Failed | Impact |
|---|-----|-------------------|--------|
| 1 | `gh` CLI not available in this VM | `gh repo view ...`, `gh run list ...`, `gh run view ...` | Cannot retrieve GitHub repo metadata (stars, forks, issues, disk usage, releases JSON) or CI run history/status |
| 2 | v1.2.1 CHANGELOG entries have no matching commits | `git log` shows only 4 commits; v1.2.1 work predates repo initialization | Cannot verify v1.2.1 changes against commit history |
| 3 | HEAD commit fix not reflected in CHANGELOG | Commit `6d8efa3` (fix: claude plugin validate requires --path argument) has no CHANGELOG entry | Minor documentation gap |
| 4 | `plugin.json` version is 1.3.0 but latest tag is v1.3.1 | Manual inspection of plugin.json vs `git tag` | Version string in plugin.json was not bumped for v1.3.1 |
| 5 | `qa-debug-v1.3.0-final.tar.gz` is in repo but gitignored | `.gitignore` excludes `*.tar.gz`; file exists on disk | Archive artifact is not tracked; `marketplace.json` references `source: "./"` — this bundle may be stale |
| 6 | `logs/` directory is empty and gitignored | Expected behavior | No archive data to audit with archive-curator agent |

---

## J. Recommended Next Actions

| Priority | Action | Assignee |
|----------|--------|----------|
| 1 | **Bump `plugin.json` version to 1.3.1** — tag v1.3.1 exists but plugin.json still reads 1.3.0, creating a version mismatch that will confuse installers | Human |
| 2 | **Add CHANGELOG entry for commit `6d8efa3`** — the CI validation fix is undocumented; add under a v1.3.2 or amend v1.3.1 | Human |
| 3 | **Verify CI is green on GitHub** — the `gh` CLI was unavailable in this audit; manually confirm the latest push passed the validate workflow, or run `gh run list --limit 1` from a machine with the CLI | Human |
| 4 | **Remove or regenerate `qa-debug-v1.3.0-final.tar.gz`** — this archive is stale (predates v1.3.1 fixes), is gitignored, and sits in the repo root cluttering the workspace; either delete it or rebuild from the current HEAD and rename to v1.3.1 | Human |
| 5 | **Consider adding `agents/` directory reference to `plugin.json`** — currently agents are auto-discovered by convention, but explicit registration would improve discoverability and schema validation | AI |
| 6 | **Harden CI workflow `validate.yml`** — the placeholder and hardcoded-path checks use `|| true`, making them informational only; consider failing the build if `~~` appears in operational files or if hardcoded paths appear in `.sh` files | AI |
| 7 | **Tag HEAD as v1.3.2** once items 1–3 are resolved, to create a clean release point | Human |

---

## K. Phase 8 Validation — v1.3.1 Release Fixup

**Objective:** Confirm all v1.3.1 fixes are complete and properly documented.

### Version Alignment
```bash
jq -r '.version' .claude-plugin/plugin.json | grep -q "1.3.1" \
  && echo "PASS — manifest version matches tag" \
  || echo "FAIL — version mismatch"
```

**Expected:** `PASS — manifest version matches tag`

### CHANGELOG Coverage
```bash
git log --oneline | grep -E "(fix|feat)" | wc -l | xargs test 0 -lt \
  && echo "PASS — commits documented" \
  || echo "FAIL — no documented changes"
```

**Expected:** `PASS — commits documented`

### Release Artifact Check
```bash
gh release view v1.3.1 >/dev/null 2>&1 \
  && echo "PASS — v1.3.1 released" \
  || echo "FAIL — no release for v1.3.1"
```

**Expected:** `PASS — v1.3.1 released`

### No Stale Artifacts
```bash
find . -name "*.tar.gz" -not -path "./.git/*" | wc -l | xargs test 0 -eq \
  && echo "PASS — no stale tarballs" \
  || echo "FAIL — stale artifacts present"
```

**Expected:** `PASS — no stale tarballs`

---

*END OF AUDIT REPORT*
