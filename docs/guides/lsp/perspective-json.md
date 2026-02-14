---
sidebar_position: 4
---

# Perspective JSON Completions

The LSP provides intelligent completions for Perspective view.json files, including component types, properties, event handlers, and bindings — making it easier to edit Perspective views in raw JSON.

## Why Edit Perspective JSON?

While the Designer provides a visual editor, editing raw JSON offers:
- **Version control** - Better diff and merge support
- **Bulk operations** - Search/replace across components
- **Templating** - Copy/paste component structures
- **Scripting** - Programmatic view generation
- **Speed** - Faster than clicking through the Designer

## How It Works

The LSP detects Perspective view.json files by:
- Filename pattern: `view.json`, `page.json`
- Path pattern: `com.inductiveautomation.perspective/views/`
- Content detection: JSON with `"type": "View"` or `"type": "Container"`

Once detected, you get completions for:
- Component types
- Component properties
- Event handlers
- Binding types
- Style classes

## Component Type Completions

When adding a new component, get completions for all available types:

```json
{
  "type": "ia.container.flex",
  "children": [
    {
      "type": "ia.  // <- Complete to see all component types
    }
  ]
}
```

### Display Components
- `ia.display.label` - Text labels
- `ia.display.markdown` - Markdown renderer
- `ia.display.image` - Images
- `ia.display.icon` - SVG icons
- `ia.display.video` - Video player
- `ia.display.gauge` - Circular gauges
- `ia.display.led` - LED indicators

### Input Components
- `ia.input.button` - Buttons
- `ia.input.textfield` - Text input
- `ia.input.textarea` - Multi-line text
- `ia.input.numeric` - Number input
- `ia.input.checkbox` - Checkboxes
- `ia.input.radio` - Radio buttons
- `ia.input.dropdown` - Dropdowns
- `ia.input.switch` - Toggle switches
- `ia.input.slider` - Sliders

### Container Components
- `ia.container.flex` - Flexbox containers
- `ia.container.coord` - Coordinate containers
- `ia.container.column` - Column layouts
- `ia.container.row` - Row layouts
- `ia.container.tabcontainer` - Tabs
- `ia.container.popup` - Popup windows

### Chart Components
- `ia.chart.timeseries` - Time series charts
- `ia.chart.pie` - Pie charts
- `ia.chart.bar` - Bar charts
- `ia.chart.scatter` - Scatter plots
- `ia.chart.ohlc` - OHLC charts

### Data Components
- `ia.display.table` - Data tables
- `ia.display.tree` - Tree views
- `ia.display.dropdown` - Selection dropdowns

## Property Completions

After typing `"props":`, get completions for properties specific to the component type:

```json
{
  "type": "ia.input.button",
  "props": {
    "text": "Click Me",
    "  // <- Complete to see: enabled, visible, style, etc.
  }
}
```

### Common Properties
Available on all components:
- `style` - Component styling
- `custom` - Custom properties
- `position` - Position metadata

### Type-Specific Properties
Each component type has unique properties:

**Button:**
- `text` - Button label
- `enabled` - Enable/disable state
- `primary` - Primary button style

**Label:**
- `text` - Label text
- `textAlign` - Text alignment
- `icon` - Icon configuration

**Table:**
- `data` - Table dataset
- `columns` - Column configuration
- `selection` - Selection mode

## Event Handler Completions

When defining events, get completions for available event types:

```json
{
  "type": "ia.input.button",
  "events": {
    "  // <- Complete to see: onClick, onMouseEnter, onMouseLeave, etc.
  }
}
```

### Event Types

**Mouse Events:**
- `onClick` - Mouse click
- `onMouseEnter` - Mouse enter
- `onMouseLeave` - Mouse leave
- `onMouseDown` - Mouse button down
- `onMouseUp` - Mouse button up

**Component Events:**
- `onStartup` - Component initialization
- `onShutdown` - Component cleanup
- `onChange` - Value change
- `onActionPerformed` - Action triggered

## Event Script Completions

Within event handlers, get completions for the event payload structure:

```json
{
  "events": {
    "onClick": {
      "0": {
        "type": "script",
        "script": "// In the decoded Python script:\nself.  // <- Complete to see: view, session, etc."
      }
    }
  }
}
```

Event scripts have access to:
- `self` - Component reference
- `self.view` - Parent view
- `self.session` - Session object
- `event` - Event payload (for some events)

## Binding Type Completions

When adding bindings, get completions for binding types:

```json
{
  "props": {
    "text": {
      "binding": {
        "type": "  // <- Complete to see: property, tag, query, expression
      }
    }
  }
}
```

### Binding Types

**property** - Bind to another property:
```json
{
  "type": "property",
  "config": {
    "path": "view.params.title"
  }
}
```

**tag** - Bind to a tag:
```json
{
  "type": "tag",
  "config": {
    "path": "[default]Path/To/Tag"
  }
}
```

**query** - Bind to a query:
```json
{
  "type": "query",
  "config": {
    "queryPath": "MyQuery",
    "params": {}
  }
}
```

**expression** - Bind to an expression:
```json
{
  "type": "expression",
  "config": {
    "expression": "{view.params.multiplier} * 2"
  }
}
```

## Style Completions

Get completions for CSS-like style properties:

```json
{
  "props": {
    "style": {
      "  // <- Complete to see: backgroundColor, color, fontSize, padding, etc.
    }
  }
}
```

### Style Properties

**Layout:**
- `display` - Display mode (flex, block, inline)
- `flexDirection` - Flex direction (row, column)
- `justifyContent` - Main axis alignment
- `alignItems` - Cross axis alignment
- `padding` - Inner spacing
- `margin` - Outer spacing

**Typography:**
- `fontSize` - Font size
- `fontWeight` - Font weight (bold, normal)
- `color` - Text color
- `textAlign` - Text alignment

**Background:**
- `backgroundColor` - Background color
- `backgroundImage` - Background image URL
- `opacity` - Transparency (0-1)

**Border:**
- `border` - Border shorthand
- `borderRadius` - Corner radius
- `borderColor` - Border color
- `borderWidth` - Border thickness

## Position Completions

For coordinate containers, get completions for position properties:

```json
{
  "meta": {
    "position": {
      "  // <- Complete to see: x, y, width, height
    }
  }
}
```

## Validation

The LSP validates Perspective JSON against the schema:

### Component Type Validation
```json
{
  "type": "ia.invalid.component"  // ❌ Error: Unknown component type
}
```

### Required Property Validation
```json
{
  "type": "ia.input.button"
  // ❌ Warning: Missing required 'props' property
}
```

### Property Type Validation
```json
{
  "props": {
    "enabled": "true"  // ❌ Error: Expected boolean, got string
  }
}
```

## Tips

### Use the Component Tree

Press `<localleader>it` to open an interactive component tree that shows the entire view structure:

```
View
├── Root (ia.container.flex)
│   ├── Header (ia.display.label)
│   └── Content (ia.container.column)
│       ├── Button1 (ia.input.button)
│       └── Table1 (ia.display.table)
```

Navigate with `<CR>`, delete with `d`, refresh with `R`.

### Format JSON Regularly

Use `:IgnitionFormat` or `<localleader>if` to auto-format JSON and ensure consistent indentation (Ignition Designer uses tabs).

### Extract Common Styles

Create reusable style objects:

```json
{
  "custom": {
    "styles": {
      "headerStyle": {
        "fontSize": "24px",
        "fontWeight": "bold",
        "color": "#333"
      }
    }
  },
  "children": [
    {
      "props": {
        "style": "{view.custom.styles.headerStyle}"
      }
    }
  ]
}
```

### Use Bindings for Dynamic Content

Instead of hardcoded values:
```json
{
  "props": {
    "text": {
      "binding": {
        "type": "tag",
        "config": {"path": "[default]Motor1/Speed"}
      }
    }
  }
}
```

## Troubleshooting

### "No completions in view.json"

1. Ensure the file is detected as Perspective:
   ```
   :set filetype?  # Should show 'json.perspective' or 'json'
   ```

2. Check the file path matches Perspective patterns:
   ```
   /path/to/com.inductiveautomation.perspective/views/MyView/view.json
   ```

3. Verify the JSON root has perspective markers:
   ```json
   {
     "type": "View",  // or "Container"
     "rootContainer": { ... }
   }
   ```

### "Completions are incomplete"

The perspective schema is continuously updated. Make sure you have the latest LSP version:
```bash
pip install --upgrade ignition-lsp
```
