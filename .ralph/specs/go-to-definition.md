# Spec: Go-to-Definition

## Purpose

Allow developers to jump to the definition of Ignition scripting functions and project-level scripts directly from their code.

## Two Types of Definitions

### 1. System API Functions (`system.*`)

When the cursor is on `system.tag.readBlocking`, go-to-definition should:
- **Primary action**: Open the official Ignition docs URL in the browser (via `docs_url` from API database)
- **Fallback**: Show the function definition inline in a floating window if docs_url is not available

### 2. Project Scripts (`project.library.*`, `shared.*`)

When the cursor is on `project.library.utils.myFunction`, go-to-definition should:
- Look up the script location in the project index
- Open the source file and jump to the correct line
- If the script is embedded in JSON, decode it first (trigger `:IgnitionDecode`)

## LSP Protocol

Handler: `textDocument/definition`

Request: cursor position in a document
Response: `Location` (file URI + range) or `LocationLink` (with origin range)

## Implementation

### Word extraction

Reuse the logic from `hover.py` — extract the full dotted identifier at the cursor position (e.g., `system.tag.readBlocking` not just `readBlocking`).

### Resolution order

1. Check project index for `project.*` / `shared.*` references
2. Check API database for `system.*` references
3. Return empty if no match

### Dependencies

- Requires project indexing (Priority 4) for project script definitions
- API database `docs_url` field already exists in all function definitions
- `server.py` already has a stub definition handler to wire up
