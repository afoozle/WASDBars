local ADDON, ns = ...

-- Extra chat output for this session only; toggled by /wasd debug, not saved.
ns.debugEnabled = false

local function join(...)
  local parts = {}
  for i = 1, select("#", ...) do
    parts[i] = tostring((select(i, ...)))
  end
  return table.concat(parts, " ")
end

-- light blue, so the addon's lines stand out from the chat around them
local PREFIX = "|cff66ccffWASDBars:|r "

function ns.print(...)
  DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. join(...))
end

function ns.debug(...)
  if ns.debugEnabled then
    ns.print("[debug]", ...)
  end
end

-- Called on ADDON_LOADED, once Logic/CombatQueue.lua has loaded.
-- Anything that moves the action buttons or changes keybinds goes through
-- ns.combatQueue:run(key, fn).
function ns.createCombatQueue()
  ns.combatQueue = ns.CombatQueue.new(InCombatLockdown, function()
    ns.print("Will apply after combat.")
  end)
end
