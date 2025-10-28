# Ignition LSP Server

Language Server Protocol implementation for Ignition by Inductive Automation.

## Features

- Autocompletion for Ignition APIs (`system.*`, `shared.*`)
- Hover documentation for Ignition functions
- Go-to-definition for project scripts
- Diagnostics for common issues and deprecated APIs
- Project structure indexing

## Installation

### From PyPI (once published)

```bash
pip install ignition-lsp
```

### From Source

```bash
cd lsp
pip install -e .
```

### Development Installation

```bash
cd lsp
pip install -e ".[dev]"
```

## Usage

The LSP server is automatically started by the ignition.nvim plugin when editing Ignition files.

### Manual Start

```bash
ignition-lsp
```

The server communicates via stdio and follows the LSP specification.

## Development

### Running Tests

```bash
pytest
```

### Code Formatting

```bash
black ignition_lsp tests
```

### Type Checking

```bash
mypy ignition_lsp
```

### Linting

```bash
ruff check ignition_lsp tests
```

## Architecture

- `server.py` - Main LSP server implementation using pygls
- `completion.py` - Completion provider for Ignition APIs
- `diagnostics.py` - Diagnostic provider for code analysis
- `indexer.py` - Project structure indexer
- `data/` - Ignition API definitions and signatures

## Contributing

See the main project README for contribution guidelines.

## License

MIT License - see LICENSE file for details.
