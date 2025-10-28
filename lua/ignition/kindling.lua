-- Kindling integration for .gwbk files
local M = {}

local kindling_path = nil

-- Detect Kindling installation
function M.detect_installation()
  local config = require('ignition').config.kindling

  if config.path and vim.fn.executable(config.path) == 1 then
    kindling_path = config.path
    return true
  end

  -- Try common installation paths
  local possible_paths = {
    '/usr/local/bin/kindling',
    '/usr/bin/kindling',
    vim.fn.expand('~/.local/bin/kindling'),
    vim.fn.exepath('kindling'),
  }

  for _, path in ipairs(possible_paths) do
    if vim.fn.executable(path) == 1 then
      kindling_path = path
      return true
    end
  end

  return false
end

-- Open file with Kindling
function M.open_with_kindling(file_path)
  if not kindling_path then
    if not M.detect_installation() then
      vim.notify(
        'Kindling not found. Please install Kindling or configure the path.',
        vim.log.levels.ERROR,
        { title = 'Ignition.nvim' }
      )
      return
    end
  end

  local file = file_path and vim.fn.expand(file_path) or vim.fn.expand('%:p')

  if not vim.fn.filereadable(file) == 1 then
    vim.notify('File not found: ' .. file, vim.log.levels.ERROR, { title = 'Ignition.nvim' })
    return
  end

  -- Open Kindling with the file
  vim.fn.jobstart({ kindling_path, file }, {
    detach = true,
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        vim.notify(
          'Kindling exited with code ' .. exit_code,
          vim.log.levels.WARN,
          { title = 'Ignition.nvim' }
        )
      end
    end,
  })

  vim.notify('Opening in Kindling: ' .. vim.fn.fnamemodify(file, ':t'), vim.log.levels.INFO, {
    title = 'Ignition.nvim',
  })
end

return M
