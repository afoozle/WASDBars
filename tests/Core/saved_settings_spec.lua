local load_addon_file = require("helpers.load_addon_file")

describe("SavedSettings", function()
  local SavedSettings

  before_each(function()
    SavedSettings = load_addon_file("Core/SavedSettings.lua").SavedSettings
  end)

  describe("fillMissingSettings", function()
    before_each(function()
      SavedSettings.DEFAULTS = { scale = 1, locked = false, layouts = {} }
    end)

    it("fills missing keys, keeping saved values and keys with no default", function()
      local savedSettings = SavedSettings.fillMissingSettings({ scale = 1.3, old = "x" })
      assert.same({ scale = 1.3, locked = false, layouts = {}, old = "x" }, savedSettings)
    end)

    it("gives each table default a new table", function()
      SavedSettings.fillMissingSettings({}).layouts.UI = {}
      assert.same({}, SavedSettings.DEFAULTS.layouts)
    end)

    it("returns the same saved table it was given, or a new one for nil", function()
      local savedSettings = {}
      assert.equal(savedSettings, SavedSettings.fillMissingSettings(savedSettings))
      assert.equal(1, SavedSettings.fillMissingSettings(nil).scale)
    end)
  end)

  it("moves v1.1.0's single key copy to the account's", function()
    local savedSettings = { keyCopy = { Q = "STRAFELEFT" }, keyCopies = {} }
    SavedSettings.moveV110KeybindCopyToAccount(savedSettings)
    assert.same({ account = { Q = "STRAFELEFT" } }, savedSettings.keyCopies)
    assert.is_nil(savedSettings.keyCopy)
  end)
end)
