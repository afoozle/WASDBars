local ADDON, ns = ...
local EditModeIds = {}
ns.EditModeIds = EditModeIds

-- Action bar setting names -> the game's EditModeActionBarSetting names.
local ACTION_BAR_SETTING_NAMES = {
  numIcons = "NumIcons",
  alwaysShowButtons = "AlwaysShowButtons",
  hideBarArt = "HideBarArt",
  hideBarScrolling = "HideBarScrolling",
  orientation = "Orientation",
  numRows = "NumRows",
  iconSize = "IconSize",
  iconPadding = "IconPadding",
}

local function readEnumValue(editModeEnum, enumName, valueName)
  local enumValues = editModeEnum[enumName]
  return enumValues and enumValues[valueName]
end

local function readActionBarSettings(editModeEnum)
  local actionBarSettings = {}
  for settingName, gameSettingName in pairs(ACTION_BAR_SETTING_NAMES) do
    actionBarSettings[settingName] = readEnumValue(editModeEnum, "EditModeActionBarSetting", gameSettingName)
  end
  return actionBarSettings
end

-- The game's Edit Mode enum values (editModeEnum is the game's Enum), so the
-- layout files make no game calls. nil if this client is missing one setup
-- can't do without.
function EditModeIds.readEditModeIds(editModeEnum)
  local editModeIds = {
    actionBarSystem = readEnumValue(editModeEnum, "EditModeSystem", "ActionBar"),
    actionBar1Index = readEnumValue(editModeEnum, "EditModeActionBarSystemIndices", "MainBar"),
    actionBar2Index = readEnumValue(editModeEnum, "EditModeActionBarSystemIndices", "Bar2"),
    endCapSystem = readEnumValue(editModeEnum, "EditModeSystem", "MainActionBarEndCap"),
    leftEndCapIndex = readEnumValue(editModeEnum, "EditModeMainActionBarEndCapSystemIndices", "EndCapLeft"),
    rightEndCapIndex = readEnumValue(editModeEnum, "EditModeMainActionBarEndCapSystemIndices", "EndCapRight"),
    endCapHiddenSetting = readEnumValue(editModeEnum, "EditModeMainActionBarEndCapSetting", "Hidden"),
    chatSystem = readEnumValue(editModeEnum, "EditModeSystem", "ChatFrame"),
    actionBarSettings = readActionBarSettings(editModeEnum),
  }
  local hasAccountLayouts = readEnumValue(editModeEnum, "EditModeLayoutType", "Account") ~= nil
  if
    editModeIds.actionBarSystem
    and editModeIds.actionBar1Index
    and editModeIds.actionBar2Index
    and hasAccountLayouts
  then
    return editModeIds
  end
  return nil
end
