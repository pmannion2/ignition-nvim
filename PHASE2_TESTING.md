# Phase 2 Testing: API Completion & Hover

## What Was Built

### API Database (44 Functions)
- ✅ `system.tag` - 10 functions (readBlocking, writeBlocking, configure, etc.)
- ✅ `system.perspective` - 15 functions (sendMessage, navigate, openPopup, etc.)
- ✅ `system.db` - 10 functions (runQuery, runPrepQuery, transactions, etc.)
- ✅ `system.util` - 9 functions (getLogger, jsonEncode, jsonDecode, etc.)

### Features Implemented
- ✅ **API Loader** - Loads and indexes JSON definitions
- ✅ **Completion Provider** - Context-aware autocomplete
- ✅ **Hover Provider** - Comprehensive documentation on hover
- ✅ **LSP Integration** - Wired into server.py

## How to Test

### Step 1: Restart LSP with New API Database

**In terminal, stop any running LSP:**
```bash
pkill -f ignition_lsp
```

**In Neovim:**
```vim
" Reload plugin
:luafile /Users/pmannion/Documents/whiskeyhouse/ignition-nvim/LOAD_PLUGIN.lua

" Open test file or create new Python file
:e test_ignition_api.py

" Start LSP
:luafile /Users/pmannion/Documents/whiskeyhouse/ignition-nvim/TEST_CONFIG_SIMPLE.lua
```

**Check logs for API loader:**
```bash
tail -20 /tmp/ignition-lsp.log
```

Should see:
```
API loader initialized with 44 functions
Loaded 44 functions from 4 modules
```

### Step 2: Test Module Completion

**In insert mode, type:**
```python
system.
```

**Expected:** Completion popup showing:
- `tag` (system.tag) (10 functions)
- `perspective` (system.perspective) (15 functions)
- `db` (system.db) (10 functions)
- `util` (system.util) (9 functions)

**Trigger completion:**
- Neovim built-in: `<C-x><C-o>`
- Or your completion plugin should auto-trigger

### Step 3: Test Function Completion

**Type:**
```python
system.tag.
```

**Expected:** Completion showing:
- `readBlocking` - Reads tag values (blocks until complete)
- `readAsync` - Asynchronously reads tag values
- `writeBlocking` - Writes values to tags
- `configure` - Creates/modifies tags from dictionaries
- `exists` - Checks if tag exists
- ... and 5 more

**Select a function and it should insert with snippet placeholders!**

### Step 4: Test Hover Documentation

**Type a full function call:**
```python
value = system.tag.readBlocking(["[default]Tag1"])
```

**Hover over `readBlocking`** (press `K` or your hover key)

**Expected popup:**
```markdown
**system.tag.readBlocking**

```python
system.tag.readBlocking(tagPaths, timeout=45000)
  -> List[QualifiedValue]
```

Reads the value of tags at the given paths. Blocks until complete or timeout.

**Parameters:**
- `tagPaths`: String | List[String]
  Single tag path or list of tag paths to read
- `timeout`: int (optional) = 45000
  Timeout in milliseconds

**Returns:**
List[QualifiedValue] - List of QualifiedValue objects with .value, .quality, and .timestamp

**Scope:** Gateway, Vision, Perspective

[Documentation](https://www.docs.inductiveautomation.com/...)
```

### Step 5: Test Other Modules

**Test system.perspective:**
```python
system.perspective.sendMessage("myMessage", {"data": "value"})
```

Hover over `sendMessage` - should show full documentation.

**Test system.db:**
```python
result = system.db.runQuery("SELECT * FROM table")
```

**Test system.util:**
```python
logger = system.util.getLogger("MyScript")
```

### Step 6: Test with Decoded Scripts

**Open Ignition JSON and decode:**
```vim
:e tests/fixtures/perspective-button-correct.json
:IgnitionDecode
```

**In the decoded script, try completion:**
```python
# Add this line
data = system.db.
```

Should see database function completions!

## Success Criteria

- ✅ Type `system.` → see 4 modules
- ✅ Type `system.tag.` → see 10+ functions
- ✅ Completions include signatures and descriptions
- ✅ Selecting completion inserts with snippet placeholders
- ✅ Hover shows comprehensive documentation
- ✅ Works in decoded Ignition scripts
- ✅ Works with multiple modules

## Debugging

**If completions don't appear:**
```bash
# Check API loader initialized
tail -f /tmp/ignition-lsp.log | grep "API loader"

# Check completion requests
tail -f /tmp/ignition-lsp.log | grep "Completion"
```

**If hover doesn't work:**
```bash
# Check hover requests
tail -f /tmp/ignition-lsp.log | grep "Hover"
```

**Manual test of API loader:**
```bash
cd lsp
source venv/bin/activate
python -c "from ignition_lsp.api_loader import IgnitionAPILoader; loader = IgnitionAPILoader(); print(f'Loaded {len(loader.api_db)} functions'); print('Modules:', list(loader.modules.keys()))"
```

## Next Steps After Testing

If Phase 2 tests pass:
- Document results in Linear
- Consider expanding API database (more modules, more functions)
- Move to Phase 3: Project indexing and go-to-definition
