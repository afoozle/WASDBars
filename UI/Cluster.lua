local ADDON, ns = ...
local Cluster = {}
ns.Cluster = Cluster

local function actionButton(key)
  return _G["ActionButton" .. key.button]
end

-- The game's own hotkey text, made larger and moved to bottom centre. The game
-- still sets the text, its range colour and whether it shows.
local HOTKEY_SIZE = 18

local function styleHotkey(button)
  local hotkey = button.HotKey
  if not hotkey then
    return
  end
  local path = hotkey:GetFont()
  if path then
    hotkey:SetFont(path, HOTKEY_SIZE, "THICKOUTLINE")
  end
  hotkey:ClearAllPoints()
  hotkey:SetPoint("BOTTOM", button, "BOTTOM", 0, 3)
  -- no width limit, so mouse button names aren't cut to "M..."
  hotkey:SetWidth(0)
  hotkey:SetJustifyH("CENTER")
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
      styleHotkey(button)
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

  -- in case the game lays the hotkey out again when it updates it
  for _, k in ipairs(Cluster.geometry.keys) do
    local button = k.key.button and actionButton(k.key)
    if button and button.UpdateHotkeys then
      hooksecurefunc(button, "UpdateHotkeys", styleHotkey)
    end
  end
end)

-- The spike found nothing moves the buttons back; this is a cheap safety check.
ns.Events.on("EDIT_MODE_LAYOUTS_UPDATED", function()
  if Cluster.frame and anyButtonOutOfPlace() then
    ns.debug("buttons left the cluster; re-applying")
    ns.combatQueue:run("layout", applyLayout)
  end
end)
