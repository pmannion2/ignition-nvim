-- Minimal init.lua for testing
-- This sets up the plugin for testing without loading the user's config

-- Add plugin directory to runtimepath
vim.opt.runtimepath:append('.')

-- Add plenary if available (for testing)
local plenary_ok, _ = pcall(require, 'plenary')
if not plenary_ok then
  local plenary_dir = vim.fn.stdpath('data') .. '/site/pack/vendor/start/plenary.nvim'
  if vim.fn.isdirectory(plenary_dir) == 0 then
    vim.notify('plenary.nvim not found. Install it for running tests.', vim.log.levels.WARN)
  else
    vim.opt.runtimepath:append(plenary_dir)
  end
end

-- Load the plugin
require('ignition').setup({
  lsp = {
    enabled = false, -- Disable LSP for tests
  },
  kindling = {
    enabled = false, -- Disable Kindling for tests
  },
  decoder = {
    auto_decode = false, -- Don't auto-decode during tests
  },
  ui = {
    show_notifications = false, -- Disable notifications during tests
  },
})
