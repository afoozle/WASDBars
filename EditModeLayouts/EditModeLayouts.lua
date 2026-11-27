local ADDON, ns = ...
local EditModeIds = ns.EditModeIds
local LayoutList = ns.LayoutList
local EditModeLayouts = {}
ns.EditModeLayouts = EditModeLayouts

-- The game's Edit Mode layouts. Layout tables are edited as Edit Mode stores
-- them, saved with C_EditMode.SaveLayouts, and LibEditModeOverride (a TOC
-- dependency) makes the game apply them.
local LibEditModeOverride = LibStub("LibEditModeOverride-1.0")
local LibEditMode = LibStub("LibEditMode")

function EditModeLayouts.findEditModeIds()
  return EditModeIds.readEditModeIds(Enum)
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
  return LayoutList.hasRoomForAnotherLayout(
    allLayouts,
    Enum.EditModeLayoutType.Account,
    Constants.EditModeConsts.EditModeMaxLayoutsPerType
  )
end

-- A new account-wide layout, copied from the active one and made active.
function EditModeLayouts.copyActiveLayout(allLayouts, newLayoutName)
  LayoutList.copyActiveLayout(
    allLayouts,
    newLayoutName,
    Enum.EditModeLayoutType.Account,
    Enum.EditModeLayoutType.Preset
  )
end

function EditModeLayouts.findPresetLayoutType()
  return Enum.EditModeLayoutType.Preset
end
