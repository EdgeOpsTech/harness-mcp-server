#!/bin/bash

# Test script for create_pipeline and create_service tools
# This script verifies the tools are registered properly

set -e

echo "=========================================="
echo "Testing Create Pipeline and Service Tools"
echo "=========================================="
echo ""

# Required environment variables
export HARNESS_ACCOUNT_ID="${HARNESS_ACCOUNT_ID:-test_account}"
export HARNESS_API_KEY="${HARNESS_API_KEY:-test_key}"
export HARNESS_DEFAULT_ORG_ID="${HARNESS_DEFAULT_ORG_ID:-test_org}"
export HARNESS_DEFAULT_PROJECT_ID="${HARNESS_DEFAULT_PROJECT_ID:-test_project}"

# Optional: Enable specific modules
export HARNESS_MODULES="${HARNESS_MODULES:-CORE,CD}"

echo "Configuration:"
echo "  Account ID: $HARNESS_ACCOUNT_ID"
echo "  Org ID: $HARNESS_DEFAULT_ORG_ID"
echo "  Project ID: $HARNESS_DEFAULT_PROJECT_ID"
echo "  Modules: $HARNESS_MODULES"
echo ""

# Test 1: Check if server binary exists
echo "Test 1: Checking server binary..."
if [ -f "./cmd/harness-mcp-server/harness-mcp-server" ]; then
    echo "✓ Server binary found"
else
    echo "✗ Server binary not found. Run: go build -o cmd/harness-mcp-server/harness-mcp-server ./cmd/harness-mcp-server"
    exit 1
fi
echo ""

# Test 2: Verify tools are listed (by sending initialize + list_tools request)
echo "Test 2: Listing all available tools..."
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test-client","version":"1.0.0"}}}
{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | \
    ./cmd/harness-mcp-server/harness-mcp-server stdio 2>/dev/null | \
    grep -q "create_pipeline" && echo "✓ create_pipeline tool found" || echo "✗ create_pipeline tool NOT found"

echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test-client","version":"1.0.0"}}}
{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}' | \
    ./cmd/harness-mcp-server/harness-mcp-server stdio 2>/dev/null | \
    grep -q "create_service" && echo "✓ create_service tool found" || echo "✗ create_service tool NOT found"
echo ""

echo "=========================================="
echo "Basic tests completed!"
echo ""
echo "Next steps:"
echo "1. Use MCP Inspector for interactive testing:"
echo "   npx @modelcontextprotocol/inspector ./cmd/harness-mcp-server/harness-mcp-server stdio"
echo ""
echo "2. Set your actual Harness credentials:"
echo "   export HARNESS_API_KEY='your-api-key'"
echo "   export HARNESS_ACCOUNT_ID='your-account-id'"
echo "   export HARNESS_DEFAULT_ORG_ID='your-org-id'"
echo "   export HARNESS_DEFAULT_PROJECT_ID='your-project-id'"
echo ""
echo "3. Enable the CD module to access create_service:"
echo "   export HARNESS_MODULES='CORE,CD'"
echo "=========================================="
