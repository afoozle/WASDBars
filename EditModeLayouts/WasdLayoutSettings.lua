local ADDON, ns = ...
local WasdLayoutSettings = {}
ns.WasdLayoutSettings = WasdLayoutSettings

-- The settings the WASDBars layout needs, on Edit Mode layout tables as
-- C_EditMode.GetLayouts() returns them: { layoutName, layoutType, systems = {
-- { system, systemIndex, anchorInfo, settings = { { setting, value } },
-- isInDefaultPosition } } }. editModeIds: EditModeIds.readEditModeIds.

-- The only Edit Mode layout the addon ever changes.
WasdLayoutSettings.WASD_LAYOUT_NAME = "WASDBars"

-- Action bar 1's settings in the WASDBars layout, as Edit Mode stores them
-- (checkboxes are 1 or 0). Keys name entries in editModeIds.actionBarSettings.
local ACTION_BAR_1_SETTINGS = { numIcons = 12, alwaysShowButtons = 1, hideBarArt = 1, hideBarScrolling = 1 }
-- Action bar 2 copies these from action bar 1. They're copied as stored, so
-- icon size (kept as a slider step, not a percentage) needs no conversion.
local ACTION_BAR_SHAPE_SETTINGS = { "orientation", "numRows", "iconSize", "iconPadding" }
local ACTION_BAR_2_ICON_COUNT = 12

-- The system entry for system/systemIndex; systemIndex nil matches any.
local function findSystem(layout, system, systemIndex)
  if system == nil then
    return nil
  end
  for _, systemEntry in ipairs(layout.systems) do
    if systemEntry.system == system and (systemIndex == nil or systemEntry.systemIndex == systemIndex) then
      return systemEntry
    end
  end
  return nil
end

local function readSetting(systemEntry, setting)
  if not systemEntry or setting == nil then
    return nil
  end
  for _, settingEntry in ipairs(systemEntry.settings) do
    if settingEntry.setting == setting then
      return settingEntry.value
    end
  end
  return nil
end

local function writeSetting(systemEntry, setting, value)
  if not systemEntry or setting == nil then
    return
  end
  for _, settingEntry in ipairs(systemEntry.settings) do
    if settingEntry.setting == setting then
      settingEntry.value = value
      return
    end
  end
  table.insert(systemEntry.settings, { setting = setting, value = value })
end

-- Anchor: { point, relativeTo (a frame name), relativePoint, offsetX, offsetY }.
local function moveSystem(systemEntry, anchor)
  if not systemEntry then
    return
  end
  systemEntry.anchorInfo = {
    point = anchor.point,
    relativeTo = anchor.relativeTo,
    relativePoint = anchor.relativePoint,
    offsetX = anchor.offsetX,
    offsetY = anchor.offsetY,
  }
  systemEntry.isInDefaultPosition = false
end

local function findActionBar(layout, editModeIds, actionBarIndex)
  return findSystem(layout, editModeIds.actionBarSystem, actionBarIndex)
end

local function readActionBarSettings(layout, editModeIds, actionBarIndex)
  local systemEntry = findActionBar(layout, editModeIds, actionBarIndex)
  local actionBarSettings = {}
  for settingName, setting in pairs(editModeIds.actionBarSettings) do
    actionBarSettings[settingName] = readSetting(systemEntry, setting)
  end
  return actionBarSettings
end

local function readEndCapHidden(layout, editModeIds, endCapIndex)
  return readSetting(findSystem(layout, editModeIds.endCapSystem, endCapIndex), editModeIds.endCapHiddenSetting)
end

-- A value the game couldn't tell (nil) never counts as wrong.
local function differs(value, wantedValue)
  return value ~= nil and wantedValue ~= nil and value ~= wantedValue
end

-- What the layout holds for setup's checks: { actionBar1 = { settingName = value },
-- actionBar2 = { … }, gryphonsHidden = { left, right } }. A missing system or
-- setting reads as nil.
function WasdLayoutSettings.readLayoutSettings(layout, editModeIds)
  return {
    actionBar1 = readActionBarSettings(layout, editModeIds, editModeIds.actionBar1Index),
    actionBar2 = readActionBarSettings(layout, editModeIds, editModeIds.actionBar2Index),
    gryphonsHidden = {
      left = readEndCapHidden(layout, editModeIds, editModeIds.leftEndCapIndex),
      right = readEndCapHidden(layout, editModeIds, editModeIds.rightEndCapIndex),
    },
  }
end

function WasdLayoutSettings.isActionBar1SetUp(layoutSettings)
  for settingName, wantedValue in pairs(ACTION_BAR_1_SETTINGS) do
    if differs(layoutSettings.actionBar1[settingName], wantedValue) then
      return false
    end
  end
  return true
end

-- Action bar 2 has 12 icons and action bar 1's shape.
function WasdLayoutSettings.doesActionBar2MatchActionBar1(layoutSettings)
  local actionBar1, actionBar2 = layoutSettings.actionBar1, layoutSettings.actionBar2
  if differs(actionBar2.numIcons, ACTION_BAR_2_ICON_COUNT) then
    return false
  end
  for _, settingName in ipairs(ACTION_BAR_SHAPE_SETTINGS) do
    if differs(actionBar2[settingName], actionBar1[settingName]) then
      return false
    end
  end
  return true
end

function WasdLayoutSettings.areGryphonsHidden(layoutSettings)
  local gryphonsHidden = layoutSettings.gryphonsHidden
  return not (differs(gryphonsHidden.left, 1) or differs(gryphonsHidden.right, 1))
end

function WasdLayoutSettings.applyActionBar1Settings(layout, editModeIds)
  local actionBar1 = findActionBar(layout, editModeIds, editModeIds.actionBar1Index)
  for settingName, value in pairs(ACTION_BAR_1_SETTINGS) do
    writeSetting(actionBar1, editModeIds.actionBarSettings[settingName], value)
  end
end

-- For a new layout only: later the player may resize action bar 2.
function WasdLayoutSettings.copyActionBar1ShapeToActionBar2(layout, editModeIds)
  local actionBar1 = findActionBar(layout, editModeIds, editModeIds.actionBar1Index)
  local actionBar2 = findActionBar(layout, editModeIds, editModeIds.actionBar2Index)
  writeSetting(actionBar2, editModeIds.actionBarSettings.numIcons, ACTION_BAR_2_ICON_COUNT)
  for _, settingName in ipairs(ACTION_BAR_SHAPE_SETTINGS) do
    local setting = editModeIds.actionBarSettings[settingName]
    local value = readSetting(actionBar1, setting)
    if value ~= nil then
      writeSetting(actionBar2, setting, value)
    end
  end
end

function WasdLayoutSettings.hideGryphons(layout, editModeIds)
  for _, endCapIndex in ipairs({ editModeIds.leftEndCapIndex, editModeIds.rightEndCapIndex }) do
    writeSetting(findSystem(layout, editModeIds.endCapSystem, endCapIndex), editModeIds.endCapHiddenSetting, 1)
  end
end

function WasdLayoutSettings.moveActionBar2(layout, editModeIds, anchor)
  moveSystem(findActionBar(layout, editModeIds, editModeIds.actionBar2Index), anchor)
end

function WasdLayoutSettings.moveChatWindow(layout, editModeIds, anchor)
  moveSystem(findSystem(layout, editModeIds.chatSystem, nil), anchor)
end
