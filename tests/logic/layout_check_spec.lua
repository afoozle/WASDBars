local load_addon_file = require("helpers.load_addon_file")

describe("LayoutCheck", function()
  local LayoutCheck
  local good = {
    numIcons = 12,
    alwaysShowButtons = true,
    hideBarArt = true,
    hideBarScrolling = true,
    bar2Shown = true,
    bar1OverlapsBar2 = false,
  }

  local function with(changes)
    local readings = {}
    for k, v in pairs(good) do
      readings[k] = v
    end
    for k, v in pairs(changes) do
      readings[k] = v
    end
    return readings
  end

  before_each(function()
    LayoutCheck = load_addon_file("Logic/LayoutCheck.lua").LayoutCheck
  end)

  it("finds nothing to fix in a good layout", function()
    assert.same({}, LayoutCheck.problems(good))
  end)

  it("lists a fix for each setting that is off", function()
    local fixes = LayoutCheck.problems(with({ numIcons = 8, hideBarArt = false, bar1OverlapsBar2 = true }))
    assert.equal(3, #fixes)
    assert.matches("# of Icons to 12", fixes[1])
    assert.matches("Hide Bar Art", fixes[2])
    assert.matches("drag it away", fixes[3])
  end)

  it("reminds the player to turn on action bar 2", function()
    assert.same({ "Action Bar 2: turn it on." }, LayoutCheck.problems(with({ bar2Shown = false })))
  end)

  it("skips checks the game couldn't answer", function()
    assert.same({}, LayoutCheck.problems({}))
  end)

  describe("overlaps", function()
    it("detects overlapping rects", function()
      assert.is_true(LayoutCheck.overlaps({ 0, 0, 10, 10 }, { 5, 5, 10, 10 }))
    end)

    it("doesn't count separate or touching rects", function()
      assert.is_false(LayoutCheck.overlaps({ 0, 0, 10, 10 }, { 20, 0, 10, 10 }))
      assert.is_false(LayoutCheck.overlaps({ 0, 0, 10, 10 }, { 10, 0, 10, 10 }))
    end)
  end)

  describe("statusLine", function()
    it("says OK or how many things to fix", function()
      assert.equal("Action bar layout: OK", LayoutCheck.statusLine({}))
      assert.equal("Action bar layout: 1 thing to fix (/wasd setup layout)", LayoutCheck.statusLine({ "a" }))
      assert.equal("Action bar layout: 2 things to fix (/wasd setup layout)", LayoutCheck.statusLine({ "a", "b" }))
    end)
  end)
end)
