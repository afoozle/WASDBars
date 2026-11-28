local load_addon_file = require("helpers.load_addon_file")

describe("ClusterPositions", function()
  local ClusterPositions

  local function findClusterPosition(savedPositions, layoutName)
    local clusterPosition = ClusterPositions.findClusterPosition(savedPositions, layoutName)
    return { clusterPosition.point, clusterPosition.x, clusterPosition.y, clusterPosition.scale }
  end

  before_each(function()
    local ns = { ClusterKeys = { defaultPosition = { point = "BOTTOM", x = -250, y = 150 }, defaultScale = 1.0 } }
    ClusterPositions = load_addon_file("ActionBarCluster/ClusterPositions.lua", ns).ClusterPositions
  end)

  it("uses the saved values for the layout, or the defaults", function()
    local savedPositions = { UI = { point = "TOPLEFT", x = 10, y = -20, scale = 1.5 } }
    assert.same({ "TOPLEFT", 10, -20, 1.5 }, findClusterPosition(savedPositions, "UI"))
    assert.same({ "BOTTOM", -250, 150, 1.0 }, findClusterPosition(savedPositions, "Raid"))
  end)

  it("uses the default position when only the scale is saved, and the reverse", function()
    assert.same({ "BOTTOM", -250, 150, 1.5 }, findClusterPosition({ UI = { scale = 1.5 } }, "UI"))
    assert.same({ "TOP", 1, 2, 1.0 }, findClusterPosition({ UI = { point = "TOP", x = 1, y = 2 } }, "UI"))
  end)

  it("saves the position and the scale into one entry", function()
    local savedPositions = {}
    ClusterPositions.saveClusterScale(savedPositions, "UI", 1.5)
    ClusterPositions.saveClusterPosition(savedPositions, "UI", "TOP", 1, 2)
    assert.same({ UI = { point = "TOP", x = 1, y = 2, scale = 1.5 } }, savedPositions)
  end)
end)
