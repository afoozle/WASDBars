local ADDON, ns = ...
local KeybindCopies = ns.KeybindCopies
local LayoutList = ns.LayoutList
local WasdLayoutSettings = ns.WasdLayoutSettings
local SetupSteps = ns.SetupSteps
local RestoreSteps = ns.RestoreSteps
local ClusterPositions = ns.ClusterPositions
local Setup = {}
ns.Setup = Setup

-- The setup flow and the first-time offer. Setup changes only the account-wide
-- "WASDBars" Edit Mode layout, the setup keys, and whether action bar 2 is on.
local WASD_LAYOUT_NAME = WasdLayoutSettings.WASD_LAYOUT_NAME
local OFFER_POPUP = "WASDBARS_OFFER_SETUP"
-- the cluster's bottom edge on a new layout, in screen units, and the space
-- between its top and the chat window, which leaves room for the chat's edit box
local CLUSTER_Y, CHAT_GAP = 12, 40

local hasCheckedOfferThisLogin = false

-- What the layout holds now; see SetupSteps.lua for the shape.
local function readCurrentLayoutState(editModeIds, allLayouts)
  local activeLayout = LayoutList.findActiveLayout(allLayouts)
  local wasdLayoutIndex = LayoutList.findLayoutIndex(allLayouts, WASD_LAYOUT_NAME)
  local currentLayoutState = { activeLayoutName = activeLayout.layoutName, isActionBar2On = ns.MainBarReplacement.isActionBar2On() }
  local layoutToChange = activeLayout
  if activeLayout.layoutName == WASD_LAYOUT_NAME then
    currentLayoutState.wasdLayout = "active"
    currentLayoutState.isActionBar2OnActionBar1 = ns.MainBarReplacement.isActionBar2OnActionBar1()
  elseif wasdLayoutIndex then
    currentLayoutState.wasdLayout = "inactive"
    layoutToChange = allLayouts.layouts[wasdLayoutIndex]
  else
    currentLayoutState.wasdLayout = "missing"
  end
  currentLayoutState.layoutSettings = WasdLayoutSettings.readLayoutSettings(layoutToChange, editModeIds)
  return currentLayoutState
end

-- { editModeIds, currentLayoutState, neededLayoutSteps }, or nil before Edit Mode is ready.
local function findNeededSetup()
  if not ns.EditModeLayouts.isEditModeReady() then
    return nil
  end
  local editModeIds = ns.EditModeLayouts.findEditModeIds()
  local currentLayoutState = readCurrentLayoutState(editModeIds, ns.EditModeLayouts.loadAllLayouts())
  return { editModeIds = editModeIds, currentLayoutState = currentLayoutState, neededLayoutSteps = SetupSteps.findNeededLayoutSteps(currentLayoutState) }
end

local function isStepNeeded(neededSetup, stepName)
  return SetupSteps.isStepNeeded(neededSetup.neededLayoutSteps, stepName)
end

-- What /wasd restore puts back: the layout and action bar 2, and the keys.
local function saveRestorePoints(neededSetup, allLayouts, groupsToChange)
  if isStepNeeded(neededSetup, "createWasdLayout") or isStepNeeded(neededSetup, "switchToWasdLayout") then
    local activeLayoutName = LayoutList.findActiveLayout(allLayouts).layoutName
    RestoreSteps.saveRestorePointOnce(ns.db.restore, UnitGUID("player"), activeLayoutName, ns.MainBarReplacement.isActionBar2On())
  end
  if #groupsToChange > 0 then
    KeybindCopies.saveKeybindCopyOnce(ns.db.keyCopies, ns.Keybinds.findCopyOwner(), ns.Keybinds.copyCurrentKeybinds())
  end
end

-- Creates or switches to the WASDBars layout, sets it up and saves it.
local function changeLayout(neededSetup, allLayouts)
  local editModeIds = neededSetup.editModeIds
  local isCreating = isStepNeeded(neededSetup, "createWasdLayout")
  if isCreating then
    -- action bar 2's art starts as action bar 1's was, read before action bar 1's art is turned off
    ns.MainBarReplacement.matchActionBar2ArtToActionBar1(neededSetup.currentLayoutState.layoutSettings)
    ns.EditModeLayouts.copyActiveLayout(allLayouts, WASD_LAYOUT_NAME)
  elseif isStepNeeded(neededSetup, "switchToWasdLayout") then
    LayoutList.makeLayoutActive(allLayouts, WASD_LAYOUT_NAME)
  end
  local wasdLayout = LayoutList.findActiveLayout(allLayouts)
  WasdLayoutSettings.applyActionBar1Settings(wasdLayout, editModeIds)
  if isCreating then
    WasdLayoutSettings.copyActionBar1ShapeToActionBar2(wasdLayout, editModeIds)
  end
  WasdLayoutSettings.hideGryphons(wasdLayout, editModeIds)
  ns.EditModeLayouts.saveAllLayouts(allLayouts)
end

-- On a new layout the cluster goes under the chat window at its left edge, and
-- the chat window moves up. The cluster's position is saved, then applied straight away.
local function placeClusterAndChatWindow(neededSetup, wasdLayout)
  local clusterScale = ClusterPositions.findClusterPosition(ns.db.layouts, WASD_LAYOUT_NAME).scale
  local chatScale = ChatFrame1:GetEffectiveScale() / UIParent:GetEffectiveScale()
  -- cluster positions are in the cluster's scaled units
  ClusterPositions.saveClusterPosition(ns.db.layouts, WASD_LAYOUT_NAME, "BOTTOMLEFT", ChatFrame1:GetLeft() * chatScale / clusterScale, CLUSTER_Y / clusterScale)
  local clusterTop = CLUSTER_Y + ns.ActionBarCluster.measuredCluster.height * clusterScale
  WasdLayoutSettings.moveChatWindow(wasdLayout, neededSetup.editModeIds, {
    point = "BOTTOMLEFT",
    relativeTo = "UIParent",
    relativePoint = "BOTTOMLEFT",
    offsetX = ChatFrame1:GetLeft(),
    offsetY = (clusterTop + CHAT_GAP) / chatScale,
  })
  ns.WasdLayoutMode.followActiveLayout(ns.EditModeLayouts.findActiveLayoutName())
end

-- Applying a layout from addon code taints the game's bar code (the stance
-- bar is blocked in combat) until the UI reloads, so setup asks for a reload
-- when it changed the layout or action bar 2's setting. Keybinds alone don't.
local function finishSetup(neededSetup)
  if #neededSetup.neededLayoutSteps > 0 then
    ns.SetupWindow.askForReload("Set up")
  else
    ns.ChatMessages.printMessage("Set up.")
  end
end

-- Second pass, once the first save has been laid out: action bar 2 onto
-- action bar 1 and, for a new layout, the cluster and the chat window.
local function placeActionBar2(neededSetup)
  local allLayouts = ns.EditModeLayouts.loadAllLayouts()
  local wasdLayout = LayoutList.findActiveLayout(allLayouts)
  local actionBar2Anchor = ns.MainBarReplacement.findActionBar2AnchorOnActionBar1()
  if actionBar2Anchor then
    WasdLayoutSettings.moveActionBar2(wasdLayout, neededSetup.editModeIds, actionBar2Anchor)
  end
  if isStepNeeded(neededSetup, "createWasdLayout") then
    placeClusterAndChatWindow(neededSetup, wasdLayout)
  end
  ns.EditModeLayouts.saveAllLayouts(allLayouts)
  finishSetup(neededSetup)
end

-- When Set up is clicked in the setup window.
local function runSetup(neededSetup, groupsToChange)
  if ns.SetupGuards.refuseLayoutChange("set up", "setup") then
    return
  end
  local allLayouts = ns.EditModeLayouts.loadAllLayouts()
  if isStepNeeded(neededSetup, "createWasdLayout") and not ns.EditModeLayouts.hasRoomForAnotherLayout(allLayouts) then
    ns.ChatMessages.printMessage("You have the most Edit Mode layouts the game allows. Delete one, then run /wasd setup.")
    return
  end
  saveRestorePoints(neededSetup, allLayouts, groupsToChange)
  if SetupSteps.isLayoutChangeNeeded(neededSetup.neededLayoutSteps) then
    changeLayout(neededSetup, allLayouts)
  end
  if isStepNeeded(neededSetup, "turnOnActionBar2") then
    ns.MainBarReplacement.turnOnActionBar2()
  end
  if #groupsToChange > 0 then
    ns.Keybinds.applyKeybindChanges(groupsToChange)
  end
  if not isStepNeeded(neededSetup, "placeActionBar2OnActionBar1") then
    finishSetup(neededSetup)
    return
  end
  -- action bar 2 is measured after the game has laid out the first save
  C_Timer.After(0, function()
    ns.CombatQueue.runOutOfCombat("setup-place", function()
      placeActionBar2(neededSetup)
    end)
  end)
end

-- /wasd setup and the Run setup button.
function Setup.openSetupWindow()
  if ns.SetupGuards.refuseLayoutChange("set up", "setup") then
    return
  end
  local neededSetup = findNeededSetup()
  local groupsToChange = ns.Keybinds.findGroupsToChange()
  if #neededSetup.neededLayoutSteps == 0 and #groupsToChange == 0 then
    ns.ChatMessages.printMessage("Everything is set up.")
    return
  end
  local neededLayoutStepTexts = {}
  for i, stepName in ipairs(neededSetup.neededLayoutSteps) do
    neededLayoutStepTexts[i] = SetupSteps.describeLayoutStep(stepName, neededSetup.currentLayoutState)
  end
  local actionsLosingTheirKey = ns.Keybinds.findActionsLosingTheirKey(groupsToChange)
  ns.SetupWindow.showSetupChanges(neededLayoutStepTexts, groupsToChange, actionsLosingTheirKey, function()
    runSetup(neededSetup, groupsToChange)
  end)
end

StaticPopupDialogs[OFFER_POPUP] = {
  text = "Set up WASDBars?\n\nIt moves action bar 1's buttons into the WASD shape, "
    .. "makes a WASDBars Edit Mode layout and binds your keys. "
    .. "You'll see every change before anything happens.",
  button1 = "Set up",
  button2 = "Not now",
  OnAccept = function()
    C_Timer.After(0, Setup.openSetupWindow)
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}

-- Setup is offered once per character, when its keys or its layout aren't set
-- up. Otherwise, a character not on the WASDBars layout gets a one-line
-- reminder at every login. The realm name isn't ready yet at PLAYER_LOGIN; the GUID is.
local function offerSetupOrRemind()
  local neededSetup = findNeededSetup()
  if not neededSetup then
    return
  end
  local playerGuid = UnitGUID("player")
  local isAnythingLeftToSetUp = #neededSetup.neededLayoutSteps > 0 or #ns.Keybinds.findGroupsToChange() > 0
  if not ns.db.setupOffered[playerGuid] and isAnythingLeftToSetUp then
    ns.CombatQueue.runOutOfCombat("setup-offer", function()
      ns.db.setupOffered[playerGuid] = true
      StaticPopup_Show(OFFER_POPUP)
    end)
  elseif neededSetup.currentLayoutState.wasdLayout ~= "active" then
    ns.ChatMessages.printMessage("Not set up on this character. Type /wasd setup to set it up.")
  end
end

-- On every Edit Mode update: layouts arrive after login, so only the first
-- one per login does anything.
function Setup.offerSetupOrRemindOncePerLogin()
  if not hasCheckedOfferThisLogin then
    hasCheckedOfferThisLogin = true
    C_Timer.After(0, offerSetupOrRemind)
  end
end
