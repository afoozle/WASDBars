local load_addon_file = require("helpers.load_addon_file")

describe("KeybindCopies", function()
  local KeybindCopies
  local ACCOUNT_BINDINGS, CHARACTER_BINDINGS = 1, 2

  before_each(function()
    KeybindCopies = load_addon_file("Keybinds/KeybindCopies.lua").KeybindCopies
  end)

  it("keeps one copy for every character on the account's keybinds", function()
    assert.equal("account", KeybindCopies.findCopyOwner(ACCOUNT_BINDINGS, CHARACTER_BINDINGS, "Player-1"))
    assert.equal("account", KeybindCopies.findCopyOwner(ACCOUNT_BINDINGS, CHARACTER_BINDINGS, "Player-2"))
  end)

  it("keeps a character's own copy when it uses its own keybinds", function()
    assert.equal("Player-2", KeybindCopies.findCopyOwner(CHARACTER_BINDINGS, CHARACTER_BINDINGS, "Player-2"))
  end)

  it("saves only the first copy for an owner", function()
    local savedCopies = {}
    KeybindCopies.saveKeybindCopyOnce(savedCopies, "account", { Q = "STRAFELEFT" })
    KeybindCopies.saveKeybindCopyOnce(savedCopies, "account", { Q = "ACTIONBUTTON1" })
    KeybindCopies.saveKeybindCopyOnce(savedCopies, "Player-2", { Q = false })
    assert.same({ account = { Q = "STRAFELEFT" }, ["Player-2"] = { Q = false } }, savedCopies)
  end)
end)
