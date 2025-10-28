-- Debug LSP completion setup
-- Run: :luafile DEBUG_LSP_COMPLETION.lua

print('=== LSP Completion Debug ===')

local bufnr = vim.api.nvim_get_current_buf()
print('Buffer:', bufnr)
print('Filetype:', vim.bo[bufnr].filetype)
print('Buffer name:', vim.api.nvim_buf_get_name(bufnr))

-- Check LSP clients
local clients = vim.lsp.get_clients({ bufnr = bufnr })
print('\nLSP Clients attached to this buffer:', #clients)
for _, client in ipairs(clients) do
  print('  - ' .. client.name .. ' (id: ' .. client.id .. ')')

  -- Check if client supports completion
  if client.server_capabilities.completionProvider then
    print('    ✓ Supports completion')
  else
    print('    ✗ No completion support')
  end
end

-- Check omnifunc
print('\nOmnifunc:', vim.bo[bufnr].omnifunc)

-- Try to get completions programmatically
print('\nTrying to get completions at cursor position...')
local pos = vim.api.nvim_win_get_cursor(0)
local line = pos[1] - 1
local col = pos[2]

print('Position: line=' .. line .. ', col=' .. col)

-- Get line text
local line_text = vim.api.nvim_buf_get_lines(bufnr, line, line + 1, false)[1]
print('Line text:', line_text)
print('Text before cursor:', line_text:sub(1, col))

-- Try vim.lsp.buf.completion
print('\nAttempting vim.lsp.buf.completion()...')
local ok, result = pcall(vim.lsp.buf.completion)
if ok then
  print('✓ Completion request sent')
else
  print('✗ Error:', result)
end
