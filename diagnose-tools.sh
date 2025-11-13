#!/bin/bash
# Diagnostic script to check if create tools are available

echo "=========================================="
echo "Tool Registration Diagnostic"
echo "=========================================="
echo ""

# Check environment variables
echo "1. Checking environment variables..."
echo "   HARNESS_API_KEY: ${HARNESS_API_KEY:+SET (${#HARNESS_API_KEY} chars)}"
echo "   HARNESS_ACCOUNT_ID: ${HARNESS_ACCOUNT_ID:-NOT SET}"
echo "   HARNESS_MODULES: ${HARNESS_MODULES:-NOT SET (defaulting to CORE only)}"
echo ""

if [ -z "$HARNESS_API_KEY" ]; then
    echo "   ⚠️  HARNESS_API_KEY is not set!"
fi
if [ -z "$HARNESS_ACCOUNT_ID" ]; then
    echo "   ⚠️  HARNESS_ACCOUNT_ID is not set!"
fi
if [ -z "$HARNESS_MODULES" ] || [[ ! "$HARNESS_MODULES" =~ "CD" ]]; then
    echo "   ⚠️  CD module not enabled! create_service won't be available"
    echo "   💡 Run: export HARNESS_MODULES='CORE,CD'"
fi
echo ""

# Check if binary exists and is recent
echo "2. Checking binary..."
if [ -f "./cmd/harness-mcp-server/harness-mcp-server.exe" ]; then
    echo "   ✅ Binary exists: cmd/harness-mcp-server/harness-mcp-server.exe"
    echo "   📅 Modified: $(stat -c %y cmd/harness-mcp-server/harness-mcp-server.exe 2>/dev/null || stat -f %Sm cmd/harness-mcp-server/harness-mcp-server.exe 2>/dev/null)"
else
    echo "   ❌ Binary not found!"
    echo "   💡 Run: go build -o cmd/harness-mcp-server/harness-mcp-server.exe ./cmd/harness-mcp-server"
fi
echo ""

# Check code for tool registration
echo "3. Checking source code for tool registration..."
if grep -q "CreatePipelineTool" pkg/modules/core.go; then
    echo "   ✅ CreatePipelineTool found in core.go"
else
    echo "   ❌ CreatePipelineTool NOT found in core.go"
fi

if grep -q "CreateServiceTool" pkg/modules/cd.go; then
    echo "   ✅ CreateServiceTool found in cd.go"
else
    echo "   ❌ CreateServiceTool NOT found in cd.go"
fi
echo ""

# Test if server can start (with fake credentials)
echo "4. Testing server startup..."
export HARNESS_API_KEY="${HARNESS_API_KEY:-sat.test.test.test}"
export HARNESS_ACCOUNT_ID="${HARNESS_ACCOUNT_ID:-test}"
export HARNESS_MODULES="${HARNESS_MODULES:-CORE,CD}"

timeout 3 ./cmd/harness-mcp-server/harness-mcp-server.exe stdio --help > /dev/null 2>&1
if [ $? -eq 0 ] || [ $? -eq 124 ]; then
    echo "   ✅ Server executable responds to --help"
else
    echo "   ❌ Server failed to start"
fi
echo ""

echo "=========================================="
echo "Summary"
echo "=========================================="
echo ""
echo "To see create_pipeline and create_service tools:"
echo ""
echo "1. Set environment variables:"
echo "   export HARNESS_API_KEY='your-actual-api-key'"
echo "   export HARNESS_ACCOUNT_ID='your-account-id'"
echo "   export HARNESS_MODULES='CORE,CD'  # ⬅️ IMPORTANT for create_service"
echo ""
echo "2. Rebuild if needed:"
echo "   go build -o cmd/harness-mcp-server/harness-mcp-server.exe ./cmd/harness-mcp-server"
echo ""
echo "3. Run inspector WITHOUT --read-only flag:"
echo "   npx @modelcontextprotocol/inspector ./cmd/harness-mcp-server/harness-mcp-server.exe stdio"
echo ""
echo "Expected tools:"
echo "   • create_pipeline (CORE module - always enabled)"
echo "   • create_service (CD module - requires HARNESS_MODULES='CORE,CD')"
echo ""
