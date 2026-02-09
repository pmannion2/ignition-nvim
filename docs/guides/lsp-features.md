---
sidebar_position: 3
---

# LSP Features

ignition-nvim includes a purpose-built Language Server Protocol (LSP) server that understands Ignition's `system.*` API.

## Completions

Type `system.` in any decoded Python script to get completions for all Ignition API modules:

- `system.tag` — Tag read/write operations
- `system.db` — Database queries and transactions
- `system.perspective` — Perspective session and component control
- `system.util` — Utility functions (timers, threading, exports)
- `system.net` — HTTP requests and email
- `system.date` — Date/time manipulation
- `system.security` — Authentication and authorization
- And more...

Each completion includes the function signature and a brief description.

## Hover Documentation

Press `K` (or your configured hover keymap) over any `system.*` function call to see:

- **Full function signature** with parameter names and types
- **Parameter descriptions** — what each argument does
- **Return type** — what the function returns
- **Usage notes** — scope restrictions, version requirements, common patterns

## Diagnostics

The LSP server reports issues in your scripts:

- Unknown `system.*` function calls
- Incorrect argument counts
- Scope violations (e.g., using a client-scoped function in a gateway script)

Diagnostics appear as inline warnings and in the quickfix list.

## API Database

The LSP server's knowledge comes from a curated JSON database at `lsp/ignition_lsp/api_db/`. Each module has its own file (e.g., `tag.json`, `db.json`) following a schema that defines:

- Module name and description
- Functions with signatures, parameters, return types
- Scope information (client, gateway, or both)
- Version compatibility notes

## Configuration

LSP behavior is controlled through the `lsp` section of your plugin config:

```lua
require('ignition').setup({
  lsp = {
    enabled = true,       -- Enable/disable the LSP server
    auto_start = true,    -- Auto-attach to Ignition buffers
    cmd = nil,            -- Custom command (auto-detected by default)
    settings = {
      ignition = {
        version = "8.1",  -- Target Ignition version
        sdk_path = nil,   -- Path to Ignition SDK (optional)
      },
    },
  },
})
```

## Server Detection

The plugin auto-detects the LSP server in this order:

1. **Plugin venv** — `lsp/venv/bin/ignition-lsp` (used during development)
2. **System install** — `ignition-lsp` on your `$PATH`
3. **System Python** — `python -m ignition_lsp` as a fallback

You can override detection by setting `lsp.cmd` explicitly:

```lua
lsp = {
  cmd = { '/path/to/ignition-lsp' },
}
```
