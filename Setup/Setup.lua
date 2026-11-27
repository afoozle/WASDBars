local ADDON, ns = ...
local KeybindCopies = ns.KeybindCopies
local LayoutList = ns.LayoutList
local WasdLayoutSettings = ns.WasdLayoutSettings
local SetupSteps = ns.SetupSteps
local RestorePoints = ns.RestorePoints
local Setup = {}
ns.Setup = Setup

-- The setup flow. Setup changes only the account-wide "WASDBars" Edit Mode
-- layout, the setup keys, and whether action bar 2 is on.
local NOT_READY_MESSAGE = "Edit Mode isn't ready yet. Try again in a moment."
-- the cluster's bottom edge on a new layout, in screen units
local CLUSTER_Y = 12

-- What the layout holds now; see SetupSteps.lua for the shape.
local function readCurrentLayoutState(editModeIds, allLayouts)
  local activeLayout = LayoutList.findActiveLayout(allLayouts)
  local wasdLayoutIndex = LayoutList.findLayoutIndex(allLayouts, WasdLayoutSettings.WASD_LAYOUT_NAME)
  local currentLayoutState = { activeLayoutName = activeLayout.layoutName }
  local layoutToChange = activeLayout
  if activeLayout.layoutName == WasdLayoutSettings.WASD_LAYOUT_NAME then
    currentLayoutState.wasdLayout = "active"
    currentLayoutState.isActionBar2OnActionBar1 = ns.MainBarReplacement.isActionBar2OnActionBar1()
  elseif wasdLayoutIndex then
    currentLayoutState.wasdLayout = "inactive"
    layoutToChange = allLayouts.layouts[wasdLayoutIndex]
  else
    currentLayoutState.wasdLayout = "missing"
  end
  currentLayoutState.layoutSettings = WasdLayoutSettings.readLayoutSettings(layoutToChange, editModeIds)
  currentLayoutState.isActionBar2On = ns.MainBarReplacement.isActionBar2On()
  return currentLayoutState
end

-- { editModeIds, currentLayoutState, neededLayoutSteps }, or nil before Edit Mode is ready.
local function findNeededSetup()
  if not ns.EditModeLayouts.isEditModeReady() then
    return nil
  end
  local editModeIds = ns.EditModeLayouts.findEditModeIds()
  local currentLayoutState = readCurrentLayoutState(editModeIds, ns.EditModeLayouts.loadAllLayouts())
  return {
    editModeIds = editModeIds,
    currentLayoutState = currentLayoutState,
    neededLayoutSteps = SetupSteps.findNeededLayoutSteps(currentLayoutState),
  }
end

local function isStepNeeded(neededSetup, stepName)
  return SetupSteps.isStepNeeded(neededSetup.neededLayoutSteps, stepName)
end

local function isLayoutSwitching(neededSetup)
  return isStepNeeded(neededSetup, "createWasdLayout") or isStepNeeded(neededSetup, "switchToWasdLayout")
end

local function refuseWithoutRoomForLayout(neededSetup, allLayouts)
  if isStepNeeded(neededSetup, "createWasdLayout") and not ns.EditModeLayouts.hasRoomForAnotherLayout(allLayouts) then
    ns.ChatMessages.printMessage(
      "You have the most Edit Mode layouts the game allows. Delete one, then run /wasd setup."
    )
    return true
  end
  return false
end

-- The layout and action bar 2 from before setup, for /wasd restore.
local function saveRestorePoint(neededSetup, allLayouts)
  if isLayoutSwitching(neededSetup) then
    RestorePoints.saveRestorePointOnce(
      ns.db.restore,
      UnitGUID("player"),
      LayoutList.findActiveLayout(allLayouts).layoutName,
      ns.MainBarReplacement.isActionBar2On()
    )
  end
end

-- The keys from before setup, for /wasd restore.
local function saveKeybindCopy(groupsToChange)
  if #groupsToChange > 0 then
    KeybindCopies.saveKeybindCopyOnce(ns.db.keyCopies, ns.Keybinds.findCopyOwner(), ns.Keybinds.copyCurrentKeybinds())
  end
end

-- Action bar 2's art starts as action bar 1's was in the source layout, read
-- before action bar 1's art is turned off.
local function createWasdLayout(neededSetup, allLayouts)
  ns.MainBarReplacement.matchActionBar2ArtToActionBar1(neededSetup.currentLayoutState.layoutSettings)
  ns.EditModeLayouts.copyActiveLayout(allLayouts, WasdLayoutSettings.WASD_LAYOUT_NAME)
end

local function switchToWasdLayout(allLayouts)
  LayoutList.makeLayoutActive(allLayouts, WasdLayoutSettings.WASD_LAYOUT_NAME)
end

local function applyWasdLayoutSettings(neededSetup, allLayouts)
  local wasdLayout = LayoutList.findActiveLayout(allLayouts)
  WasdLayoutSettings.applyActionBar1Settings(wasdLayout, neededSetup.editModeIds)
  if isStepNeeded(neededSetup, "createWasdLayout") then
    WasdLayoutSettings.copyActionBar1ShapeToActionBar2(wasdLayout, neededSetup.editModeIds)
  end
  WasdLayoutSettings.hideGryphons(wasdLayout, neededSetup.editModeIds)
end

local function changeLayout(neededSetup, allLayouts)
  if not SetupSteps.isLayoutChangeNeeded(neededSetup.neededLayoutSteps) then
    return
  end
  if isStepNeeded(neededSetup, "createWasdLayout") then
    createWasdLayout(neededSetup, allLayouts)
  elseif isStepNeeded(neededSetup, "switchToWasdLayout") then
    switchToWasdLayout(allLayouts)
  end
  applyWasdLayoutSettings(neededSetup, allLayouts)
  ns.EditModeLayouts.saveAllLayouts(allLayouts)
end

local function turnOnActionBar2IfOff(neededSetup)
  if isStepNeeded(neededSetup, "turnOnActionBar2") then
    ns.MainBarReplacement.turnOnActionBar2()
  end
end

local function applyKeybindChanges(groupsToChange)
  if #groupsToChange > 0 then
    ns.Keybinds.applyKeybindChanges(groupsToChange)
  end
end

-- The cluster goes bottom left, under the chat window, which moves up. The
-- cluster's position is saved first, then applied straight away.
local function positionClusterAndChatWindowOnNewLayout(neededSetup, wasdLayout)
  local clusterScale = ns.ClusterEditModeElement.findClusterPosition(WasdLayoutSettings.WASD_LAYOUT_NAME).scale
  -- cluster positions are in the cluster's scaled units
  ns.ClusterEditModeElement.saveClusterPosition(
    WasdLayoutSettings.WASD_LAYOUT_NAME,
    "BOTTOMLEFT",
    ns.ChatWindow.findLeftEdge() / clusterScale,
    CLUSTER_Y / clusterScale
  )
  local clusterTop = CLUSTER_Y + ns.ActionBarCluster.measuredCluster.height * clusterScale
  WasdLayoutSettings.moveChatWindow(
    wasdLayout,
    neededSetup.editModeIds,
    ns.ChatWindow.findAnchorAboveCluster(clusterTop)
  )
  ns.WasdLayoutMode.followActiveLayout(ns.EditModeLayouts.findActiveLayoutName())
end

-- Applying a layout from addon code taints the game's bar code (the stance
-- bar is blocked in combat) until the UI reloads, so setup asks for a reload
-- when it changed the layout or action bar 2's setting. Keybinds alone don't.
local function confirmSetupOrAskForReload(neededSetup)
  if #neededSetup.neededLayoutSteps > 0 then
    ns.ReloadPrompt.askForReloadAfterSetup()
  else
    ns.ChatMessages.printMessage("Set up.")
  end
end

-- Second pass, once the first save has been laid out: action bar 2 onto
-- action bar 1 and, for a new layout, the cluster and the chat window.
local function placeActionBar2OnActionBar1(neededSetup)
  local allLayouts = ns.EditModeLayouts.loadAllLayouts()
  local wasdLayout = LayoutList.findActiveLayout(allLayouts)
  local actionBar2Anchor = ns.MainBarReplacement.findActionBar2AnchorOnActionBar1()
  if actionBar2Anchor then
    WasdLayoutSettings.moveActionBar2(wasdLayout, neededSetup.editModeIds, actionBar2Anchor)
  end
  if isStepNeeded(neededSetup, "createWasdLayout") then
    positionClusterAndChatWindowOnNewLayout(neededSetup, wasdLayout)
  end
  ns.EditModeLayouts.saveAllLayouts(allLayouts)
  confirmSetupOrAskForReload(neededSetup)
end

local function placeActionBar2OutOfCombat(neededSetup)
  ns.CombatQueue.runOutOfCombat("setup-place", function()
    placeActionBar2OnActionBar1(neededSetup)
  end)
end

-- Action bar 2 is measured after the game has laid out the first save.
local function finishSetup(neededSetup)
  if isStepNeeded(neededSetup, "placeActionBar2OnActionBar1") then
    C_Timer.After(0, function()
      placeActionBar2OutOfCombat(neededSetup)
    end)
  else
    confirmSetupOrAskForReload(neededSetup)
  end
end

-- When Set up is clicked in the setup window.
local function runSetup(neededSetup, groupsToChange)
  if ns.SetupGuards.refuseInCombat("set up") or ns.SetupGuards.refuseInEditMode("setup") then
    return
  end
  local allLayouts = ns.EditModeLayouts.loadAllLayouts()
  if refuseWithoutRoomForLayout(neededSetup, allLayouts) then
    return
  end
  saveRestorePoint(neededSetup, allLayouts)
  saveKeybindCopy(groupsToChange)
  changeLayout(neededSetup, allLayouts)
  turnOnActionBar2IfOff(neededSetup)
  applyKeybindChanges(groupsToChange)
  finishSetup(neededSetup)
end

local function describeLayoutSteps(neededSetup)
  local neededLayoutStepTexts = {}
  for i, stepName in ipairs(neededSetup.neededLayoutSteps) do
    neededLayoutStepTexts[i] = SetupSteps.describeLayoutStep(stepName, neededSetup.currentLayoutState)
  end
  return neededLayoutStepTexts
end

-- /wasd setup and the Run setup button.
function Setup.openSetupWindow()
  if ns.SetupGuards.refuseInCombat("set up") or ns.SetupWindow.isSetupWindowShown() then
    return
  end
  if ns.SetupGuards.refuseInEditMode("setup") then
    return
  end
  local neededSetup = findNeededSetup()
  if not neededSetup then
    ns.ChatMessages.printMessage(NOT_READY_MESSAGE)
    return
  end
  local groupsToChange = ns.Keybinds.findGroupsToChange()
  if #neededSetup.neededLayoutSteps == 0 and #groupsToChange == 0 then
    ns.ChatMessages.printMessage("Everything is set up.")
    return
  end
  local actionsLosingTheirKey = ns.Keybinds.findActionsLosingTheirKey(groupsToChange)
  ns.SetupWindow.showSetupChanges(describeLayoutSteps(neededSetup), groupsToChange, actionsLosingTheirKey, function()
    runSetup(neededSetup, groupsToChange)
  end)
end

-- For the first-time offer. False before Edit Mode is ready.
function Setup.isAnythingLeftToSetUp()
  local neededSetup = findNeededSetup()
  if not neededSetup then
    return false
  end
  return #neededSetup.neededLayoutSteps > 0 or not ns.Keybinds.isEveryKeybindSetUp()
end

-- For the login reminder. False before Edit Mode is ready.
function Setup.isOffWasdLayout()
  local neededSetup = findNeededSetup()
  return neededSetup ~= nil and neededSetup.currentLayoutState.wasdLayout ~= "active"
end

-- /wasd setup status.
function Setup.describeSetupStatus()
  local neededSetup = findNeededSetup()
  local layoutStatus = NOT_READY_MESSAGE
  if neededSetup then
    layoutStatus = SetupSteps.describeLayoutStatus(neededSetup.currentLayoutState, neededSetup.neededLayoutSteps)
  end
  return ns.Keybinds.describeKeybindStatus() .. " " .. layoutStatus
end
