-- Tests for Ignition encoding/decoding functionality
-- Run with: nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile tests/encoding_spec.lua"

local encoding = require('ignition.encoding')
local eq = assert.are.equal

describe('Ignition encoding', function()
  it('encodes newlines correctly', function()
    local input = 'line1\nline2'
    local encoded = encoding.encode_script(input)
    eq('line1\\nline2', encoded)
  end)

  it('encodes double quotes correctly', function()
    local input = 'print("hello")'
    local encoded = encoding.encode_script(input)
    eq('print(\\"hello\\")', encoded)
  end)

  it('encodes less than with Unicode escape', function()
    local input = 'x < 10'
    local encoded = encoding.encode_script(input)
    eq('x \\u003c 10', encoded)
  end)

  it('encodes equals with Unicode escape', function()
    local input = 'x = 5'
    local encoded = encoding.encode_script(input)
    eq('x \\u003d 5', encoded)
  end)

  it('encodes backslashes correctly', function()
    local input = 'path\\to\\file'
    local encoded = encoding.encode_script(input)
    eq('path\\\\to\\\\file', encoded)
  end)

  it('encodes complex Python script correctly', function()
    local input = 'logger = system.util.getLogger("Test")\nlogger.info("Value: " + str(x))\nif x < 10:\n\treturn True'
    local encoded = encoding.encode_script(input)
    -- Should have escaped quotes, newlines, less than, etc.
    assert.is_truthy(encoded:find('\\\\"'))
    assert.is_truthy(encoded:find('\\\\n'))
    assert.is_truthy(encoded:find('\\\\u003c'))
  end)
end)

describe('Ignition decoding', function()
  it('decodes newlines correctly', function()
    local encoded = 'line1\\nline2'
    local decoded = encoding.decode_script(encoded)
    eq('line1\nline2', decoded)
  end)

  it('decodes double quotes correctly', function()
    local encoded = 'print(\\"hello\\")'
    local decoded = encoding.decode_script(encoded)
    eq('print("hello")', decoded)
  end)

  it('decodes Unicode escapes correctly', function()
    local encoded = 'x \\u003c 10'
    local decoded = encoding.decode_script(encoded)
    eq('x < 10', decoded)
  end)

  it('decodes equals from Unicode escape', function()
    local encoded = 'x \\u003d 5'
    local decoded = encoding.decode_script(encoded)
    eq('x = 5', decoded)
  end)

  it('decodes backslashes correctly', function()
    local encoded = 'path\\\\to\\\\file'
    local decoded = encoding.decode_script(encoded)
    eq('path\\to\\file', decoded)
  end)
end)

describe('Ignition encoding round-trip', function()
  it('handles round-trip encoding/decoding', function()
    local original = 'print("Hello")\nx = 5\nif x < 10:\n\treturn True'
    local encoded = encoding.encode_script(original)
    local decoded = encoding.decode_script(encoded)
    eq(original, decoded)
  end)

  it('preserves complex scripts through round-trip', function()
    local original = [[logger = system.util.getLogger("Test")
logger.info("Value: " + str(x))
if x < 10 & x > 0:
    return True
else:
    return False]]

    local encoded = encoding.encode_script(original)
    local decoded = encoding.decode_script(encoded)
    eq(original, decoded)
  end)
end)

describe('Script detection', function()
  it('detects encoded scripts', function()
    local encoded = 'print(\\"hello\\")\\nx \\u003d 5'
    assert.is_true(encoding.is_encoded_script(encoded))
  end)

  it('does not detect plain text as encoded', function()
    local plain = 'This is plain text'
    assert.is_false(encoding.is_encoded_script(plain))
  end)

  it('detects scripts with newlines', function()
    local encoded = 'line1\\nline2'
    assert.is_true(encoding.is_encoded_script(encoded))
  end)
end)
