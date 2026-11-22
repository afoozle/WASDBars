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

  describe("statusLine", function()
    it("describes each state", function()
      assert.equal("Test keys: set up", BindingPlan.statusLine(group, { state = "applied" }))
      assert.equal(
        "Test keys: 1 of 3 set up",
        BindingPlan.statusLine(group, { state = "partial", correct = 1, total = 3 })
      )
      assert.equal("Test keys: not set up", BindingPlan.statusLine(group, { state = "not applied" }))
    end)
  end)
end)
