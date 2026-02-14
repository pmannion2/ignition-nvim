---
sidebar_position: 3
---

# LSP Features

ignition-nvim includes a comprehensive Language Server Protocol (LSP) server providing intelligent code completion, documentation, and navigation for:

- **Ignition System APIs** — All `system.*` modules (14 modules, 239+ functions)
- **Java/Jython APIs** — Standard Java libraries and Ignition SDK (27 modules)
- **Project Scripts** — `project.*` and `shared.*` module completions with inheritance
- **Perspective JSON** — Component types, props, and event handlers for view.json files

## System API Completions

Type `system.` in any decoded Python script to get completions for all Ignition API modules:

### Available Modules (14 total)

- `system.tag` — Tag read/write operations, browsing, quality codes
- `system.db` — Database queries, transactions, named queries
- `system.perspective` — Perspective session control, component messaging
- `system.util` — Utility functions (timers, threading, exports, logging)
- `system.alarm` — Alarm management, querying, acknowledgment
- `system.dataset` — Dataset creation, manipulation, conversion
- `system.date` — Date/time manipulation, formatting, parsing
- `system.file` — File I/O operations, CSV/JSON handling
- `system.gui` — GUI interactions (client scope only)
- `system.nav` — Navigation functions (Vision client)
- `system.net` — HTTP requests, email, webhooks
- `system.opc` — OPC operations, browsing, read/write
- `system.security` — Authentication, authorization, user roles
- `system.user` — User management, sessions, preferences

Each completion includes:
- Function signature with parameter names and types
- Brief description
- Scope information (client, gateway, or both)

## Java API Completions

Full support for Java/Jython class imports and methods (27 modules with comprehensive coverage):

### Standard Java Libraries

- **java.lang** — String, Integer, Double, Math, System, Thread, etc.
- **java.util** — ArrayList, HashMap, Date, Collections, UUID, etc.
- **java.io** — File, FileInputStream, BufferedReader, PrintWriter, etc.
- **java.math** — BigDecimal, BigInteger for precise calculations
- **java.nio.file** — Modern file I/O with Path, Files, etc.

### Java GUI Frameworks

- **java.awt** — Graphics, Color, Dimension, Font, etc.
- **java.awt.event** — Event listeners and handlers
- **java.awt.geom** — Geometric shapes and transformations
- **javax.swing** — GUI components (JFrame, JButton, JTable, etc.)
- **javax.swing.table** — Table models and renderers

### Java Networking & Security

- **java.net** — URL, URLConnection, HttpURLConnection, InetAddress
- **java.security** — MessageDigest, SecureRandom, cryptographic operations
- **javax.crypto** — Cipher, encryption/decryption utilities
- **javax.net.ssl** — SSL/TLS for secure connections

### Java Data & Time

- **java.sql** — Database connectivity (Connection, PreparedStatement, ResultSet)
- **java.time** — Modern date/time API (LocalDateTime, Instant, Duration)
- **java.time.format** — DateTimeFormatter for parsing/formatting
- **java.time.temporal** — Temporal adjusters and fields
- **java.text** — Legacy text formatting (SimpleDateFormat, DecimalFormat)

### Java Utilities

- **java.util.concurrent** — Executor, Future, concurrent collections
- **java.util.logging** — Logger, Level, Handler for logging
- **java.util.regex** — Pattern, Matcher for regular expressions

### Ignition SDK

- **com.inductiveautomation.common** — Common Ignition utilities and types
- **com.inductiveautomation.gateway** — Gateway-scoped SDK functions

### Web & XML

- **javax.servlet.http** — HttpServletRequest, HttpServletResponse
- **javax.xml.parsers** — DocumentBuilder, SAXParser for XML

### Usage Example

```python
# Import completions
from java.util import ArrayList, HashMap
from java.io import File, BufferedReader
from com.inductiveautomation.common import Dataset

# Class member completions
files = ArrayList()  # Type '.' after files to see add(), remove(), etc.
map = HashMap()      # Type '.' to see put(), get(), keySet(), etc.
```

## Project Script Completions

Access project-level and shared script modules with full inheritance support:

### Project Modules

Type `project.` to access scripts defined in your Ignition project:

```python
# Project script completions
project.utils.formatValue(value)
project.database.getConnection()
project.tags.readSafely(tagPath)
```

### Shared Modules

Type `shared.` to access shared scripts:

```python
# Shared script completions
shared.common.logger
shared.calculations.computeTotals(data)
```

### Inherited Projects

The LSP server supports inherited projects. Scripts from parent projects are automatically indexed and available for completion, even if they're defined in a parent project hierarchy.

## Perspective JSON Completions

When editing Perspective `view.json` files, the LSP provides context-aware completions for:

### Component Types

Start typing a component type to get completions:

```json
{
  "type": "ia.container.flex",  // Completions for all ia.* components
  "props": { ... }
}
```

**Available component families:**
- `ia.container.*` — Flex, Coord, Column, Row, Tab, Carousel, Split
- `ia.display.*` — Label, Icon, Image, Markdown, Progress Bar, LED Display, Gauge, Table, etc.
- `ia.input.*` — Button, Toggle Switch, Checkbox, Radio Group, Dropdown, Text Field, etc.
- `ia.chart.*` — Time Series Chart, XY Chart, Pie Chart, Power Chart
- `ia.navigation.*` — Breadcrumb, Dropdown, Tree, Vertical Menu
- And many more...

### Structural Keys

Completions for view structure:

```json
{
  "root": { ... },          // Root component definition
  "custom": { ... },        // Custom properties
  "meta": { ... },          // View metadata
  "propConfig": { ... },    // Prop configuration
  "position": { ... },      // Component positioning
  "events": { ... }         // Event handler scripts
}
```

### Component Props

After specifying a component type, get completions for props specific to that component:

```json
{
  "type": "ia.input.button",
  "props": {
    "text": "",           // Text to display
    "style": { ... },     // Style configuration
    "enabled": true,      // Enable/disable
    "variant": "primary"  // primary, secondary, etc.
  }
}
```

### Event Handlers

Completions for common event handlers:

```json
{
  "events": {
    "onActionPerformed": { ... },  // Button click, etc.
    "onValueChange": { ... },      // Input value changed
    "onStartup": { ... },          // Component mounted
    "onShutdown": { ... }          // Component unmounted
  }
}
```

## Hover Documentation

Press `K` (or your configured hover keymap) over any `system.*` function call to see:

- **Full function signature** with parameter names and types
- **Parameter descriptions** — what each argument does
- **Return type** — what the function returns
- **Usage notes** — scope restrictions, version requirements, common patterns

## Diagnostics

The LSP server reports issues in your scripts:

- Unknown `system.*` function calls
- Incorrect argument counts
- Scope violations (e.g., using a client-scoped function in a gateway script)

Diagnostics appear as inline warnings and in the quickfix list.

## Go-to-Definition

Jump to definitions with `gd` or `:lua vim.lsp.buf.definition()`:

**For `system.*` functions:**
Opens the API database entry showing the full function definition, parameters, and documentation.

**For project scripts:**
Jumps to the script definition in your workspace. Works across files using the project indexer.

## Workspace Symbols

Search all scripts in your project with `:LspWorkspaceSymbol <query>`:

- Find functions across multiple files
- Navigate project structure quickly
- Powered by the project indexer

The LSP server scans your Ignition project directory and indexes all Python scripts, making them searchable and navigable.

## API Databases

The LSP server's knowledge comes from curated JSON databases:

### Ignition System API Database

Located at `lsp/ignition_lsp/api_db/`, with one file per module:

- `system_tag.json`, `system_db.json`, `system_perspective.json`, etc.
- Each follows `schema.json` structure
- Includes function signatures, parameters, return types, scope information

### Java API Database

Located at `lsp/ignition_lsp/java_db/`, with 27 modules:

- Standard Java libraries (java.*, javax.*)
- Ignition SDK modules (com.inductiveautomation.*)
- Follows `java_schema.json` structure
- Includes class definitions, methods, constructors, fields

### Adding New APIs

To extend the LSP with additional APIs:

1. Add a new JSON file to the appropriate database directory
2. Follow the existing schema structure
3. Include comprehensive documentation
4. Add corresponding tests in `lsp/tests/`

See [CONTRIBUTING.md](../../CONTRIBUTING.md) for detailed instructions.

## Configuration

LSP behavior is controlled through the `lsp` section of your plugin config:

```lua
require('ignition').setup({
  lsp = {
    enabled = true,       -- Enable/disable the LSP server
    auto_start = true,    -- Auto-attach to Ignition buffers
    cmd = nil,            -- Custom command (auto-detected by default)
    settings = {
      ignition = {
        version = "8.1",  -- Target Ignition version
        sdk_path = nil,   -- Path to Ignition SDK (optional)
      },
    },
  },
})
```

## Server Detection

The plugin auto-detects the LSP server in this order:

1. **Plugin venv** — `lsp/venv/bin/ignition-lsp` (used during development)
2. **System install** — `ignition-lsp` on your `$PATH`
3. **System Python** — `python -m ignition_lsp` as a fallback

You can override detection by setting `lsp.cmd` explicitly:

```lua
lsp = {
  cmd = { '/path/to/ignition-lsp' },
}
```
