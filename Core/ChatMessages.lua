local ADDON, ns = ...
local ChatMessages = {}
ns.ChatMessages = ChatMessages

-- light blue, so the addon's lines stand out from the chat around them
local PREFIX = "|cff66ccffWASDBars:|r "

-- Extra chat output for this session only; switched by /wasd debug, not saved.
local isDebugOutputOn = false

local function joinWithSpaces(...)
  local parts = {}
  for i = 1, select("#", ...) do
    parts[i] = tostring((select(i, ...)))
  end
  return table.concat(parts, " ")
end

function ChatMessages.printMessage(...)
  DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. joinWithSpaces(...))
end

function ChatMessages.printDebugMessage(...)
  if isDebugOutputOn then
    ChatMessages.printMessage("[debug]", ...)
  end
end

function ChatMessages.turnDebugOutputOn()
  isDebugOutputOn = true
end

function ChatMessages.turnDebugOutputOff()
  isDebugOutputOn = false
end

function ChatMessages.isDebugOutputOn()
  return isDebugOutputOn
end
