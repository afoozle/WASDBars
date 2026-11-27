local ADDON, ns = ...
local ActionBarCluster = {}
ns.ActionBarCluster = ActionBarCluster

-- The cluster frame, and action bar 1's buttons in it while the WASDBars
-- layout is active.
local clusterFrame, measuredCluster, buttonSize
local areActionButtonsInCluster = false

-- The game's own hotkey text, made larger and moved to bottom centre, with
-- mouse buttons shortened to M4/M5. The game still sets the text, its range
-- colour and whether it shows; this runs again after it does. With the
-- "Large hotkey text" option off, the game's own style is put back.
local LARGE_HOTKEY_SIZE = 18
local gameHotkeyStyles = {}

local function findActionButton(measuredKey)
  return _G["ActionButton" .. measuredKey.clusterKey.actionButtonNumber]
end

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
  local shortHotkeyText = ns.HotkeyText.shortenMouseButtonNames(hotkeyText)
  if shortHotkeyText ~= hotkeyText then
    hotkey:SetText(shortHotkeyText)
  end
end

local function restyleHotkey(button)
  if not button.HotKey then
    return
  end
  saveGameHotkeyStyle(button.HotKey)
  if ns.db.largeHotkeys then
    applyLargeHotkeyStyle(button)
  else
    applyGameHotkeyStyle(button.HotKey)
  end
end

local function restyleAllHotkeys()
  for _, measuredKey in ipairs(measuredCluster.measuredKeys) do
    if measuredKey.clusterKey.actionButtonNumber then
      restyleHotkey(findActionButton(measuredKey))
    end
  end
end

-- Has the game write its own hotkey text again.
local function redrawGameHotkeys()
  for _, measuredKey in ipairs(measuredCluster.measuredKeys) do
    local button = measuredKey.clusterKey.actionButtonNumber and findActionButton(measuredKey)
    if button and button.UpdateHotkeys then
      button:UpdateHotkeys(button.buttonType)
    end
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
  for _, measuredKey in ipairs(measuredCluster.measuredKeys) do
    if measuredKey.clusterKey.actionButtonNumber then
      local button = findActionButton(measuredKey)
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
  end
  ns.ChatMessages.printDebugMessage("layout applied")
end

-- Puts the buttons back the way the game first places them: centred in their
-- own holder (MainActionBarButtonContainerN), which carries the icon size.
-- Out of combat only.
local function returnActionButtonsToActionBar1()
  for _, measuredKey in ipairs(measuredCluster.measuredKeys) do
    if measuredKey.clusterKey.actionButtonNumber then
      local button = findActionButton(measuredKey)
      button:SetParent(button.container)
      button:SetScale(1)
      button:ClearAllPoints()
      button:SetPoint("CENTER")
      if button.HotKey then
        applyGameHotkeyStyle(button.HotKey)
      end
      if button.UpdateHotkeys then
        button:UpdateHotkeys(button.buttonType)
      end
    end
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
  for _, measuredKey in ipairs(measuredCluster.measuredKeys) do
    if measuredKey.clusterKey.actionButtonNumber and findActionButton(measuredKey):GetParent() ~= clusterFrame then
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
  buttonSize = _G.ActionButton1:GetWidth()
  measuredCluster = ns.ClusterGeometry.measureClusterKeys(ns.ClusterKeys, buttonSize)
  clusterFrame = CreateFrame("Frame", "WASDBarsCluster", UIParent)
  clusterFrame:SetSize(measuredCluster.width, measuredCluster.height)
  clusterFrame:Hide()
  for _, measuredKey in ipairs(measuredCluster.measuredKeys) do
    local button = measuredKey.clusterKey.actionButtonNumber and findActionButton(measuredKey)
    if button and button.UpdateHotkeys then
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

function ActionBarCluster.areActionButtonsInCluster()
  return areActionButtonsInCluster
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

-- For the "Large hotkey text" option. Font strings aren't protected, so these
-- are safe in combat.
function ActionBarCluster.showLargeHotkeys()
  if areActionButtonsInCluster then
    restyleAllHotkeys()
  end
end

-- The game's text comes back on its next update.
function ActionBarCluster.showGameHotkeys()
  if areActionButtonsInCluster then
    restyleAllHotkeys()
    redrawGameHotkeys()
  end
end

-- After the game rewrites the hotkey text for new keybinds.
function ActionBarCluster.restyleHotkeysAfterKeybindChange()
  if areActionButtonsInCluster then
    restyleAllHotkeys()
  end
end

function ActionBarCluster.findClusterFrame()
  return clusterFrame
end

function ActionBarCluster.findMeasuredKeys()
  return measuredCluster.measuredKeys
end

function ActionBarCluster.findButtonSize()
  return buttonSize
end

-- Unscaled.
function ActionBarCluster.measureClusterHeight()
  return clusterFrame:GetHeight()
end
