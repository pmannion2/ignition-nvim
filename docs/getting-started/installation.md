---
sidebar_position: 1
---

# Installation

## Plugin Installation

### lazy.nvim (Recommended)

The simplest install — lazy.nvim auto-discovers the plugin spec from `lazy.lua`:

```lua
{ 'whiskeyhouse/ignition-nvim' }
```

This gives you sensible defaults: lazy-loading on the `ignition` filetype and all commands, plus automatic LSP server installation via `pip install -e .` in the `lsp/` directory.

To customize options:

```lua
{
  'whiskeyhouse/ignition-nvim',
  opts = {
    lsp = {
      enabled = true,
      auto_start = true,
      settings = {
        ignition = {
          version = "8.1",
        },
      },
    },
    kindling = {
      enabled = true,
    },
    decoder = {
      auto_decode = true,
      auto_encode = true,
    },
  },
}
```

### packer.nvim

```lua
use {
  'whiskeyhouse/ignition-nvim',
  config = function()
    require('ignition').setup()
  end,
}
```

After installing, you'll need to manually install the LSP server (see below).

### Manual Installation

Clone the repository into your Neovim packages directory:

```bash
git clone https://github.com/WhiskeyHouse/ignition-nvim.git \
  ~/.local/share/nvim/site/pack/plugins/start/ignition-nvim
```

Add the setup call to your `init.lua`:

```lua
require('ignition').setup()
```

## LSP Server Installation

The Python LSP server provides completions, hover docs, and diagnostics for Ignition's `system.*` API.

### Automatic (lazy.nvim)

If you're using lazy.nvim with the default spec, the LSP server installs automatically via the `build` step. No extra action needed.

### Manual

```bash
cd ~/.local/share/nvim/lazy/ignition-nvim/lsp
pip install -e .
```

Or install from any checkout of the repository:

```bash
cd /path/to/ignition-nvim/lsp
pip install -e .
```

The plugin auto-detects the LSP server location in this order:

1. **Plugin venv** — `lsp/venv/bin/ignition-lsp` (development mode)
2. **System install** — `ignition-lsp` on `$PATH`
3. **System Python** — `python -m ignition_lsp`

## Requirements

- **Neovim** >= 0.11.0 (uses `vim.lsp.start()`)
- **Python** >= 3.8 (for the LSP server)
- **pip** (for installing the LSP server)

### Optional

- [Kindling](https://github.com/ia-eknorr/kindling) — for `.gwbk` gateway backup file support
