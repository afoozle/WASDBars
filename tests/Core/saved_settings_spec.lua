local load_addon_file = require("helpers.load_addon_file")

describe("SavedSettings", function()
  local SavedSettings

  before_each(function()
    SavedSettings = load_addon_file("Core/SavedSettings.lua").SavedSettings
  end)

  describe("fillMissingSettings", function()
    before_each(function()
      SavedSettings.DEFAULTS = { scale = 1, locked = false, position = { x = 0, y = 100, point = "BOTTOM" } }
    end)

    it("fills missing keys from the defaults", function()
      assert.same(
        { scale = 1, locked = false, position = { x = 0, y = 100, point = "BOTTOM" } },
        SavedSettings.fillMissingSettings({})
      )
    end)

    it("keeps saved values and saved keys that have no default", function()
      local savedSettings = SavedSettings.fillMissingSettings({ scale = 1.3, old = "x" })
      assert.equal(1.3, savedSettings.scale)
      assert.equal("x", savedSettings.old)
    end)

    it("fills nested tables", function()
      local savedSettings = SavedSettings.fillMissingSettings({ position = { x = 25 } })
      assert.same({ x = 25, y = 100, point = "BOTTOM" }, savedSettings.position)
    end)

    it("copies default tables instead of sharing them", function()
      local savedSettings = SavedSettings.fillMissingSettings({})
      savedSettings.position.x = 50
      assert.equal(0, SavedSettings.DEFAULTS.position.x)
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

  it("creates the recordings list", function()
    assert.same({ sessions = {} }, SavedSettings.createRecordingsList(nil))
    local savedRecordings = { sessions = { { label = "idle" } } }
    assert.equal(savedRecordings, SavedSettings.createRecordingsList(savedRecordings))
    assert.equal("idle", savedRecordings.sessions[1].label)
  end)

  it("needs no WoW globals to load", function()
    assert.is_nil(_G.CreateFrame)
  end)
end)
