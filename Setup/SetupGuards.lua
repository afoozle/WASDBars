local ADDON, ns = ...
local SetupGuards = {}
ns.SetupGuards = SetupGuards

-- Setup and restore refuse rather than wait. Each returns true when it refused.

-- whatPlayerTried: e.g. "set up", for "Can't set up in combat."
function SetupGuards.refuseInCombat(whatPlayerTried)
  if InCombatLockdown() then
    ns.ChatMessages.printMessage("Can't " .. whatPlayerTried .. " in combat.")
    return true
  end
  return false
end

-- Also refuses with Edit Mode open, or before Edit Mode's layouts have loaded.
-- commandToRunAgain: e.g. "setup", for "Close Edit Mode, then run /wasd setup."
function SetupGuards.refuseLayoutChange(whatPlayerTried, commandToRunAgain)
  if SetupGuards.refuseInCombat(whatPlayerTried) then
    return true
  elseif EditModeManagerFrame:IsEditModeActive() then
    ns.ChatMessages.printMessage("Close Edit Mode, then run /wasd " .. commandToRunAgain .. ".")
    return true
  elseif not ns.EditModeLayouts.isEditModeReady() then
    ns.ChatMessages.printMessage("Edit Mode isn't ready yet. Try again in a moment.")
    return true
  end
  return false
end
