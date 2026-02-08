-- Minimal init.lua for testing
-- This sets up the plugin for testing without loading the user's config

-- Add plugin directory to runtimepath
vim.opt.runtimepath:append('.')

-- Add plenary if available (for testing)
local plenary_ok, _ = pcall(require, 'plenary')
if not plenary_ok then
  local search_paths = {
    vim.fn.stdpath('data') .. '/site/pack/vendor/start/plenary.nvim',
    vim.fn.stdpath('data') .. '/lazy/plenary.nvim',
  }
  local found = false
  for _, plenary_dir in ipairs(search_paths) do
    if vim.fn.isdirectory(plenary_dir) == 1 then
      vim.opt.runtimepath:append(plenary_dir)
      found = true
      break
    end
  end
  if not found then
    vim.notify('plenary.nvim not found. Install it for running tests.', vim.log.levels.WARN)
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
