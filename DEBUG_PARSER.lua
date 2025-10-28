-- Debug the JSON parser
-- Run: :luafile DEBUG_PARSER.lua

print('=== Debugging JSON Parser ===')

-- Clear cache
package.loaded['ignition.json_parser'] = nil
package.loaded['ignition.encoding'] = nil

-- Add to path
package.path = package.path .. ';/Users/pmannion/Documents/whiskeyhouse/ignition-nvim/lua/?.lua'
package.path = package.path .. ';/Users/pmannion/Documents/whiskeyhouse/ignition-nvim/lua/?/init.lua'

local json_parser = require('ignition.json_parser')
local encoding = require('ignition.encoding')

-- Get current buffer
local bufnr = vim.api.nvim_get_current_buf()
print('Buffer:', bufnr)
print('File:', vim.api.nvim_buf_get_name(bufnr))

-- Find scripts
local scripts = json_parser.find_scripts(bufnr)
print('Scripts found:', #scripts)

for i, script in ipairs(scripts) do
  print('')
  print('Script #' .. i .. ':')
  print('  Key:', script.key)
  print('  Line:', script.line)
  print('  Content length:', #script.content)
  print('  First 100 chars:', script.content:sub(1, 100))
  print('  Encoded newlines:', select(2, script.content:gsub('\\n', '')))

  -- Try decoding
  local decoded = encoding.decode_script(script.content)
  print('  Decoded length:', #decoded)
  print('  Decoded lines:', #vim.split(decoded, '\n', { plain = true }))
  print('  First 100 chars decoded:', decoded:sub(1, 100))
end
