local load_addon_file = require("helpers.load_addon_file")

describe("KeybindPlan", function()
  local KeybindPlan
  local wasdGroup = {
    name = "WASD keys",
    keybinds = {
      { key = "Q", action = "ACTIONBUTTON1" },
      { key = "E", action = "ACTIONBUTTON2" },
      { key = "BUTTON5", action = "ACTIONBUTTON11", keyLabel = "Mouse front" },
    },
  }
  local numberGroup = {
    name = "number row",
    keybinds = { { key = "1", action = "MULTIACTIONBAR1BUTTON1" }, { key = "2", action = "MULTIACTIONBAR1BUTTON2" } },
  }

  -- { [action] = keys } for every action in currentActions, as GetBindingKey reads them.
  local function readKeysOfEachAction(currentActions)
    local keysOfEachAction = {}
    for key, action in pairs(currentActions) do
      keysOfEachAction[action] = keysOfEachAction[action] or {}
      table.insert(keysOfEachAction[action], key)
    end
    for _, keys in pairs(keysOfEachAction) do
      table.sort(keys)
    end
    return keysOfEachAction
  end

  local function findActionsLosingTheirKey(keybindGroups, currentActions)
    return KeybindPlan.findActionsLosingTheirKey(KeybindPlan.findGroupsToChange(keybindGroups, currentActions), readKeysOfEachAction(currentActions))
  end

  before_each(function()
    KeybindPlan = load_addon_file("Keybinds/KeybindPlan.lua").KeybindPlan
  end)

  describe("findGroupsToChange", function()
    local function findWasdChanges(currentActions)
      return KeybindPlan.findGroupsToChange({ wasdGroup }, currentActions)[1]
    end

    it("lists every key with its current and wanted action on a fresh setup", function()
      local groupChanges = findWasdChanges({ Q = "STRAFELEFT", E = "STRAFERIGHT", BUTTON5 = "SHAPESHIFTBUTTON1" })
      assert.same({
        { key = "Q", wantedAction = "ACTIONBUTTON1", currentAction = "STRAFELEFT" },
        { key = "E", wantedAction = "ACTIONBUTTON2", currentAction = "STRAFERIGHT" },
        {
          key = "BUTTON5",
          keyLabel = "Mouse front",
          wantedAction = "ACTIONBUTTON11",
          currentAction = "SHAPESHIFTBUTTON1",
        },
      }, groupChanges.keybindChanges)
    end)

    it("leaves out keys already right", function()
      local groupChanges = findWasdChanges({ Q = "ACTIONBUTTON1", E = "ACTIONBUTTON7" })
      assert.same({ "E", "BUTTON5" }, { groupChanges.keybindChanges[1].key, groupChanges.keybindChanges[2].key })
    end)

    it("shows no current action for unbound keys", function()
      assert.is_nil(findWasdChanges({}).keybindChanges[1].currentAction)
    end)

    it("leaves out groups already set up", function()
      local groupsToChange = KeybindPlan.findGroupsToChange(
        { wasdGroup, numberGroup },
        { Q = "ACTIONBUTTON1", E = "ACTIONBUTTON2", BUTTON5 = "ACTIONBUTTON11" }
      )
      assert.equal(1, #groupsToChange)
      assert.equal(numberGroup, groupsToChange[1].group)
    end)
  end)

  describe("findActionsLosingTheirKey", function()
    it("lists actions left with no key, with the keys that did them", function()
      assert.same({
        { action = "REPLY", keyLabels = { "Q" } },
        { action = "TOGGLEAUTORUN", keyLabels = { "Mouse front" } },
      }, findActionsLosingTheirKey({ wasdGroup }, { Q = "REPLY", BUTTON5 = "TOGGLEAUTORUN" }))
    end)

    it("leaves out actions another key still does", function()
      assert.same({}, findActionsLosingTheirKey({ wasdGroup }, { Q = "TURNLEFT", A = "TURNLEFT" }))
    end)

    it("leaves out actions setup binds to another key", function()
      assert.same({}, findActionsLosingTheirKey({ wasdGroup }, { Q = "ACTIONBUTTON2" }))
    end)

    it("groups keys that did the same action", function()
      assert.same({ { action = "JUMP", keyLabels = { "Q", "E" } } }, findActionsLosingTheirKey({ wasdGroup }, { Q = "JUMP", E = "JUMP" }))
    end)

    -- A new player's 1 fires action bar 1's first button, which setup moves to Q.
    it("counts keys across both groups", function()
      assert.same({}, findActionsLosingTheirKey({ wasdGroup, numberGroup }, { ["1"] = "ACTIONBUTTON1", ["2"] = "ACTIONBUTTON2" }))
      assert.same(
        { { action = "EXTRAACTIONBUTTON1", keyLabels = { "2" } } },
        findActionsLosingTheirKey({ wasdGroup, numberGroup }, { ["2"] = "EXTRAACTIONBUTTON1" })
      )
    end)

    it("keeps an action that a key outside both groups still does", function()
      assert.same({}, findActionsLosingTheirKey({ wasdGroup, numberGroup }, { ["1"] = "REPLY", Q = "REPLY", F12 = "REPLY" }))
    end)
  end)

  describe("copying and restoring", function()
    it("copies what each key is bound to, false when unbound", function()
      assert.same(
        { Q = "STRAFELEFT", E = false, BUTTON5 = false, ["1"] = "ACTIONBUTTON1", ["2"] = false },
        KeybindPlan.copyKeybinds({ wasdGroup, numberGroup }, { Q = "STRAFELEFT", ["1"] = "ACTIONBUTTON1" })
      )
    end)

    it("lists the keys to put back, sorted, unbound ones with no action", function()
      assert.same(
        { { key = "1", action = "ACTIONBUTTON1" }, { key = "Q", action = "STRAFELEFT" }, { key = "T" } },
        KeybindPlan.findRestoreChanges({ Q = "STRAFELEFT", T = false, ["1"] = "ACTIONBUTTON1" })
      )
    end)

    it("puts back exactly the copy taken before setup", function()
      local keybindCopy = KeybindPlan.copyKeybinds({ wasdGroup }, { Q = "STRAFELEFT", E = "JUMP" })
      assert.same({
        { key = "BUTTON5" },
        { key = "E", action = "JUMP" },
        { key = "Q", action = "STRAFELEFT" },
      }, KeybindPlan.findRestoreChanges(keybindCopy))
    end)
  end)

  describe("nameAction", function()
    local function nameAction(action, formName)
      return KeybindPlan.nameAction(action, formName, "game:" .. action)
    end

    it("names action bar buttons briefly", function()
      assert.equal("Action bar 1 button 7", nameAction("ACTIONBUTTON7"))
      assert.equal("Action bar 2 button 12", nameAction("MULTIACTIONBAR1BUTTON12"))
    end)

    it("names stance bar buttons after their form", function()
      assert.equal(3, KeybindPlan.findStanceButtonNumber("SHAPESHIFTBUTTON3"))
      assert.equal("Cat Form", nameAction("SHAPESHIFTBUTTON3", "Cat Form"))
      assert.equal("Stance bar button 2", nameAction("SHAPESHIFTBUTTON2", nil))
    end)

    it("uses the game's name for anything else", function()
      assert.is_nil(KeybindPlan.findStanceButtonNumber("STRAFELEFT"))
      assert.equal("game:STRAFELEFT", nameAction("STRAFELEFT"))
    end)
  end)
end)
