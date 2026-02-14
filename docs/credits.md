---
sidebar_position: 100
---

# Credits

## Acknowledgments

ignition-nvim builds on the work of several open-source projects and community efforts.

### Ignition Flint

The script encoding/decoding format is based on [Ignition Flint](https://marketplace.visualstudio.com/items?itemName=Keith-gamble.ignition-flint) by Keith Gamble — a VS Code extension for Ignition development. The character replacement table used by ignition-nvim matches Flint's `textEncoding.ts` implementation.

### pygls

The LSP server is built on [pygls](https://github.com/openlawlibrary/pygls) (Python Generic Language Server), a framework for building Language Server Protocol implementations in Python.

### Kindling

Gateway backup (`.gwbk`) support is powered by [Kindling](https://github.com/ia-eknorr/kindling) by [Eric Knorr](https://github.com/ia-eknorr).

### ignition-lint

Code quality diagnostics are provided by integrating [ignition-lint](https://github.com/ia-eknorr/ignition-lint) by [Eric Knorr](https://github.com/ia-eknorr) — a Jython linter and static analyzer specifically designed for Ignition projects.

### Inductive Automation

[Ignition](https://inductiveautomation.com/) is developed by Inductive Automation. The API database used by the LSP server is curated from Ignition's public documentation.

## License

ignition-nvim is released under the MIT License.
