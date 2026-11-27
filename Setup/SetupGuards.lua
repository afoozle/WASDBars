local ADDON, ns = ...
local SetupGuards = {}
ns.SetupGuards = SetupGuards

-- Setup and restore refuse in combat or with Edit Mode open, rather than
-- waiting. Each returns true when it refused.

-- whatPlayerTried: e.g. "set up", for "Can't set up in combat."
function SetupGuards.refuseInCombat(whatPlayerTried)
  if ns.CombatQueue.isInCombat() then
    ns.ChatMessages.printMessage("Can't " .. whatPlayerTried .. " in combat.")
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
