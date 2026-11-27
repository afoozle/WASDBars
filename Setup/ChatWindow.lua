local ADDON, ns = ...
local ChatWindow = {}
ns.ChatWindow = ChatWindow

-- The game's chat window, moved up on a new layout to make room for the cluster.

-- Space between the cluster's top and the chat window, which leaves room for
-- the chat's edit box.
local CHAT_GAP = 40

-- The chat window's scale relative to the screen.
local function findChatScale()
  return ChatFrame1:GetEffectiveScale() / UIParent:GetEffectiveScale()
end

-- The chat window's left edge, in screen units: where the cluster goes.
function ChatWindow.findLeftEdge()
  return ChatFrame1:GetLeft() * findChatScale()
end

-- The chat window's Edit Mode anchor above the cluster. clusterTop: in screen units.
function ChatWindow.findAnchorAboveCluster(clusterTop)
  return {
    point = "BOTTOMLEFT",
    relativeTo = "UIParent",
    relativePoint = "BOTTOMLEFT",
    offsetX = ChatFrame1:GetLeft(),
    offsetY = (clusterTop + CHAT_GAP) / findChatScale(),
  }
end
