local load_addon_file = require("helpers.load_addon_file")

describe("HotkeyText.shorten", function()
  local shorten

  before_each(function()
    shorten = load_addon_file("Logic/HotkeyText.lua").HotkeyText.shorten
  end)

  it("shortens mouse buttons", function()
    assert.equal("M5", shorten("Mouse Button 5"))
    assert.equal("M4", shorten("Mouse Button 4"))
    assert.equal("M3", shorten("Middle Mouse"))
  end)

  it("keeps modifiers", function()
    assert.equal("s-M4", shorten("s-Mouse Button 4"))
  end)

  it("leaves other keys and missing text alone", function()
    assert.equal("Q", shorten("Q"))
    assert.is_nil(shorten(nil))
  end)
end)
