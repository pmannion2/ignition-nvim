---
sidebar_position: 1
slug: /
---

# Introduction

**ignition-nvim** is a Neovim plugin for developers working with [Ignition by Inductive Automation](https://inductiveautomation.com/). It brings first-class editing support for Ignition projects directly into your terminal workflow.

## The Problem

Ignition stores Python scripts inside JSON configuration files using a custom encoding format. Editing these scripts means either:

- Using the Ignition Designer's built-in editor (no Vim motions, no LSP, no plugins)
- Manually decoding/encoding scripts by hand (error-prone and tedious)
- Using VS Code with Ignition Flint (works, but it's not Neovim)

## The Solution

ignition-nvim decodes embedded scripts into virtual buffers with full Python editing support, then encodes them back when you save. Combined with a purpose-built LSP server that understands Ignition's `system.*` API, you get completions, hover docs, and diagnostics — all without leaving Neovim.

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
