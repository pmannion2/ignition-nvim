# Debug Checklist for LSP Issues

## Check 1: Is LSP Actually Connected?

In Neovim with the test file open, run:
```vim
:LspInfo
```

**Expected:** Should show `ignition_lsp` client attached

## Check 2: Check Recent Server Activity

In a terminal:
```bash
tail -f /tmp/ignition-lsp.log
```

Then in Neovim:
- Hover over some code (should see hover request logged)
- Make a change and save (should see didChange/didSave logged)

## Check 3: Test Hover Manually

In Neovim:
```vim
:lua vim.lsp.buf.hover()
```

Should show a hover popup (even if it just says "Ignition Function")

## Check 4: Check LSP Client Logs

In Neovim:
```vim
:LspLog
```

Look for any errors or connection issues

## Quick Fixes

### If LSP Not Attached:

```vim
" Manually start LSP
:LspStart ignition_lsp

" Check if command exists
:lua print(vim.inspect(require('ignition').config.lsp.cmd))
```

### If Hover Not Working:

Check your Neovim LSP configuration for hover keybindings:
```vim
" Default LSP hover is usually:
K  " in normal mode

" Or manually:
:lua vim.lsp.buf.hover()
```

## Fix "system not defined" Issue

The LSP is correctly reporting that `system` isn't defined in standard Python. We need to:

1. **Create Ignition type stubs** (Phase 2 work)
2. **OR** Filter these diagnostics for now

Let me know what you see when you run these checks!
