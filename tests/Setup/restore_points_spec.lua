local load_addon_file = require("helpers.load_addon_file")

describe("RestorePoints", function()
  local RestorePoints

  before_each(function()
    RestorePoints = load_addon_file("Setup/RestorePoints.lua").RestorePoints
  end)

  it("saves only the first restore point per character", function()
    local savedRestorePoints = {}
    RestorePoints.saveRestorePointOnce(savedRestorePoints, "Player-1", "UI", false)
    RestorePoints.saveRestorePointOnce(savedRestorePoints, "Player-1", "WASDBars", true)
    RestorePoints.saveRestorePointOnce(savedRestorePoints, "Player-2", "Modern", true)
    assert.same({ layout = "UI", bar2 = false }, RestorePoints.findRestorePoint(savedRestorePoints, "Player-1"))
    assert.same({ layout = "Modern", bar2 = true }, RestorePoints.findRestorePoint(savedRestorePoints, "Player-2"))
  end)

  it("forgets one character's restore point", function()
    local savedRestorePoints = { ["Player-1"] = { layout = "UI", bar2 = false } }
    RestorePoints.forgetRestorePoint(savedRestorePoints, "Player-1")
    assert.is_nil(RestorePoints.findRestorePoint(savedRestorePoints, "Player-1"))
  end)
end)
