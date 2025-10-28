-- LSP client integration for Ignition
local M = {}

local lsp_config = {}

-- Setup LSP client
function M.setup(config)
  lsp_config = config

  -- Auto-detect LSP server command if not provided
  if not lsp_config.cmd then
    lsp_config.cmd = M.find_lsp_server()
  end

  -- Register LSP client configuration
  local lspconfig_ok, lspconfig = pcall(require, 'lspconfig')
  if not lspconfig_ok then
    vim.notify(
      'nvim-lspconfig not found. LSP features will be unavailable.',
      vim.log.levels.WARN,
      { title = 'Ignition.nvim' }
    )
    return
  end

  M.register_lsp_config(lspconfig)
end

-- Find the Ignition LSP server executable
function M.find_lsp_server()
  -- Get plugin root directory
  local plugin_root = vim.fn.fnamemodify(debug.getinfo(1).source:sub(2), ':p:h:h:h')

  -- Try venv Python first (development mode)
  local venv_python = plugin_root .. '/lsp/venv/bin/python'
  local server_path = plugin_root .. '/lsp/ignition_lsp/server.py'

  if vim.fn.executable(venv_python) == 1 and vim.fn.filereadable(server_path) == 1 then
    vim.notify(
      'Found ignition-lsp in development mode',
      vim.log.levels.INFO,
      { title = 'Ignition.nvim' }
    )
    return { venv_python, server_path }
  end

  -- Try system-installed ignition-lsp
  local installed_cmd = vim.fn.exepath('ignition-lsp')
  if installed_cmd ~= '' then
    vim.notify(
      'Found ignition-lsp system installation',
      vim.log.levels.INFO,
      { title = 'Ignition.nvim' }
    )
    return { installed_cmd }
  end

  -- Try with system Python (last resort)
  local python_cmd = vim.fn.exepath('python3') or vim.fn.exepath('python')
  if python_cmd ~= '' and vim.fn.filereadable(server_path) == 1 then
    vim.notify(
      'Using system Python for ignition-lsp (may not have dependencies)',
      vim.log.levels.WARN,
      { title = 'Ignition.nvim' }
    )
    return { python_cmd, server_path }
  end

  vim.notify(
    'Ignition LSP server not found. Install with: cd lsp && pip install -e .',
    vim.log.levels.ERROR,
    { title = 'Ignition.nvim' }
  )

  return nil
end

-- Start LSP for a buffer
function M.start_lsp_for_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()

  if not lsp_config.cmd or not lsp_config.cmd[1] then
    vim.notify(
      'Ignition LSP command not configured',
      vim.log.levels.ERROR,
      { title = 'Ignition.nvim' }
    )
    return nil
  end

  -- Check if already attached
  local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'ignition_lsp' })
  if #clients > 0 then
    return clients[1].id
  end

  -- Find root directory
  local fname = vim.api.nvim_buf_get_name(bufnr)
  local root_dir = vim.fs.root(bufnr, { 'project.json', '.git' }) or vim.fn.getcwd()

  -- Start the LSP client using modern vim.lsp.start()
  local client_id = vim.lsp.start({
    name = 'ignition_lsp',
    cmd = lsp_config.cmd,
    root_dir = root_dir,
    settings = lsp_config.settings or {},
    init_options = {
      ignition_version = (lsp_config.settings or {}).ignition
        and (lsp_config.settings.ignition.version or '8.1')
        or '8.1',
    },
  }, {
    bufnr = bufnr,
    reuse_client = function(client, conf)
      return client.name == conf.name
    end,
  })

  return client_id
end

-- Register LSP configuration
function M.register_lsp_config(lspconfig)
  -- For newer Neovim (0.11+), we use vim.lsp.start() directly
  -- For older versions with lspconfig, we can still register the config

  -- Auto-start LSP for Ignition files if enabled
  if lsp_config.auto_start then
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'python', 'ignition' },
      callback = function(args)
        local bufname = vim.api.nvim_buf_get_name(args.buf)

        -- Start LSP for Ignition files or virtual buffers (decoded scripts)
        if vim.bo[args.buf].filetype == 'ignition' or bufname:match('%[Ignition:') then
          M.start_lsp_for_buffer(args.buf)
        end
      end,
    })
  end
end

return M
