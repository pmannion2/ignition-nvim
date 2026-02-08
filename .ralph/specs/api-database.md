# Spec: Ignition API Database

## Purpose

The API database provides function definitions for Ignition's `system.*` scripting API. It powers LSP completions, hover documentation, and (eventually) go-to-definition.

## Schema

All JSON files must conform to `lsp/ignition_lsp/api_db/schema.json`.

### File naming

One file per module: `system_<module>.json` (e.g., `system_tag.json`, `system_net.json`)

### Required fields per function

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `name` | string | yes | Function name without module prefix (e.g., `readBlocking`) |
| `signature` | string | yes | Full call signature (e.g., `readBlocking(tagPaths, timeout=45000)`) |
| `description` | string | yes | Brief one-line description |
| `params` | array | no | Parameter definitions (name, type, description, optional, default) |
| `returns` | object | no | Return type and description |
| `scope` | array | no | Where callable: `Gateway`, `Vision`, `Perspective`, `Designer` |
| `deprecated` | boolean | no | Default false |
| `since` | string | no | Ignition version introduced (e.g., `"8.0"`) |
| `docs_url` | string | no | Link to official docs |
| `examples` | array | no | Code example strings |
| `long_description` | string | no | Detailed usage notes |

## Existing modules (4)

- `system_tag.json` — 18 functions (read, write, browse, configure, history, etc.)
- `system_db.json` — database functions
- `system_perspective.json` — Perspective component functions
- `system_util.json` — utility functions

## Modules to add (10)

Priority order based on usage frequency in real Ignition projects:

1. **system.net** — HTTP requests are extremely common in gateway scripts
2. **system.date** — Date manipulation is used everywhere
3. **system.gui** — Vision client scripting (large install base)
4. **system.security** — Auth checks in most projects
5. **system.alarm** — Core SCADA functionality
6. **system.opc** — Direct OPC reads/writes
7. **system.dataset** — Dataset manipulation (used with system.db results)
8. **system.file** — File I/O in gateway scripts
9. **system.nav** — Vision navigation
10. **system.user** — User management

## Data sources

- Official docs: https://docs.inductiveautomation.com/docs/8.1/appendix/scripting-functions
- Ignition SDK Javadocs for parameter types
- Ignition Flint VS Code extension for reference

## Validation

After creating each file, verify:
1. JSON is valid
2. Conforms to `schema.json` structure
3. `api_loader.py` loads it without errors
4. Completions appear for the new module in the LSP
