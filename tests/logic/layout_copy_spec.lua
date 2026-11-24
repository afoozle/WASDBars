local load_addon_file = require("helpers.load_addon_file")

describe("LayoutCopy", function()
  local LayoutCopy
  local PRESET, ACCOUNT, CHARACTER = 0, 1, 2

  local function presets()
    return {
      {
        layoutName = "Modern",
        layoutType = PRESET,
        systems = { { system = 0, settings = { { setting = 2, value = 12 } } } },
      },
      { layoutName = "Classic", layoutType = PRESET, systems = {} },
    }
  end

  local function names(data)
    local result = {}
    for i, layout in ipairs(data.layouts) do
      result[i] = layout.layoutName
    end
    return result
  end

  before_each(function()
    LayoutCopy = load_addon_file("Logic/LayoutCopy.lua").LayoutCopy
  end)

  it("puts the presets first, keeping the active index", function()
    local data =
      LayoutCopy.combine(presets(), { layouts = { { layoutName = "UI", layoutType = ACCOUNT } }, activeLayout = 3 })
    assert.same({ "Modern", "Classic", "UI" }, names(data))
    assert.equal("UI", data.layouts[data.activeLayout].layoutName)
  end)

  it("finds and counts layouts", function()
    local data =
      LayoutCopy.combine(presets(), { layouts = { { layoutName = "UI", layoutType = ACCOUNT } }, activeLayout = 1 })
    assert.equal(3, LayoutCopy.find(data, "UI"))
    assert.is_nil(LayoutCopy.find(data, "WASDBars"))
    assert.equal(2, LayoutCopy.count(data, PRESET))
  end)

  it("copies a preset after the presets and makes it active", function()
    local data = LayoutCopy.combine(presets(), { layouts = {}, activeLayout = 1 })
    local index = LayoutCopy.add(data, "WASDBars", ACCOUNT, PRESET)
    assert.equal(3, index)
    assert.equal(3, data.activeLayout)
    local copy = data.layouts[3]
    assert.same({ "WASDBars", ACCOUNT }, { copy.layoutName, copy.layoutType })
    assert.equal(12, copy.systems[1].settings[1].value)
  end)

  it("leaves the source unchanged", function()
    local data = LayoutCopy.combine(presets(), { layouts = {}, activeLayout = 1 })
    LayoutCopy.add(data, "WASDBars", ACCOUNT, PRESET)
    data.layouts[3].systems[1].settings[1].value = 6
    assert.same({ "Modern", PRESET }, { data.layouts[1].layoutName, data.layouts[1].layoutType })
    assert.equal(12, data.layouts[1].systems[1].settings[1].value)
  end)

  it("copies the player's own layout, after the last account layout and before character ones", function()
    local saved = {
      layouts = {
        { layoutName = "UI", layoutType = ACCOUNT, systems = {} },
        { layoutName = "Raid", layoutType = CHARACTER, systems = {} },
      },
      activeLayout = 4,
    }
    local data = LayoutCopy.combine(presets(), saved)
    LayoutCopy.add(data, "WASDBars", ACCOUNT, PRESET)
    assert.same({ "Modern", "Classic", "UI", "WASDBars", "Raid" }, names(data))
    assert.equal(4, data.activeLayout)
  end)
end)
