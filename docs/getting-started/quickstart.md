---
sidebar_position: 2
---

# Quickstart

This guide walks you through decoding, editing, and encoding your first Ignition script.

## 1. Open an Ignition File

Open any Ignition resource file that contains embedded Python scripts:

```bash
nvim path/to/resource.json
```

The plugin automatically detects Ignition files by extension (`.gwbk`, `.proj`), filename (`resource.json`, `tags.json`), path patterns (`perspective/`, `script-python/`), and content markers.

## 2. Decode a Script

Run the decode command:

```
:IgnitionDecode
```

Or use the default keymap: `<localleader>id`

If the file contains a single script, it opens immediately in a new split. If there are multiple scripts, you'll see a selection menu with previews.

To decode all scripts at once:

```
:IgnitionDecodeAll
```

## 3. Edit the Script

The decoded script opens in a virtual buffer with:

- **Python filetype** — full syntax highlighting
- **LSP support** — completions for `system.tag.read()`, `system.db.runQuery()`, and more
- **Hover docs** — press `K` over any `system.*` function for parameter info

Edit the script as you would any Python file.

## 4. Save Back to JSON

Save the virtual buffer with `:w`. The plugin automatically:

1. Encodes the script using Ignition's encoding format
2. Writes the encoded content back to the correct location in the source JSON
3. Marks the source buffer as modified

Then save the source JSON file (`:w` in that buffer) to persist the changes to disk.

## 5. Explore Further

- List all scripts in a file: `:IgnitionListScripts` or `<localleader>il`
- Check plugin status: `:IgnitionInfo` or `<localleader>ii`
- Open a gateway backup: `:IgnitionOpenKindling path/to/backup.gwbk`

## Example Workflow

```
# Open a Perspective view with event scripts
nvim com.inductiveautomation.perspective/views/MyView/view.json

# Decode → opens virtual buffer with the Python script
:IgnitionDecode

# Edit the script (LSP completions work here)
# ... make changes ...

# Save virtual buffer → encodes back to JSON
:w

# Switch to source buffer and save
<C-w>p
:w
```
