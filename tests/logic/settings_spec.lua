local load_addon_file = require("helpers.load_addon_file")

describe("Settings.merge", function()
  local Settings

  before_each(function()
    Settings = load_addon_file("Logic/Settings.lua").Settings
  end)

  it("fills missing keys from the defaults", function()
    local saved = Settings.merge({}, { scale = 1, locked = false })
    assert.same({ scale = 1, locked = false }, saved)
  end)

  it("keeps saved values", function()
    local saved = Settings.merge({ scale = 1.3, locked = false }, { scale = 1, locked = true })
    assert.same({ scale = 1.3, locked = false }, saved)
  end)

  it("keeps saved keys that have no default", function()
    local saved = Settings.merge({ old = "x" }, { scale = 1 })
    assert.same({ old = "x", scale = 1 }, saved)
  end)

  it("merges nested tables", function()
    local defaults = { position = { x = 0, y = 100, point = "BOTTOM" } }
    local saved = Settings.merge({ position = { x = 25 } }, defaults)
    assert.same({ position = { x = 25, y = 100, point = "BOTTOM" } }, saved)
  end)

  it("copies default tables instead of sharing them", function()
    local defaults = { position = { x = 0 } }
    local saved = Settings.merge({}, defaults)
    saved.position.x = 50
    assert.equal(0, defaults.position.x)
  end)

  it("returns the same saved table it was given", function()
    local saved = {}
    assert.equal(saved, Settings.merge(saved, { scale = 1 }))
  end)

  it("handles a nil saved table", function()
    assert.same({ scale = 1 }, Settings.merge(nil, { scale = 1 }))
  end)

  it("needs no WoW globals to load", function()
    assert.is_nil(_G.CreateFrame)
    assert.is_table(Settings.defaults)
  end)
end)
