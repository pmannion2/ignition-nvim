-- Simplest possible LSP test - Direct vim.lsp.start()
-- Run: :luafile TEST_CONFIG_SIMPLE.lua

print('=== Simple Direct LSP Start ===')

local venv_python = '/Users/pmannion/Documents/whiskeyhouse/ignition-nvim/lsp/venv/bin/python'
local server_path = '/Users/pmannion/Documents/whiskeyhouse/ignition-nvim/lsp/ignition_lsp/server.py'

print('Command:', venv_python, server_path)

-- Start LSP directly - no plugins, no helpers
local client_id = vim.lsp.start({
  name = 'ignition_lsp',
  cmd = { venv_python, server_path },
  root_dir = vim.fn.getcwd(),
})

print('Client ID:', client_id)

if client_id then
  print('✓ LSP started!')
  print('Wait 2 seconds then check :LspInfo')

  vim.defer_fn(function()
    local clients = vim.lsp.get_clients({ id = client_id })
    if #clients > 0 then
      print('✓ Client is active:', clients[1].name)
    else
      print('✗ Client disappeared')
    end
  end, 2000)
else
  print('✗ Failed to start')
  print('Check logs:')
  print('  tail -f /tmp/ignition-lsp.log')
  print('  tail -f ~/.local/state/nvim/lsp.log')
end
