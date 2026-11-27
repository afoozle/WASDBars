local load_addon_file = require("helpers.load_addon_file")

describe("ClusterPositions", function()
  local ClusterPositions
  local DEFAULT_POSITION = { point = "BOTTOM", x = -250, y = 150 }

  local function findClusterPosition(savedPositions, layoutName)
    local clusterPosition = ClusterPositions.findClusterPosition(savedPositions, layoutName, DEFAULT_POSITION, 1.0)
    return { clusterPosition.point, clusterPosition.x, clusterPosition.y, clusterPosition.scale }
  end

  before_each(function()
    ClusterPositions = load_addon_file("ActionBarCluster/ClusterPositions.lua").ClusterPositions
  end)

  describe("limitScale", function()
    it("keeps values in range", function()
      assert.equal(1.25, ClusterPositions.limitScale(1.25))
      assert.equal(0.5, ClusterPositions.limitScale(0.5))
      assert.equal(2.0, ClusterPositions.limitScale(2.0))
    end)

    it("limits values below 0.5 and above 2.0", function()
      assert.equal(0.5, ClusterPositions.limitScale(0.1))
      assert.equal(2.0, ClusterPositions.limitScale(5))
    end)

    it("returns nil for non-numbers", function()
      assert.is_nil(ClusterPositions.limitScale("big"))
      assert.is_nil(ClusterPositions.limitScale(nil))
      assert.is_nil(ClusterPositions.limitScale(0 / 0))
    end)
  end)

  describe("findClusterPosition", function()
    it("uses the saved values for the layout", function()
      local savedPositions = { UI = { point = "TOPLEFT", x = 10, y = -20, scale = 1.5 } }
      assert.same({ "TOPLEFT", 10, -20, 1.5 }, findClusterPosition(savedPositions, "UI"))
    end)

    it("uses the defaults for a layout with nothing saved", function()
      local savedPositions = { UI = { point = "TOPLEFT", x = 10, y = -20, scale = 1.5 } }
      assert.same({ "BOTTOM", -250, 150, 1.0 }, findClusterPosition(savedPositions, "Raid"))
      assert.same({ "BOTTOM", -250, 150, 1.0 }, findClusterPosition(savedPositions, nil))
      assert.same({ "BOTTOM", -250, 150, 1.0 }, findClusterPosition(nil, "UI"))
    end)

    it("falls back to the default position when the saved one is damaged", function()
      assert.same(
        { "BOTTOM", -250, 150, 1.2 },
        findClusterPosition({ UI = { point = "MIDDLE", x = 1, y = 2, scale = 1.2 } }, "UI")
      )
      assert.same({ "BOTTOM", -250, 150, 1.0 }, findClusterPosition({ UI = { point = "TOP", x = "1", y = 2 } }, "UI"))
      assert.same({ "BOTTOM", -250, 150, 1.0 }, findClusterPosition({ UI = "nonsense" }, "UI"))
    end)

    it("keeps a saved position when only the scale is damaged", function()
      assert.same(
        { "TOP", 1, 2, 1.0 },
        findClusterPosition({ UI = { point = "TOP", x = 1, y = 2, scale = "big" } }, "UI")
      )
    end)

    it("limits a saved scale", function()
      assert.same({ "TOP", 1, 2, 2.0 }, findClusterPosition({ UI = { point = "TOP", x = 1, y = 2, scale = 9 } }, "UI"))
    end)
  end)

  describe("saving", function()
    it("creates the layout's entry", function()
      local savedPositions = {}
      ClusterPositions.saveClusterPosition(savedPositions, "UI", "TOP", 1, 2)
      assert.same({ UI = { point = "TOP", x = 1, y = 2 } }, savedPositions)
    end)

    it("adds a limited scale to an existing entry", function()
      local savedPositions = { UI = { point = "TOP", x = 1, y = 2 } }
      ClusterPositions.saveClusterScale(savedPositions, "UI", 9)
      assert.same({ UI = { point = "TOP", x = 1, y = 2, scale = 2.0 } }, savedPositions)
    end)

    it("replaces a damaged entry", function()
      local savedPositions = { UI = "nonsense" }
      ClusterPositions.saveClusterScale(savedPositions, "UI", 1.5)
      assert.same({ UI = { scale = 1.5 } }, savedPositions)
    end)
  end)
end)
