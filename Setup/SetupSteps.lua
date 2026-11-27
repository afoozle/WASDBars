local ADDON, ns = ...
local SetupSteps = {}
ns.SetupSteps = SetupSteps

-- Which layout steps setup still needs. currentLayoutState (Setup.lua):
-- { wasdLayout = "active" | "inactive" | "missing", activeLayoutName,
-- layoutSettings (of the layout setup will change), isActionBar2On,
-- isActionBar2OnActionBar1 }. A value the game couldn't tell is nil and never
-- needs a step.

local LAYOUT_STEP_TEXTS = {
  switchToWasdLayout = "Switch to your WASDBars layout",
  moveActionButtons = "Move action bar 1's buttons into the WASD shape",
  replaceActionBar1 = "Replace action bar 1 with action bar 2",
  positionClusterAndChatWindow = "Put the WASD keys bottom left and move the chat window up",
  setUpActionBar1 = "Action Bar 1: 12 icons, always show buttons, hide bar art and scrolling",
  matchActionBar2ToActionBar1 = "Action Bar 2: same size and shape as Action Bar 1, 12 icons",
  placeActionBar2OnActionBar1 = "Put Action Bar 2 on Action Bar 1",
  hideGryphons = "Hide the gryphons",
  turnOnActionBar2 = "Turn on Action Bar 2",
}

local function isWasdLayoutMissing(currentLayoutState)
  return currentLayoutState.wasdLayout == "missing"
end

local function isWasdLayoutInactive(currentLayoutState)
  return currentLayoutState.wasdLayout == "inactive"
end

-- Switching to the layout is what moves the buttons and replaces action bar 1
-- (WasdLayoutMode.lua), so these steps are listed for the player and need no
-- applying of their own.
local function isWasdLayoutChanging(currentLayoutState)
  return currentLayoutState.wasdLayout ~= "active"
end

local function isActionBar1Wrong(currentLayoutState)
  return not ns.WasdLayoutSettings.isActionBar1SetUp(currentLayoutState.layoutSettings)
end

-- Only on a new layout: later the player may resize action bar 2.
local function isActionBar2ShapeWrong(currentLayoutState)
  return isWasdLayoutMissing(currentLayoutState)
    and not ns.WasdLayoutSettings.doesActionBar2MatchActionBar1(currentLayoutState.layoutSettings)
end

local function isActionBar2AwayFromActionBar1(currentLayoutState)
  return isWasdLayoutMissing(currentLayoutState) or currentLayoutState.isActionBar2OnActionBar1 == false
end

local function areGryphonsShowing(currentLayoutState)
  return not ns.WasdLayoutSettings.areGryphonsHidden(currentLayoutState.layoutSettings)
end

local function isActionBar2TurnedOff(currentLayoutState)
  return currentLayoutState.isActionBar2On == false
end

-- The step names still needed, in the order the setup window lists them.
function SetupSteps.findNeededLayoutSteps(currentLayoutState)
  local neededLayoutSteps = {}
  if isWasdLayoutMissing(currentLayoutState) then
    table.insert(neededLayoutSteps, "createWasdLayout")
  end
  if isWasdLayoutInactive(currentLayoutState) then
    table.insert(neededLayoutSteps, "switchToWasdLayout")
  end
  if isWasdLayoutChanging(currentLayoutState) then
    table.insert(neededLayoutSteps, "moveActionButtons")
    table.insert(neededLayoutSteps, "replaceActionBar1")
  end
  if isWasdLayoutMissing(currentLayoutState) then
    table.insert(neededLayoutSteps, "positionClusterAndChatWindow")
  end
  if isActionBar1Wrong(currentLayoutState) then
    table.insert(neededLayoutSteps, "setUpActionBar1")
  end
  if isActionBar2ShapeWrong(currentLayoutState) then
    table.insert(neededLayoutSteps, "matchActionBar2ToActionBar1")
  end
  if isActionBar2AwayFromActionBar1(currentLayoutState) then
    table.insert(neededLayoutSteps, "placeActionBar2OnActionBar1")
  end
  if areGryphonsShowing(currentLayoutState) then
    table.insert(neededLayoutSteps, "hideGryphons")
  end
  if isActionBar2TurnedOff(currentLayoutState) then
    table.insert(neededLayoutSteps, "turnOnActionBar2")
  end
  return neededLayoutSteps
end

function SetupSteps.isStepNeeded(neededLayoutSteps, stepName)
  for _, neededStep in ipairs(neededLayoutSteps) do
    if neededStep == stepName then
      return true
    end
  end
  return false
end

-- Any step that edits the layout; turning on action bar 2 is a game option.
function SetupSteps.isLayoutChangeNeeded(neededLayoutSteps)
  for _, neededStep in ipairs(neededLayoutSteps) do
    if neededStep ~= "turnOnActionBar2" then
      return true
    end
  end
  return false
end

-- The setup window's line for a step.
function SetupSteps.describeLayoutStep(stepName, currentLayoutState)
  if stepName == "createWasdLayout" then
    return "Create a WASDBars layout from '" .. currentLayoutState.activeLayoutName .. "' and switch to it"
  end
  return LAYOUT_STEP_TEXTS[stepName]
end

-- The layout half of /wasd setup status.
function SetupSteps.describeLayoutStatus(currentLayoutState, neededLayoutSteps)
  if currentLayoutState.wasdLayout ~= "active" then
    return "Not on the WASDBars layout (/wasd setup)."
  end
  if #neededLayoutSteps == 0 then
    return "Edit Mode layout ready."
  end
  local changeWord = #neededLayoutSteps == 1 and " change" or " changes"
  return "WASDBars layout needs " .. #neededLayoutSteps .. changeWord .. " (/wasd setup)."
end
