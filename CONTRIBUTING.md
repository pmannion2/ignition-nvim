# Contributing to ignition-nvim

Thank you for your interest in contributing! This guide will help you get started.

## Getting Started

### Prerequisites

- Neovim >= 0.11.0
- Python >= 3.8
- Git
- luacheck (for Lua linting)

### Development Setup

1. **Clone the repository:**
   ```bash
   git clone https://github.com/whiskeyhouse/ignition-nvim.git
   cd ignition-nvim
   ```

2. **Set up Python LSP server:**
   ```bash
   cd lsp
   python3 -m venv venv
   source venv/bin/activate  # On Windows: venv\Scripts\activate
   pip install -e ".[dev]"
   ```

3. **Install test dependencies:**
   - [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for Lua tests
   - pytest for Python tests (installed with `[dev]` extras above)

## Project Structure

```
ignition-nvim/
├── lua/ignition/              # Neovim plugin (Lua)
│   ├── init.lua              # Entry point, setup()
│   ├── config.lua            # Configuration schema
│   ├── encoding.lua          # Encode/decode scripts
│   ├── decoder.lua           # Interactive decode workflow
│   ├── virtual_doc.lua       # Virtual buffer system
│   ├── lsp.lua               # LSP client
│   └── kindling.lua          # Kindling integration
│
├── lsp/ignition_lsp/         # Python LSP server (pygls 2.0)
│   ├── server.py             # Main server, request routing
│   ├── completion.py         # Completions
│   ├── hover.py              # Hover documentation
│   ├── diagnostics.py        # ignition-lint integration
│   ├── definition.py         # Go-to-definition
│   ├── api_loader.py         # API database loader
│   ├── project_scanner.py    # Project indexing
│   └── api_db/               # API definitions (JSON)
│       ├── schema.json       # JSON schema for API modules
│       ├── tag.json          # system.tag functions
│       ├── db.json           # system.db functions
│       └── ...               # 14 modules total
│
├── tests/                     # Lua tests (plenary.nvim)
│   ├── minimal_init.lua      # Test harness
│   ├── encoding_spec.lua     # Encoding tests
│   └── ...                   # 7 spec files total
│
├── lsp/tests/                # Python tests (pytest)
│   ├── test_completion.py   # Completion tests
│   ├── test_hover.py        # Hover tests
│   └── ...                  # 7 test files total
│
├── docs/                     # User documentation (Docusaurus)
│   ├── intro.md
│   ├── getting-started/
│   ├── guides/
│   └── configuration/
│
└── .github/workflows/        # CI/CD pipelines
    ├── ci.yml               # Test and lint
    ├── beta.yml             # PyPI beta releases
    ├── release.yml          # PyPI releases
    └── deploy-docs.yml      # Docusaurus deployment
```

## Running Tests

### Lua Tests (plenary.nvim)

**All tests (107 tests across 7 spec files):**
```bash
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"
```

**Single file:**
```bash
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile tests/encoding_spec.lua"
```

### Python Tests (pytest)

**All tests (162 tests across 7 test files):**
```bash
cd lsp
venv/bin/python -m pytest tests/ -v
```

**With coverage:**
```bash
cd lsp
venv/bin/python -m pytest tests/ -v --cov=ignition_lsp
```

**Single file:**
```bash
cd lsp
venv/bin/python -m pytest tests/test_completion.py -v
```

## Linting

### Lua

```bash
luacheck lua/ --config .luacheckrc
```

### Python

```bash
cd lsp
venv/bin/ruff check ignition_lsp/
venv/bin/mypy ignition_lsp/
venv/bin/black --check ignition_lsp/
```

**Auto-fix with Black:**
```bash
cd lsp
venv/bin/black ignition_lsp/
```

## Contribution Guidelines

### Code Style

**Lua:**
- Follow Neovim plugin conventions
- Use `snake_case` for functions and variables
- Add comments for complex logic
- Prefer explicit over implicit

**Python:**
- Black formatting (line length 88)
- Type hints for all function signatures
- Follow PEP 8
- Docstrings for public functions

### Commit Messages

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

- `feat:` — New feature
- `fix:` — Bug fix
- `refactor:` — Code refactoring (no behavior change)
- `test:` — Adding/updating tests
- `docs:` — Documentation changes
- `chore:` — Maintenance tasks (CI, deps, etc.)

**Examples:**
```
feat: add system.alarm completions
fix: prevent duplicate LSP client instances
refactor: extract common encoding logic
test: add round-trip encoding tests
docs: update installation instructions
chore: bump pygls to 2.0.1
```

### Pull Request Process

1. **Fork the repository** and create a feature branch:
   ```bash
   git checkout -b feat/my-feature
   ```

2. **Make your changes** with tests:
   - Add tests for new features
   - Update tests for bug fixes
   - Ensure all tests pass

3. **Run linting:**
   ```bash
   # Lua
   luacheck lua/

   # Python
   cd lsp
   venv/bin/ruff check ignition_lsp/
   venv/bin/mypy ignition_lsp/
   venv/bin/black --check ignition_lsp/
   ```

4. **Commit with conventional commit messages:**
   ```bash
   git add .
   git commit -m "feat: add workspace symbols support"
   ```

5. **Push and open a pull request:**
   ```bash
   git push origin feat/my-feature
   ```

6. **Respond to review feedback:**
   - Address reviewer comments
   - Make requested changes
   - Update tests as needed

## Critical Areas (Require Discussion First)

**Always open an issue or discussion before modifying:**

- **Encoding/decoding logic** (`lua/ignition/encoding.lua`) — Round-trip fidelity is the most fragile part of the system. Any changes must preserve `encode(decode(x)) == x`.

- **LSP protocol handlers** (`lsp/ignition_lsp/server.py`) — These affect every user's editor experience. Changes to request handlers, capabilities, or the LSP protocol require careful review.

- **API database schema** (`lsp/ignition_lsp/api_db/schema.json`) — All 14 module files depend on this schema. Schema changes require updating all modules and tests.

- **Breaking configuration changes** — Anything that changes the `setup(opts)` interface or default behavior affects all users.

- **CI/CD pipeline modifications** (`.github/workflows/*.yml`) — These control releases and PyPI publishing. Errors can break deployments.

- **Package metadata** (`lsp/pyproject.toml`) — Version numbers, dependencies, and publish config must be handled carefully.

- **Git operations** — Never force-push to main. Never amend published commits. Always use feature branches.

- **Cross-repo changes** — Anything that affects `ignition-lint` or other Whiskey House projects requires coordination.

**Safe to proceed without discussion:**

- Adding new API modules (as long as they follow `schema.json`)
- Adding test cases
- Bug fixes with clear scope and comprehensive tests
- Documentation improvements (typos, clarity, examples)
- Adding code examples or fixtures

## Adding API Functions

To add new functions to the LSP server's knowledge base:

1. **Find or create the module JSON** in `lsp/ignition_lsp/api_db/`
   - Use existing modules as templates
   - Follow the exact structure in `schema.json`

2. **Add function definition:**
   ```json
   {
     "name": "readBlocking",
     "signature": "readBlocking(tagPaths, timeout=45000)",
     "description": "Read one or more tags synchronously",
     "parameters": [
       {
         "name": "tagPaths",
         "type": "List[str]",
         "description": "Tag paths to read"
       },
       {
         "name": "timeout",
         "type": "int",
         "description": "Timeout in milliseconds",
         "optional": true
       }
     ],
     "returns": {
       "type": "List[QualifiedValue]",
       "description": "List of qualified tag values"
     },
     "scope": "both",
     "docs": "https://docs.inductiveautomation.com/..."
   }
   ```

3. **Required fields:**
   - `name`: Function name (e.g., "readBlocking")
   - `signature`: Full signature with defaults (e.g., "readBlocking(tagPaths, timeout=45000)")
   - `description`: Brief summary
   - `parameters`: Array of parameter objects
   - `returns`: Return type and description
   - `scope`: "client", "gateway", or "both"
   - `docs`: Link to official Ignition documentation

4. **Add tests** in `lsp/tests/test_completion.py`:
   ```python
   def test_tag_read_blocking_completion(lsp_server):
       """Test completion for system.tag.readBlocking"""
       # Test setup and assertions
   ```

5. **Verify:**
   ```bash
   cd lsp
   venv/bin/python -m pytest tests/test_completion.py -v -k readBlocking
   ```

## Testing Guidelines

- **All new features require tests** — No exceptions
- **Maintain or improve coverage** — Run with `--cov` to check
- **Test both Lua and Python components** — Integration tests for cross-component features
- **Use fixtures** — `tests/fixtures/` (Lua) and `lsp/tests/fixtures/` (Python)
- **Test edge cases** — Empty inputs, special characters, error conditions
- **Test round-trip operations** — Especially for encoding/decoding

### Test Organization

**Lua tests (`tests/*_spec.lua`):**
- `encoding_spec.lua` — Encode/decode round-trip tests
- `json_parser_spec.lua` — JSON script extraction
- `decoder_spec.lua` — Interactive decode workflow
- `virtual_doc_spec.lua` — Virtual buffer system
- `lsp_spec.lua` — LSP client initialization
- `kindling_spec.lua` — Kindling integration
- `config_spec.lua` — Configuration validation

**Python tests (`lsp/tests/test_*.py`):**
- `test_completion.py` — Completion provider
- `test_hover.py` — Hover documentation
- `test_diagnostics.py` — Diagnostic integration
- `test_definition.py` — Go-to-definition
- `test_api_loader.py` — API database loading
- `test_project_scanner.py` — Project indexing
- `test_workspace_symbols.py` — Workspace symbols

## Documentation

When making changes, update relevant documentation:

### User-Facing Changes

- Update `docs/` (Docusaurus site) for new features or changed behavior
- Update `README.md` if installation or quick start changes
- Update `CHANGELOG.md` following [Keep a Changelog](https://keepachangelog.com/) format
- Add examples to relevant guides

### Developer Documentation

- Add docstrings to Python functions (Google style)
- Add comments for complex Lua logic
- Update `CLAUDE.md` if architecture changes
- Update this file (`CONTRIBUTING.md`) if contribution process changes

### Changelog Format

Add entries to `CHANGELOG.md` under `[Unreleased]`:

```markdown
## [Unreleased]

### Added
- New feature descriptions

### Changed
- Modified behavior descriptions

### Fixed
- Bug fix descriptions
```

## Questions?

- **Architecture details**: Review [CLAUDE.md](CLAUDE.md)
- **Common issues**: Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
- **Design questions**: Open a [GitHub Discussion](https://github.com/whiskeyhouse/ignition-nvim/discussions)
- **Bug reports**: Open a [GitHub Issue](https://github.com/whiskeyhouse/ignition-nvim/issues)

## License

By contributing, you agree that your contributions will be licensed under the MIT License.
