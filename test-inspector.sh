#!/bin/bash
# Quick test script for running MCP Inspector with all tools visible
# For Git Bash on Windows

echo "=========================================="
echo "MCP Inspector Test Script"
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

# Set environment variables
echo "Setting environment variables..."
export HARNESS_API_KEY="${HARNESS_API_KEY:-your-api-key-here}"
export HARNESS_ACCOUNT_ID="${HARNESS_ACCOUNT_ID:-your-account-id-here}"
export HARNESS_DEFAULT_ORG_ID="${HARNESS_DEFAULT_ORG_ID:-default}"
export HARNESS_DEFAULT_PROJECT_ID="${HARNESS_DEFAULT_PROJECT_ID:-default}"

# IMPORTANT: Enable CD module for create_service tool
export HARNESS_MODULES='CORE,CD'

echo ""
echo "Configuration:"
echo "  API Key: ${HARNESS_API_KEY:0:20}..."
echo "  Account ID: $HARNESS_ACCOUNT_ID"
echo "  Org ID: $HARNESS_DEFAULT_ORG_ID"
echo "  Project ID: $HARNESS_DEFAULT_PROJECT_ID"
echo "  Modules: $HARNESS_MODULES"
echo ""
echo "Expected tools:"
echo "  ✓ create_pipeline (from CORE module)"
echo "  ✓ create_service (from CD module)"
echo ""
echo "Starting MCP Inspector..."
echo "Look for 'create_pipeline' and 'create_service' in the tools list!"
echo ""

# Run the inspector - NO --read-only flag!
npx @modelcontextprotocol/inspector ./cmd/harness-mcp-server/harness-mcp-server.exe stdio
