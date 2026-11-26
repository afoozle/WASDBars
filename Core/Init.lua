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

-- The TOC version, or nil for a dev build (the packager hasn't replaced it).
function ns.addonVersion()
  local version = C_AddOns.GetAddOnMetadata(ADDON, "Version")
  if not version or version == "@project-version@" then
    return nil
  end
  return (version:gsub("^v", ""))
end

function ns.debug(...)
  if ns.debugEnabled then
    ns.print("[debug]", ...)
  end
end
