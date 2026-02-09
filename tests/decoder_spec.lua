-- Tests for Ignition decoder module
-- Run with: nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile tests/decoder_spec.lua"

local decoder = require('ignition.decoder')
local virtual_doc = require('ignition.virtual_doc')
local encoding = require('ignition.encoding')
local eq = assert.are.equal

-- Unique name counter to avoid buffer name collisions between tests
local _name_counter = 0
local function unique_name(base)
  _name_counter = _name_counter + 1
  return string.format('/tmp/dectest_%d_%s.json', _name_counter, base)
end

--- Helper: wipeout a buffer completely
local function wipe(bufnr)
  if bufnr and vim.api.nvim_buf_is_valid(bufnr) then
    vim.cmd('silent! bwipeout! ' .. bufnr)
  end
end

--- Helper: create a source buffer with JSON content and make it current
local function setup_source_buf(lines, name)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.bo[buf].swapfile = false
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_buf_set_name(buf, name)
  vim.api.nvim_set_current_buf(buf)
  return buf
end

--- Helper: close all splits except current (clean up after decode_script opens splits)
local function close_extra_windows()
  while #vim.api.nvim_list_wins() > 1 do
    local wins = vim.api.nvim_list_wins()
    -- Close the last window that isn't the current one
    for i = #wins, 1, -1 do
      if wins[i] ~= vim.api.nvim_get_current_win() then
        vim.api.nvim_win_close(wins[i], true)
        break
      end
    end
  end
end

--- Helper: full reset between tests
local function reset()
  virtual_doc.virtual_docs = {}
  close_extra_windows()
end

--- Build an encoded Ignition JSON line with a script key
--- e.g., build_script_line('script', 'print("hello")') produces a JSON line
--- with the content encoded in Ignition Flint format
local function build_script_line(key, python_code)
  local encoded = encoding.encode_script(python_code)
  return string.format('    "%s": "%s",', key, encoded)
end

-- ──────────────────────────────────────────────
-- decode_script (the core decode function)
-- ──────────────────────────────────────────────
describe('decode_script', function()
  before_each(reset)

  it('creates a virtual buffer with decoded content', function()
    local code = 'print("hello")'
    local line = build_script_line('script', code)
    local source = setup_source_buf({ line }, unique_name('decode_basic'))

    local script_info = {
      key = 'script',
      line = 1,
      content = encoding.encode_script(code),
      line_text = line,
    }

    decoder.decode_script(source, script_info)

    -- Should have created a virtual doc
    local docs = virtual_doc.get_virtual_docs_for_source(source)
    eq(1, #docs)

    -- Virtual buffer should contain the decoded content
    local vbuf = docs[1].bufnr
    local vlines = vim.api.nvim_buf_get_lines(vbuf, 0, -1, false)
    eq('print("hello")', vlines[1])

    wipe(vbuf)
    close_extra_windows()
    wipe(source)
  end)

  it('decodes multiline scripts correctly', function()
    local code = 'x = 1\nprint(x)\nreturn x'
    local line = build_script_line('script', code)
    local source = setup_source_buf({ line }, unique_name('decode_multiline'))

    local script_info = {
      key = 'script',
      line = 1,
      content = encoding.encode_script(code),
      line_text = line,
    }

    decoder.decode_script(source, script_info)

    local docs = virtual_doc.get_virtual_docs_for_source(source)
    local vbuf = docs[1].bufnr
    local vlines = vim.api.nvim_buf_get_lines(vbuf, 0, -1, false)

    eq(3, #vlines)
    eq('x = 1', vlines[1])
    eq('print(x)', vlines[2])
    eq('return x', vlines[3])

    wipe(vbuf)
    close_extra_windows()
    wipe(source)
  end)

  it('decodes special characters (equals, angle brackets, quotes)', function()
    local code = "x = 'hello <world>'"
    local line = build_script_line('script', code)
    local source = setup_source_buf({ line }, unique_name('decode_special'))

    local script_info = {
      key = 'script',
      line = 1,
      content = encoding.encode_script(code),
      line_text = line,
    }

    decoder.decode_script(source, script_info)

    local docs = virtual_doc.get_virtual_docs_for_source(source)
    local vbuf = docs[1].bufnr
    local vlines = vim.api.nvim_buf_get_lines(vbuf, 0, -1, false)

    eq("x = 'hello <world>'", vlines[1])

    wipe(vbuf)
    close_extra_windows()
    wipe(source)
  end)

  it('opens a split window for the decoded buffer', function()
    local win_count_before = #vim.api.nvim_list_wins()
    local code = 'pass'
    local line = build_script_line('script', code)
    local source = setup_source_buf({ line }, unique_name('decode_split'))

    decoder.decode_script(source, {
      key = 'script',
      line = 1,
      content = encoding.encode_script(code),
      line_text = line,
    })

    local win_count_after = #vim.api.nvim_list_wins()
    assert.is_true(win_count_after > win_count_before)

    local docs = virtual_doc.get_virtual_docs_for_source(source)
    wipe(docs[1].bufnr)
    close_extra_windows()
    wipe(source)
  end)

  it('marks the virtual buffer as unmodified after initial decode', function()
    local code = 'x = 1'
    local line = build_script_line('script', code)
    local source = setup_source_buf({ line }, unique_name('decode_unmodified'))

    decoder.decode_script(source, {
      key = 'script',
      line = 1,
      content = encoding.encode_script(code),
      line_text = line,
    })

    local docs = virtual_doc.get_virtual_docs_for_source(source)
    local vbuf = docs[1].bufnr
    eq(false, vim.api.nvim_buf_get_option(vbuf, 'modified'))

    wipe(vbuf)
    close_extra_windows()
    wipe(source)
  end)

  it('reuses existing virtual buffer on second decode of same script', function()
    local code = 'pass'
    local line = build_script_line('script', code)
    local source = setup_source_buf({ line }, unique_name('decode_reuse'))

    local script_info = {
      key = 'script',
      line = 1,
      content = encoding.encode_script(code),
      line_text = line,
    }

    decoder.decode_script(source, script_info)
    local docs1 = virtual_doc.get_virtual_docs_for_source(source)
    local vbuf1 = docs1[1].bufnr

    -- Decode same script again
    decoder.decode_script(source, script_info)
    local docs2 = virtual_doc.get_virtual_docs_for_source(source)

    -- Should still only have one virtual doc (reused)
    eq(1, #docs2)
    eq(vbuf1, docs2[1].bufnr)

    wipe(vbuf1)
    close_extra_windows()
    wipe(source)
  end)
end)

-- ──────────────────────────────────────────────
-- has_encoded_scripts / get_script_stats
-- ──────────────────────────────────────────────
describe('has_encoded_scripts', function()
  before_each(reset)

  it('returns true for buffer with encoded scripts', function()
    local line = build_script_line('script', 'print("test")\nx = 1')
    local source = setup_source_buf({ line }, unique_name('has_scripts'))

    assert.is_true(decoder.has_encoded_scripts(source))

    wipe(source)
  end)

  it('returns false for buffer with no scripts', function()
    local source = setup_source_buf(
      { '{"name": "test", "type": "component"}' },
      unique_name('no_scripts')
    )

    assert.is_false(decoder.has_encoded_scripts(source))

    wipe(source)
  end)
end)

describe('get_script_stats', function()
  before_each(reset)

  it('returns count and breakdown of scripts by type', function()
    local line1 = build_script_line('script', 'print(1)\nx = 1')
    local line2 = build_script_line('code', 'return value\nx = 2')
    local line3 = build_script_line('script', 'pass\ny = 3')
    local source = setup_source_buf({ line1, line2, line3 }, unique_name('stats'))

    local stats = decoder.get_script_stats(source)

    eq(3, stats.count)
    eq(2, stats.by_type['script'])
    eq(1, stats.by_type['code'])
    assert.is_true(stats.total_length > 0)

    wipe(source)
  end)

  it('returns zero count for buffer with no scripts', function()
    local source = setup_source_buf({ '{"empty": true}' }, unique_name('stats_empty'))

    local stats = decoder.get_script_stats(source)
    eq(0, stats.count)

    wipe(source)
  end)
end)

-- ──────────────────────────────────────────────
-- encode_current_buffer
-- ──────────────────────────────────────────────
describe('encode_current_buffer', function()
  before_each(reset)

  it('encodes virtual buffer content back to source', function()
    local original_code = 'x = 1'
    local line = build_script_line('script', original_code)
    local source = setup_source_buf({ line }, unique_name('encode_back'))

    local script_info = {
      key = 'script',
      line = 1,
      content = encoding.encode_script(original_code),
      line_text = line,
    }

    decoder.decode_script(source, script_info)

    local docs = virtual_doc.get_virtual_docs_for_source(source)
    local vbuf = docs[1].bufnr

    -- Simulate user editing the decoded content
    vim.api.nvim_buf_set_lines(vbuf, 0, -1, false, { 'y = 2' })

    -- Make virtual buffer current and encode
    vim.api.nvim_set_current_buf(vbuf)
    decoder.encode_current_buffer()

    -- Verify the source buffer was updated with encoded content
    local updated = vim.api.nvim_buf_get_lines(source, 0, 1, false)[1]
    assert.is_truthy(updated:find('y', 1, true))

    wipe(vbuf)
    close_extra_windows()
    wipe(source)
  end)

  it('does nothing when current buffer is not a virtual doc', function()
    local source = setup_source_buf({ '{"test": true}' }, unique_name('encode_noop'))

    -- Should not error — just warns
    decoder.encode_current_buffer()

    -- Buffer should be unchanged
    local content = vim.api.nvim_buf_get_lines(source, 0, 1, false)[1]
    eq('{"test": true}', content)

    wipe(source)
  end)
end)

-- ──────────────────────────────────────────────
-- Full round-trip: decode -> edit -> encode
-- ──────────────────────────────────────────────
describe('round-trip', function()
  before_each(reset)

  it('preserves special characters through decode-edit-encode cycle', function()
    local original = "if x == 'test' and y > 0:\n    print(x)"
    local line = build_script_line('script', original)
    local source = setup_source_buf({ line }, unique_name('roundtrip'))

    local script_info = {
      key = 'script',
      line = 1,
      content = encoding.encode_script(original),
      line_text = line,
    }

    -- Decode
    decoder.decode_script(source, script_info)
    local docs = virtual_doc.get_virtual_docs_for_source(source)
    local vbuf = docs[1].bufnr

    -- Verify decoded content is correct
    local decoded_lines = vim.api.nvim_buf_get_lines(vbuf, 0, -1, false)
    eq("if x == 'test' and y > 0:", decoded_lines[1])
    eq("    print(x)", decoded_lines[2])

    -- Encode back (without editing — content should be identical)
    vim.api.nvim_set_current_buf(vbuf)
    decoder.encode_current_buffer()

    -- The source line should match the original
    local result = vim.api.nvim_buf_get_lines(source, 0, 1, false)[1]
    eq(line, result)

    wipe(vbuf)
    close_extra_windows()
    wipe(source)
  end)

  it('correctly encodes modified content back to source', function()
    local original = 'x = 1'
    local line = build_script_line('script', original)
    local source = setup_source_buf({ line }, unique_name('roundtrip_edit'))

    local script_info = {
      key = 'script',
      line = 1,
      content = encoding.encode_script(original),
      line_text = line,
    }

    -- Decode
    decoder.decode_script(source, script_info)
    local docs = virtual_doc.get_virtual_docs_for_source(source)
    local vbuf = docs[1].bufnr

    -- Edit: change to multiline with special chars
    local new_code = "y = 'hello <world>'\nprint(y)"
    local new_lines = vim.split(new_code, '\n', { plain = true })
    vim.api.nvim_buf_set_lines(vbuf, 0, -1, false, new_lines)

    -- Encode back
    vim.api.nvim_set_current_buf(vbuf)
    decoder.encode_current_buffer()

    -- Verify the source has the new encoded content
    local result = vim.api.nvim_buf_get_lines(source, 0, 1, false)[1]
    local expected = build_script_line('script', new_code)
    eq(expected, result)

    wipe(vbuf)
    close_extra_windows()
    wipe(source)
  end)
end)
