# Testing Create Pipeline and Service Tools

This guide shows you how to test the newly implemented `create_pipeline` and `create_service` tools.

## Prerequisites

### Build the Binary

**For Linux/Mac:**
```bash
go build -o cmd/harness-mcp-server/harness-mcp-server ./cmd/harness-mcp-server
```

**For Windows (PowerShell):**
```powershell
.\build-windows.ps1
# OR manually:
go build -o cmd\harness-mcp-server\harness-mcp-server.exe .\cmd\harness-mcp-server
```

**For Windows (Command Prompt):**
```cmd
build-windows.bat
REM OR manually:
go build -o cmd\harness-mcp-server\harness-mcp-server.exe .\cmd\harness-mcp-server
```

### Harness Credentials

You need valid Harness credentials:
- API Key
- Account ID
- Organization ID (optional, can be specified per-request)
- Project ID (optional for pipelines, required for most operations)

## Option 1: MCP Inspector (Recommended)

The MCP Inspector provides an interactive web UI for testing:

**For Linux/Mac/Git Bash:**
```bash
# Set your credentials
export HARNESS_API_KEY='your-harness-api-key'
export HARNESS_ACCOUNT_ID='your-account-id'
export HARNESS_DEFAULT_ORG_ID='your-org-id'
export HARNESS_DEFAULT_PROJECT_ID='your-project-id'

# Enable both CORE and CD modules (CD module has create_service)
export HARNESS_MODULES='CORE,CD'

# Launch MCP Inspector
npx @modelcontextprotocol/inspector ./cmd/harness-mcp-server/harness-mcp-server stdio
```

**For Windows (PowerShell):**
```powershell
# Set your credentials
$env:HARNESS_API_KEY='your-harness-api-key'
$env:HARNESS_ACCOUNT_ID='your-account-id'
$env:HARNESS_DEFAULT_ORG_ID='your-org-id'
$env:HARNESS_DEFAULT_PROJECT_ID='your-project-id'

# Enable both CORE and CD modules (CD module has create_service)
$env:HARNESS_MODULES='CORE,CD'

# Launch MCP Inspector
npx @modelcontextprotocol/inspector cmd\harness-mcp-server\harness-mcp-server.exe stdio
```

**For Windows (Command Prompt):**
```cmd
REM Set your credentials
set HARNESS_API_KEY=your-harness-api-key
set HARNESS_ACCOUNT_ID=your-account-id
set HARNESS_DEFAULT_ORG_ID=your-org-id
set HARNESS_DEFAULT_PROJECT_ID=your-project-id

REM Enable both CORE and CD modules (CD module has create_service)
set HARNESS_MODULES=CORE,CD

REM Launch MCP Inspector
npx @modelcontextprotocol/inspector cmd\harness-mcp-server\harness-mcp-server.exe stdio
```

This will:
1. Start the MCP server
2. Open a web browser with the inspector UI
3. Show all available tools including `create_pipeline` and `create_service`

In the inspector, you can:
- Browse all available tools
- View tool parameters and descriptions
- Call tools with test data
- See the responses

## Option 2: Direct Server Testing

You can also run the server directly:

```bash
# Set credentials
export HARNESS_API_KEY='your-harness-api-key'
export HARNESS_ACCOUNT_ID='your-account-id'
export HARNESS_DEFAULT_ORG_ID='your-org-id'
export HARNESS_DEFAULT_PROJECT_ID='your-project-id'
export HARNESS_MODULES='CORE,CD'

# Run the server
./cmd/harness-mcp-server/harness-mcp-server stdio
```

Then send JSON-RPC requests via stdin. Example:

```json
{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2024-11-05","capabilities":{},"clientInfo":{"name":"test","version":"1.0"}}}
{"jsonrpc":"2.0","id":2,"method":"tools/list","params":{}}
```

## Option 3: Testing with Read-Only Mode

To test without making actual changes to Harness:

```bash
# Run in read-only mode (write tools will be disabled)
export HARNESS_API_KEY='your-key'
export HARNESS_ACCOUNT_ID='your-account'

./cmd/harness-mcp-server/harness-mcp-server stdio --read-only
```

In read-only mode:
- `create_pipeline` and `create_service` won't be available
- Only read tools like `list_pipelines`, `get_pipeline`, etc. will work
- Safe for testing without modifying your Harness account

## Tool Specifications

### create_pipeline

**Module:** CORE (always enabled by default)

**Required Parameters:**
- `name` (string) - Name of the pipeline
- `identifier` (string) - Unique identifier for the pipeline
- `pipeline_yaml` (string) - Full YAML definition of the pipeline
- `account_id` (string) - From environment or parameter
- `org_id` (string) - From environment or parameter
- `project_id` (string) - From environment or parameter

**Optional Parameters:**
- `description` (string) - Description of the pipeline

**Example YAML:**
```yaml
pipeline:
  name: "My Test Pipeline"
  identifier: "my_test_pipeline"
  projectIdentifier: "default"
  orgIdentifier: "default"
  tags: {}
  stages:
    - stage:
        name: "Test Stage"
        identifier: "test_stage"
        type: "Custom"
        spec:
          execution:
            steps:
              - step:
                  type: "ShellScript"
                  name: "Echo"
                  identifier: "echo"
                  spec:
                    shell: "Bash"
                    source:
                      type: "Inline"
                      spec:
                        script: "echo 'Hello World'"
```

### create_service

**Module:** CD (must be enabled with `HARNESS_MODULES='CORE,CD'`)

**Required Parameters:**
- `name` (string) - Name of the service
- `identifier` (string) - Unique identifier for the service
- `service_yaml` (string) - Full YAML definition of the service
- `account_id` (string) - From environment or parameter

**Optional Parameters:**
- `description` (string) - Description of the service
- `org_id` (string) - Organization ID (from environment or parameter)
- `project_id` (string) - Project ID (from environment or parameter)

**Example YAML:**
```yaml
service:
  name: "My Test Service"
  identifier: "my_test_service"
  tags: {}
  serviceDefinition:
    type: "Kubernetes"
    spec:
      manifests:
        - manifest:
            identifier: "manifest1"
            type: "K8sManifest"
            spec:
              store:
                type: "Harness"
                spec:
                  files:
                    - /templates
```

## Verification Checklist

- [ ] Build completes without errors
- [ ] Server starts with valid credentials
- [ ] `create_pipeline` appears in tool list (CORE module)
- [ ] `create_service` appears in tool list (CD module enabled)
- [ ] Tools show correct parameter descriptions
- [ ] Can create a test pipeline with valid YAML
- [ ] Can create a test service with valid YAML
- [ ] Error messages are clear for invalid inputs
- [ ] Read-only mode blocks write operations

## Troubleshooting

### Tools not appearing in list

1. **Check modules are enabled:**
   ```bash
   # create_pipeline needs CORE (enabled by default)
   # create_service needs CD module
   export HARNESS_MODULES='CORE,CD'
   ```

2. **Check server logs:**
   ```bash
   # Enable debug logging
   ./cmd/harness-mcp-server/harness-mcp-server stdio --debug
   ```

3. **Verify build is up to date:**
   ```bash
   go build -o cmd/harness-mcp-server/harness-mcp-server ./cmd/harness-mcp-server
   ```

### Authentication errors

- Ensure `HARNESS_API_KEY` is a valid Harness API key (format: `sat.xxx.yyy.zzz`)
- Verify `HARNESS_ACCOUNT_ID` matches your Harness account
- Check that org/project IDs exist in your account

### YAML validation errors

- Ensure YAML is properly formatted
- Check that all required fields are present
- Verify identifiers don't conflict with existing resources

## Next Steps

After verifying the tools work:

1. Test edge cases (invalid YAML, missing required fields)
2. Test with different scopes (account, org, project levels)
3. Verify the API responses match Harness API docs
4. Add integration tests if needed
5. Update documentation with real examples
