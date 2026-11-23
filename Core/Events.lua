local ADDON, ns = ...
local Events = {}
ns.Events = Events

local handlers = {}
local frame = CreateFrame("Frame")

-- Registers fn(...) for a game event; several handlers per event run in order.
function Events.on(event, fn)
  if not handlers[event] then
    handlers[event] = {}
    frame:RegisterEvent(event)
  end
  table.insert(handlers[event], fn)
end

frame:SetScript("OnEvent", function(_, event, ...)
  for _, fn in ipairs(handlers[event]) do
    fn(...)
  end
end)

Events.on("ADDON_LOADED", function(name)
  if name ~= ADDON then
    return
  end
  WASDBarsDB = ns.Settings.merge(WASDBarsDB, ns.Settings.defaults)
  ns.db = WASDBarsDB
  -- Anything that moves the action buttons or changes keybinds goes through
  -- ns.combatQueue:run(key, fn).
  ns.combatQueue = ns.CombatQueue.new(InCombatLockdown, function()
    ns.print("Will apply after combat.")
  end)
  ns.debug("loaded")
end)

Events.on("PLAYER_REGEN_ENABLED", function()
  if ns.combatQueue then
    ns.combatQueue:flush()
  end
end)
