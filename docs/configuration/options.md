---
sidebar_position: 1
---

# Configuration

## Full Default Config

```lua
require('ignition').setup({
  -- LSP server settings
  lsp = {
    enabled = true,           -- Enable the Ignition LSP server
    auto_start = true,        -- Auto-attach LSP to Ignition buffers
    cmd = nil,                -- LSP command (nil = auto-detect)
    settings = {
      ignition = {
        version = "8.1",      -- Target Ignition version
        sdk_path = nil,       -- Path to Ignition SDK (optional)
      },
    },
  },

  -- Kindling integration
  kindling = {
    enabled = true,           -- Enable Kindling .gwbk support
    path = nil,               -- Kindling binary path (nil = auto-detect)
  },

  -- Script decoder settings
  decoder = {
    auto_decode = true,       -- Auto-detect scripts when opening files
    auto_encode = true,       -- Auto-encode on virtual buffer save
    create_scratch_buffer = true, -- Use scratch buffers for decoded scripts
  },

  -- UI settings
  ui = {
    show_notifications = true,  -- Show notification messages
    show_statusline = true,     -- Show status in statusline
  },
})
```

## LSP Options

### `lsp.enabled`
**Type:** `boolean` | **Default:** `true`

Enable or disable the LSP server entirely. When disabled, no LSP features (completions, hover, diagnostics) are available.

### `lsp.auto_start`
**Type:** `boolean` | **Default:** `true`

Automatically start the LSP server and attach it to buffers with the `ignition` filetype. Set to `false` to start the server manually.

### `lsp.cmd`
**Type:** `string[]|nil` | **Default:** `nil`

Override the LSP server command. When `nil`, the plugin auto-detects the server location. Set this if you have a custom installation:

```lua
lsp = {
  cmd = { '/custom/path/to/ignition-lsp' },
}
```

### `lsp.settings.ignition.version`
**Type:** `string` | **Default:** `"8.1"`

Target Ignition version. Affects which API functions are available in completions.

### `lsp.settings.ignition.sdk_path`
**Type:** `string|nil` | **Default:** `nil`

Path to the Ignition SDK for additional type information.

## Kindling Options

### `kindling.enabled`
**Type:** `boolean` | **Default:** `true`

Enable Kindling integration for `.gwbk` file support.

### `kindling.path`
**Type:** `string|nil` | **Default:** `nil`

Explicit path to the Kindling binary. When `nil`, the plugin searches common installation paths automatically.

## Decoder Options

### `decoder.auto_decode`
**Type:** `boolean` | **Default:** `true`

Automatically detect embedded scripts when opening Ignition files and notify the user.

### `decoder.auto_encode`
**Type:** `boolean` | **Default:** `true`

Automatically encode scripts when saving virtual buffers. When disabled, you must call `:IgnitionEncode` manually.

### `decoder.create_scratch_buffer`
**Type:** `boolean` | **Default:** `true`

Create virtual scratch buffers for decoded scripts. These buffers intercept saves and write back to the source JSON.

## UI Options

### `ui.show_notifications`
**Type:** `boolean` | **Default:** `true`

Show notification messages (via `vim.notify`) for plugin events like decode/encode operations.

### `ui.show_statusline`
**Type:** `boolean` | **Default:** `true`

Include ignition-nvim status information in the statusline.
