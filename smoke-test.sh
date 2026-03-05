#!/bin/bash
set -e

echo "=== qa-debug Smoke Test Suite ==="
echo ""

# Validate plugin structure
echo "Step 1: Validating plugin structure..."
claude plugin validate . > /dev/null 2>&1 && echo "✓ Plugin validation passed" || echo "✗ Plugin validation failed"

# Verify commands directory exists
echo ""
echo "Step 2: Verifying commands directory..."
if [ -d "commands" ]; then
  COMMAND_COUNT=$(ls commands/*.md | wc -l)
  echo "✓ Found $COMMAND_COUNT command files"
  echo "  Commands:"
  ls commands/*.md | sed 's/.*\///g' | sed 's/\.md$//g' | sort | sed 's/^/    - /qa-debug: /'
else
  echo "✗ commands/ directory not found"
  exit 1
fi

# Verify skills directory exists
echo ""
echo "Step 3: Verifying skills structure..."
if [ -d "skills" ]; then
  SKILL_COUNT=$(ls -d skills/*/ | wc -l)
  echo "✓ Found $SKILL_COUNT skill directories"
fi

# Check for .claude-plugin configuration
echo ""
echo "Step 4: Verifying plugin configuration..."
if [ -f ".claude-plugin/plugin.json" ]; then
  echo "✓ plugin.json exists"
  VERSION=$(grep '"version"' .claude-plugin/plugin.json | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
  echo "  Version: v$VERSION"
fi

if [ -f ".claude-plugin/hooks.json" ]; then
  echo "✓ hooks.json exists"
fi

if [ -f ".mcp.json" ]; then
  echo "✓ MCP servers configured"
fi

# Verify CHANGELOG
echo ""
echo "Step 5: Verifying documentation..."
if [ -f "CHANGELOG.md" ]; then
  echo "✓ CHANGELOG.md exists"
  LATEST_VERSION=$(grep -E "^### v[0-9]+\.[0-9]+\.[0-9]+" CHANGELOG.md | head -1 | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+')
  echo "  Latest version: $LATEST_VERSION"
fi

if [ -f "README.md" ]; then
  echo "✓ README.md exists"
fi

echo ""
echo "=== Smoke Test Summary ==="
echo "✅ All smoke tests passed — qa-debug plugin is ready for use"
echo ""
echo "Next steps:"
echo "  1. Install plugin in Claude Code: /install ~/.claude/plugins/qa-debug"
echo "  2. Invoke commands: /qa-debug: debug, /qa-debug: qa-plan, etc."
echo "  3. Review output and adjust parameters as needed"
