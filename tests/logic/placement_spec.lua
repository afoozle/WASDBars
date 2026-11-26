local load_addon_file = require("helpers.load_addon_file")

describe("Placement", function()
  local Placement
  local DEFAULT = { point = "BOTTOM", x = -250, y = 150 }

  local function forLayout(layouts, name)
    return { Placement.forLayout(layouts, name, DEFAULT, 1.0) }
  end

  before_each(function()
    Placement = load_addon_file("Logic/Placement.lua").Placement
  end)

  describe("clampScale", function()
    it("keeps values in range", function()
      assert.equal(1.25, Placement.clampScale(1.25))
      assert.equal(0.5, Placement.clampScale(0.5))
      assert.equal(2.0, Placement.clampScale(2.0))
    end)

    it("limits values below 0.5 and above 2.0", function()
      assert.equal(0.5, Placement.clampScale(0.1))
      assert.equal(2.0, Placement.clampScale(5))
    end)

    it("returns nil for non-numbers", function()
      assert.is_nil(Placement.clampScale("big"))
      assert.is_nil(Placement.clampScale(nil))
      assert.is_nil(Placement.clampScale(0 / 0))
    end)
  end)

  describe("forLayout", function()
    it("uses the saved values for the layout", function()
      local layouts = { UI = { point = "TOPLEFT", x = 10, y = -20, scale = 1.5 } }
      assert.same({ "TOPLEFT", 10, -20, 1.5 }, forLayout(layouts, "UI"))
    end)

    it("uses the defaults for a layout with nothing saved", function()
      local layouts = { UI = { point = "TOPLEFT", x = 10, y = -20, scale = 1.5 } }
      assert.same({ "BOTTOM", -250, 150, 1.0 }, forLayout(layouts, "Raid"))
      assert.same({ "BOTTOM", -250, 150, 1.0 }, forLayout(layouts, nil))
      assert.same({ "BOTTOM", -250, 150, 1.0 }, forLayout(nil, "UI"))
    end)

    it("falls back to the default position when the saved one is damaged", function()
      assert.same(
        { "BOTTOM", -250, 150, 1.2 },
        forLayout({ UI = { point = "MIDDLE", x = 1, y = 2, scale = 1.2 } }, "UI")
      )
      assert.same({ "BOTTOM", -250, 150, 1.0 }, forLayout({ UI = { point = "TOP", x = "1", y = 2 } }, "UI"))
      assert.same({ "BOTTOM", -250, 150, 1.0 }, forLayout({ UI = "nonsense" }, "UI"))
    end)

    it("keeps a saved position when only the scale is damaged", function()
      assert.same({ "TOP", 1, 2, 1.0 }, forLayout({ UI = { point = "TOP", x = 1, y = 2, scale = "big" } }, "UI"))
    end)

    it("clamps a saved scale", function()
      assert.same({ "TOP", 1, 2, 2.0 }, forLayout({ UI = { point = "TOP", x = 1, y = 2, scale = 9 } }, "UI"))
    end)
  end)

  describe("save", function()
    it("creates the layout's entry", function()
      local layouts = {}
      Placement.save(layouts, "UI", { point = "TOP", x = 1, y = 2 })
      assert.same({ UI = { point = "TOP", x = 1, y = 2 } }, layouts)
    end)

    it("merges into an existing entry", function()
      local layouts = { UI = { point = "TOP", x = 1, y = 2 } }
      Placement.save(layouts, "UI", { scale = 1.5 })
      assert.same({ UI = { point = "TOP", x = 1, y = 2, scale = 1.5 } }, layouts)
    end)

    it("replaces a damaged entry", function()
      local layouts = { UI = "nonsense" }
      Placement.save(layouts, "UI", { scale = 1.5 })
      assert.same({ UI = { scale = 1.5 } }, layouts)
    end)
  end)
end)
