local load_addon_file = require("helpers.load_addon_file")

describe("LayoutPlan", function()
  local LayoutPlan

  -- made-up enum values, standing in for the game's
  local ids = {
    actionBar = 0,
    bar1 = 1,
    bar2 = 2,
    endCap = 30,
    capLeft = 0,
    capRight = 1,
    chat = 3,
    capHidden = 0,
    bar = {
      orientation = 0,
      numRows = 1,
      numIcons = 2,
      iconSize = 3,
      iconPadding = 4,
      hideBarArt = 6,
      hideBarScrolling = 8,
      alwaysShowButtons = 9,
    },
  }

  local function settings(map)
    local list = {}
    for setting, value in pairs(map) do
      table.insert(list, { setting = setting, value = value })
    end
    return list
  end

  -- A Modern-like layout: action bar 1 with art, action bar 2 with its own shape, gryphons shown.
  local function layout()
    return {
      layoutName = "Modern",
      systems = {
        {
          system = 0,
          systemIndex = 1,
          settings = settings({ [0] = 0, [1] = 1, [2] = 12, [3] = 5, [4] = 2, [6] = 0, [8] = 0, [9] = 1 }),
        },
        { system = 0, systemIndex = 2, settings = settings({ [0] = 0, [1] = 2, [2] = 8, [3] = 3, [4] = 4 }) },
        { system = 30, systemIndex = 0, settings = settings({ [0] = 0 }) },
        { system = 30, systemIndex = 1, settings = settings({ [0] = 0 }) },
        {
          system = 3,
          anchorInfo = { point = "BOTTOMLEFT", relativeTo = "UIParent", relativePoint = "BOTTOMLEFT", offsetX = 35 },
          isInDefaultPosition = true,
          settings = {},
        },
      },
    }
  end

  local function ids_of(list)
    local result = {}
    for i, action in ipairs(list) do
      result[i] = action.id
    end
    return result
  end

  before_each(function()
    LayoutPlan = load_addon_file("Logic/LayoutPlan.lua").LayoutPlan
  end)

  describe("read", function()
    it("reads both bars and the end caps", function()
      local r = LayoutPlan.read(layout(), ids)
      assert.equal(12, r.bar1.numIcons)
      assert.equal(0, r.bar1.hideBarArt)
      assert.equal(8, r.bar2.numIcons)
      assert.equal(0, r.capsHidden.left)
    end)

    it("reads missing systems and settings as nil", function()
      local r = LayoutPlan.read({ systems = {} }, ids)
      assert.is_nil(r.bar1.numIcons)
      assert.is_nil(r.capsHidden.right)
    end)
  end)

  describe("actions", function()
    it("lists everything for a first setup, in window order", function()
      local r = { step = "create", source = "Modern", layout = LayoutPlan.read(layout(), ids), bar2On = false }
      local list = LayoutPlan.actions(r)
      assert.same(
        { "create", "buttons", "replace", "place", "bar1", "bar2Shape", "bar2Place", "endCaps", "bar2On" },
        ids_of(list)
      )
      assert.equal("Create a WASDBars layout from 'Modern' and switch to it", list[1].text)
      assert.equal("Move action bar 1's buttons into the WASD shape", list[2].text)
      assert.equal("Replace action bar 1 with action bar 2", list[3].text)
    end)

    it("switches without placing when the layout exists", function()
      local done = layout()
      LayoutPlan.edit(done, ids, true)
      local r = { step = "switch", layout = LayoutPlan.read(done, ids), bar2On = true }
      assert.same({ "switch", "buttons", "replace" }, ids_of(LayoutPlan.actions(r)))
    end)

    it("finds nothing to do on a finished layout", function()
      local done = layout()
      LayoutPlan.edit(done, ids, true)
      local r = { layout = LayoutPlan.read(done, ids), bar2On = true, onBar1 = true }
      assert.same({}, LayoutPlan.actions(r))
    end)

    it("puts action bar 2 back when it has drifted", function()
      local done = layout()
      LayoutPlan.edit(done, ids, true)
      local r = { layout = LayoutPlan.read(done, ids), bar2On = true, onBar1 = false }
      assert.same({ "bar2Place" }, ids_of(LayoutPlan.actions(r)))
    end)

    it("leaves a resized action bar 2 alone once the layout exists", function()
      local done = layout()
      LayoutPlan.edit(done, ids, true)
      done.systems[2].settings = settings({ [0] = 0, [1] = 2, [2] = 8, [3] = 9, [4] = 4 })
      local r = { layout = LayoutPlan.read(done, ids), bar2On = true, onBar1 = true }
      assert.same({}, LayoutPlan.actions(r))
    end)

    it("skips what the game couldn't tell", function()
      assert.same({}, LayoutPlan.actions({ layout = LayoutPlan.read({ systems = {} }, ids) }))
    end)
  end)

  describe("edit", function()
    it("sets action bar 1, copies its shape to action bar 2 and hides the gryphons", function()
      local l = layout()
      LayoutPlan.edit(l, ids, true)
      local r = LayoutPlan.read(l, ids)
      assert.same(
        { 12, 1, 1, 1 },
        { r.bar1.numIcons, r.bar1.alwaysShowButtons, r.bar1.hideBarArt, r.bar1.hideBarScrolling }
      )
      assert.same(
        { 12, 0, 1, 5, 2 },
        { r.bar2.numIcons, r.bar2.orientation, r.bar2.numRows, r.bar2.iconSize, r.bar2.iconPadding }
      )
      assert.same({ left = 1, right = 1 }, r.capsHidden)
    end)

    it("leaves action bar 2's shape alone without withShape", function()
      local l = layout()
      LayoutPlan.edit(l, ids)
      assert.equal(8, LayoutPlan.read(l, ids).bar2.numIcons)
    end)

    it("adds a setting the layout doesn't have yet", function()
      local l = layout()
      l.systems[1].settings = settings({ [2] = 12 })
      LayoutPlan.edit(l, ids)
      assert.equal(1, LayoutPlan.read(l, ids).bar1.hideBarScrolling)
    end)
  end)

  describe("anchor", function()
    it("moves a system and marks it moved", function()
      local l = layout()
      local anchor =
        { point = "BOTTOMLEFT", relativeTo = "UIParent", relativePoint = "BOTTOMLEFT", offsetX = 35, offsetY = 300 }
      assert.is_true(LayoutPlan.anchor(l, ids.chat, nil, anchor))
      assert.equal(300, l.systems[5].anchorInfo.offsetY)
      assert.is_false(l.systems[5].isInDefaultPosition)
    end)

    it("returns false for a missing system", function()
      assert.is_false(LayoutPlan.anchor({ systems = {} }, ids.chat, nil, {}))
    end)
  end)

  describe("statusSentence", function()
    it("says ready, not on the layout, or how many changes", function()
      assert.equal("Edit Mode layout ready.", LayoutPlan.statusSentence({}, {}))
      assert.equal("Not on the WASDBars layout (/wasd setup).", LayoutPlan.statusSentence({ step = "switch" }, {}))
      assert.equal("WASDBars layout needs 2 changes (/wasd setup).", LayoutPlan.statusSentence({}, { {}, {} }))
    end)
  end)
end)
