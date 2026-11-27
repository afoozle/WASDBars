local ADDON, ns = ...
local LayoutList = ns.LayoutList
local EditModeLayouts = {}
ns.EditModeLayouts = EditModeLayouts

-- The game's Edit Mode layouts. Layout tables are edited as Edit Mode stores
-- them, saved with C_EditMode.SaveLayouts, and LibEditModeOverride (a TOC
-- dependency) makes the game apply them.
local LibEditModeOverride = LibStub("LibEditModeOverride-1.0")
local LibEditMode = LibStub("LibEditMode")

-- The game's Edit Mode enum values setup uses, so the layout logic files make no game calls.
function EditModeLayouts.findEditModeIds()
  local actionBarSetting = Enum.EditModeActionBarSetting
  local endCapIndices = Enum.EditModeMainActionBarEndCapSystemIndices
  return {
    actionBarSystem = Enum.EditModeSystem.ActionBar,
    actionBar1Index = Enum.EditModeActionBarSystemIndices.MainBar,
    actionBar2Index = Enum.EditModeActionBarSystemIndices.Bar2,
    endCapSystem = Enum.EditModeSystem.MainActionBarEndCap,
    leftEndCapIndex = endCapIndices.EndCapLeft,
    rightEndCapIndex = endCapIndices.EndCapRight,
    endCapHiddenSetting = Enum.EditModeMainActionBarEndCapSetting.Hidden,
    chatSystem = Enum.EditModeSystem.ChatFrame,
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

function EditModeLayouts.isEditModeReady()
  return LibEditModeOverride:IsReady()
end

function EditModeLayouts.isEditModeOpen()
  return EditModeManagerFrame:IsEditModeActive()
end

function EditModeLayouts.openEditMode()
  HideUIPanel(SettingsPanel)
  ShowUIPanel(EditModeManagerFrame)
end

-- Every layout, presets first (LayoutList.lua). Saved layouts are brought up
-- to date with the game's current systems first, as LibEditModeOverride does.
function EditModeLayouts.loadAllLayouts()
  local savedLayouts = C_EditMode.GetLayouts()
  for _, layout in ipairs(savedLayouts.layouts) do
    EditModeManagerFrame:ReconcileWithModern(layout)
  end
  return LayoutList.combinePresetAndSavedLayouts(EditModePresetLayoutManager:GetCopyOfPresetLayouts(), savedLayouts)
end

-- Saves and makes the game apply them.
function EditModeLayouts.saveAllLayouts(allLayouts)
  C_EditMode.SaveLayouts(allLayouts)
  C_EditMode.SetActiveLayout(allLayouts.activeLayout)
  LibEditModeOverride:LoadLayouts()
  LibEditModeOverride:ApplyChanges()
end

function EditModeLayouts.findActiveLayoutName()
  return LibEditMode:GetActiveLayoutName()
end

-- Straight away.
function EditModeLayouts.switchToLayout(layoutName)
  LibEditModeOverride:LoadLayouts()
  LibEditModeOverride:SetActiveLayout(layoutName)
  LibEditModeOverride:ApplyChanges()
end

function EditModeLayouts.hasRoomForAnotherLayout(allLayouts)
  return LayoutList.hasRoomForAnotherLayout(allLayouts, Enum.EditModeLayoutType.Account, Constants.EditModeConsts.EditModeMaxLayoutsPerType)
end

-- A new account-wide layout, copied from the active one and made active.
function EditModeLayouts.copyActiveLayout(allLayouts, newLayoutName)
  LayoutList.copyActiveLayout(allLayouts, newLayoutName, Enum.EditModeLayoutType.Account, Enum.EditModeLayoutType.Preset)
end
