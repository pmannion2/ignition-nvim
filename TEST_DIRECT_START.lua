-- Direct LSP start test - bypasses lspconfig
-- Run in Neovim: :luafile TEST_DIRECT_START.lua

print('=== Direct LSP Start Test ===')

-- Define the LSP command
local venv_python = '/Users/pmannion/Documents/whiskeyhouse/ignition-nvim/lsp/venv/bin/python'
local server_path = '/Users/pmannion/Documents/whiskeyhouse/ignition-nvim/lsp/ignition_lsp/server.py'

print('Python:', venv_python)
print('Server:', server_path)
print('Exists:', vim.fn.filereadable(venv_python) == 1 and vim.fn.filereadable(server_path) == 1)

-- Start the LSP client directly
local client_id = vim.lsp.start({
  name = 'ignition_lsp',
  cmd = { venv_python, server_path },
  root_dir = vim.fn.getcwd(),
  filetypes = { 'python', 'ignition' },
  settings = {},
})

print('Client ID:', client_id)

if client_id then
  print('✓ LSP started successfully!')
  print('Waiting for initialization...')

  vim.defer_fn(function()
    local clients = vim.lsp.get_clients({ id = client_id })
    if #clients > 0 then
      print('✓ LSP client active')
      print('Client name:', clients[1].name)
      print('Check :LspInfo now!')
    else
      print('✗ LSP client not found')
    end
  end, 2000)
else
  print('✗ Failed to start LSP')
  print('Check /tmp/ignition-lsp.log for errors')
end
