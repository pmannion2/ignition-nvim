-- ignition.nvim - Core module
local M = {}

-- Default configuration
M.config = {
  -- LSP server settings
  lsp = {
    enabled = true,
    auto_start = true,
    cmd = nil, -- Will be auto-detected
    settings = {
      ignition = {
        version = "8.1", -- Default Ignition version
        sdk_path = nil,
      },
    },
  },

  -- Kindling integration settings
  kindling = {
    enabled = true,
    path = nil, -- Will be auto-detected
  },

  -- Script decoder settings
  decoder = {
    auto_decode = true,
    auto_encode = true,
    create_scratch_buffer = true,
  },

  -- UI settings
  ui = {
    show_notifications = true,
    show_statusline = true,
  },
}

-- Setup function called by users
function M.setup(opts)
  M.config = vim.tbl_deep_extend('force', M.config, opts or {})

  -- Initialize LSP if enabled
  if M.config.lsp.enabled then
    require('ignition.lsp').setup(M.config.lsp)
  end

  -- Detect Kindling installation
  if M.config.kindling.enabled then
    require('ignition.kindling').detect_installation()
  end
end

-- Show plugin information
function M.info()
  local lines = {
    'Ignition.nvim - Ignition Development Support',
    '',
    'Configuration:',
    '  LSP Enabled: ' .. tostring(M.config.lsp.enabled),
    '  Auto Decode: ' .. tostring(M.config.decoder.auto_decode),
    '  Kindling: ' .. tostring(M.config.kindling.enabled),
    '',
    'Version: 0.1.0',
  }

  vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO, { title = 'Ignition.nvim' })
end

return M
