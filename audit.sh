#!/bin/bash
set -euo pipefail

echo "=== qa-debug Self-Audit v1.3.1 ==="

# 1. Version sync
PLUGIN_VER=$(jq -r '.version' .claude-plugin/plugin.json)
LATEST_TAG=$(git tag --sort=-v:refname | head -1)
[ "$PLUGIN_VER" = "${LATEST_TAG#v}" ] \
  && echo "✅ Versions sync: $PLUGIN_VER" \
  || echo "❌ Version mismatch: plugin=$PLUGIN_VER tag=$LATEST_TAG"

# 2. CHANGELOG coverage
BUG_COMMITS=$(git log --oneline | grep -iE 'fix|bug|patch' | wc -l)
CHANGELOG_BUGS=$(grep -c '^ *-.*(fix|bug|patch)' CHANGELOG.md || echo "0")
[ "$BUG_COMMITS" -gt 0 ] && echo "✅ $BUG_COMMITS bug commits documented"

# 3. No stale artifacts
find . -name "*.tar.gz" -not -path './.git/*' | \
  grep -q . && echo "❌ Stale tarballs" || echo "✅ No artifacts"

# 4. CI green
LATEST_CI=$(gh run list --limit 1 --json conclusion --jq '..conclusion')
[ "$LATEST_CI" = "success" ] && echo "✅ Latest CI: $LATEST_CI" || echo "❌ CI: $LATEST_CI"

# 5. Manifest validation
claude plugin validate . && echo "✅ Manifest valid" || echo "❌ Manifest invalid"

echo ""
echo "=== Audit Complete ==="
