local ADDON, ns = ...
local EditModeIds = {}
ns.EditModeIds = EditModeIds

-- The game's Edit Mode enum values (editModeEnum is the game's Enum), so the
-- layout files make no game calls.
function EditModeIds.readEditModeIds(editModeEnum)
  local actionBarSetting = editModeEnum.EditModeActionBarSetting
  local endCapIndices = editModeEnum.EditModeMainActionBarEndCapSystemIndices
  return {
    actionBarSystem = editModeEnum.EditModeSystem.ActionBar,
    actionBar1Index = editModeEnum.EditModeActionBarSystemIndices.MainBar,
    actionBar2Index = editModeEnum.EditModeActionBarSystemIndices.Bar2,
    endCapSystem = editModeEnum.EditModeSystem.MainActionBarEndCap,
    leftEndCapIndex = endCapIndices.EndCapLeft,
    rightEndCapIndex = endCapIndices.EndCapRight,
    endCapHiddenSetting = editModeEnum.EditModeMainActionBarEndCapSetting.Hidden,
    chatSystem = editModeEnum.EditModeSystem.ChatFrame,
    actionBarSettings = {
      numIcons = actionBarSetting.NumIcons,
      alwaysShowButtons = actionBarSetting.AlwaysShowButtons,
      hideBarArt = actionBarSetting.HideBarArt,
      hideBarScrolling = actionBarSetting.HideBarScrolling,
      orientation = actionBarSetting.Orientation,
      numRows = actionBarSetting.NumRows,
      iconSize = actionBarSetting.IconSize,
      iconPadding = actionBarSetting.IconPadding,
    },
  }
end
