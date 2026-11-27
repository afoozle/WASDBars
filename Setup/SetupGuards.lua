local ADDON, ns = ...
local SetupGuards = {}
ns.SetupGuards = SetupGuards

-- Setup and restore refuse in combat, with Edit Mode open, or before Edit
-- Mode's layouts have loaded, rather than waiting. Each returns true when it refused.
SetupGuards.NOT_READY_MESSAGE = "Edit Mode isn't ready yet. Try again in a moment."

-- whatPlayerTried: e.g. "set up", for "Can't set up in combat."
function SetupGuards.refuseInCombat(whatPlayerTried)
  if InCombatLockdown() then
    ns.ChatMessages.printMessage("Can't " .. whatPlayerTried .. " in combat.")
    return true
  end
  return false
end

function SetupGuards.refuseBeforeEditModeReady()
  if not ns.EditModeLayouts.isEditModeReady() then
    ns.ChatMessages.printMessage(SetupGuards.NOT_READY_MESSAGE)
    return true
  end
  return false
end

-- commandToRunAgain: e.g. "setup", for "Close Edit Mode, then run /wasd setup."
function SetupGuards.refuseInEditMode(commandToRunAgain)
  if ns.EditModeLayouts.isEditModeOpen() then
    ns.ChatMessages.printMessage("Close Edit Mode, then run /wasd " .. commandToRunAgain .. ".")
    return true
  end
  return false
end
