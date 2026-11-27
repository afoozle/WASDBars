local load_addon_file = require("helpers.load_addon_file")

describe("HotkeyText.shortenMouseButtonNames", function()
  local shortenMouseButtonNames

  before_each(function()
    shortenMouseButtonNames = load_addon_file("ActionBarCluster/HotkeyText.lua").HotkeyText.shortenMouseButtonNames
  end)

  it("shortens mouse buttons", function()
    assert.equal("M5", shortenMouseButtonNames("Mouse Button 5"))
    assert.equal("M4", shortenMouseButtonNames("Mouse Button 4"))
    assert.equal("M3", shortenMouseButtonNames("Middle Mouse"))
  end)

  it("keeps modifiers", function()
    assert.equal("s-M4", shortenMouseButtonNames("s-Mouse Button 4"))
  end)

  it("leaves other keys and missing text alone", function()
    assert.equal("Q", shortenMouseButtonNames("Q"))
    assert.is_nil(shortenMouseButtonNames(nil))
  end)
end)
