local ADDON, ns = ...
local Cluster = {}
ns.Cluster = Cluster

local function actionButton(key)
  return _G["ActionButton" .. key.button]
end

-- Moves the game's action buttons into the cluster. Out of combat only:
-- always called through ns.combatQueue.
local function applyLayout()
  local frame = Cluster.frame
  for _, k in ipairs(Cluster.geometry.keys) do
    if k.key.button then
      local button = actionButton(k.key)
      button:SetParent(frame)
      button:ClearAllPoints()
      button:SetScale(k.scale)
      -- a scaled frame's offsets are in its own scaled units
      button:SetPoint("CENTER", frame, "TOPLEFT", k.cx / k.scale, -k.cy / k.scale)
    end
  end
  ns.debug("layout applied")
end

local function anyButtonOutOfPlace()
  for _, k in ipairs(Cluster.geometry.keys) do
    if k.key.button and actionButton(k.key):GetParent() ~= Cluster.frame then
      return true
    end
  end
  return false
end

ns.Events.on("PLAYER_LOGIN", function()
  local layout = ns.Layout
  Cluster.baseSize = _G.ActionButton1:GetWidth()
  Cluster.geometry = ns.LayoutGeometry.compute(layout, Cluster.baseSize)

  -- Holds protected buttons once the layout is applied, so it is only
  -- created and sized here, before any buttons are inside. UI/EditMode.lua
  -- positions and scales it.
  local frame = CreateFrame("Frame", "WASDBarsCluster", UIParent)
  frame:SetSize(Cluster.geometry.width, Cluster.geometry.height)
  Cluster.frame = frame

  ns.combatQueue:run("layout", applyLayout)
end)

-- The spike found nothing moves the buttons back; this is a cheap safety check.
ns.Events.on("EDIT_MODE_LAYOUTS_UPDATED", function()
  if Cluster.frame and anyButtonOutOfPlace() then
    ns.debug("buttons left the cluster; re-applying")
    ns.combatQueue:run("layout", applyLayout)
  end
end)
