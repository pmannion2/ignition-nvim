-- lazy.nvim plugin spec for ignition.nvim
-- Users can install with just: { 'pmannion2/ignition-nvim' }
-- and get sensible defaults. All options are overridable in the user spec.

---@type LazyPluginSpec
return {
  'pmannion2/ignition-nvim',

  -- Lazy-load on Ignition file types and commands
  ft = { 'ignition' },
  cmd = {
    'IgnitionDecode',
    'IgnitionDecodeAll',
    'IgnitionEncode',
    'IgnitionListScripts',
    'IgnitionOpenKindling',
    'IgnitionInfo',
  },

  -- Install the Python LSP server after cloning
  build = 'cd lsp && python3 -m venv venv && venv/bin/pip install ignition-lsp',

  opts = {},

  config = function(_, opts)
    require('ignition').setup(opts)
  end,
}
