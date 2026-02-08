# Fix Plan - ignition-nvim

## Priority 1: LSP Server Testing & Reliability

- [x] Create Python test infrastructure: `lsp/tests/conftest.py` with LSP server fixtures using pygls test utilities
- [x] Add unit tests for `api_loader.py`: loading, indexing, search, version filtering
- [x] Add unit tests for `completion.py`: context detection, completion items, snippet generation
- [x] Add unit tests for `hover.py`: function lookup, markdown doc generation, module hover
- [x] Add unit tests for `diagnostics.py`: validator integration, severity mapping, empty results

## Priority 2: Expand Ignition API Database

- [x] Add `system_net.json` — system.net functions (httpGet, httpPost, httpClient, openURL, etc.)
- [x] Add `system_date.json` — system.date functions (now, parse, format, addHours, addMinutes, etc.)
- [x] Add `system_gui.json` — system.gui functions (openDesktop, messageBox, confirm, inputBox, etc.) — 32 functions
- [x] Add `system_security.json` — system.security functions (getRoles, getUsername, getUserRoles, validateUser, lockScreen, unlockScreen, isScreenLocked, switchUser, logout) — 9 functions
- [x] Add `system_alarm.json` — system.alarm functions (queryStatus, queryJournal, acknowledge, cancel, shelve, unshelve, getShelvedPaths, createRoster, getRosters, listPipelines) — 10 functions
- [x] Add `system_opc.json` — system.opc functions (readValue, readValues, writeValue, writeValues, browse, browseServer, browseSimple, getServers, getServerState, isServerEnabled, setServerEnabled) — 11 functions
- [x] Add `system_dataset.json` — system.dataset functions (toDataSet, toPyDataSet, addColumn, addRow, addRows, appendDataset, clearDataset, deleteRow, deleteRows, setValue, updateRow, sort, filterColumns, formatDates, fromCSV, toCSV, toExcel, exportCSV, exportExcel, exportHTML, dataSetToHTML, getColumnHeaders) — 22 functions
- [x] Add `system_file.json` — system.file functions (readFileAsString, readFileAsBytes, writeFile, fileExists, getTempFile, openFile, openFiles, saveFile) — 8 functions
- [x] Add `system_nav.json` — system.nav functions (openWindow, openWindowInstance, closeWindow, closeParentWindow, swapWindow, swapTo, centerWindow, getCurrentWindow, goBack, goForward, goHome, desktop) — 12 functions
- [x] Add `system_user.json` — system.user functions (getUser, getUsers, getUserSources, getNewUser, addUser, editUser, removeUser, getRoles, addRole, editRole, removeRole, getSchedule, getSchedules, getScheduleNames, getScheduledUsers, addSchedule, editSchedule, removeSchedule, addCompositeSchedule, createScheduleAdjustment, isUserScheduled, getHoliday, getHolidays, getHolidayNames, addHoliday, editHoliday, removeHoliday) — 27 functions
- [x] Validate all new JSON files against `api_db/schema.json` — 14 modules, 239 functions, all valid

## Priority 3: Lua Test Coverage

- [x] Add tests for `json_parser.lua`: script discovery, escaped quote handling, script key detection — 32 tests, fixed off-by-one bug in `replace_script_in_line`
- [x] Add tests for `virtual_doc.lua`: buffer creation, metadata tracking, duplicate prevention, auto-save encoding — 28 tests, fixed bufnr() glob pattern bug in duplicate detection
- [x] Add tests for `decoder.lua`: single decode, multi-script selection, decode-all, encode-back workflow — 14 tests covering decode_script, has_encoded_scripts, get_script_stats, encode_current_buffer, and full round-trip
- [x] Add tests for `lsp.lua`: server detection, root finding, client reuse — 12 tests covering find_lsp_server cascading fallbacks, start_lsp_for_buffer guards, root directory detection with vim.fs.root, setup cmd routing, and FileType autocmd registration

## Priority 4: Project Indexing (TEC-8)

- [x] Implement project scanner in LSP server: walk Ignition project directory, find all `resource.json` files — `project_scanner.py` with `ProjectScanner`, `ScriptLocation`, `ProjectIndex` classes; 20 tests
- [x] Build project index: map script locations (file path, script key, line number) across the project — `ProjectIndex` with `scripts_by_type()`, `scripts_in_file()`, `find_by_module_path()`, `search_module_paths()` queries; lazy init via `ensure_project_index()` in server.py; re-indexes on resource JSON save
- [x] Expose project index via LSP workspace symbols — `workspace_symbols.py` with `get_workspace_symbols()`, maps ScriptLocation to SymbolInformation (Module/Event/Function kinds), case-insensitive query filtering; wired via `workspace/symbol` handler in server.py; 22 tests
- [x] Support cross-file script references in completions — extended `completion.py` with `_get_project_completions()` for `project.*` and `shared.*` prefixes; hierarchical trie-like traversal of module paths; wired project index through `server.py` completion handler; 20 tests

## Priority 5: Go-to-Definition (TEC-441 Phase 6)

- [x] Implement definition provider for `system.*` functions: jump to API docs URL or show inline definition — `definition.py` with `_resolve_api_function()` jumping to the function's "name" entry in api_db/ JSON files; bare name matching for unqualified references; 23 tests
- [x] Implement definition provider for project-level scripts: jump to script location in source JSON — `_resolve_project_script()` with progressive prefix stripping (e.g., `project.library.utils.doStuff` -> `project.library.utils`); handles exact match, unique prefix match, and shared.* references
- [x] Wire definition handler in `server.py` (currently a stub) — fixed missing `ls` parameter; delegates to `get_definition()` with both `api_loader` and `project_index`

## Priority 6: Kindling Integration (TEC-442)

- [x] Test Kindling detection across platforms (macOS, Linux) — 8 detection tests covering config.path, /usr/local/bin, /opt/homebrew/bin (Apple Silicon), ~/.local/bin (Linux), exepath fallback, empty exepath guard; added /opt/homebrew and Snap/Flatpak paths
- [x] Add `:IgnitionOpenKindling` command tests — 3 command registration tests + 5 open_with_kindling tests covering jobstart launch, current buffer fallback, empty string arg, file-not-found error
- [x] Handle Kindling not installed gracefully (show install instructions) — `show_install_instructions()` with GitHub URL + config snippet; fixed `filereadable` operator precedence bug; added `reset()`/`get_path()` for testability; 21 total Lua tests

## Priority 7: Package Manager & Distribution

- [x] Create proper lazy.nvim plugin spec (verify it works with `lazy.nvim` install) — `lazy.lua` at repo root with `ft`/`cmd` lazy-loading triggers and `build` step for LSP pip install; updated README installation section; verified spec loads correctly via headless Neovim
- [x] Publish Python LSP server to PyPI as `ignition-lsp` — fixed `pyproject.toml` package-data (was `data/*.json`, now `api_db/*.json`), updated license format to SPDX string, added Python 3.13 classifier, auto-discover subpackages, updated `lsp/README.md` architecture section; verified wheel builds with all 15 JSON files + 9 Python modules; added `.github/workflows/publish.yml` for tag-triggered PyPI publishing via trusted publishers
- [x] Add CI workflow (GitHub Actions) for Lua and Python tests — `.github/workflows/ci.yml` with Lua tests (Neovim stable+nightly, plenary.nvim) and Python tests (3.9/3.11/3.13 matrix); ANSI-stripping for plenary output; triggers on push/PR to main

## Completed

- [x] Project foundation: directory structure, config, manifest (TEC-445)
- [x] File type detection for Ignition files (TEC-444)
- [x] Script decoder/encoder with Ignition Flint encoding (TEC-443)
- [x] Virtual document system for editing decoded scripts
- [x] LSP server Phase 1: foundation, document sync, diagnostics (TEC-441)
- [x] API database with 4 modules: system.tag, system.db, system.perspective, system.util
- [x] Completion provider with context-aware `system.*` lookups
- [x] Hover documentation provider
- [x] All commands and keymaps registered
- [x] Ralph project configuration initialized
- [x] Python test infrastructure: conftest.py with MockTextDocument, api_loader, and position fixtures (77 tests)
- [x] Unit tests for api_loader.py, completion.py, hover.py, diagnostics.py — all passing

## Notes

- The API database is the highest-leverage work: each new `system_*.json` file immediately improves completions and hover docs for all users
- The encoding round-trip is the most fragile part of the system; always verify after changes
- Reference for API functions: https://docs.inductiveautomation.com/docs/8.1/appendix/scripting-functions
- Reference for encoding format: https://github.com/keith-gamble/ignition-flint/blob/master/src/utils/textEncoding.ts
