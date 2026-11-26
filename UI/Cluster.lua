local ADDON, ns = ...
local Cluster = {}
ns.Cluster = Cluster

local function actionButton(key)
  return _G["ActionButton" .. key.button]
end

-- The game's own hotkey text, made larger and moved to bottom centre, with
-- mouse buttons shortened to M4/M5. The game still sets the text, its range
-- colour and whether it shows; this runs again after it does.
-- With the "Large hotkey text" option off, the game's own style is put back.
local HOTKEY_SIZE = 18
local original = {}

local function remember(hotkey)
  if original[hotkey] then
    return
  end
  local points = {}
  for i = 1, hotkey:GetNumPoints() do
    points[i] = { hotkey:GetPoint(i) }
  end
  local width, height = hotkey:GetSize()
  original[hotkey] =
    { font = { hotkey:GetFont() }, points = points, width = width, height = height, justify = hotkey:GetJustifyH() }
end

local function restore(hotkey)
  local saved = original[hotkey]
  if not saved then
    return
  end
  if saved.font[1] then
    hotkey:SetFont(unpack(saved.font))
  end
  hotkey:ClearAllPoints()
  for _, point in ipairs(saved.points) do
    hotkey:SetPoint(unpack(point))
  end
  hotkey:SetSize(saved.width, saved.height)
  hotkey:SetJustifyH(saved.justify)
end

local function styleHotkey(button)
  local hotkey = button.HotKey
  if not hotkey then
    return
  end
  remember(hotkey)
  if not ns.db.largeHotkeys then
    restore(hotkey)
    return
  end
  local path = hotkey:GetFont()
  if path then
    hotkey:SetFont(path, HOTKEY_SIZE, "THICKOUTLINE")
  end
  hotkey:ClearAllPoints()
  hotkey:SetPoint("BOTTOM", button, "BOTTOM", 0, 3)
  -- the game's box is shorter than this font; make it fit so the text sits where anchored
  hotkey:SetSize(button:GetWidth(), HOTKEY_SIZE + 2)
  hotkey:SetJustifyH("CENTER")
  local text = hotkey:GetText()
  local short = ns.HotkeyText.shorten(text)
  if short ~= text then
    hotkey:SetText(short)
  end
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

-- Puts the buttons back the way the game first places them: centred in their
-- own holder (MainActionBarButtonContainerN), which carries the icon size.
-- Out of combat only, like applyLayout.
local function returnButtons()
  for _, k in ipairs(Cluster.geometry.keys) do
    if k.key.button then
      local button = actionButton(k.key)
      button:SetParent(button.container)
      button:SetScale(1)
      button:ClearAllPoints()
      button:SetPoint("CENTER")
      if button.HotKey then
        restore(button.HotKey)
      end
      if button.UpdateHotkeys then
        button:UpdateHotkeys(button.buttonType)
      end
    end
  end
  ns.debug("buttons returned")
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
  -- positions and scales it, and shows it with the buttons (Cluster.follow).
  local frame = CreateFrame("Frame", "WASDBarsCluster", UIParent)
  frame:SetSize(Cluster.geometry.width, Cluster.geometry.height)
  frame:Hide()
  Cluster.frame = frame
  Cluster.holding = false

  -- in case the game lays the hotkey out again when it updates it
  for _, k in ipairs(Cluster.geometry.keys) do
    local button = k.key.button and actionButton(k.key)
    if button and button.UpdateHotkeys then
      hooksecurefunc(button, "UpdateHotkeys", function(b)
        if Cluster.holding then
          styleHotkey(b)
        end
      end)
    end
  end
end)

-- The buttons are in the cluster exactly while the WASDBars layout is
-- active (wanted = true), and on action bar 1 otherwise. Both directions
-- share one combat queue key, so only the last one asked for runs.
function Cluster.follow(wanted)
  ns.combatQueue:run("buttons", function()
    if wanted == Cluster.holding then
      return
    end
    Cluster.holding = wanted
    if wanted then
      applyLayout()
      Cluster.frame:Show()
    else
      Cluster.frame:Hide()
      returnButtons()
    end
  end)
end

local function styleAllHotkeys()
  if not Cluster.holding then
    return
  end
  for _, k in ipairs(Cluster.geometry.keys) do
    if k.key.button then
      styleHotkey(actionButton(k.key))
    end
  end
end

-- For the "Large hotkey text" option. Font strings aren't protected, so this
-- is safe in combat. The game's text comes back on its next update or reload.
function Cluster.refreshHotkeys()
  if not Cluster.holding then
    return
  end
  styleAllHotkeys()
  if not ns.db.largeHotkeys then
    for _, k in ipairs(Cluster.geometry.keys) do
      local button = k.key.button and actionButton(k.key)
      if button and button.UpdateHotkeys then
        button:UpdateHotkeys(button.buttonType)
      end
    end
  end
end

-- After the game rewrites the hotkey text for new keybinds.
ns.Events.on("UPDATE_BINDINGS", styleAllHotkeys)

-- The spike found nothing moves the buttons back; this is a cheap safety check.
ns.Events.on("EDIT_MODE_LAYOUTS_UPDATED", function()
  if Cluster.holding and anyButtonOutOfPlace() then
    ns.debug("buttons left the cluster; re-applying")
    ns.combatQueue:run("layout", function()
      -- the layout may have been left while this waited for combat to end
      if Cluster.holding then
        applyLayout()
      end
    end)
  end
end)
