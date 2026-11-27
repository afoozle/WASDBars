local load_addon_file = require("helpers.load_addon_file")
local editModeFixtures = require("helpers.edit_mode_fixtures")

describe("WasdLayoutSettings", function()
  local WasdLayoutSettings
  local editModeIds = editModeFixtures.editModeIds

  before_each(function()
    WasdLayoutSettings = load_addon_file("EditModeLayouts/WasdLayoutSettings.lua").WasdLayoutSettings
  end)

  describe("readLayoutSettings", function()
    it("reads both bars and the gryphons", function()
      local layoutSettings = WasdLayoutSettings.readLayoutSettings(editModeFixtures.modernLayout(), editModeIds)
      assert.equal(12, layoutSettings.actionBar1.numIcons)
      assert.equal(0, layoutSettings.actionBar1.hideBarArt)
      assert.equal(8, layoutSettings.actionBar2.numIcons)
      assert.equal(0, layoutSettings.gryphonsHidden.left)
    end)

    it("reads missing settings as nil", function()
      local layoutSettings =
        WasdLayoutSettings.readLayoutSettings(editModeFixtures.layoutWithoutSettings(), editModeIds)
      assert.is_nil(layoutSettings.actionBar1.numIcons)
      assert.is_nil(layoutSettings.gryphonsHidden.right)
    end)
  end)

  describe("checks", function()
    it("finds a Modern layout not set up", function()
      local layoutSettings = WasdLayoutSettings.readLayoutSettings(editModeFixtures.modernLayout(), editModeIds)
      assert.is_false(WasdLayoutSettings.isActionBar1SetUp(layoutSettings))
      assert.is_false(WasdLayoutSettings.doesActionBar2MatchActionBar1(layoutSettings))
      assert.is_false(WasdLayoutSettings.areGryphonsHidden(layoutSettings))
    end)

    it("never counts what the game couldn't tell as wrong", function()
      local layoutSettings =
        WasdLayoutSettings.readLayoutSettings(editModeFixtures.layoutWithoutSettings(), editModeIds)
      assert.is_true(WasdLayoutSettings.isActionBar1SetUp(layoutSettings))
      assert.is_true(WasdLayoutSettings.doesActionBar2MatchActionBar1(layoutSettings))
      assert.is_true(WasdLayoutSettings.areGryphonsHidden(layoutSettings))
    end)
  end)

  describe("applying", function()
    it("sets action bar 1, copies its shape to action bar 2 and hides the gryphons", function()
      local layout = editModeFixtures.modernLayout()
      WasdLayoutSettings.applyActionBar1Settings(layout, editModeIds)
      WasdLayoutSettings.copyActionBar1ShapeToActionBar2(layout, editModeIds)
      WasdLayoutSettings.hideGryphons(layout, editModeIds)
      local layoutSettings = WasdLayoutSettings.readLayoutSettings(layout, editModeIds)
      local actionBar1, actionBar2 = layoutSettings.actionBar1, layoutSettings.actionBar2
      assert.same(
        { 12, 1, 1, 1 },
        { actionBar1.numIcons, actionBar1.alwaysShowButtons, actionBar1.hideBarArt, actionBar1.hideBarScrolling }
      )
      assert.same(
        { 12, 0, 1, 5, 2 },
        { actionBar2.numIcons, actionBar2.orientation, actionBar2.numRows, actionBar2.iconSize, actionBar2.iconPadding }
      )
      assert.same({ left = 1, right = 1 }, layoutSettings.gryphonsHidden)
      assert.is_true(WasdLayoutSettings.isActionBar1SetUp(layoutSettings))
      assert.is_true(WasdLayoutSettings.doesActionBar2MatchActionBar1(layoutSettings))
      assert.is_true(WasdLayoutSettings.areGryphonsHidden(layoutSettings))
    end)

    it("leaves action bar 2's shape alone when only action bar 1 is set up", function()
      local layout = editModeFixtures.modernLayout()
      WasdLayoutSettings.applyActionBar1Settings(layout, editModeIds)
      assert.equal(8, WasdLayoutSettings.readLayoutSettings(layout, editModeIds).actionBar2.numIcons)
    end)

    it("adds a setting the layout doesn't have yet", function()
      local layout = editModeFixtures.modernLayout()
      layout.systems[1].settings = editModeFixtures.listSettings({ [2] = 12 })
      WasdLayoutSettings.applyActionBar1Settings(layout, editModeIds)
      assert.equal(1, WasdLayoutSettings.readLayoutSettings(layout, editModeIds).actionBar1.hideBarScrolling)
    end)
  end)

  describe("moving", function()
    local anchor =
      { point = "BOTTOMLEFT", relativeTo = "UIParent", relativePoint = "BOTTOMLEFT", offsetX = 35, offsetY = 300 }

    it("moves the chat window and marks it moved", function()
      local layout = editModeFixtures.modernLayout()
      WasdLayoutSettings.moveChatWindow(layout, editModeIds, anchor)
      assert.equal(300, layout.systems[5].anchorInfo.offsetY)
      assert.is_false(layout.systems[5].isInDefaultPosition)
    end)

    it("moves action bar 2", function()
      local layout = editModeFixtures.modernLayout()
      WasdLayoutSettings.moveActionBar2(layout, editModeIds, anchor)
      assert.equal(35, layout.systems[2].anchorInfo.offsetX)
    end)
  end)
end)
