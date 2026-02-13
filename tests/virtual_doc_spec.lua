-- Tests for Ignition virtual document system
-- Run with: nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile tests/virtual_doc_spec.lua"

local virtual_doc = require('ignition.virtual_doc')
local eq = assert.are.equal

-- Unique name counter to avoid buffer name collisions between tests
local _name_counter = 0
local function unique_name(base)
  _name_counter = _name_counter + 1
  return string.format('/tmp/vdtest_%d_%s.json', _name_counter, base)
end

--- Helper: create a source buffer with given lines
local function create_source_buf(lines, name)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  if name then
    vim.api.nvim_buf_set_name(buf, name)
  end
  return buf
end

--- Helper: wipeout a buffer completely (removes name registration)
local function wipe(bufnr)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    vim.cmd('silent! bwipeout! ' .. bufnr)
  end
end

--- Helper: build a script_info table matching what json_parser produces
local function make_script_info(key, line, content, line_text)
  return {
    key = key,
    line = line,
    content = content,
    line_text = line_text or '',
  }
end

--- Helper: reset virtual_docs state between tests
local function reset()
  virtual_doc.virtual_docs = {}
end

-- ──────────────────────────────────────────────
-- create_virtual_doc
-- ──────────────────────────────────────────────
describe('create_virtual_doc', function()
  before_each(reset)

  it('creates a scratch buffer and returns its number', function()
    local source = create_source_buf({ '{"script": "print(1)"}' }, unique_name('create'))
    local info = make_script_info('script', 1, 'print(1)')

    local vbuf = virtual_doc.create_virtual_doc(source, info)

    assert.is_number(vbuf)
    assert.is_true(vim.api.nvim_buf_is_valid(vbuf))

    wipe(vbuf)
    wipe(source)
  end)

  it('sets buffer type to acwrite', function()
    local source = create_source_buf({ '{}' }, unique_name('acwrite'))
    local vbuf = virtual_doc.create_virtual_doc(source, make_script_info('script', 1, ''))

    eq('acwrite', vim.api.nvim_buf_get_option(vbuf, 'buftype'))

    wipe(vbuf)
    wipe(source)
  end)

  it('sets filetype to python', function()
    local source = create_source_buf({ '{}' }, unique_name('ft'))
    local vbuf = virtual_doc.create_virtual_doc(source, make_script_info('code', 1, ''))

    eq('python', vim.api.nvim_buf_get_option(vbuf, 'filetype'))

    wipe(vbuf)
    wipe(source)
  end)

  it('disables swapfile', function()
    local source = create_source_buf({ '{}' }, unique_name('swap'))
    local vbuf = virtual_doc.create_virtual_doc(source, make_script_info('script', 1, ''))

    eq(false, vim.api.nvim_buf_get_option(vbuf, 'swapfile'))

    wipe(vbuf)
    wipe(source)
  end)

  it('names buffer with [Ignition:filename:key:Lnum] format', function()
    local source = create_source_buf({ '{}' }, unique_name('naming'))
    local vbuf = virtual_doc.create_virtual_doc(source, make_script_info('onActionPerformed', 1, ''))

    local name = vim.api.nvim_buf_get_name(vbuf)
    assert.is_truthy(name:find('%[Ignition:'))
    assert.is_truthy(name:find(':onActionPerformed:L1%]'))

    wipe(vbuf)
    wipe(source)
  end)

  it('stores metadata for the virtual buffer', function()
    local source = create_source_buf({ '{"script": "x=1"}' }, unique_name('meta'))
    local info = make_script_info('script', 1, 'x=1', '{"script": "x=1"}')
    local vbuf = virtual_doc.create_virtual_doc(source, info)

    local meta = virtual_doc.get_metadata(vbuf)
    assert.is_not_nil(meta)
    eq(source, meta.source_bufnr)
    eq('script', meta.script_key)
    eq(1, meta.line_num)
    eq('x=1', meta.original_content)

    wipe(vbuf)
    wipe(source)
  end)

  it('stores source_file path from source buffer name', function()
    local source = create_source_buf({ '{}' }, unique_name('path'))
    local vbuf = virtual_doc.create_virtual_doc(source, make_script_info('script', 1, ''))

    local meta = virtual_doc.get_metadata(vbuf)
    assert.is_truthy(meta.source_file:find('path'))

    wipe(vbuf)
    wipe(source)
  end)
end)

-- ──────────────────────────────────────────────
-- Duplicate prevention
-- ──────────────────────────────────────────────
describe('duplicate prevention', function()
  before_each(reset)

  it('returns existing buffer when virtual doc already exists', function()
    local source = create_source_buf({ '{}' }, unique_name('dup'))
    local info = make_script_info('script', 1, '')

    local vbuf1 = virtual_doc.create_virtual_doc(source, info)
    local vbuf2 = virtual_doc.create_virtual_doc(source, info)

    eq(vbuf1, vbuf2)

    wipe(vbuf1)
    wipe(source)
  end)

  it('creates separate buffers for different keys on the same source', function()
    local source = create_source_buf({ '{}', '{}' }, unique_name('multikey'))
    local vbuf_script = virtual_doc.create_virtual_doc(source, make_script_info('script', 1, ''))
    local vbuf_code = virtual_doc.create_virtual_doc(source, make_script_info('code', 2, ''))

    assert.is_not.equal(vbuf_script, vbuf_code)

    wipe(vbuf_script)
    wipe(vbuf_code)
    wipe(source)
  end)
end)

-- ──────────────────────────────────────────────
-- is_virtual_doc
-- ──────────────────────────────────────────────
describe('is_virtual_doc', function()
  before_each(reset)

  it('returns true for a virtual document buffer', function()
    local source = create_source_buf({ '{}' }, unique_name('isvd'))
    local vbuf = virtual_doc.create_virtual_doc(source, make_script_info('script', 1, ''))

    assert.is_true(virtual_doc.is_virtual_doc(vbuf))

    wipe(vbuf)
    wipe(source)
  end)

  it('returns false for a regular buffer', function()
    local buf = vim.api.nvim_create_buf(true, false)

    assert.is_false(virtual_doc.is_virtual_doc(buf))

    wipe(buf)
  end)

  it('returns false for a non-existent buffer number', function()
    assert.is_false(virtual_doc.is_virtual_doc(99999))
  end)
end)

-- ──────────────────────────────────────────────
-- get_metadata
-- ──────────────────────────────────────────────
describe('get_metadata', function()
  before_each(reset)

  it('returns nil for non-virtual buffers', function()
    assert.is_nil(virtual_doc.get_metadata(99999))
  end)

  it('returns metadata table with all expected fields', function()
    local source = create_source_buf({ '{}' }, unique_name('fields'))
    local info = make_script_info('onChange', 1, 'old_value', '  "onChange": "old_value"')
    local vbuf = virtual_doc.create_virtual_doc(source, info)

    local meta = virtual_doc.get_metadata(vbuf)
    assert.is_not_nil(meta.source_bufnr)
    assert.is_not_nil(meta.source_file)
    assert.is_not_nil(meta.script_key)
    assert.is_not_nil(meta.line_num)
    assert.is_not_nil(meta.original_content)
    assert.is_not_nil(meta.line_text)

    wipe(vbuf)
    wipe(source)
  end)
end)

-- ──────────────────────────────────────────────
-- cleanup_virtual_doc
-- ──────────────────────────────────────────────
describe('cleanup_virtual_doc', function()
  before_each(reset)

  it('removes metadata for a virtual document', function()
    local source = create_source_buf({ '{}' }, unique_name('cleanup'))
    local vbuf = virtual_doc.create_virtual_doc(source, make_script_info('script', 1, ''))

    assert.is_true(virtual_doc.is_virtual_doc(vbuf))
    virtual_doc.cleanup_virtual_doc(vbuf)
    assert.is_false(virtual_doc.is_virtual_doc(vbuf))

    wipe(vbuf)
    wipe(source)
  end)

  it('is safe to call on a non-existent buffer', function()
    virtual_doc.cleanup_virtual_doc(99999)
  end)
end)

-- ──────────────────────────────────────────────
-- get_virtual_docs_for_source
-- ──────────────────────────────────────────────
describe('get_virtual_docs_for_source', function()
  before_each(reset)

  it('returns all virtual docs for a given source buffer', function()
    local source = create_source_buf({ '{}', '{}', '{}' }, unique_name('multi_vd'))
    local v1 = virtual_doc.create_virtual_doc(source, make_script_info('script', 1, ''))
    local v2 = virtual_doc.create_virtual_doc(source, make_script_info('code', 2, ''))
    local v3 = virtual_doc.create_virtual_doc(source, make_script_info('onChange', 3, ''))

    local docs = virtual_doc.get_virtual_docs_for_source(source)
    eq(3, #docs)

    local bufnrs = {}
    for _, doc in ipairs(docs) do
      bufnrs[doc.bufnr] = true
    end
    assert.is_true(bufnrs[v1])
    assert.is_true(bufnrs[v2])
    assert.is_true(bufnrs[v3])

    wipe(v1)
    wipe(v2)
    wipe(v3)
    wipe(source)
  end)

  it('returns empty table when source has no virtual docs', function()
    local source = create_source_buf({ '{}' }, unique_name('empty_vd'))

    local docs = virtual_doc.get_virtual_docs_for_source(source)
    eq(0, #docs)

    wipe(source)
  end)

  it('does not include virtual docs from different source buffers', function()
    local source1 = create_source_buf({ '{}' }, unique_name('src1'))
    local source2 = create_source_buf({ '{}' }, unique_name('src2'))
    local v1 = virtual_doc.create_virtual_doc(source1, make_script_info('script', 1, ''))
    local v2 = virtual_doc.create_virtual_doc(source2, make_script_info('script', 1, ''))

    local docs1 = virtual_doc.get_virtual_docs_for_source(source1)
    eq(1, #docs1)
    eq(v1, docs1[1].bufnr)

    local docs2 = virtual_doc.get_virtual_docs_for_source(source2)
    eq(1, #docs2)
    eq(v2, docs2[1].bufnr)

    wipe(v1)
    wipe(v2)
    wipe(source1)
    wipe(source2)
  end)
end)

-- ──────────────────────────────────────────────
-- save_virtual_doc
-- ──────────────────────────────────────────────
describe('save_virtual_doc', function()
  before_each(reset)

  it('returns false when buffer has no metadata', function()
    local buf = vim.api.nvim_create_buf(false, true)

    local result = virtual_doc.save_virtual_doc(buf)
    eq(false, result)

    wipe(buf)
  end)

  it('encodes content and writes back to source buffer', function()
    local json_line = '    "script": "print(1)",'
    local source = create_source_buf({ json_line }, unique_name('save'))
    local info = make_script_info('script', 1, 'print(1)', json_line)

    local vbuf = virtual_doc.create_virtual_doc(source, info)

    -- Simulate user editing: change the decoded content
    vim.api.nvim_buf_set_lines(vbuf, 0, -1, false, { 'print(2)' })

    local result = virtual_doc.save_virtual_doc(vbuf)
    eq(true, result)

    -- Verify the source buffer was updated
    local updated_line = vim.api.nvim_buf_get_lines(source, 0, 1, false)[1]
    assert.is_truthy(updated_line:find('print(2)', 1, true))

    wipe(vbuf)
    wipe(source)
  end)

  it('marks virtual buffer as unmodified after save', function()
    local json_line = '    "script": "x",'
    local source = create_source_buf({ json_line }, unique_name('modified'))
    local info = make_script_info('script', 1, 'x', json_line)

    local vbuf = virtual_doc.create_virtual_doc(source, info)
    vim.api.nvim_buf_set_lines(vbuf, 0, -1, false, { 'y' })
    vim.api.nvim_buf_set_option(vbuf, 'modified', true)

    virtual_doc.save_virtual_doc(vbuf)

    eq(false, vim.api.nvim_buf_get_option(vbuf, 'modified'))

    wipe(vbuf)
    wipe(source)
  end)

  it('marks source buffer as modified after save', function()
    local json_line = '    "script": "a",'
    local source = create_source_buf({ json_line }, unique_name('src_modified'))
    vim.api.nvim_buf_set_option(source, 'modified', false)
    local info = make_script_info('script', 1, 'a', json_line)

    local vbuf = virtual_doc.create_virtual_doc(source, info)
    vim.api.nvim_buf_set_lines(vbuf, 0, -1, false, { 'b' })

    virtual_doc.save_virtual_doc(vbuf)

    eq(true, vim.api.nvim_buf_get_option(source, 'modified'))

    wipe(vbuf)
    wipe(source)
  end)

  it('returns false when source buffer is no longer valid', function()
    local json_line = '    "script": "z",'
    local source = create_source_buf({ json_line }, unique_name('invalid_src'))
    local info = make_script_info('script', 1, 'z', json_line)
    local vbuf = virtual_doc.create_virtual_doc(source, info)

    -- Wipeout the source buffer
    wipe(source)

    local result = virtual_doc.save_virtual_doc(vbuf)
    eq(false, result)

    wipe(vbuf)
  end)

  it('preserves encoding round-trip for special characters', function()
    local json_line = '    "script": "x \\u003d 1\\nprint(x)",'
    local source = create_source_buf({ json_line }, unique_name('roundtrip'))
    local info = make_script_info('script', 1, 'x \\u003d 1\\nprint(x)', json_line)

    local vbuf = virtual_doc.create_virtual_doc(source, info)

    -- Simulate decoded content (actual newline and equals sign)
    vim.api.nvim_buf_set_lines(vbuf, 0, -1, false, { 'x = 1', 'print(x)' })

    virtual_doc.save_virtual_doc(vbuf)

    local updated = vim.api.nvim_buf_get_lines(source, 0, 1, false)[1]
    -- Verify the equals sign got re-encoded to \u003d
    assert.is_truthy(updated:find('\\u003d', 1, true))
    -- Verify the newline got re-encoded to \n
    assert.is_truthy(updated:find('\\n', 1, true))

    wipe(vbuf)
    wipe(source)
  end)
end)

-- ──────────────────────────────────────────────
-- close_virtual_docs_for_source
-- ──────────────────────────────────────────────
describe('close_virtual_docs_for_source', function()
  before_each(reset)

  it('deletes all virtual buffers for a source', function()
    local source = create_source_buf({ '{}', '{}' }, unique_name('close_all'))
    local v1 = virtual_doc.create_virtual_doc(source, make_script_info('script', 1, ''))
    local v2 = virtual_doc.create_virtual_doc(source, make_script_info('code', 2, ''))

    virtual_doc.close_virtual_docs_for_source(source)

    assert.is_false(vim.api.nvim_buf_is_valid(v1))
    assert.is_false(vim.api.nvim_buf_is_valid(v2))

    wipe(source)
  end)

  it('does not affect virtual docs from other sources', function()
    local source1 = create_source_buf({ '{}' }, unique_name('close_src1'))
    local source2 = create_source_buf({ '{}' }, unique_name('close_src2'))
    local v1 = virtual_doc.create_virtual_doc(source1, make_script_info('script', 1, ''))
    local v2 = virtual_doc.create_virtual_doc(source2, make_script_info('script', 1, ''))

    virtual_doc.close_virtual_docs_for_source(source1)

    assert.is_false(vim.api.nvim_buf_is_valid(v1))
    assert.is_true(vim.api.nvim_buf_is_valid(v2))

    wipe(v2)
    wipe(source1)
    wipe(source2)
  end)

  it('is safe to call when source has no virtual docs', function()
    local source = create_source_buf({ '{}' }, unique_name('close_none'))

    virtual_doc.close_virtual_docs_for_source(source)

    wipe(source)
  end)
end)
