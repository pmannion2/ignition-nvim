---
sidebar_position: 2
---

# Script Editing

## How Ignition Stores Scripts

Ignition embeds Python scripts inside JSON configuration files. A typical `resource.json` might look like:

```json
{
  "script": "\tvalue \u003d system.tag.readBlocking([\u0027MyTag\u0027])[0].value\n\tif value \u003e 10:\n\t\tsystem.perspective.print(\u0027High\u0027)"
}
```

The script is encoded with character replacements — not base64. Characters like `<`, `>`, `=`, `&`, and `'` are replaced with Unicode escapes to make the content safe for JSON transport.

## The Encoding Format

ignition-nvim uses the same encoding as [Ignition Flint](https://github.com/keith-gamble/ignition-flint). The replacement table:

| Character | Encoded As |
|-----------|-----------|
| `\` | `\\` |
| `"` | `\"` |
| newline | `\n` |
| tab | `\t` |
| `<` | `\u003c` |
| `>` | `\u003e` |
| `&` | `\u0026` |
| `=` | `\u003d` |
| `'` | `\u0027` |

Replacements are applied in a specific order during encoding, and reversed during decoding. The plugin uses plain string replacement (not regex/pattern matching) to avoid issues with special characters.

## Decode/Encode Workflow

### Decoding

When you run `:IgnitionDecode`, the plugin:

1. Parses the JSON buffer to find all script-containing keys
2. Extracts the encoded string value
3. Applies the reverse replacement table to recover the original Python source
4. Opens a virtual buffer with the decoded content

### Script Keys

The plugin looks for these JSON keys that typically contain scripts:

- `script`
- `code`
- `eventScript`
- `transform`
- `onActionPerformed`
- `onChange`
- `onStartup`
- `onShutdown`

### Encoding

When you save a virtual buffer (`:w`), the plugin:

1. Reads the edited Python source from the virtual buffer
2. Applies the replacement table to encode special characters
3. Writes the encoded string back to the correct line in the source JSON buffer
4. Marks the source buffer as modified

### Multiple Scripts

A single JSON file can contain many scripts (e.g., a Perspective view with multiple event handlers). Use `:IgnitionDecodeAll` to open all of them, or `:IgnitionListScripts` to see an inventory before choosing which to edit.

## Virtual Buffers

Decoded scripts live in virtual buffers — special Neovim buffers that intercept save operations. Key properties:

- **Filetype**: `python` — you get syntax highlighting, LSP completions, and all your Python plugins
- **Save behavior**: `:w` encodes and writes back to the source JSON (it does not write a file to disk)
- **Metadata**: Each virtual buffer tracks its source buffer, script key, and line number
- **Cleanup**: Closing the virtual buffer removes tracking metadata automatically

You can have multiple virtual buffers open simultaneously from the same or different source files.
