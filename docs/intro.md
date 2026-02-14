---
sidebar_position: 1
slug: /
---

# Introduction

**ignition-nvim** is a Neovim plugin for developers working with [Ignition by Inductive Automation](https://inductiveautomation.com/). It brings first-class IDE support for Ignition development directly into your terminal workflow.

## The Problem

Developing Ignition projects outside the Designer is painful:

- **No IDE support** — Generic Python editors don't understand Ignition's `system.*` APIs, Java/Jython interop, or project structure
- **No type awareness** — Jython's dynamic typing combined with Java imports means zero autocomplete in most editors
- **No schema validation** — Tag JSON and Perspective component definitions have strict schemas that generic editors can't validate
- **Embedded scripts** — Python code is stored inside JSON files using Ignition's custom encoding format, making editing tedious
- **Limited tooling** — The Designer's built-in editor lacks modern IDE features (LSP, plugins, advanced motions)

## The Solution

ignition-nvim brings modern IDE capabilities to Ignition development:

- **Full LSP integration** — Context-aware completions for all `system.*` APIs (239+ functions), Java/Jython classes (146 classes), and project scripts
- **Schema validation** — Built-in validation for Tag JSON and Perspective component definitions with inline error reporting
- **Intelligent decode/encode** — Seamlessly edit embedded Python scripts with full syntax highlighting and LSP support, auto-encoded on save
- **Type-aware completions** — Understands Jython's Java interop, providing accurate completions for `java.util.*`, `javax.swing.*`, and Ignition SDK classes
- **Project navigation** — Workspace symbols, go-to-definition, and cross-file script references

## Features

- **Script Decode/Encode** — Extract embedded Python from JSON, edit with full syntax highlighting, save back seamlessly
- **LSP Completions** — `system.tag.read`, `system.db.runQuery`, and 239+ Ignition API functions plus 146 Java classes with signatures and docs
- **Hover Documentation** — Inline parameter info and return types for all Ignition and Java API calls
- **Diagnostics** — Catch errors in your scripts before deploying to the gateway
- **Kindling Integration** — Open `.gwbk` gateway backup files directly from Neovim
- **File Type Detection** — Automatic recognition of Ignition project files by extension, filename, path, and content

## Architecture

ignition-nvim is a hybrid Lua + Python plugin:

- **Lua plugin** (`lua/ignition/`) — Core functionality: decode/encode, virtual buffers, commands, file detection, LSP client
- **Python LSP server** (`lsp/ignition_lsp/`) — Built on [pygls](https://github.com/openlawlibrary/pygls), provides completions, hover, and diagnostics from a curated API database

## Next Steps

- [Install the plugin](getting-started/installation) and LSP server
- [Try the quickstart](getting-started/quickstart) to decode your first script
- [Browse all commands](guides/commands) and keymaps
