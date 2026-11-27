local load_addon_file = require("helpers.load_addon_file")

describe("EditModeIds.readEditModeIds", function()
  local readEditModeIds

  -- made-up values, standing in for the game's Enum
  local function editModeEnum()
    return {
      EditModeSystem = { ActionBar = 0, MainActionBarEndCap = 30, ChatFrame = 3 },
      EditModeActionBarSystemIndices = { MainBar = 1, Bar2 = 2 },
      EditModeMainActionBarEndCapSystemIndices = { EndCapLeft = 0, EndCapRight = 1 },
      EditModeMainActionBarEndCapSetting = { Hidden = 0 },
      EditModeLayoutType = { Preset = 0, Account = 1 },
      EditModeActionBarSetting = { NumIcons = 2, HideBarArt = 6 },
    }
  end

  before_each(function()
    readEditModeIds = load_addon_file("EditModeLayouts/EditModeIds.lua").EditModeIds.readEditModeIds
  end)

  it("reads the systems, indices and settings setup uses", function()
    local editModeIds = readEditModeIds(editModeEnum())
    assert.same({ 0, 1, 2 }, { editModeIds.actionBarSystem, editModeIds.actionBar1Index, editModeIds.actionBar2Index })
    assert.same({ 30, 0, 1, 0 }, {
      editModeIds.endCapSystem,
      editModeIds.leftEndCapIndex,
      editModeIds.rightEndCapIndex,
      editModeIds.endCapHiddenSetting,
    })
    assert.equal(3, editModeIds.chatSystem)
    assert.equal(6, editModeIds.actionBarSettings.hideBarArt)
    assert.is_nil(editModeIds.actionBarSettings.iconSize)
  end)

  it("is nil when the client is missing something setup can't do without", function()
    local withoutBar2 = editModeEnum()
    withoutBar2.EditModeActionBarSystemIndices.Bar2 = nil
    assert.is_nil(readEditModeIds(withoutBar2))
    local withoutLayoutTypes = editModeEnum()
    withoutLayoutTypes.EditModeLayoutType = nil
    assert.is_nil(readEditModeIds(withoutLayoutTypes))
  end)
end)
