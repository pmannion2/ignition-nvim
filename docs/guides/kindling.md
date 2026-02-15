---
sidebar_position: 4
---

# Kindling Integration

[Kindling](https://github.com/paul-griffith/kindling) is a utility for working with Ignition gateway backup (`.gwbk`) files. ignition-nvim integrates with Kindling to let you open and manage backups directly from Neovim.

## What is a .gwbk File?

Gateway backup files are zip archives containing an Ignition gateway's configuration, projects, tags, and other resources. They're used for backup/restore, migration between environments, and version control of gateway state.

## Usage

Open a gateway backup with the Kindling command:

```
:IgnitionOpenKindling path/to/backup.gwbk
```

Or use the keymap `<localleader>ik` when your cursor is on a `.gwbk` file.

If no path argument is given, the command uses the current buffer's file path.

## Installation Detection

The plugin automatically scans common installation paths for Kindling:

**macOS:**
- `/usr/local/bin/kindling`
- `/opt/homebrew/bin/kindling`
- `~/Applications/kindling`

**Linux:**
- `/usr/bin/kindling`
- `~/.local/bin/kindling`
- Snap and Flatpak paths

The detected path is cached for the session. You can also set it explicitly:

```lua
require('ignition').setup({
  kindling = {
    enabled = true,
    path = '/path/to/kindling',
  },
})
```

## Configuration

```lua
require('ignition').setup({
  kindling = {
    enabled = true,   -- Enable/disable Kindling integration
    path = nil,       -- Kindling binary path (nil = auto-detect)
  },
})
```

Set `enabled = false` to disable the integration entirely. The `:IgnitionOpenKindling` command will show installation instructions if Kindling is not found.
