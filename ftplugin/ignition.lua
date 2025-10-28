-- Filetype plugin for Ignition files
-- This file is sourced when a buffer's filetype is set to 'ignition'

-- Only load once per buffer
if vim.b.did_ftplugin then
  return
end
vim.b.did_ftplugin = 1

-- Save user's existing options to restore on filetype change
vim.b.undo_ftplugin = vim.b.undo_ftplugin or ''

local function set_option_with_undo(option, value)
  local current_value = vim.bo[option]
  vim.bo[option] = value
  vim.b.undo_ftplugin = vim.b.undo_ftplugin
    .. string.format('|setlocal %s=%s', option, vim.inspect(current_value))
end

-- Buffer options for Python-style editing (most Ignition scripts are Python)
set_option_with_undo('expandtab', true)
set_option_with_undo('tabstop', 4)
set_option_with_undo('shiftwidth', 4)
set_option_with_undo('softtabstop', 4)
set_option_with_undo('textwidth', 100)
set_option_with_undo('commentstring', '# %s')

-- Enable wrapping for long lines in JSON files
set_option_with_undo('wrap', false)

-- Format options for better editing experience
set_option_with_undo('formatoptions', 'croql')

-- Set up buffer-local keymaps
local keymap_opts = { buffer = true, silent = true, noremap = true }

-- Decode/Encode shortcuts
vim.keymap.set('n', '<localleader>id', '<cmd>IgnitionDecode<cr>', vim.tbl_extend('force', keymap_opts, {
  desc = 'Decode Ignition embedded scripts',
}))

vim.keymap.set('n', '<localleader>ie', '<cmd>IgnitionEncode<cr>', vim.tbl_extend('force', keymap_opts, {
  desc = 'Encode Ignition scripts to JSON',
}))

vim.keymap.set('n', '<localleader>ii', '<cmd>IgnitionInfo<cr>', vim.tbl_extend('force', keymap_opts, {
  desc = 'Show Ignition plugin info',
}))

vim.keymap.set('n', '<localleader>il', '<cmd>IgnitionListScripts<cr>', vim.tbl_extend('force', keymap_opts, {
  desc = 'List all scripts in file',
}))

vim.keymap.set('n', '<localleader>ia', '<cmd>IgnitionDecodeAll<cr>', vim.tbl_extend('force', keymap_opts, {
  desc = 'Decode all scripts in file',
}))

-- Open with Kindling (for .gwbk files)
if vim.fn.expand('%:e') == 'gwbk' then
  vim.keymap.set('n', '<localleader>ik', '<cmd>IgnitionOpenKindling<cr>', vim.tbl_extend('force', keymap_opts, {
    desc = 'Open in Kindling',
  }))
end

-- Add undo command for keymaps
vim.b.undo_ftplugin = vim.b.undo_ftplugin .. '|mapclear <buffer>'

-- Check if auto-decode is enabled
local ignition_ok, ignition = pcall(require, 'ignition')
if ignition_ok and ignition.config.decoder.auto_decode then
  -- Check if current buffer has encoded scripts
  local decoder = require('ignition.decoder')
  if decoder.has_encoded_scripts() then
    -- Notify user that scripts are detected
    vim.notify(
      'Ignition scripts detected. Use <localleader>id to decode.',
      vim.log.levels.INFO,
      { title = 'Ignition.nvim' }
    )
  end
end

-- Set up LSP if available and enabled
if ignition_ok and ignition.config.lsp.enabled then
  -- LSP will be auto-started by the lsp.lua module
  vim.defer_fn(function()
    -- Check if LSP is attached
    local clients = vim.lsp.get_active_clients({ bufnr = 0 })
    local has_ignition_lsp = false
    for _, client in ipairs(clients) do
      if client.name == 'ignition_lsp' then
        has_ignition_lsp = true
        break
      end
    end

    if not has_ignition_lsp and ignition.config.lsp.auto_start then
      -- Try to start LSP
      pcall(vim.cmd, 'LspStart ignition_lsp')
    end
  end, 100)
end
