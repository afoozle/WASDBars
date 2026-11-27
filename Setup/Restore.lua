local ADDON, ns = ...
local KeybindCopies = ns.KeybindCopies
local RestorePoints = ns.RestorePoints
local RestoreSteps = ns.RestoreSteps
local Restore = {}
ns.Restore = Restore

-- /wasd restore: back to the character's layout and action bar 2 from before
-- setup, and optionally its keys.
local RESTORE_POPUP = "WASDBARS_RESTORE"
local RESTORE_KEYBINDS_POPUP = "WASDBARS_RESTORE_KEYS"

-- Restore always switches the layout, so it asks for a reload like setup.
local function finishRestore()
  ns.ChatMessages.printMessage(
    "Restored. You can delete the WASDBars layout in Edit Mode whenever you like. "
      .. "Type /wasd setup to set it up again."
  )
  ns.ReloadPrompt.askForReload("Restored")
end

local function restoreKeybinds()
  if ns.SetupGuards.refuseInCombat("restore keybinds") then
    return
  end
  local copyOwner = ns.Keybinds.findCopyOwner()
  ns.Keybinds.restoreKeybinds(KeybindCopies.findKeybindCopy(ns.db.keyCopies, copyOwner))
  KeybindCopies.forgetKeybindCopy(ns.db.keyCopies, copyOwner)
  finishRestore()
end

local function askToRestoreKeybinds()
  StaticPopup_Show(RESTORE_KEYBINDS_POPUP)
end

-- restoreChoice: { layout, bar2 }, from askToRestore.
local function restoreLayout(_, restoreChoice)
  if ns.SetupGuards.refuseInCombat("restore") or ns.SetupGuards.refuseInEditMode("restore") then
    return
  end
  ns.EditModeLayouts.switchToLayout(restoreChoice.layout)
  if restoreChoice.bar2 then
    ns.MainBarReplacement.turnOnActionBar2()
  else
    ns.MainBarReplacement.turnOffActionBar2()
  end
  RestorePoints.forgetRestorePoint(ns.db.restore, UnitGUID("player"))
  if KeybindCopies.findKeybindCopy(ns.db.keyCopies, ns.Keybinds.findCopyOwner()) then
    askToRestoreKeybinds()
  else
    finishRestore()
  end
end

StaticPopupDialogs[RESTORE_KEYBINDS_POPUP] = {
  text = "Restore your keybinds too?\n\nPuts the keys around WASD and the number row back to what they were "
    .. "before WASDBars set them up.",
  button1 = "Yes",
  button2 = "No",
  OnAccept = restoreKeybinds,
  OnCancel = finishRestore,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}

StaticPopupDialogs[RESTORE_POPUP] = {
  text = "Restore WASDBars changes?\n\n%s",
  button1 = "Restore",
  button2 = "Cancel",
  OnAccept = restoreLayout,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}

-- /wasd restore and the Restore button.
function Restore.askToRestore()
  if ns.SetupGuards.refuseInCombat("restore") then
    return
  end
  local restorePoint = RestorePoints.findRestorePoint(ns.db.restore, UnitGUID("player"))
  if not restorePoint then
    ns.ChatMessages.printMessage("Nothing to restore on this character.")
    return
  end
  if ns.SetupGuards.refuseInEditMode("restore") then
    return
  end
  if not ns.EditModeLayouts.isEditModeReady() then
    ns.ChatMessages.printMessage("Edit Mode isn't ready yet. Try again in a moment.")
    return
  end
  local layoutToRestore, isSavedLayoutMissing = RestoreSteps.findLayoutToRestore(
    ns.EditModeLayouts.loadAllLayouts(),
    restorePoint,
    ns.EditModeLayouts.findPresetLayoutType()
  )
  local restoreLines = RestoreSteps.describeRestore(layoutToRestore, isSavedLayoutMissing, restorePoint)
  StaticPopup_Show(
    RESTORE_POPUP,
    table.concat(restoreLines, "\n"),
    nil,
    { layout = layoutToRestore, bar2 = restorePoint.bar2 }
  )
end
