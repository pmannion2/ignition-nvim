-- Tests for Ignition component tree view
-- Run with: nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedFile tests/component_tree_spec.lua"

local component_tree = require('ignition.component_tree')
local eq = assert.are.equal

-- Helper: read fixture file
local function read_fixture(name)
  local path = 'tests/fixtures/' .. name
  local f = io.open(path, 'r')
  if not f then
    error('Fixture not found: ' .. path)
  end
  local content = f:read('*a')
  f:close()
  return content
end

describe('is_perspective_view', function()
  it('returns true for a Perspective view with ia.* root type', function()
    local data = { root = { type = 'ia.container.flex', meta = { name = 'root' } } }
    assert.is_true(component_tree.is_perspective_view(data))
  end)

  it('returns false when root type does not start with ia.', function()
    local data = { root = { type = 'custom.component', meta = { name = 'root' } } }
    assert.is_false(component_tree.is_perspective_view(data))
  end)

  it('returns false when root is missing', function()
    local data = { custom = {} }
    assert.is_false(component_tree.is_perspective_view(data))
  end)

  it('returns false for nil input', function()
    assert.is_false(component_tree.is_perspective_view(nil))
  end)

  it('returns false when root.type is missing', function()
    local data = { root = { meta = { name = 'root' } } }
    assert.is_false(component_tree.is_perspective_view(data))
  end)
end)

describe('build_node', function()
  it('extracts name and type from a component', function()
    local comp = {
      type = 'ia.input.button',
      meta = { name = 'MyButton' },
    }
    local node = component_tree.build_node(comp, 0)
    eq('MyButton', node.name)
    eq('ia.input.button', node.type)
    eq('input.button', node.short_type)
    eq(0, node.depth)
  end)

  it('uses (unnamed) when meta.name is missing', function()
    local comp = { type = 'ia.display.label' }
    local node = component_tree.build_node(comp, 1)
    eq('(unnamed)', node.name)
    eq(1, node.depth)
  end)

  it('handles empty meta table', function()
    local comp = { type = 'ia.container.flex', meta = {} }
    local node = component_tree.build_node(comp, 2)
    eq('(unnamed)', node.name)
  end)

  it('handles non-ia type prefix', function()
    local comp = { type = 'custom.widget', meta = { name = 'Test' } }
    local node = component_tree.build_node(comp, 0)
    eq('custom.widget', node.short_type)
  end)

  it('handles missing type', function()
    local comp = { meta = { name = 'NoType' } }
    local node = component_tree.build_node(comp, 0)
    eq('', node.type)
    eq('', node.short_type)
  end)
end)

describe('detect_scripts', function()
  it('returns true when component has script in events', function()
    local comp = {
      events = {
        onActionPerformed = { script = 'print("hello")' },
      },
    }
    assert.is_true(component_tree.detect_scripts(comp))
  end)

  it('returns true for top-level script key in events', function()
    local comp = {
      events = {
        script = 'print("top level")',
      },
    }
    assert.is_true(component_tree.detect_scripts(comp))
  end)

  it('returns false when events is empty', function()
    local comp = { events = {} }
    assert.is_false(component_tree.detect_scripts(comp))
  end)

  it('returns false when no events table', function()
    local comp = { meta = { name = 'test' } }
    assert.is_false(component_tree.detect_scripts(comp))
  end)

  it('returns false when events has no script keys', function()
    local comp = {
      events = {
        someCustomEvent = { handler = 'doStuff()' },
      },
    }
    assert.is_false(component_tree.detect_scripts(comp))
  end)

  it('detects onChange script', function()
    local comp = {
      events = {
        onChange = { script = 'system.tag.writeBlocking(...)' },
      },
    }
    assert.is_true(component_tree.detect_scripts(comp))
  end)
end)

describe('parse_view_json', function()
  it('parses the nested fixture into a correct tree', function()
    local json_str = read_fixture('perspective-view-nested.json')
    local root, err = component_tree.parse_view_json(json_str)
    assert.is_nil(err)
    assert.is_not_nil(root)

    -- Root node
    eq('root', root.name)
    eq('ia.container.flex', root.type)
    eq(0, root.depth)
    assert.is_true(root.has_scripts) -- has onStartup

    -- Root has 3 children: Header, ContentArea, Footer
    eq(3, #root.children)
    eq('Header', root.children[1].name)
    eq('ContentArea', root.children[2].name)
    eq('Footer', root.children[3].name)
  end)

  it('captures correct depth for nested components', function()
    local json_str = read_fixture('perspective-view-nested.json')
    local root = component_tree.parse_view_json(json_str)

    -- Header (depth 1) > NavButton (depth 2)
    local header = root.children[1]
    eq(1, header.depth)
    eq(2, #header.children) -- Label_Header, NavButton
    eq(2, header.children[2].depth)
    eq('NavButton', header.children[2].name)
  end)

  it('detects scripts on the right components', function()
    local json_str = read_fixture('perspective-view-nested.json')
    local root = component_tree.parse_view_json(json_str)

    -- root has scripts (onStartup)
    assert.is_true(root.has_scripts)

    -- Header container has no scripts
    assert.is_false(root.children[1].has_scripts)

    -- NavButton has scripts (onActionPerformed)
    assert.is_true(root.children[1].children[2].has_scripts)

    -- Footer has no scripts
    assert.is_false(root.children[3].has_scripts)

    -- SetpointSlider has scripts (onChange)
    local content = root.children[2]
    assert.is_true(content.children[2].has_scripts)
    eq('SetpointSlider', content.children[2].name)
  end)

  it('finds deeply nested components', function()
    local json_str = read_fixture('perspective-view-nested.json')
    local root = component_tree.parse_view_json(json_str)

    -- ContentArea > TankGroup > TankLevel (depth 3)
    local tank_level = root.children[2].children[1].children[1]
    eq('TankLevel', tank_level.name)
    eq(3, tank_level.depth)
    eq('ia.display.cylindricaltank', tank_level.type)
  end)

  it('returns error for invalid JSON', function()
    local root, err = component_tree.parse_view_json('not json')
    assert.is_nil(root)
    assert.is_not_nil(err)
  end)

  it('returns error for non-Perspective JSON', function()
    local json_str = '{"type": "resource", "data": {}}'
    local root, err = component_tree.parse_view_json(json_str)
    assert.is_nil(root)
    eq('Not a Perspective view', err)
  end)
end)

describe('render_node_line', function()
  it('renders a root node with children and expand icon', function()
    local node = {
      name = 'root',
      short_type = 'container.flex',
      has_scripts = true,
      depth = 0,
      expanded = true,
      children = { {} },
    }
    local line = component_tree.render_node_line(node)
    eq('▾ root  ‹container.flex› [scripts]', line)
  end)

  it('renders a collapsed node with collapse icon', function()
    local node = {
      name = 'Header',
      short_type = 'container.flex',
      has_scripts = false,
      depth = 1,
      expanded = false,
      children = { {} },
    }
    local line = component_tree.render_node_line(node)
    eq('  ▸ Header  ‹container.flex›', line)
  end)

  it('renders a leaf node without expand/collapse icon', function()
    local node = {
      name = 'MyLabel',
      short_type = 'display.label',
      has_scripts = false,
      depth = 2,
      expanded = true,
      children = {},
    }
    local line = component_tree.render_node_line(node)
    eq('      MyLabel  ‹display.label›', line)
  end)

  it('shows [scripts] annotation for scripted components', function()
    local node = {
      name = 'Button',
      short_type = 'input.button',
      has_scripts = true,
      depth = 1,
      expanded = true,
      children = {},
    }
    local line = component_tree.render_node_line(node)
    assert.truthy(line:find('%[scripts%]'))
  end)

  it('indents correctly by depth', function()
    local node = {
      name = 'Deep',
      short_type = 'display.label',
      has_scripts = false,
      depth = 3,
      expanded = true,
      children = {},
    }
    local line = component_tree.render_node_line(node)
    -- depth 3 = 6 spaces indent + 2 spaces (leaf icon) = starts at position 9
    assert.truthy(line:match('^      '))
  end)
end)

describe('flatten', function()
  it('flattens an expanded tree in depth-first order', function()
    local root = {
      name = 'root', depth = 0, expanded = true,
      children = {
        {
          name = 'A', depth = 1, expanded = true,
          children = {
            { name = 'A1', depth = 2, expanded = true, children = {} },
          },
        },
        { name = 'B', depth = 1, expanded = true, children = {} },
      },
    }
    local flat = component_tree.flatten(root)
    eq(4, #flat)
    eq('root', flat[1].name)
    eq('A', flat[2].name)
    eq('A1', flat[3].name)
    eq('B', flat[4].name)
  end)

  it('hides children of collapsed nodes', function()
    local root = {
      name = 'root', depth = 0, expanded = true,
      children = {
        {
          name = 'A', depth = 1, expanded = false,
          children = {
            { name = 'A1', depth = 2, expanded = true, children = {} },
          },
        },
        { name = 'B', depth = 1, expanded = true, children = {} },
      },
    }
    local flat = component_tree.flatten(root)
    eq(3, #flat) -- root, A (collapsed), B — A1 hidden
    eq('root', flat[1].name)
    eq('A', flat[2].name)
    eq('B', flat[3].name)
  end)
end)
