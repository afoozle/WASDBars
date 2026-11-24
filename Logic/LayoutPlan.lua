local ADDON, ns = ...
local LayoutPlan = {}
ns.LayoutPlan = LayoutPlan

-- The only Edit Mode layout the addon ever changes.
LayoutPlan.NAME = "WASDBars"

-- Action bar 1's settings in the WASDBars layout, as Edit Mode stores them
-- (checkboxes are 1 or 0). Keys name entries in ids.bar (see below).
LayoutPlan.BAR1 = { numIcons = 12, alwaysShowButtons = 1, hideBarArt = 1, hideBarScrolling = 1 }
-- Action bar 2 copies these from action bar 1. They're copied as stored, so
-- icon size (kept as a slider step, not a percentage) needs no conversion.
LayoutPlan.SHAPE = { "orientation", "numRows", "iconSize", "iconPadding" }

-- All functions work on Edit Mode layout tables, as C_EditMode.GetLayouts()
-- returns them: { layoutName, layoutType, systems = { { system, systemIndex,
-- anchorInfo, settings = { { setting, value } }, isInDefaultPosition } } }.
-- ids holds the game's enum values, so this file makes no game calls:
-- { actionBar, bar1, bar2, endCap, capLeft, capRight, chat, capHidden,
--   bar = { numIcons, alwaysShowButtons, ... } }

-- The system entry for system/index; index nil matches any.
local function findSystem(layout, system, index)
  if system == nil then
    return nil
  end
  for _, entry in ipairs(layout.systems) do
    if entry.system == system and (index == nil or entry.systemIndex == index) then
      return entry
    end
  end
end

local function getSetting(entry, setting)
  if entry and setting ~= nil then
    for _, item in ipairs(entry.settings) do
      if item.setting == setting then
        return item.value
      end
    end
  end
end

local function setSetting(entry, setting, value)
  if not entry or setting == nil then
    return
  end
  for _, item in ipairs(entry.settings) do
    if item.setting == setting then
      item.value = value
      return
    end
  end
  table.insert(entry.settings, { setting = setting, value = value })
end

-- What the layout holds for the checks: { bar1 = { name = value }, bar2 = { ... },
-- capsHidden = { left, right } }. A missing system or setting reads as nil.
function LayoutPlan.read(layout, ids)
  local function bar(index)
    local entry, values = findSystem(layout, ids.actionBar, index), {}
    for name, setting in pairs(ids.bar) do
      values[name] = getSetting(entry, setting)
    end
    return values
  end
  return {
    bar1 = bar(ids.bar1),
    bar2 = bar(ids.bar2),
    capsHidden = {
      left = getSetting(findSystem(layout, ids.endCap, ids.capLeft), ids.capHidden),
      right = getSetting(findSystem(layout, ids.endCap, ids.capRight), ids.capHidden),
    },
  }
end

local function differs(value, want)
  return value ~= nil and want ~= nil and value ~= want
end

-- readings: { step = "create" | "switch" | nil, source = active layout's name,
-- layout = LayoutPlan.read(...) of the layout setup will change, bar2On, onBar1 }.
-- nil readings are skipped. Returns the actions still needed, in window order:
-- { { id, text } }.
function LayoutPlan.actions(readings)
  local list = {}
  local function add(id, text)
    table.insert(list, { id = id, text = text })
  end
  local layout = readings.layout
  local bar1, bar2 = layout.bar1, layout.bar2

  if readings.step == "create" then
    add("create", "Create a WASDBars layout from '" .. readings.source .. "' and switch to it")
    add("place", "Put the WASD keys bottom left and move the chat window up")
  elseif readings.step == "switch" then
    add("switch", "Switch to your WASDBars layout")
  end
  for name, want in pairs(LayoutPlan.BAR1) do
    if differs(bar1[name], want) then
      add("bar1", "Action Bar 1: 12 icons, always show buttons, hide bar art and scrolling")
      break
    end
  end
  local shapeOff = differs(bar2.numIcons, 12)
  for _, name in ipairs(LayoutPlan.SHAPE) do
    shapeOff = shapeOff or differs(bar2[name], bar1[name])
  end
  if shapeOff then
    add("bar2Shape", "Action Bar 2: same size and shape as Action Bar 1, 12 icons")
  end
  if readings.step == "create" or readings.onBar1 == false then
    add("bar2Place", "Put Action Bar 2 on Action Bar 1")
  end
  if differs(layout.capsHidden.left, 1) or differs(layout.capsHidden.right, 1) then
    add("endCaps", "Hide the gryphons")
  end
  if readings.bar2On == false then
    add("bar2On", "Turn on Action Bar 2")
  end
  return list
end

-- True if actions has one with this id.
function LayoutPlan.has(actions, id)
  for _, action in ipairs(actions) do
    if action.id == id then
      return true
    end
  end
  return false
end

-- Sets the WASDBars settings in the layout: action bar 1's, action bar 2's
-- (12 icons and action bar 1's shape) and the hidden end caps.
function LayoutPlan.edit(layout, ids)
  local bar1 = findSystem(layout, ids.actionBar, ids.bar1)
  local bar2 = findSystem(layout, ids.actionBar, ids.bar2)
  for name, value in pairs(LayoutPlan.BAR1) do
    setSetting(bar1, ids.bar[name], value)
  end
  setSetting(bar2, ids.bar.numIcons, 12)
  for _, name in ipairs(LayoutPlan.SHAPE) do
    local value = getSetting(bar1, ids.bar[name])
    if value ~= nil then
      setSetting(bar2, ids.bar[name], value)
    end
  end
  for _, index in ipairs({ ids.capLeft, ids.capRight }) do
    setSetting(findSystem(layout, ids.endCap, index), ids.capHidden, 1)
  end
end

-- Moves a system: anchor is { point, relativeTo (a frame name), relativePoint,
-- offsetX, offsetY }. Returns false if the layout doesn't have the system.
function LayoutPlan.anchor(layout, system, index, anchor)
  local entry = findSystem(layout, system, index)
  if not entry then
    return false
  end
  entry.anchorInfo = {
    point = anchor.point,
    relativeTo = anchor.relativeTo,
    relativePoint = anchor.relativePoint,
    offsetX = anchor.offsetX,
    offsetY = anchor.offsetY,
  }
  entry.isInDefaultPosition = false
  return true
end

-- The layout half of /wasd setup status.
function LayoutPlan.statusSentence(readings, actions)
  if readings.step then
    return "Not on the WASDBars layout (/wasd setup layout)."
  end
  if #actions == 0 then
    return "Edit Mode layout ready."
  end
  return "WASDBars layout needs " .. #actions .. (#actions == 1 and " change" or " changes") .. " (/wasd setup layout)."
end
