local ADDON, ns = ...
local ClusterKeys = ns.ClusterKeys
local ClusterGeometry = ns.ClusterGeometry
local HotkeyText = ns.HotkeyText
local ActionBarCluster = {}
ns.ActionBarCluster = ActionBarCluster

-- The cluster frame, and action bar 1's buttons in it while the WASDBars
-- layout is active. clusterFrame, measuredCluster (ClusterGeometry) and
-- buttonSize are set at login.
local clusterFrame
-- { button, measuredKey } for action bar 1's 12 buttons
local actionButtonKeys = {}
local areActionButtonsInCluster = false

-- The game's own hotkey text, made larger and moved to bottom centre, with
-- mouse buttons shortened to M4/M5. The game still sets the text, its range
-- colour and whether it shows; this runs again after it does. With the
-- "Large hotkey text" option off, the game's own style is put back.
local LARGE_HOTKEY_SIZE = 18
local gameHotkeyStyles = {}

local function saveGameHotkeyStyle(hotkey)
  if gameHotkeyStyles[hotkey] then
    return
  end
  local points = {}
  for i = 1, hotkey:GetNumPoints() do
    points[i] = { hotkey:GetPoint(i) }
  end
  local width, height = hotkey:GetSize()
  gameHotkeyStyles[hotkey] =
    { font = { hotkey:GetFont() }, points = points, width = width, height = height, justify = hotkey:GetJustifyH() }
end

local function applyGameHotkeyStyle(hotkey)
  local gameHotkeyStyle = gameHotkeyStyles[hotkey]
  if not gameHotkeyStyle then
    return
  end
  if gameHotkeyStyle.font[1] then
    hotkey:SetFont(unpack(gameHotkeyStyle.font))
  end
  hotkey:ClearAllPoints()
  for _, point in ipairs(gameHotkeyStyle.points) do
    hotkey:SetPoint(unpack(point))
  end
  hotkey:SetSize(gameHotkeyStyle.width, gameHotkeyStyle.height)
  hotkey:SetJustifyH(gameHotkeyStyle.justify)
end

local function applyLargeHotkeyStyle(button)
  local hotkey = button.HotKey
  local fontPath = hotkey:GetFont()
  if fontPath then
    hotkey:SetFont(fontPath, LARGE_HOTKEY_SIZE, "THICKOUTLINE")
  end
  hotkey:ClearAllPoints()
  hotkey:SetPoint("BOTTOM", button, "BOTTOM", 0, 3)
  -- the game's box is shorter than this font; make it fit so the text sits where anchored
  hotkey:SetSize(button:GetWidth(), LARGE_HOTKEY_SIZE + 2)
  hotkey:SetJustifyH("CENTER")
  local hotkeyText = hotkey:GetText()
  local shortHotkeyText = HotkeyText.shortenMouseButtonNames(hotkeyText)
  if shortHotkeyText ~= hotkeyText then
    hotkey:SetText(shortHotkeyText)
  end
end

local function restyleHotkey(button)
  saveGameHotkeyStyle(button.HotKey)
  if ns.db.largeHotkeys then
    applyLargeHotkeyStyle(button)
  else
    applyGameHotkeyStyle(button.HotKey)
  end
end

-- In case the game lays the hotkey out again when it updates it.
local function restyleHotkeyWhileInCluster(button)
  if areActionButtonsInCluster then
    restyleHotkey(button)
  end
end

-- Puts the game's action buttons in their cluster keys. Out of combat only.
local function arrangeActionButtonsInCluster()
  for _, actionButtonKey in ipairs(actionButtonKeys) do
    local button, measuredKey = actionButtonKey.button, actionButtonKey.measuredKey
    button:SetParent(clusterFrame)
    button:ClearAllPoints()
    button:SetScale(measuredKey.scale)
    -- a scaled frame's offsets are in its own scaled units
    button:SetPoint(
      "CENTER",
      clusterFrame,
      "TOPLEFT",
      measuredKey.centreX / measuredKey.scale,
      -measuredKey.centreY / measuredKey.scale
    )
    restyleHotkey(button)
  end
  ns.ChatMessages.printDebugMessage("layout applied")
end

-- Puts the buttons back the way the game first places them: centred in their
-- own holder (MainActionBarButtonContainerN), which carries the icon size.
-- Out of combat only.
local function returnActionButtonsToActionBar1()
  for _, actionButtonKey in ipairs(actionButtonKeys) do
    local button = actionButtonKey.button
    button:SetParent(button.container)
    button:SetScale(1)
    button:ClearAllPoints()
    button:SetPoint("CENTER")
    applyGameHotkeyStyle(button.HotKey)
    button:UpdateHotkeys(button.buttonType)
  end
  ns.ChatMessages.printDebugMessage("buttons returned")
end

local function attachActionButtonsToCluster()
  if areActionButtonsInCluster then
    return
  end
  areActionButtonsInCluster = true
  arrangeActionButtonsInCluster()
  clusterFrame:Show()
end

local function detachActionButtonsFromCluster()
  if not areActionButtonsInCluster then
    return
  end
  areActionButtonsInCluster = false
  clusterFrame:Hide()
  returnActionButtonsToActionBar1()
end

local function isAnyActionButtonOutOfCluster()
  for _, actionButtonKey in ipairs(actionButtonKeys) do
    if actionButtonKey.button:GetParent() ~= clusterFrame then
      return true
    end
  end
  return false
end

-- The layout may have been left while this waited for combat to end.
local function rearrangeActionButtonsIfStillInCluster()
  if areActionButtonsInCluster then
    arrangeActionButtonsInCluster()
  end
end

-- Scale first, then the point: the offsets are in the frame's scaled units.
local function placeClusterFrame(clusterPosition)
  clusterFrame:SetScale(clusterPosition.scale)
  clusterFrame:ClearAllPoints()
  clusterFrame:SetPoint(clusterPosition.point, UIParent, clusterPosition.point, clusterPosition.x, clusterPosition.y)
end

-- At login. The frame holds protected buttons once they're in it, so it is
-- only created and sized here, before any buttons are inside.
function ActionBarCluster.buildActionBarCluster()
  ActionBarCluster.buttonSize = _G.ActionButton1:GetWidth()
  local measuredCluster = ClusterGeometry.measureClusterKeys(ClusterKeys, ActionBarCluster.buttonSize)
  ActionBarCluster.measuredCluster = measuredCluster
  clusterFrame = CreateFrame("Frame", "WASDBarsCluster", UIParent)
  clusterFrame:SetSize(measuredCluster.width, measuredCluster.height)
  clusterFrame:Hide()
  ActionBarCluster.clusterFrame = clusterFrame
  for _, measuredKey in ipairs(measuredCluster.measuredKeys) do
    local actionButtonNumber = measuredKey.clusterKey.actionButtonNumber
    if actionButtonNumber then
      local button = _G["ActionButton" .. actionButtonNumber]
      table.insert(actionButtonKeys, { button = button, measuredKey = measuredKey })
      hooksecurefunc(button, "UpdateHotkeys", restyleHotkeyWhileInCluster)
    end
  end
end

-- Both directions share one combat queue job name, so only the last one asked for runs.
function ActionBarCluster.moveActionButtonsIntoCluster()
  ns.CombatQueue.runOutOfCombat("buttons", attachActionButtonsToCluster)
end

function ActionBarCluster.moveActionButtonsBackToActionBar1()
  ns.CombatQueue.runOutOfCombat("buttons", detachActionButtonsFromCluster)
end

-- The spike found nothing moves the buttons back; this is a cheap safety check.
function ActionBarCluster.moveStrayActionButtonsIntoCluster()
  if areActionButtonsInCluster and isAnyActionButtonOutOfCluster() then
    ns.ChatMessages.printDebugMessage("buttons left the cluster; re-applying")
    ns.CombatQueue.runOutOfCombat("layout", rearrangeActionButtonsIfStillInCluster)
  end
end

-- clusterPosition: { point, x, y, scale } (ClusterPositions.lua)
function ActionBarCluster.repositionActionBarCluster(clusterPosition)
  ns.CombatQueue.runOutOfCombat("placement", function()
    placeClusterFrame(clusterPosition)
  end)
end

-- After the "Large hotkey text" option or keybinds change: the game writes
-- its hotkey text again, and the hook above restyles it. Font strings aren't
-- protected, so this is safe in combat.
function ActionBarCluster.refreshHotkeys()
  if areActionButtonsInCluster then
    for _, actionButtonKey in ipairs(actionButtonKeys) do
      actionButtonKey.button:UpdateHotkeys(actionButtonKey.button.buttonType)
    end
  end
end
