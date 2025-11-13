@echo off
REM Build script for Windows

echo Building Harness MCP Server for Windows...
go build -o cmd\harness-mcp-server\harness-mcp-server.exe .\cmd\harness-mcp-server

if %ERRORLEVEL% EQU 0 (
    echo.
    echo Build successful!
    echo Binary created at: cmd\harness-mcp-server\harness-mcp-server.exe
    echo.
    echo To test with MCP Inspector, run:
    echo npx @modelcontextprotocol/inspector cmd\harness-mcp-server\harness-mcp-server.exe stdio
) else (
    echo.
    echo Build failed!
    exit /b 1
)
