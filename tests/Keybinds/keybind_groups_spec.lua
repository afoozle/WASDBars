local load_addon_file = require("helpers.load_addon_file")

describe("KeybindGroups", function()
  local keybindGroups

  local function listField(group, fieldName)
    local values = {}
    for _, keybind in ipairs(group.keybinds) do
      table.insert(values, keybind[fieldName])
    end
    return values
  end

  local function numbered(prefix, count)
    local names = {}
    for i = 1, count do
      names[i] = prefix .. i
    end
    return names
  end

  before_each(function()
    keybindGroups = load_addon_file("Keybinds/KeybindGroups.lua").KeybindGroups
  end)

  it("never uses a key twice across both groups", function()
    local seen = {}
    for _, group in ipairs(keybindGroups) do
      for _, keybind in ipairs(group.keybinds) do
        assert.is_nil(seen[keybind.key], keybind.key .. " used twice")
        seen[keybind.key] = true
      end
    end
  end)

  it("binds Q E R T F G Z X C V and the mouse side buttons to action buttons 1-12", function()
    assert.equal("WASD keys", keybindGroups[1].name)
    assert.same(numbered("ACTIONBUTTON", 12), listField(keybindGroups[1], "action"))
  end)

  it("binds 1-0, - and = to action bar 2's buttons 1-12", function()
    assert.equal("number row", keybindGroups[2].name)
    assert.same(numbered("MULTIACTIONBAR1BUTTON", 12), listField(keybindGroups[2], "action"))
  end)
end)
