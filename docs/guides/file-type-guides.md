---
sidebar_position: 6
---

# File Type Quick Start Guides

This guide provides specific workflows and features for each common Ignition file type.

## Perspective View Files (`view.json`)

Perspective views contain both **JSON structure** (components, props) and **embedded Python scripts** (event handlers).

### Features Available

- **JSON schema completions** for component types, props, and events
- **Script decode/encode** for event handlers
- **LSP support** in decoded scripts (system.*, project.*, Java)

### Workflow

1. **Open a Perspective view:**
   ```bash
   nvim com.inductiveautomation.perspective/views/MyView/view.json
   ```

2. **Use JSON completions** for component structure:
   ```json
   {
     "root": {
       "type": "ia.container.flex",  // Type "ia." to see all component types
       "props": {
         "direction": "column",       // Props specific to flex container
         "style": { ... }
       },
       "children": [
         {
           "type": "ia.input.button", // Components auto-complete
           "props": {
             "text": "Click Me",
             "variant": "primary"     // Prop completions for button
           },
           "events": {
             "onActionPerformed": {   // Event handler completions
               "script": "..."        // Encoded Python script
             }
           }
         }
       ]
     }
   }
   ```

3. **Decode event handler scripts:**
   ```vim
   :IgnitionDecode
   ```
   Select the event script (e.g., `onActionPerformed`) from the menu.

4. **Edit with full LSP support:**
   ```python
   # System API completions
   system.perspective.sendMessage("close-popup")
   system.tag.writeBlocking(["[default]MyTag"], [value])

   # Project script completions
   project.utils.logEvent("Button clicked")

   # Java completions
   from java.util import HashMap
   payload = HashMap()
   ```

5. **Save and encode back:**
   ```vim
   :w              " Save virtual buffer (auto-encodes to JSON)
   <C-w>p          " Switch back to source
   :w              " Save the view.json file
   ```

### Common Perspective Events

- `onActionPerformed` — Button clicks, user actions
- `onValueChange` — Input value changes
- `onStartup` — Component mounted
- `onShutdown` — Component unmounted
- `onClick` — Mouse click events
- `onDoubleClick` — Double-click events

---

## Resource Files (`resource.json`)

Generic resource files containing embedded scripts (transforms, expressions, etc.).

### Features Available

- **Script decode/encode** for embedded Python
- **LSP support** in scripts
- **Interactive selection** for multiple scripts

### Workflow

1. **Open a resource file:**
   ```bash
   nvim com.inductiveautomation.perspective/page-config/resources/MyResource/resource.json
   ```

2. **List all scripts in the file:**
   ```vim
   :IgnitionListScripts
   ```
   Shows all scripts with previews in a floating window.

3. **Decode a specific script:**
   ```vim
   :IgnitionDecode
   ```
   Select from the interactive menu with syntax-highlighted previews.

4. **Or decode all scripts at once:**
   ```vim
   :IgnitionDecodeAll
   ```
   Opens each script in its own virtual buffer.

5. **Edit with LSP completions:**
   ```python
   # Full Ignition API support
   results = system.db.runNamedQuery("MyQuery", {"param": value})
   dataset = system.dataset.toPyDataSet(results)

   # Java support
   from java.util import ArrayList
   items = ArrayList()
   ```

6. **Save changes:**
   ```vim
   :w              " In each virtual buffer
   <C-w>p          " Return to source
   :w              " Save resource.json
   ```

---

## Tag Configuration Files (`tags.json`)

Tag definitions and configuration, including UDT instances and alarm configurations.

### Features Available

- **Script decode** for value change scripts, alarm scripts
- **LSP support** in decoded scripts

### Workflow

1. **Open tags configuration:**
   ```bash
   nvim ignition/tags/MyFolder/tags.json
   ```

2. **Decode tag scripts:**
   ```vim
   :IgnitionDecode
   ```
   Common tag script types:
   - Value change scripts
   - Alarm notification scripts
   - Expression tags with scripted expressions

3. **Edit tag scripts with completions:**
   ```python
   # Read other tags
   current_value = system.tag.readBlocking(["[default]OtherTag"])[0].value

   # Write to tags
   system.tag.writeBlocking(["[default]TargetTag"], [computed_value])

   # Trigger alarms
   system.alarm.acknowledge([alarm_path])
   ```

4. **Save encoded changes:**
   ```vim
   :w              " Save virtual buffer
   <C-w>p          " Back to tags.json
   :w              " Persist changes
   ```

---

## Gateway Backup Files (`.gwbk`)

Gateway backup archives require **Kindling** integration for exploration.

### Features Available

- **Kindling integration** for browsing `.gwbk` contents
- **Decode/encode** after extracting files from backup

### Workflow

1. **Open with Kindling:**
   ```vim
   :IgnitionOpenKindling path/to/backup.gwbk
   ```
   Or use the keymap: `<localleader>ik`

2. **Kindling opens the backup** in your default application (browser or desktop app).

3. **Export files from Kindling** to local directory.

4. **Open exported files in Neovim:**
   ```bash
   nvim exported/com.inductiveautomation.perspective/views/*/view.json
   ```

5. **Use normal decode/encode workflow** on extracted files.

6. **Re-import to Gateway** after editing (via Ignition Designer or Gateway web interface).

### Supported Backup Contents

- Perspective projects
- Vision projects
- Gateway scripts
- Tag configurations
- Named queries
- Alarm configurations

---

## Project Script Files

Python modules at the project level (`project.*`) or shared level (`shared.*`).

### Features Available

- **Full LSP support** (no decode needed — these are already `.py` files)
- **Project-level completions** for other project scripts
- **Go-to-definition** across project modules
- **Workspace symbols** for project navigation

### Workflow

1. **Open a project script module:**
   ```bash
   nvim ignition/script-python/MyModule/code.py
   ```

2. **LSP features work immediately** (no decode step needed):
   ```python
   # System API completions
   def read_tag(tag_path):
       return system.tag.readBlocking([tag_path])[0].value

   # Call other project scripts
   from project.utils import format_value  # Go-to-definition works
   from shared.database import get_connection

   # Java imports
   from java.util import HashMap, ArrayList
   from com.inductiveautomation.common import BasicDataset
   ```

3. **Navigate the project:**
   ```vim
   :LspWorkspaceSymbol query    " Search all project scripts
   gd                           " Go to definition
   gr                           " Find references
   ```

4. **Save changes:**
   ```vim
   :w              " Normal save (no encoding needed)
   ```

### Project Structure

Typical project script layout:
```
ignition/
├── script-python/
│   ├── utils/
│   │   └── code.py          # project.utils
│   ├── database/
│   │   └── code.py          # project.database
│   └── calculations/
│       └── code.py          # project.calculations
└── shared/
    └── common/
        └── code.py           # shared.common
```

---

## Vision Window Files (`window.xml`, `resource.json`)

Vision windows may have embedded scripts in component event handlers.

### Features Available

- **Script decode/encode** for event handlers
- **LSP support** in scripts

### Workflow

1. **Open a Vision window resource:**
   ```bash
   nvim com.inductiveautomation.vision/windows/MyWindow/resource.json
   ```

2. **Decode event scripts:**
   ```vim
   :IgnitionDecode
   ```
   Select from component event handlers:
   - `actionPerformed` (button clicks)
   - `propertyChange` (component property changes)
   - `mouseClicked` / `mousePressed`
   - `componentOpened` / `componentClosed`

3. **Edit with Vision-specific APIs:**
   ```python
   # Vision client functions (client scope)
   system.gui.messageBox("Hello from Vision!")
   system.nav.swapTo("MainWindow")

   # Component access
   event.source.text = "Clicked!"

   # Java Swing (Vision uses Swing)
   from javax.swing import JOptionPane
   JOptionPane.showMessageDialog(None, "Message")
   ```

4. **Save and encode:**
   ```vim
   :w              " Encode back
   <C-w>p
   :w              " Save resource.json
   ```

---

## Named Query Files

Named queries in `com.inductiveautomation.perspective/queries/` or similar.

### Features Available

- **Script decode** for query scripts (if using scripted queries)
- **SQL syntax** (if Neovim has SQL support)

### Workflow

1. **Open named query:**
   ```bash
   nvim com.inductiveautomation.perspective/queries/MyQuery/query.json
   ```

2. **Edit SQL or decode scripts** as needed.

3. **LSP support in scripted queries:**
   ```python
   # Build dynamic queries
   query = "SELECT * FROM table WHERE id = ?"
   params = [value]
   results = system.db.runPrepQuery(query, params)
   ```

---

## Tips for All File Types

### Listing Scripts

Before decoding, see what's in a file:
```vim
:IgnitionListScripts
```

### Decode All at Once

Working with a complex file with many scripts:
```vim
:IgnitionDecodeAll
```

### Check Plugin Status

Verify LSP connection and configuration:
```vim
:IgnitionInfo
```

### Keyboard Shortcuts

Default keymaps (in Ignition files):
- `<localleader>id` — Decode
- `<localleader>ia` — Decode all
- `<localleader>il` — List scripts
- `<localleader>ie` — Encode
- `<localleader>ii` — Plugin info
- `<localleader>ik` — Open in Kindling

### LSP Features

In any decoded script or project Python file:
- `K` — Hover documentation
- `gd` — Go to definition
- `gr` — Find references
- `:LspWorkspaceSymbol` — Search project
- Completions trigger automatically as you type

---

## File Type Detection

The plugin automatically detects Ignition files by:

1. **File extension**: `.gwbk`, `.proj`
2. **File name**: `resource.json`, `tags.json`, `view.json`, `page.json`
3. **Path patterns**: `perspective/`, `vision/`, `script-python/`
4. **Content markers**: JSON keys like `"scriptType": "python"`

You can manually set the filetype if needed:
```vim
:set filetype=ignition
```
