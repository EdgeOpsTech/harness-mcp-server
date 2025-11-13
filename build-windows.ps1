# PowerShell build script for Windows

Write-Host "Building Harness MCP Server for Windows..." -ForegroundColor Cyan

# Build the binary
go build -o cmd\harness-mcp-server\harness-mcp-server.exe .\cmd\harness-mcp-server

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "Build successful!" -ForegroundColor Green
    Write-Host "Binary created at: cmd\harness-mcp-server\harness-mcp-server.exe"
    Write-Host ""
    Write-Host "To test with MCP Inspector, run:" -ForegroundColor Yellow
    Write-Host "npx @modelcontextprotocol/inspector cmd\harness-mcp-server\harness-mcp-server.exe stdio"
    Write-Host ""
    Write-Host "Or set environment variables and run:" -ForegroundColor Yellow
    Write-Host '$env:HARNESS_API_KEY="your-api-key"'
    Write-Host '$env:HARNESS_ACCOUNT_ID="your-account-id"'
    Write-Host '$env:HARNESS_MODULES="CORE,CD"'
    Write-Host "npx @modelcontextprotocol/inspector cmd\harness-mcp-server\harness-mcp-server.exe stdio"
} else {
    Write-Host ""
    Write-Host "Build failed!" -ForegroundColor Red
    exit 1
}
