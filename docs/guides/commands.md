---
sidebar_position: 1
---

# Commands & Keymaps

## Commands

All commands are available globally once the plugin loads.

### Script Management

| Command | Description |
|---------|-------------|
| `:IgnitionDecode` | Decode embedded scripts in current buffer. Prompts for selection if multiple scripts are found. |
| `:IgnitionDecodeAll` | Decode all scripts in current buffer into separate virtual buffers. |
| `:IgnitionEncode` | Encode the current virtual buffer back into the source JSON. Called automatically on `:w`. |
| `:IgnitionListScripts` | Show all detected scripts in a floating window with previews. |

### Integration

| Command | Description |
|---------|-------------|
| `:IgnitionOpenKindling [file]` | Open a `.gwbk` gateway backup file with Kindling. If no file is given, uses the current buffer. |
| `:IgnitionInfo` | Show plugin version, configuration, and LSP status. |

## Default Keymaps

These keymaps are set for buffers with the `ignition` filetype.

| Keymap | Command | Description |
|--------|---------|-------------|
| `<localleader>id` | `:IgnitionDecode` | Decode scripts |
| `<localleader>ia` | `:IgnitionDecodeAll` | Decode all scripts |
| `<localleader>il` | `:IgnitionListScripts` | List scripts |
| `<localleader>ie` | `:IgnitionEncode` | Encode back to JSON |
| `<localleader>ii` | `:IgnitionInfo` | Plugin info |
| `<localleader>ik` | `:IgnitionOpenKindling` | Open in Kindling |

:::tip
The default `<localleader>` is `\` (backslash). So `<localleader>id` means pressing `\` then `i` then `d`.
:::

## Virtual Buffer Behavior

When you decode a script, the plugin creates a virtual buffer with special properties:

- **Buffer type**: `acwrite` — saves are intercepted by the plugin
- **Filetype**: `python` — enables syntax highlighting and LSP
- **On save** (`:w`): The script is encoded and written back to the source JSON buffer
- **On close**: The virtual buffer is cleaned up and its tracking metadata is removed

The source JSON buffer is marked as modified after encoding but is not auto-saved to disk. You must explicitly save it.
