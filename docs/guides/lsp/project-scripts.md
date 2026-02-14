---
sidebar_position: 3
---

# Project Script Completions

The LSP automatically indexes your Ignition project directory and provides intelligent completions for `project.*` and `shared.*` script references, including functions, classes, and variables defined in your project scripts.

## How It Works

When you open an Ignition project directory, the LSP scans all Python scripts and builds an index of:
- Module paths (`project.library.utils`, `shared.common.helpers`)
- Functions and their signatures
- Classes and their methods
- Module-level variables

This enables **cross-file completions** and **go-to-definition** for your entire project.

## Project Structure

Ignition organizes scripts in a hierarchical structure:

```
ignition/
└── script-python/
    ├── project/           # Project-scoped scripts
    │   └── library/
    │       ├── code.py    # project.library
    │       └── utils/
    │           └── code.py  # project.library.utils
    └── shared/            # Shared across projects
        └── common/
            └── code.py    # shared.common
```

## Module Path Completions

Type `project.` or `shared.` to see available modules:

```python
# Type 'project.' to see:
project.library.
project.alarms.
project.database.

# Navigate deeper:
project.library.utils.
project.library.config.
```

The LSP shows:
- **Packages** - Modules with children (e.g., `project.library`)
- **Leaf modules** - Final scripts with symbols (e.g., `project.library.utils`)

## Function Completions

After selecting a module, get completions for all functions defined in that script:

```python
# In project/library/utils/code.py:
def validate_tag_path(path):
    """Check if tag path is valid."""
    return path.startswith("[")

def format_timestamp(ts):
    """Format timestamp for display."""
    return system.date.format(ts, "yyyy-MM-dd HH:mm:ss")

# In another script:
from project.library import utils

utils.  # <- See: validate_tag_path(), format_timestamp()
```

Each completion shows:
- Function signature with parameter names
- Docstring (if available)
- Module source path

## Class Completions

Access classes and their members:

```python
# In project/library/models/code.py:
class AlarmConfig:
    """Configuration for alarm handling."""

    def __init__(self, name, priority):
        self.name = name
        self.priority = priority

    def to_dict(self):
        return {"name": self.name, "priority": self.priority}

# In another script:
from project.library.models import AlarmConfig

config = AlarmConfig("HighTemp", 1)
config.  # <- See: to_dict(), name, priority
```

## Variable Completions

Module-level variables and constants are also available:

```python
# In project/config/constants/code.py:
DATABASE_NAME = "production"
MAX_RETRIES = 3
TAG_PROVIDER = "[default]"

# In another script:
from project.config import constants

db = constants.DATABASE_NAME  # <- Autocomplete available
```

## Nested Packages

Navigate through deeply nested project structures:

```python
# Deep hierarchy:
project.
  production.
    lines.
      line1.
        controls.
          temperature.  # <- All levels indexed
```

## Go-to-Definition

Use LSP go-to-definition (typically `gd`) on any project reference to jump to the actual implementation:

```python
from project.library import utils

# Press 'gd' on 'utils' -> Jump to project/library/utils/code.py
# Press 'gd' on 'validate_tag_path' -> Jump to function definition
result = utils.validate_tag_path(tag)
```

## Workspace Symbols

Search for any symbol across your entire project using LSP workspace symbols (`:LspWorkspaceSymbols` or telescope/fzf integration):

```
# Search: "validate"
→ validate_tag_path (project.library.utils)
→ validate_user (project.security.auth)
→ validate_config (shared.common.validation)
```

## Symbol Cache

The LSP caches parsed symbols for performance:
- **On open**: Scans all project scripts
- **On save**: Updates symbols for the modified file
- **On refresh**: Manual refresh via `:LspRestart`

## Inheritance Tracking

The LSP understands class inheritance:

```python
# In project/base/handler/code.py:
class BaseHandler:
    def handle(self, event):
        pass

# In project/alarms/handler/code.py:
from project.base.handler import BaseHandler

class AlarmHandler(BaseHandler):
    def handle(self, event):
        # Overrides base method
        self.process_alarm(event)

# LSP knows AlarmHandler has both:
# - handle() (overridden)
# - Any methods from BaseHandler
```

## Multi-Project Support

If your workspace contains multiple Ignition projects, each is indexed separately:

```
workspace/
├── ignition-project-1/
│   └── script-python/
│       └── project/  # project.* for project 1
└── ignition-project-2/
    └── script-python/
        └── project/  # project.* for project 2 (separate index)
```

## Private Symbol Filtering

The LSP automatically filters out private symbols (names starting with `_`):

```python
# In module:
def public_function():  # Shown in completions
    pass

def _private_helper():  # Hidden from completions
    pass

_INTERNAL_CONSTANT = 42  # Hidden from completions
```

## Performance

The project scanner is optimized for large projects:
- **Async scanning** - Non-blocking background indexing
- **Incremental updates** - Only re-scans modified files
- **Symbol caching** - In-memory cache for fast lookups
- **Lazy loading** - Only parses files when needed

## Troubleshooting

### "No completions for project.*"

1. Check that the LSP has scanned your project:
   ```
   :IgnitionInfo  # Look for "Project index: X scripts"
   ```

2. Ensure you're in an Ignition project directory:
   ```
   workspace/
   └── ignition/
       └── script-python/  # LSP looks for this
   ```

3. Restart the LSP to force a rescan:
   ```
   :LspRestart
   ```

### "Completions are outdated"

The LSP updates symbols on save. If you modify a file outside Neovim:
```
:LspRestart  # Force full rescan
```

### "Missing some modules"

Check the LSP log for scanning errors:
```
:lua vim.cmd.edit('/tmp/ignition-lsp.log')
```

Look for parse errors or permission issues.
