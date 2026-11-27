local load_addon_file = require("helpers.load_addon_file")
local editModeFixtures = require("helpers.edit_mode_fixtures")

describe("SetupSteps", function()
  local ns, SetupSteps
  local editModeIds = editModeFixtures.editModeIds

  local function readSettings(layout)
    return ns.WasdLayoutSettings.readLayoutSettings(layout, editModeIds)
  end

  -- The Modern layout once setup has changed it.
  local function finishedLayout()
    local layout = editModeFixtures.modernLayout()
    ns.WasdLayoutSettings.applyActionBar1Settings(layout, editModeIds)
    ns.WasdLayoutSettings.copyActionBar1ShapeToActionBar2(layout, editModeIds)
    ns.WasdLayoutSettings.hideGryphons(layout, editModeIds)
    return layout
  end

  local function activeLayoutState(layout)
    return {
      wasdLayout = "active",
      activeLayoutName = "WASDBars",
      layoutSettings = readSettings(layout),
      isActionBar2On = true,
      isActionBar2OnActionBar1 = true,
    }
  end

  before_each(function()
    ns = {}
    load_addon_file("EditModeLayouts/WasdLayoutSettings.lua", ns)
    SetupSteps = load_addon_file("Setup/SetupSteps.lua", ns).SetupSteps
  end)

  describe("findNeededLayoutSteps", function()
    it("lists everything for a first setup, in window order", function()
      local currentLayoutState = {
        wasdLayout = "missing",
        activeLayoutName = "Modern",
        layoutSettings = readSettings(editModeFixtures.modernLayout()),
        isActionBar2On = false,
      }
      assert.same({
        "createWasdLayout",
        "moveActionButtons",
        "replaceActionBar1",
        "positionClusterAndChatWindow",
        "setUpActionBar1",
        "matchActionBar2ToActionBar1",
        "placeActionBar2OnActionBar1",
        "hideGryphons",
        "turnOnActionBar2",
      }, SetupSteps.findNeededLayoutSteps(currentLayoutState))
    end)

    it("leaves out matching action bar 2 when it already matches on create", function()
      local currentLayoutState = {
        wasdLayout = "missing",
        activeLayoutName = "UI",
        layoutSettings = readSettings(finishedLayout()),
        isActionBar2On = true,
      }
      assert.is_false(SetupSteps.isStepNeeded(SetupSteps.findNeededLayoutSteps(currentLayoutState), "matchActionBar2ToActionBar1"))
    end)

    it("switches without placing when the layout exists", function()
      local currentLayoutState = {
        wasdLayout = "inactive",
        activeLayoutName = "Modern",
        layoutSettings = readSettings(finishedLayout()),
        isActionBar2On = true,
      }
      assert.same({ "switchToWasdLayout", "moveActionButtons", "replaceActionBar1" }, SetupSteps.findNeededLayoutSteps(currentLayoutState))
    end)

    it("finds nothing to do on a finished layout", function()
      assert.same({}, SetupSteps.findNeededLayoutSteps(activeLayoutState(finishedLayout())))
    end)

    it("puts action bar 2 back when it has drifted", function()
      local currentLayoutState = activeLayoutState(finishedLayout())
      currentLayoutState.isActionBar2OnActionBar1 = false
      assert.same({ "placeActionBar2OnActionBar1" }, SetupSteps.findNeededLayoutSteps(currentLayoutState))
    end)

    it("leaves a resized action bar 2 alone once the layout exists", function()
      local layout = finishedLayout()
      layout.systems[2].settings = editModeFixtures.listSettings({ [0] = 0, [1] = 2, [2] = 8, [3] = 9, [4] = 4 })
      assert.same({}, SetupSteps.findNeededLayoutSteps(activeLayoutState(layout)))
    end)

    it("sets up action bar 1 on its own", function()
      local layout = finishedLayout()
      layout.systems[1].settings = editModeFixtures.listSettings({ [2] = 10 })
      assert.same({ "setUpActionBar1" }, SetupSteps.findNeededLayoutSteps(activeLayoutState(layout)))
    end)

    it("hides the gryphons when one is showing", function()
      local layout = finishedLayout()
      layout.systems[4].settings = editModeFixtures.listSettings({ [0] = 0 })
      assert.same({ "hideGryphons" }, SetupSteps.findNeededLayoutSteps(activeLayoutState(layout)))
    end)

    it("turns on action bar 2 on its own", function()
      local currentLayoutState = activeLayoutState(finishedLayout())
      currentLayoutState.isActionBar2On = false
      local neededLayoutSteps = SetupSteps.findNeededLayoutSteps(currentLayoutState)
      assert.same({ "turnOnActionBar2" }, neededLayoutSteps)
      assert.is_false(SetupSteps.isLayoutChangeNeeded(neededLayoutSteps))
    end)

    it("skips what the game couldn't tell", function()
      local currentLayoutState = { wasdLayout = "active", layoutSettings = readSettings(editModeFixtures.layoutWithoutSettings()) }
      assert.same({}, SetupSteps.findNeededLayoutSteps(currentLayoutState))
    end)
  end)

  it("needs a layout change for any step but turning on action bar 2", function()
    assert.is_true(SetupSteps.isLayoutChangeNeeded({ "hideGryphons", "turnOnActionBar2" }))
    assert.is_false(SetupSteps.isLayoutChangeNeeded({}))
  end)

  it("describes each step for the window", function()
    local currentLayoutState = { activeLayoutName = "Modern" }
    assert.equal("Create a WASDBars layout from 'Modern' and switch to it", SetupSteps.describeLayoutStep("createWasdLayout", currentLayoutState))
    assert.equal("Move action bar 1's buttons into the WASD shape", SetupSteps.describeLayoutStep("moveActionButtons", currentLayoutState))
    assert.equal("Turn on Action Bar 2", SetupSteps.describeLayoutStep("turnOnActionBar2", currentLayoutState))
  end)
end)
