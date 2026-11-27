local load_addon_file = require("helpers.load_addon_file")

describe("RestoreSteps", function()
  local RestoreSteps
  local PRESET, ACCOUNT = 0, 1
  local allLayouts = {
    layouts = {
      { layoutName = "Modern", layoutType = PRESET },
      { layoutName = "Classic", layoutType = PRESET },
      { layoutName = "UI", layoutType = ACCOUNT },
    },
  }

  before_each(function()
    local ns = {}
    load_addon_file("EditModeLayouts/LayoutList.lua", ns)
    RestoreSteps = load_addon_file("Setup/RestoreSteps.lua", ns).RestoreSteps
  end)

  it("goes back to the saved layout", function()
    assert.same({ "UI", false }, { RestoreSteps.findLayoutToRestore(allLayouts, { layout = "UI" }, PRESET) })
  end)

  it("falls back to the first preset when the saved layout is gone", function()
    assert.same({ "Modern", true }, { RestoreSteps.findLayoutToRestore(allLayouts, { layout = "Raid" }, PRESET) })
  end)

  it("says where it switches and whether action bar 2 goes off", function()
    assert.same({ "Switch back to 'UI'" }, RestoreSteps.describeRestore("UI", false, { layout = "UI", bar2 = true }))
    assert.same(
      { "Switch to Modern ('Raid' no longer exists)", "Turn Action Bar 2 off" },
      RestoreSteps.describeRestore("Modern", true, { layout = "Raid", bar2 = false })
    )
  end)
end)
