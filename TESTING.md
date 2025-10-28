# Testing Ignition.nvim LSP Server

## Phase 1 Status: ✅ READY TO TEST

The LSP server foundation is complete and tested standalone. Ready for Neovim testing.

## What Works
- ✅ LSP server starts and runs
- ✅ Document synchronization (open, change, save, close)
- ✅ Diagnostics integration with ignition-lint
- ✅ Python path detection
- ✅ Auto-import of ignition-lint validators

## Prerequisites

1. **Install LSP Server**
   ```bash
   cd lsp
   python3 -m venv venv
   source venv/bin/activate
   pip install -e .
   ```

2. **Verify Installation**
   ```bash
   source lsp/venv/bin/activate
   python -c "from ignition_lsp.server import server; print('✓ OK')"
   ```

3. **Ensure nvim-lspconfig is installed**
   - Required for Neovim LSP client integration
   - Install with your plugin manager (lazy.nvim, packer, etc.)

## Test 1: LSP Server Connection

1. **Open test file in Neovim:**
   ```bash
   nvim tests/fixtures/test_script_with_issues.py
   ```

2. **Check LSP status:**
   ```vim
   :LspInfo
   ```

   Expected output:
   - Should show `ignition_lsp` client
   - Status: `attached`
   - Root directory: Current project

3. **View LSP logs:**
   ```vim
   :LspLog
   ```

4. **Check server logs:**
   ```bash
   tail -f /tmp/ignition-lsp.log
   ```

## Test 2: Diagnostics Appear

With `test_script_with_issues.py` open, you should see diagnostics:

### Expected Diagnostics:
1. **ERROR**: Lines with no indentation
2. **WARNING**: Hardcoded localhost (2 occurrences)
3. **INFO**: Print statement (use system.perspective.print)
4. **WARNING**: HTTP without exception handling
5. **INFO**: Recommend error handling for getSibling

### Verify:
- Underlines/highlights appear in the buffer
- Hover over issues to see messages
- Check diagnostic list: `:lua vim.diagnostic.setloclist()`

## Test 3: Diagnostics Update on Change

1. Open the test file
2. Add a new hardcoded localhost line:
   ```python
   new_url = "http://localhost:9000"
   ```
3. Save the file (`:w`)
4. New diagnostic should appear immediately

## Test 4: Decoded Script Integration

1. **Open Ignition JSON with embedded script:**
   ```bash
   nvim tests/fixtures/perspective-button-with-script.json
   ```

2. **Decode the script:**
   ```vim
   :IgnitionDecode
   ```
   or press `<localleader>id`

3. **Verify LSP attaches:**
   - Buffer name: `[Ignition:perspective-button-with-script.json:onActionPerformed]`
   - Filetype: `python`
   - LSP should auto-attach
   - Check `:LspInfo` to confirm

4. **Diagnostics should appear** in the decoded script buffer

## Test 5: Multiple Scripts

1. **Open file with multiple scripts:**
   ```bash
   nvim tests/fixtures/perspective-view-with-scripts.json
   ```

2. **List scripts:**
   ```vim
   :IgnitionListScripts
   ```
   or press `<localleader>il`

3. **Decode all:**
   ```vim
   :IgnitionDecodeAll
   ```
   or press `<localleader>ia`

4. **Verify LSP on each** decoded buffer

## Troubleshooting

### LSP Not Attaching

Check Python path:
```vim
:lua print(vim.fn.exepath('python3'))
```

Check LSP command:
```vim
:lua print(vim.inspect(require('ignition').config.lsp.cmd))
```

Manually start:
```vim
:LspStart ignition_lsp
```

### No Diagnostics

Check server log:
```bash
cat /tmp/ignition-lsp.log
```

Check ignition-lint import:
```bash
cd lsp
source venv/bin/activate
python -c "from ignition_lint.validators.jython import JythonValidator; print('✓ OK')"
```

### Diagnostics Not Updating

Force refresh:
```vim
:lua vim.lsp.buf_attach_client(0, vim.lsp.get_active_clients()[1].id)
```

Restart LSP:
```vim
:LspRestart ignition_lsp
```

## Expected Results Summary

| Test | Expected | Status |
|------|----------|--------|
| Server starts | ignition_lsp in :LspInfo | ⏳ |
| Diagnostics appear | Underlines in buffer | ⏳ |
| Diagnostics update | New issues on change | ⏳ |
| Decoded scripts | LSP attaches to virtual buf | ⏳ |
| Multiple scripts | Each buffer has LSP | ⏳ |

## Next Steps After Testing

Once Phase 1 tests pass:
- ✅ Mark TEC-441 progress in Linear
- 🚀 Proceed to Phase 2: API Database
- 📊 Document any issues found
