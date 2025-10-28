# Quick Debug Steps

## Issue: "system is not defined" diagnostics appearing

These diagnostics are likely coming from **another source**, not ignition-lint. The ignition-lint JythonValidator only checks for:
- Syntax errors
- Indentation issues
- Hardcoded localhost
- Print statements
- HTTP without error handling

It does NOT check for undefined names like "system".

## Step 1: Check What LSP Clients Are Attached

In Neovim with the test file open:
```vim
:LspInfo
```

**Look for:** Multiple LSP clients (e.g., pylsp, pyright, basedpyright, etc.)

## Step 2: Check Diagnostic Sources

In Neovim:
```vim
:lua vim.print(vim.diagnostic.get(0))
```

This shows all diagnostics with their sources. Look for the `source` field on each diagnostic.

**Expected from ignition-lint:**
- `source: "ignition-lint"`
- codes: `JYTHON_*` (like `JYTHON_HARDCODED_LOCALHOST`)

**If you see:**
- `source: "Pylance"` or `"Pyright"` or `"pyls"` → Another Python LSP is running
- No source field → Coming from Neovim's built-in diagnostics or another plugin

## Step 3: Solution Options

### Option A: Disable Other Python LSPs for Ignition Files

Add to your Neovim config:
```lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = {"python", "ignition"},
  callback = function()
    -- Only use ignition_lsp for Ignition-related files
    local bufname = vim.api.nvim_buf_get_name(0)
    if bufname:match("Ignition") or vim.bo.filetype == "ignition" then
      -- Stop other Python LSPs
      for _, client in ipairs(vim.lsp.get_active_clients({bufnr = 0})) do
        if client.name ~= "ignition_lsp" and client.name:match("[Pp]y") then
          vim.lsp.stop_client(client.id)
        end
      end
    end
  end,
})
```

### Option B: Filter Diagnostics by Source

In your Neovim config:
```lua
-- Only show diagnostics from ignition-lint for Ignition files
vim.diagnostic.config({
  virtual_text = {
    source = "if_many",  -- Only show source if multiple
    format = function(diagnostic)
      -- Filter out "not defined" errors for Ignition built-ins
      if diagnostic.message:match("'system' is not defined") or
         diagnostic.message:match("'shared' is not defined") or
         diagnostic.message:match("'self' is not defined") then
        return nil  -- Don't show this diagnostic
      end
      return diagnostic.message
    end,
  },
})
```

## Step 4: Hover Not Working

Try hovering and check:
```bash
# In terminal, watch the log:
tail -f /tmp/ignition-lsp.log
```

Then in Neovim, press `K` (or your hover key) over some code.

**If you see:** "Hover requested at..." in the log → Hover IS working, just returning generic message
**If you don't see anything:** LSP client might not be configured to call hover

Let me know what you find!
