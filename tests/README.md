# Ignition.nvim Tests

This directory contains tests for the ignition.nvim plugin.

## Running Tests

### Prerequisites

Install [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for running tests:

```bash
git clone https://github.com/nvim-lua/plenary.nvim ~/.local/share/nvim/site/pack/vendor/start/plenary.nvim
```

### Run All Tests

```bash
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"
```

### Run Specific Test File

```bash
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile tests/filetype_spec.lua"
```

### Manual Testing

Open test fixture files in Neovim to verify filetype detection:

```bash
nvim tests/fixtures/test.gwbk
# Check with :set filetype?
```

## Test Fixtures

The `fixtures/` directory contains sample Ignition files for testing:

- `test.gwbk` - Gateway Backup file
- `test.proj` - Project file
- `ignition-project/resource.json` - Resource definition
- `ignition-project/tags.json` - Tag configuration with embedded script
- `ignition-project/project.json` - Project metadata
- `ignition-project/perspective-view.json` - Perspective view component

## Test Structure

- `minimal_init.lua` - Minimal Neovim config for testing
- `filetype_spec.lua` - File type detection tests
- More test files to be added as features are implemented

## Future Tests

- Script decoder/encoder tests
- LSP server tests
- Kindling integration tests
- Configuration validation tests
