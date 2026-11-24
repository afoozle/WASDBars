local load_addon_file = require("helpers.load_addon_file")
local stubs = require("helpers.wow_stubs")

describe("Restore", function()
  local Restore
  local PRESET, ACCOUNT = 0, 1
  local groups = {
    { binds = { { key = "Q", command = "ACTIONBUTTON1" }, { key = "T", command = "ACTIONBUTTON4" } } },
    { binds = { { key = "1", command = "MULTIACTIONBAR1BUTTON1" } } },
  }

  before_each(function()
    Restore = load_addon_file("Logic/Restore.lua").Restore
  end)

  it("copies what each key is bound to, false when unbound", function()
    local b = stubs.bindings({ Q = "STRAFELEFT", ["1"] = "ACTIONBUTTON1" })
    assert.same({ Q = "STRAFELEFT", T = false, ["1"] = "ACTIONBUTTON1" }, Restore.keyCopy(groups, b.GetBindingAction))
  end)

  it("lists the keys to put back, sorted, unbound ones with no command", function()
    assert.same(
      { { key = "1", command = "ACTIONBUTTON1" }, { key = "Q", command = "STRAFELEFT" }, { key = "T" } },
      Restore.keyChanges({ Q = "STRAFELEFT", T = false, ["1"] = "ACTIONBUTTON1" })
    )
  end)

  describe("target", function()
    local data = {
      layouts = {
        { layoutName = "Modern", layoutType = PRESET },
        { layoutName = "Classic", layoutType = PRESET },
        { layoutName = "UI", layoutType = ACCOUNT },
      },
    }

    it("goes back to the saved layout", function()
      assert.same({ "UI", false }, { Restore.target(data, "UI", PRESET) })
    end)

    it("falls back to the first preset when the saved layout is gone", function()
      assert.same({ "Modern", true }, { Restore.target(data, "Raid", PRESET) })
    end)
  end)

  describe("lines", function()
    it("says where it switches and whether action bar 2 goes off", function()
      assert.same({ "Switch back to 'UI'" }, Restore.lines("UI", false, "UI", true))
      assert.same(
        { "Switch to Modern ('Raid' no longer exists)", "Turn Action Bar 2 off" },
        Restore.lines("Modern", true, "Raid", false)
      )
    end)
  end)
end)
