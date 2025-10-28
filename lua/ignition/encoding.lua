-- Script encoding/decoding utilities for Ignition
-- Based on ignition-flint: https://github.com/keith-gamble/ignition-flint

local M = {}

-- Character replacement map
-- This matches the encoding used by Ignition when storing scripts in JSON
-- Source: ignition-flint/src/utils/textEncoding.ts
M.REPLACEMENT_CHARS = {
  { from = '\\', to = '\\\\' },     -- Backslash (must be first!)
  { from = '"', to = '\\"' },       -- Double quote
  { from = '\t', to = '\\t' },      -- Tab
  { from = '\b', to = '\\b' },      -- Backspace
  { from = '\n', to = '\\n' },      -- Newline
  { from = '\r', to = '\\r' },      -- Carriage return
  { from = '\f', to = '\\f' },      -- Form feed
  { from = '<', to = '\\u003c' },   -- Less than (Unicode escape)
  { from = '>', to = '\\u003e' },   -- Greater than (Unicode escape)
  { from = '&', to = '\\u0026' },   -- Ampersand (Unicode escape)
  { from = '=', to = '\\u003d' },   -- Equals (Unicode escape)
  { from = "'", to = '\\u0027' },   -- Single quote (Unicode escape)
}

-- Encode Python code for storage in JSON
-- Converts special characters to their escaped/Unicode equivalents
function M.encode_script(code)
  if not code or code == '' then
    return ''
  end

  local encoded = code

  -- Apply each character replacement using plain string replacement
  for _, replacement in ipairs(M.REPLACEMENT_CHARS) do
    local search = replacement.from
    local replace = replacement.to

    -- Use simple string replacement (split and join)
    local parts = {}
    local start = 1
    while true do
      local pos = encoded:find(search, start, true) -- true = plain search, no patterns
      if not pos then
        table.insert(parts, encoded:sub(start))
        break
      end
      table.insert(parts, encoded:sub(start, pos - 1))
      table.insert(parts, replace)
      start = pos + #search
    end
    encoded = table.concat(parts)
  end

  return encoded
end

-- Decode script from JSON string format
-- Converts escaped/Unicode characters back to their original form
function M.decode_script(encoded)
  if not encoded or encoded == '' then
    return ''
  end

  local decoded = encoded

  -- Apply replacements in reverse order using plain string replacement
  -- This avoids pattern matching issues with special characters
  for i = #M.REPLACEMENT_CHARS, 1, -1 do
    local replacement = M.REPLACEMENT_CHARS[i]
    local search = replacement.to
    local replace = replacement.from

    -- Use simple string replacement (split and join)
    local parts = {}
    local start = 1
    while true do
      local pos = decoded:find(search, start, true) -- true = plain search, no patterns
      if not pos then
        table.insert(parts, decoded:sub(start))
        break
      end
      table.insert(parts, decoded:sub(start, pos - 1))
      table.insert(parts, replace)
      start = pos + #search
    end
    decoded = table.concat(parts)
  end

  return decoded
end

-- Test if a string appears to be an encoded Ignition script
-- Looks for common encoded patterns
function M.is_encoded_script(text)
  if not text or text == '' then
    return false
  end

  -- Check for common encoded patterns
  local patterns = {
    '\\n',     -- Escaped newlines are very common in scripts
    '\\t',     -- Escaped tabs
    '\\"',     -- Escaped quotes
    '\\u003',  -- Unicode escapes (< > =)
  }

  for _, pattern in ipairs(patterns) do
    if text:find(pattern, 1, true) then
      return true
    end
  end

  return false
end

-- Get encoding statistics (for debugging)
function M.encoding_stats(text)
  local stats = {
    length = #text,
    newlines = 0,
    tabs = 0,
    quotes = 0,
    unicode_escapes = 0,
  }

  for _ in text:gmatch('\\n') do
    stats.newlines = stats.newlines + 1
  end

  for _ in text:gmatch('\\t') do
    stats.tabs = stats.tabs + 1
  end

  for _ in text:gmatch('\\"') do
    stats.quotes = stats.quotes + 1
  end

  for _ in text:gmatch('\\u%d%d%d%d') do
    stats.unicode_escapes = stats.unicode_escapes + 1
  end

  return stats
end

return M
