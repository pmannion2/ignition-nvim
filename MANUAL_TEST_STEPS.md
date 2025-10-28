# Manual Test Steps - Direct Approach

## What I Fixed

1. **Updated `lua/ignition/lsp.lua`** to use the venv Python directly
2. **Created `TEST_CONFIG.lua`** for easy testing

## Step-by-Step Test

### Step 1: Verify Venv Python Exists

```bash
ls -la /Users/pmannion/Documents/whiskeyhouse/ignition-nvim/lsp/venv/bin/python
```

Expected: Should show the python executable

### Step 2: Open Neovim with Test File

```bash
cd /Users/pmannion/Documents/whiskeyhouse/ignition-nvim
nvim tests/fixtures/test_script_with_issues.py
```

### Step 3: Load Test Config

In Neovim, run:
```vim
:luafile TEST_CONFIG.lua
```

You should see output like:
```
✓ Loaded ignition module
Found ignition-lsp in development mode
✓ Ignition setup complete
LSP command: { "/Users/pmannion/Documents/whiskeyhouse/ignition-nvim/lsp/venv/bin/python", "/Users/pmannion/Documents/whiskeyhouse/ignition-nvim/lsp/ignition_lsp/server.py" }
✓ Current buffer is Python/Ignition
Active LSP clients:
  - ignition_lsp
  - pyright
```

### Step 4: Check LSP Status

```vim
:LspInfo
```

Expected: `ignition_lsp` should be in "Active Clients" list

### Step 5: Check Server Log

In a terminal:
```bash
tail -f /tmp/ignition-lsp.log
```

You should see:
```
2025-10-27 XX:XX:XX - ignition_lsp.server - INFO - Starting Ignition LSP Server...
2025-10-27 XX:XX:XX - ignition_lsp.server - INFO - Document opened: file://...
2025-10-27 XX:XX:XX - ignition_lsp.server - INFO - Published X diagnostics...
```

### Step 6: Verify Diagnostics

In the Neovim buffer, you should see diagnostics from ignition-lint (NOT Pyright's "system not defined").

Check diagnostic sources:
```vim
:lua vim.print(vim.diagnostic.get(0))
```

Look for diagnostics with `source = "ignition-lint"` and codes like `JYTHON_HARDCODED_LOCALHOST`.

## If It Still Doesn't Work

### Debug Command

```vim
:lua print(vim.inspect(require('ignition').config.lsp.cmd))
```

Should output:
```
{ "/Users/pmannion/Documents/whiskeyhouse/ignition-nvim/lsp/venv/bin/python",
  "/Users/pmannion/Documents/whiskeyhouse/ignition-nvim/lsp/ignition_lsp/server.py" }
```

### Manual Start

```vim
:lua vim.lsp.start({
  name = 'ignition_lsp',
  cmd = { '/Users/pmannion/Documents/whiskeyhouse/ignition-nvim/lsp/venv/bin/python', '/Users/pmannion/Documents/whiskeyhouse/ignition-nvim/lsp/ignition_lsp/server.py' },
  root_dir = vim.fn.getcwd(),
})
```

Then check `:LspInfo` again.

## Success Criteria

✅ `ignition_lsp` in Active Clients
✅ Diagnostics with `source = "ignition-lint"`
✅ Log shows "Published X diagnostics"
✅ No "system not defined" from ignition-lint (only from Pyright)

## Next Step

Once this works, we can add ignition.nvim to your permanent Neovim config!
