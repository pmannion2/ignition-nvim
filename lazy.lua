-- lazy.nvim auto-discovered plugin spec for ignition.nvim
-- Users can install with just: { 'whiskeyhouse/ignition-nvim' }
-- and get sensible defaults. All options are overridable in the user spec.

---@type LazyPluginSpec
return {
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
  build = 'cd lsp && pip install -e .',

  opts = {},

  config = function(_, opts)
    require('ignition').setup(opts)
  end,
}
