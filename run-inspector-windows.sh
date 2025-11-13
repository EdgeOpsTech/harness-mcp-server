#!/bin/bash
# Fixed MCP Inspector launcher for Git Bash on Windows
# This script properly configures logging to avoid JSON-RPC conflicts

echo "=========================================="
echo "Harness MCP Inspector Launcher"
echo "=========================================="
echo ""

# Check if binary exists
if [ ! -f "./cmd/harness-mcp-server/harness-mcp-server.exe" ]; then
    echo "❌ Binary not found. Building now..."
    go build -o cmd/harness-mcp-server/harness-mcp-server.exe ./cmd/harness-mcp-server
    if [ $? -ne 0 ]; then
        echo "❌ Build failed!"
        exit 1
    fi
    echo "✅ Build successful!"
    echo ""
fi

# Prompt for credentials if not set
if [ -z "$HARNESS_API_KEY" ]; then
    echo "⚠️  HARNESS_API_KEY not set!"
    echo "Please set your credentials first:"
    echo "  export HARNESS_API_KEY='your-api-key'"
    echo "  export HARNESS_ACCOUNT_ID='your-account-id'"
    echo "  export HARNESS_DEFAULT_ORG_ID='your-org-id'"
    echo "  export HARNESS_DEFAULT_PROJECT_ID='your-project-id'"
    echo ""
    read -p "Do you want to continue anyway? (y/n) " -n 1 -r
    echo ""
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Set default modules if not set
if [ -z "$HARNESS_MODULES" ]; then
    echo "Setting HARNESS_MODULES to 'CORE,CD' (required for create_service)"
    export HARNESS_MODULES='CORE,CD'
fi

echo "Configuration:"
echo "  API Key: ${HARNESS_API_KEY:0:20}... (${#HARNESS_API_KEY} chars)"
echo "  Account ID: ${HARNESS_ACCOUNT_ID:-NOT SET}"
echo "  Org ID: ${HARNESS_DEFAULT_ORG_ID:-NOT SET}"
echo "  Project ID: ${HARNESS_DEFAULT_PROJECT_ID:-NOT SET}"
echo "  Modules: $HARNESS_MODULES"
echo ""
echo "📝 Logs will be written to: harness-mcp.log"
echo ""
echo "Expected tools in inspector:"
echo "  ✓ create_pipeline (from CORE module)"
echo "  ✓ create_service (from CD module)"
echo ""
echo "Starting MCP Inspector..."
echo "Press Ctrl+C to stop"
echo ""

# CRITICAL: Use --log-file to prevent logs from interfering with JSON-RPC on stdout
npx @modelcontextprotocol/inspector ./cmd/harness-mcp-server/harness-mcp-server.exe stdio --log-file harness-mcp.log
