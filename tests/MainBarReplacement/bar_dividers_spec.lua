local load_addon_file = require("helpers.load_addon_file")

describe("BarDividers.findButtonsNeedingDivider", function()
  local findButtonsNeedingDivider

  before_each(function()
    findButtonsNeedingDivider =
      load_addon_file("MainBarReplacement/BarDividers.lua").BarDividers.findButtonsNeedingDivider
  end)

  it("puts one before every shown button that follows a shown button", function()
    assert.same({ 2, 3, 4 }, findButtonsNeedingDivider({ true, true, true, true }, 1, 2, 2))
  end)

  it("skips gaps left by hidden buttons", function()
    assert.same({ 2, 5 }, findButtonsNeedingDivider({ true, true, false, true, true }, 1, 2, 2))
  end)

  it("draws none on more than one row", function()
    assert.same({}, findButtonsNeedingDivider({ true, true }, 2, 2, 2))
  end)

  it("draws none with padding above the minimum", function()
    assert.same({}, findButtonsNeedingDivider({ true, true }, 1, 3, 2))
  end)
end)
