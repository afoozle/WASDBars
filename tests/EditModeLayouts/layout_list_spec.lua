local load_addon_file = require("helpers.load_addon_file")

describe("LayoutList", function()
  local LayoutList
  local PRESET, ACCOUNT, CHARACTER = 0, 1, 2

  local function presetLayouts()
    return {
      {
        layoutName = "Modern",
        layoutType = PRESET,
        systems = { { system = 0, settings = { { setting = 2, value = 12 } } } },
      },
      { layoutName = "Classic", layoutType = PRESET, systems = {} },
    }
  end

  local function listLayoutNames(allLayouts)
    local layoutNames = {}
    for i, layout in ipairs(allLayouts.layouts) do
      layoutNames[i] = layout.layoutName
    end
    return layoutNames
  end

  local function combineWithSaved(savedLayouts, activeLayout)
    return LayoutList.combinePresetAndSavedLayouts(
      presetLayouts(),
      { layouts = savedLayouts, activeLayout = activeLayout }
    )
  end

  before_each(function()
    LayoutList = load_addon_file("EditModeLayouts/LayoutList.lua").LayoutList
  end)

  it("puts the presets first, keeping the active index", function()
    local allLayouts = combineWithSaved({ { layoutName = "UI", layoutType = ACCOUNT } }, 3)
    assert.same({ "Modern", "Classic", "UI" }, listLayoutNames(allLayouts))
    assert.equal("UI", LayoutList.findActiveLayout(allLayouts).layoutName)
  end)

  it("finds layouts by name and the first preset", function()
    local allLayouts = combineWithSaved({ { layoutName = "UI", layoutType = ACCOUNT } }, 1)
    assert.equal(3, LayoutList.findLayoutIndex(allLayouts, "UI"))
    assert.is_nil(LayoutList.findLayoutIndex(allLayouts, "WASDBars"))
    assert.equal("Modern", LayoutList.findFirstPresetLayoutName(allLayouts, PRESET))
  end)

  it("has room until a layout type reaches the game's limit", function()
    local allLayouts = combineWithSaved({ { layoutName = "UI", layoutType = ACCOUNT } }, 1)
    assert.is_true(LayoutList.hasRoomForAnotherLayout(allLayouts, ACCOUNT, 2))
    assert.is_false(LayoutList.hasRoomForAnotherLayout(allLayouts, ACCOUNT, 1))
  end)

  it("makes a layout active by name", function()
    local allLayouts = combineWithSaved({ { layoutName = "UI", layoutType = ACCOUNT } }, 1)
    LayoutList.makeLayoutActive(allLayouts, "UI")
    assert.equal(3, allLayouts.activeLayout)
  end)

  it("copies a preset after the presets and makes it active", function()
    local allLayouts = combineWithSaved({}, 1)
    LayoutList.copyActiveLayout(allLayouts, "WASDBars", ACCOUNT, PRESET)
    assert.equal(3, allLayouts.activeLayout)
    local layoutCopy = allLayouts.layouts[3]
    assert.same({ "WASDBars", ACCOUNT }, { layoutCopy.layoutName, layoutCopy.layoutType })
    assert.equal(12, layoutCopy.systems[1].settings[1].value)
  end)

  it("leaves the source unchanged", function()
    local allLayouts = combineWithSaved({}, 1)
    LayoutList.copyActiveLayout(allLayouts, "WASDBars", ACCOUNT, PRESET)
    allLayouts.layouts[3].systems[1].settings[1].value = 6
    assert.same({ "Modern", PRESET }, { allLayouts.layouts[1].layoutName, allLayouts.layouts[1].layoutType })
    assert.equal(12, allLayouts.layouts[1].systems[1].settings[1].value)
  end)

  it("copies the player's own layout, after the last account layout and before character ones", function()
    local allLayouts = combineWithSaved({
      { layoutName = "UI", layoutType = ACCOUNT, systems = {} },
      { layoutName = "Raid", layoutType = CHARACTER, systems = {} },
    }, 4)
    LayoutList.copyActiveLayout(allLayouts, "WASDBars", ACCOUNT, PRESET)
    assert.same({ "Modern", "Classic", "UI", "WASDBars", "Raid" }, listLayoutNames(allLayouts))
    assert.equal(4, allLayouts.activeLayout)
  end)
end)
