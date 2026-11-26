local load_addon_file = require("helpers.load_addon_file")

describe("Dividers.between", function()
  local Dividers

  before_each(function()
    Dividers = load_addon_file("Logic/Dividers.lua").Dividers
  end)

  it("puts one before every shown button that follows a shown button", function()
    assert.same({ 2, 3, 4 }, Dividers.between({ true, true, true, true }, 1, 2, 2, false))
  end)

  it("skips gaps left by hidden buttons", function()
    assert.same({ 2, 5 }, Dividers.between({ true, true, false, true, true }, 1, 2, 2, false))
  end)

  it("draws none with the art hidden", function()
    assert.same({}, Dividers.between({ true, true }, 1, 2, 2, true))
  end)

  it("draws none on more than one row", function()
    assert.same({}, Dividers.between({ true, true }, 2, 2, 2, false))
  end)

  it("draws none with padding above the minimum", function()
    assert.same({}, Dividers.between({ true, true }, 1, 3, 2, false))
  end)
end)
