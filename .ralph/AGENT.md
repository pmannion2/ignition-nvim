# Ralph Agent Configuration - ignition-nvim

## Project Structure

This is a hybrid Lua + Python project:
- **Lua plugin**: `lua/ignition/` — Neovim plugin loaded at runtime
- **Python LSP server**: `lsp/ignition_lsp/` — Language server using pygls 2.0
- **Tests (Lua)**: `tests/*_spec.lua` — plenary.nvim (busted) test suite
- **Tests (Python)**: `lsp/tests/` — pytest test suite (to be created)

## Environment Setup

```bash
# Python LSP server venv (already exists at lsp/venv)
cd lsp && source venv/bin/activate
pip install -e ".[dev]"
```

## Build Instructions

```bash
# No build step for Lua plugin — it's loaded directly by Neovim
# Python LSP: install in editable mode
cd lsp && venv/bin/pip install -e ".[dev]"
```

## Test Instructions

### Lua Tests (plenary.nvim / busted)

```bash
# Run all Lua tests
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

# Run a single Lua test file
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile tests/encoding_spec.lua"
```

### Python LSP Tests (pytest)

```bash
# Run all Python LSP tests
cd lsp && venv/bin/python -m pytest tests/ -v

# Run with coverage
cd lsp && venv/bin/python -m pytest tests/ -v --cov=ignition_lsp
```

## Lint Instructions

### Python

```bash
# Ruff (linting + formatting check)
cd lsp && venv/bin/ruff check ignition_lsp/

# Mypy (type checking)
cd lsp && venv/bin/mypy ignition_lsp/

# Black (formatting check)
cd lsp && venv/bin/black --check ignition_lsp/
```

### Lua

```bash
# Luacheck (if installed)
luacheck lua/ --config .luacheckrc
```

## Run Instructions

```bash
# Start LSP server manually (for debugging)
cd lsp && venv/bin/python -m ignition_lsp.server

# Load plugin in Neovim for manual testing
nvim -u LOAD_PLUGIN.lua tests/fixtures/perspective-view-with-scripts.json
```

## Quality Standards

- All Lua tests passing before committing
- All Python tests passing before committing
- Ruff clean on Python code
- Encoding round-trip tests must always pass (core correctness)

## Git Workflow

- Conventional commit formatting: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`
- Work on `main` branch (small project, single contributor flow)
- Commit working changes with descriptive messages

## Feature Completion Checklist

- [ ] All Lua tests passing
- [ ] All Python tests passing
- [ ] Linting clean
- [ ] Changes committed
- [ ] fix_plan.md updated

## Notes

- The Python venv is at `lsp/venv/` (Python 3.13)
- plenary.nvim must be on the Neovim runtimepath for Lua tests
- LSP server depends on `pygls>=1.3.0` and `lsprotocol>=2023.0.0`
- Diagnostics integration depends on sibling project `../ignition-lint/`
- API definitions live in `lsp/ignition_lsp/api_db/*.json` and follow `schema.json`
