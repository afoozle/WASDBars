local ADDON, ns = ...
local ChatMessages = {}
ns.ChatMessages = ChatMessages

-- light blue, so the addon's lines stand out from the chat around them
local PREFIX = "|cff66ccffWASDBars:|r "

function ChatMessages.printMessage(message)
  DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. message)
end
