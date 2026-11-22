local load_addon_file = require("helpers.load_addon_file")
local stubs = require("helpers.wow_stubs")

describe("BindingPlan", function()
  local BindingPlan
  local group = {
    title = "Test keys",
    binds = {
      { key = "Q", command = "ACTIONBUTTON1" },
      { key = "E", command = "ACTIONBUTTON2" },
      { key = "BUTTON5", command = "ACTIONBUTTON11", label = "Mouse front" },
    },
  }

  local function build(keys)
    return BindingPlan.build(group, stubs.bindings(keys).GetBindingAction)
  end

  before_each(function()
    BindingPlan = load_addon_file("Logic/BindingPlan.lua").BindingPlan
  end)

  it("lists every key with its current and new command on a fresh setup", function()
    local plan = build({ Q = "STRAFELEFT", E = "STRAFERIGHT", BUTTON5 = "SHAPESHIFTBUTTON1" })
    assert.same({
      { key = "Q", command = "ACTIONBUTTON1", current = "STRAFELEFT" },
      { key = "E", command = "ACTIONBUTTON2", current = "STRAFERIGHT" },
      { key = "BUTTON5", label = "Mouse front", command = "ACTIONBUTTON11", current = "SHAPESHIFTBUTTON1" },
    }, plan.changes)
    assert.equal("not applied", plan.state)
    assert.equal(0, plan.correct)
    assert.equal(3, plan.total)
  end)

  it("has no changes when the group is already applied", function()
    local plan = build({ Q = "ACTIONBUTTON1", E = "ACTIONBUTTON2", BUTTON5 = "ACTIONBUTTON11" })
    assert.same({}, plan.changes)
    assert.equal("applied", plan.state)
  end)

  it("counts correct keys and leaves them out of a partial setup", function()
    local plan = build({ Q = "ACTIONBUTTON1", E = "ACTIONBUTTON7" })
    assert.equal("partial", plan.state)
    assert.equal(1, plan.correct)
    assert.same({ "E", "BUTTON5" }, { plan.changes[1].key, plan.changes[2].key })
  end)

  it("shows no current command for unbound keys", function()
    local plan = build({})
    assert.is_nil(plan.changes[1].current)
  end)

  describe("commandName", function()
    local function name(command)
      return BindingPlan.commandName(command, function(c)
        return "game:" .. c
      end, function(n)
        return ({ "Bear Form", nil, "Cat Form" })[n]
      end)
    end

    it("names action bar buttons briefly", function()
      assert.equal("Action bar 1 button 7", name("ACTIONBUTTON7"))
      assert.equal("Action bar 2 button 12", name("MULTIACTIONBAR1BUTTON12"))
    end)

    it("names stance bar buttons after their form", function()
      assert.equal("Cat Form", name("SHAPESHIFTBUTTON3"))
      assert.equal("Stance bar button 2", name("SHAPESHIFTBUTTON2"))
    end)

    it("uses the game's name for anything else", function()
      assert.equal("game:STRAFELEFT", name("STRAFELEFT"))
    end)
  end)

  describe("lostActions", function()
    local function lost(keys)
      local b = stubs.bindings(keys)
      return BindingPlan.lostActions({ BindingPlan.build(group, b.GetBindingAction) }, b.GetBindingKey)
    end

    it("lists actions left with no key, with the keys that did them", function()
      assert.same({
        { command = "REPLY", keys = { "Q" } },
        { command = "TOGGLEAUTORUN", keys = { "Mouse front" } },
      }, lost({ Q = "REPLY", BUTTON5 = "TOGGLEAUTORUN" }))
    end)

    it("leaves out actions another key still does", function()
      assert.same({}, lost({ Q = "TURNLEFT", A = "TURNLEFT" }))
    end)

    it("leaves out actions the setup binds to another key", function()
      assert.same({}, lost({ Q = "ACTIONBUTTON2" }))
    end)

    it("groups keys that did the same action", function()
      assert.same({ { command = "JUMP", keys = { "Q", "E" } } }, lost({ Q = "JUMP", E = "JUMP" }))
    end)
  end)

  describe("statusSentence", function()
    local groups = { { name = "WASD keys" }, { name = "number row" } }

    it("sums up when everything is set up", function()
      assert.equal(
        "Keybinds set up (WASD keys and number row).",
        BindingPlan.statusSentence(groups, { { state = "applied" }, { state = "applied" } })
      )
    end)

    it("lists each group otherwise", function()
      assert.equal(
        "Keybinds: WASD keys set up, number row 7 of 12 set up.",
        BindingPlan.statusSentence(groups, { { state = "applied" }, { state = "partial", correct = 7, total = 12 } })
      )
      assert.equal(
        "Keybinds: WASD keys not set up, number row not set up.",
        BindingPlan.statusSentence(groups, { { state = "not applied" }, { state = "not applied" } })
      )
    end)
  end)
end)
