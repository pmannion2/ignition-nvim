-- ignition.nvim - Neovim plugin for Ignition by Inductive Automation
-- Main plugin entry point

-- Prevent loading the plugin multiple times
if vim.g.loaded_ignition then
  return
end
vim.g.loaded_ignition = true

-- Create user commands
vim.api.nvim_create_user_command('IgnitionDecode', function()
  require('ignition.decoder').decode_current_buffer()
end, { desc = 'Decode Ignition embedded scripts in current buffer' })

vim.api.nvim_create_user_command('IgnitionEncode', function()
  require('ignition.decoder').encode_current_buffer()
end, { desc = 'Encode Ignition scripts back to JSON format' })

vim.api.nvim_create_user_command('IgnitionOpenKindling', function(opts)
  require('ignition.kindling').open_with_kindling(opts.args)
end, {
  nargs = '?',
  complete = 'file',
  desc = 'Open .gwbk file with Kindling utility'
})

vim.api.nvim_create_user_command('IgnitionDecodeAll', function()
  require('ignition.decoder').decode_all_scripts()
end, { desc = 'Decode all Ignition scripts in current buffer' })

vim.api.nvim_create_user_command('IgnitionListScripts', function()
  require('ignition.decoder').list_scripts()
end, { desc = 'List all Ignition scripts in current buffer' })

vim.api.nvim_create_user_command('IgnitionInfo', function()
  require('ignition').info()
end, { desc = 'Show Ignition plugin information and status' })

-- Create augroup for plugin autocommands
local augroup = vim.api.nvim_create_augroup('Ignition', { clear = true })

-- Note: File type detection is handled by ftdetect/ignition.lua
-- This augroup is reserved for future global autocommands
