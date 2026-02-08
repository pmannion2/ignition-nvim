-- Tests for Kindling integration module
-- Run with: nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile tests/kindling_spec.lua"

local eq = assert.are.equal

-- ──────────────────────────────────────────────
-- Helpers for mocking vim.fn functions
-- ──────────────────────────────────────────────

local _saved_fn = {}
local _saved_notify = nil

--- Mock vim.fn functions, saving originals for restore
local function mock_fn(overrides)
  for name, fn in pairs(overrides) do
    _saved_fn[name] = vim.fn[name]
    vim.fn[name] = fn
  end
end

--- Capture vim.notify calls
local notifications = {}
local function capture_notifications()
  _saved_notify = vim.notify
  notifications = {}
  vim.notify = function(msg, level, opts)
    table.insert(notifications, { msg = msg, level = level, opts = opts })
  end
end

--- Restore all mocked functions
local function restore_all()
  for name, fn in pairs(_saved_fn) do
    vim.fn[name] = fn
  end
  _saved_fn = {}
  if _saved_notify then
    vim.notify = _saved_notify
    _saved_notify = nil
  end
  notifications = {}
end

--- Fresh-load kindling module (clears module cache + internal state)
local function fresh_kindling()
  package.loaded['ignition.kindling'] = nil
  local k = require('ignition.kindling')
  k.reset()
  return k
end

-- ──────────────────────────────────────────────
-- detect_installation — platform detection logic
-- ──────────────────────────────────────────────
describe('detect_installation', function()
  after_each(restore_all)

  it('returns true when config.path is a valid executable', function()
    local kindling = fresh_kindling()
    -- Set up config with an explicit path
    require('ignition').config.kindling = { enabled = true, path = '/custom/kindling' }
    mock_fn({
      executable = function(path)
        if path == '/custom/kindling' then return 1 end
        return 0
      end,
      exepath = function() return '' end,
      expand = vim.fn.expand,
    })
    eq(true, kindling.detect_installation())
    eq('/custom/kindling', kindling.get_path())
  end)

  it('returns false when config.path is not executable', function()
    local kindling = fresh_kindling()
    require('ignition').config.kindling = { enabled = true, path = '/bad/kindling' }
    mock_fn({
      executable = function() return 0 end,
      exepath = function() return '' end,
      expand = function() return '' end,
    })
    eq(false, kindling.detect_installation())
    eq(nil, kindling.get_path())
  end)

  it('finds kindling at /usr/local/bin/kindling (macOS/Linux)', function()
    local kindling = fresh_kindling()
    require('ignition').config.kindling = { enabled = true, path = nil }
    mock_fn({
      executable = function(path)
        if path == '/usr/local/bin/kindling' then return 1 end
        return 0
      end,
      exepath = function() return '' end,
      expand = function() return '' end,
    })
    eq(true, kindling.detect_installation())
    eq('/usr/local/bin/kindling', kindling.get_path())
  end)

  it('finds kindling at /opt/homebrew/bin/kindling (macOS Apple Silicon)', function()
    local kindling = fresh_kindling()
    require('ignition').config.kindling = { enabled = true, path = nil }
    mock_fn({
      executable = function(path)
        if path == '/opt/homebrew/bin/kindling' then return 1 end
        return 0
      end,
      exepath = function() return '' end,
      expand = function() return '' end,
    })
    eq(true, kindling.detect_installation())
    eq('/opt/homebrew/bin/kindling', kindling.get_path())
  end)

  it('finds kindling at ~/.local/bin/kindling (Linux user install)', function()
    local kindling = fresh_kindling()
    require('ignition').config.kindling = { enabled = true, path = nil }
    local home_path = vim.fn.expand('~/.local/bin/kindling')
    mock_fn({
      executable = function(path)
        if path == home_path then return 1 end
        return 0
      end,
      exepath = function() return '' end,
      -- keep real expand so ~/.local resolves correctly
    })
    eq(true, kindling.detect_installation())
    eq(home_path, kindling.get_path())
  end)

  it('finds kindling via exepath as last resort', function()
    local kindling = fresh_kindling()
    require('ignition').config.kindling = { enabled = true, path = nil }
    mock_fn({
      executable = function(path)
        if path == '/some/weird/path/kindling' then return 1 end
        return 0
      end,
      exepath = function() return '/some/weird/path/kindling' end,
      expand = function() return '' end,
    })
    eq(true, kindling.detect_installation())
    eq('/some/weird/path/kindling', kindling.get_path())
  end)

  it('returns false when kindling is not installed anywhere', function()
    local kindling = fresh_kindling()
    require('ignition').config.kindling = { enabled = true, path = nil }
    mock_fn({
      executable = function() return 0 end,
      exepath = function() return '' end,
      expand = function() return '' end,
    })
    eq(false, kindling.detect_installation())
    eq(nil, kindling.get_path())
  end)

  it('skips empty exepath result', function()
    local kindling = fresh_kindling()
    require('ignition').config.kindling = { enabled = true, path = nil }
    -- exepath returns '' — the '' should be skipped, not passed to executable
    local executable_args = {}
    mock_fn({
      executable = function(path)
        table.insert(executable_args, path)
        return 0
      end,
      exepath = function() return '' end,
      expand = function() return '' end,
    })
    kindling.detect_installation()
    -- '' should NOT appear in the executable args
    for _, arg in ipairs(executable_args) do
      assert.is_not.equal('', arg)
    end
  end)
end)

-- ──────────────────────────────────────────────
-- open_with_kindling — launching and error cases
-- ──────────────────────────────────────────────
describe('open_with_kindling', function()
  after_each(restore_all)

  it('shows install instructions when kindling not found', function()
    local kindling = fresh_kindling()
    require('ignition').config.kindling = { enabled = true, path = nil }
    capture_notifications()
    mock_fn({
      executable = function() return 0 end,
      exepath = function() return '' end,
      expand = function() return '' end,
    })
    kindling.open_with_kindling(nil)
    -- Should have shown install instructions
    assert.is_true(#notifications > 0)
    local msg = notifications[1].msg
    assert.is_truthy(msg:find('not installed'))
    assert.is_truthy(msg:find('github'))
    assert.is_truthy(msg:find('kindling'))
    eq(vim.log.levels.WARN, notifications[1].level)
  end)

  it('shows error for non-existent file', function()
    local kindling = fresh_kindling()
    require('ignition').config.kindling = { enabled = true, path = '/usr/bin/kindling' }
    capture_notifications()
    mock_fn({
      executable = function(path)
        if path == '/usr/bin/kindling' then return 1 end
        return 0
      end,
      exepath = function() return '' end,
      filereadable = function() return 0 end,
      expand = function(path) return path end,
    })
    kindling.detect_installation()
    kindling.open_with_kindling('/nonexistent/file.gwbk')
    assert.is_true(#notifications > 0)
    local found_error = false
    for _, n in ipairs(notifications) do
      if n.level == vim.log.levels.ERROR and n.msg:find('not found') then
        found_error = true
      end
    end
    assert.is_true(found_error)
  end)

  it('launches kindling via jobstart for valid file', function()
    local kindling = fresh_kindling()
    require('ignition').config.kindling = { enabled = true, path = '/usr/bin/kindling' }
    capture_notifications()
    local jobstart_args = nil
    mock_fn({
      executable = function(path)
        if path == '/usr/bin/kindling' then return 1 end
        return 0
      end,
      exepath = function() return '' end,
      filereadable = function() return 1 end,
      expand = function(path) return path end,
      fnamemodify = function(_, modifier)
        return 'test.gwbk'
      end,
      jobstart = function(cmd, opts)
        jobstart_args = { cmd = cmd, opts = opts }
        return 1 -- fake job id
      end,
    })
    kindling.detect_installation()
    kindling.open_with_kindling('/path/to/test.gwbk')
    -- Verify jobstart was called with correct args
    assert.is_not_nil(jobstart_args)
    eq('/usr/bin/kindling', jobstart_args.cmd[1])
    eq('/path/to/test.gwbk', jobstart_args.cmd[2])
    assert.is_true(jobstart_args.opts.detach)
    -- Verify notification was sent
    local found_opening = false
    for _, n in ipairs(notifications) do
      if n.msg:find('Opening in Kindling') then found_opening = true end
    end
    assert.is_true(found_opening)
  end)

  it('uses current buffer when no file_path given', function()
    local kindling = fresh_kindling()
    require('ignition').config.kindling = { enabled = true, path = '/usr/bin/kindling' }
    capture_notifications()
    local jobstart_args = nil
    mock_fn({
      executable = function(path)
        if path == '/usr/bin/kindling' then return 1 end
        return 0
      end,
      exepath = function() return '' end,
      filereadable = function() return 1 end,
      expand = function(path)
        -- Simulate %:p expansion to current buffer path
        if path == '%:p' then return '/current/buffer.gwbk' end
        return path
      end,
      fnamemodify = function() return 'buffer.gwbk' end,
      jobstart = function(cmd, opts)
        jobstart_args = { cmd = cmd, opts = opts }
        return 1
      end,
    })
    kindling.detect_installation()
    kindling.open_with_kindling(nil)
    assert.is_not_nil(jobstart_args)
    eq('/current/buffer.gwbk', jobstart_args.cmd[2])
  end)

  it('uses current buffer when file_path is empty string', function()
    local kindling = fresh_kindling()
    require('ignition').config.kindling = { enabled = true, path = '/usr/bin/kindling' }
    capture_notifications()
    local jobstart_args = nil
    mock_fn({
      executable = function(path)
        if path == '/usr/bin/kindling' then return 1 end
        return 0
      end,
      exepath = function() return '' end,
      filereadable = function() return 1 end,
      expand = function(path)
        if path == '%:p' then return '/current/buffer.gwbk' end
        return path
      end,
      fnamemodify = function() return 'buffer.gwbk' end,
      jobstart = function(cmd, opts)
        jobstart_args = { cmd = cmd, opts = opts }
        return 1
      end,
    })
    kindling.detect_installation()
    kindling.open_with_kindling('')
    assert.is_not_nil(jobstart_args)
    eq('/current/buffer.gwbk', jobstart_args.cmd[2])
  end)
end)

-- ──────────────────────────────────────────────
-- show_install_instructions — content validation
-- ──────────────────────────────────────────────
describe('show_install_instructions', function()
  after_each(restore_all)

  it('includes GitHub repository URL', function()
    local kindling = fresh_kindling()
    capture_notifications()
    kindling.show_install_instructions()
    assert.is_true(#notifications > 0)
    assert.is_truthy(notifications[1].msg:find('github.com'))
  end)

  it('includes setup configuration example', function()
    local kindling = fresh_kindling()
    capture_notifications()
    kindling.show_install_instructions()
    assert.is_truthy(notifications[1].msg:find('require.-ignition'))
    assert.is_truthy(notifications[1].msg:find('kindling'))
  end)

  it('uses WARN level', function()
    local kindling = fresh_kindling()
    capture_notifications()
    kindling.show_install_instructions()
    eq(vim.log.levels.WARN, notifications[1].level)
  end)
end)

-- ──────────────────────────────────────────────
-- IgnitionOpenKindling command registration
-- ──────────────────────────────────────────────
describe('IgnitionOpenKindling command', function()
  -- Ensure plugin/ files are loaded (headless nvim doesn't auto-source them)
  before_each(function()
    vim.g.loaded_ignition = nil
    vim.cmd('runtime plugin/ignition.lua')
  end)

  it('is registered as a user command', function()
    local cmds = vim.api.nvim_get_commands({})
    assert.is_not_nil(cmds['IgnitionOpenKindling'])
  end)

  it('has file completion', function()
    local cmds = vim.api.nvim_get_commands({})
    eq('file', cmds['IgnitionOpenKindling'].complete)
  end)

  it('accepts optional file argument', function()
    local cmds = vim.api.nvim_get_commands({})
    eq('?', cmds['IgnitionOpenKindling'].nargs)
  end)
end)

-- ──────────────────────────────────────────────
-- reset / get_path — state management
-- ──────────────────────────────────────────────
describe('state management', function()
  after_each(restore_all)

  it('reset clears cached path', function()
    local kindling = fresh_kindling()
    require('ignition').config.kindling = { enabled = true, path = '/test/kindling' }
    mock_fn({
      executable = function() return 1 end,
      exepath = function() return '' end,
      expand = vim.fn.expand,
    })
    kindling.detect_installation()
    assert.is_not_nil(kindling.get_path())
    kindling.reset()
    eq(nil, kindling.get_path())
  end)

  it('caches path after first detection', function()
    local kindling = fresh_kindling()
    require('ignition').config.kindling = { enabled = true, path = '/cached/kindling' }
    mock_fn({
      executable = function(path)
        if path == '/cached/kindling' then return 1 end
        return 0
      end,
      exepath = function() return '' end,
      expand = vim.fn.expand,
    })
    kindling.detect_installation()
    eq('/cached/kindling', kindling.get_path())
    -- Now change config — but cached path should persist
    require('ignition').config.kindling = { enabled = true, path = '/other/kindling' }
    -- get_path still returns the cached value
    eq('/cached/kindling', kindling.get_path())
  end)
end)
