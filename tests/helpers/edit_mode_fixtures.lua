-- Made-up Edit Mode values and layouts, standing in for the game's, shared by
-- the EditModeLayouts and Setup specs.
local editModeFixtures = {}

editModeFixtures.editModeIds = {
  actionBarSystem = 0,
  actionBar1Index = 1,
  actionBar2Index = 2,
  endCapSystem = 30,
  leftEndCapIndex = 0,
  rightEndCapIndex = 1,
  chatSystem = 3,
  endCapHiddenSetting = 0,
  actionBarSettings = {
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

-- { [setting] = value } -> Edit Mode's { { setting, value } }
function editModeFixtures.listSettings(valuesBySetting)
  local settings = {}
  for setting, value in pairs(valuesBySetting) do
    table.insert(settings, { setting = setting, value = value })
  end
  return settings
end

-- A Modern-like layout: action bar 1 with art, action bar 2 with its own shape, gryphons shown.
function editModeFixtures.modernLayout()
  local listSettings = editModeFixtures.listSettings
  return {
    layoutName = "Modern",
    systems = {
      {
        system = 0,
        systemIndex = 1,
        settings = listSettings({ [0] = 0, [1] = 1, [2] = 12, [3] = 5, [4] = 2, [6] = 0, [8] = 0, [9] = 1 }),
      },
      { system = 0, systemIndex = 2, settings = listSettings({ [0] = 0, [1] = 2, [2] = 8, [3] = 3, [4] = 4 }) },
      { system = 30, systemIndex = 0, settings = listSettings({ [0] = 0 }) },
      { system = 30, systemIndex = 1, settings = listSettings({ [0] = 0 }) },
      {
        system = 3,
        anchorInfo = { point = "BOTTOMLEFT", relativeTo = "UIParent", relativePoint = "BOTTOMLEFT", offsetX = 35 },
        isInDefaultPosition = true,
        settings = {},
      },
    },
  }
end

-- Every system, with none of its settings saved yet.
function editModeFixtures.layoutWithoutSettings()
  local layout = editModeFixtures.modernLayout()
  for _, systemEntry in ipairs(layout.systems) do
    systemEntry.settings = {}
  end
  return layout
end

return editModeFixtures
