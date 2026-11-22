local load_addon_file = require("helpers.load_addon_file")

describe("Data/BindingGroups", function()
  local groups

  local function commands(group)
    local found = {}
    for _, bind in ipairs(group.binds) do
      table.insert(found, bind.command)
    end
    return found
  end

  local function numbered(prefix, count)
    local list = {}
    for i = 1, count do
      list[i] = prefix .. i
    end
    return list
  end

  before_each(function()
    groups = load_addon_file("Data/BindingGroups.lua").BindingGroups
  end)

  it("never uses a key twice across both groups", function()
    local seen = {}
    for _, group in ipairs(groups) do
      for _, bind in ipairs(group.binds) do
        assert.is_nil(seen[bind.key], bind.key .. " used twice")
        seen[bind.key] = true
      end
    end
  end)

  it("binds Q E R T F G Z X C V and the mouse side buttons to action buttons 1-12", function()
    assert.equal("wasd", groups[1].id)
    assert.same(numbered("ACTIONBUTTON", 12), commands(groups[1]))
    local keys = {}
    for _, bind in ipairs(groups[1].binds) do
      table.insert(keys, bind.key)
    end
    assert.same({ "Q", "E", "R", "T", "F", "G", "Z", "X", "C", "V", "BUTTON5", "BUTTON4" }, keys)
  end)

  it("binds 1-0, - and = to action bar 2's buttons 1-12", function()
    assert.equal("numbers", groups[2].id)
    assert.same(numbered("MULTIACTIONBAR1BUTTON", 12), commands(groups[2]))
    assert.equal("0", groups[2].binds[10].key)
    assert.equal("=", groups[2].binds[12].key)
  end)
end)
