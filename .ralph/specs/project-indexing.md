# Spec: Project Indexing

## Purpose

Ignition projects have a well-defined directory structure. Indexing the project enables cross-file navigation, workspace symbols, and context-aware completions that reference other scripts in the project.

## Ignition Project Structure

```
project-root/
├── project.json                    # Project metadata
├── ignition/
│   ├── script-python/
│   │   └── project-library/        # Project library scripts
│   │       ├── resource.json       # Script resource definition
│   │       └── code.py             # Actual Python code
│   ├── named-query/                # Named queries
│   │   └── QueryName/
│   │       └── resource.json
│   ├── perspective-views/          # Perspective views
│   │   └── ViewName/
│   │       └── view.json           # Contains embedded scripts
│   └── vision-windows/             # Vision windows
│       └── WindowName/
│           └── resource.json
```

## Index Data Model

```python
@dataclass
class ScriptLocation:
    file_path: str           # Absolute path to the file
    script_key: str          # JSON key (e.g., "script", "onActionPerformed")
    line_number: int         # Line in the source file
    module_path: str         # Logical path (e.g., "project.library.utils")
    resource_type: str       # "script-python", "perspective-view", etc.

@dataclass
class ProjectIndex:
    root_path: str
    scripts: Dict[str, ScriptLocation]     # module_path -> location
    resources: Dict[str, ResourceInfo]      # file_path -> resource info
    last_updated: datetime
```

## Implementation Plan

1. **Project scanner** (`lsp/ignition_lsp/project_scanner.py`):
   - Walk directory from project root
   - Find all `resource.json`, `view.json`, `*.py` files
   - Extract script locations and module paths

2. **Index builder** (part of `server.py` initialization):
   - Build index on workspace open
   - Re-index on file save events
   - Cache index for performance

3. **LSP workspace symbols** (`textDocument/documentSymbol`, `workspace/symbol`):
   - Return project scripts as symbols
   - Support filtering by name

4. **Cross-file completions**:
   - When typing `project.library.`, suggest available modules
   - When typing `shared.`, suggest shared script modules

## Trigger

Index builds when:
- LSP server initializes with a workspace folder containing `project.json`
- A `resource.json` file is saved
- User explicitly requests re-index (future command)
