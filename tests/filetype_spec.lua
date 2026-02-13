-- Tests for Ignition file type detection
-- Run with: nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"

local eq = assert.are.equal

describe('Ignition filetype detection', function()
  local test_fixtures = vim.fn.getcwd() .. '/tests/fixtures/'

  after_each(function()
    -- Clean up buffers after each test
    vim.cmd('bufdo! bwipeout!')
  end)

  it('detects .gwbk files as ignition filetype', function()
    vim.cmd('edit ' .. test_fixtures .. 'test.gwbk')
    eq('ignition', vim.bo.filetype)
  end)

  it('detects .proj files as ignition filetype', function()
    vim.cmd('edit ' .. test_fixtures .. 'test.proj')
    eq('ignition', vim.bo.filetype)
  end)

  it('detects resource.json as ignition filetype', function()
    vim.cmd('edit ' .. test_fixtures .. 'ignition-project/resource.json')
    eq('ignition', vim.bo.filetype)
  end)

  it('detects tags.json as ignition filetype', function()
    vim.cmd('edit ' .. test_fixtures .. 'ignition-project/tags.json')
    eq('ignition', vim.bo.filetype)
  end)

  it('detects project.json as ignition filetype', function()
    vim.cmd('edit ' .. test_fixtures .. 'ignition-project/project.json')
    eq('ignition', vim.bo.filetype)
  end)

  it('detects perspective views as ignition filetype', function()
    vim.cmd('edit ' .. test_fixtures .. 'ignition-project/perspective-view.json')
    eq('ignition', vim.bo.filetype)
  end)

  it('sets correct buffer options for ignition files', function()
    vim.cmd('edit ' .. test_fixtures .. 'test.gwbk')

    eq('ignition', vim.bo.filetype)
    eq(true, vim.bo.expandtab)
    eq(2, vim.bo.tabstop)
    eq(2, vim.bo.shiftwidth)
    eq(2, vim.bo.softtabstop)
    eq('// %s', vim.bo.commentstring)
  end)
end)
