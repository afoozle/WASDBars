local ADDON, ns = ...
local KeybindPlan = {}
ns.KeybindPlan = KeybindPlan

-- "Action" is what a key does (the game calls it a command).
-- currentActions: { [key] = action } for every bound setup key (Keybinds.lua).

local function findStatus(correctCount, totalCount)
  if correctCount == totalCount then
    return "set up"
  elseif correctCount > 0 then
    return "partly set up"
  end
  return "not set up"
end

-- { group, keybindChanges = { { key, keyLabel, wantedAction, currentAction } },
-- correctCount, totalCount, status }. Keys already right are left out of
-- keybindChanges; currentAction is nil for an unbound key.
local function findGroupChanges(group, currentActions)
  local groupChanges = { group = group, keybindChanges = {}, correctCount = 0, totalCount = #group.keybinds }
  for _, keybind in ipairs(group.keybinds) do
    local currentAction = currentActions[keybind.key]
    if currentAction == keybind.action then
      groupChanges.correctCount = groupChanges.correctCount + 1
    else
      table.insert(groupChanges.keybindChanges, {
        key = keybind.key,
        keyLabel = keybind.keyLabel,
        wantedAction = keybind.action,
        currentAction = currentAction,
      })
    end
  end
  groupChanges.status = findStatus(groupChanges.correctCount, groupChanges.totalCount)
  return groupChanges
end

-- Per group, the keys not yet bound as setup wants.
function KeybindPlan.findKeybindChanges(keybindGroups, currentActions)
  local allGroupChanges = {}
  for i, group in ipairs(keybindGroups) do
    allGroupChanges[i] = findGroupChanges(group, currentActions)
  end
  return allGroupChanges
end

-- The groups with keys left to change.
function KeybindPlan.selectGroupsToChange(allGroupChanges)
  local groupsToChange = {}
  for _, groupChanges in ipairs(allGroupChanges) do
    if #groupChanges.keybindChanges > 0 then
      table.insert(groupsToChange, groupChanges)
    end
  end
  return groupsToChange
end

-- Every keybind change of every group, in order.
local function listKeybindChanges(groupsToChange)
  local keybindChanges = {}
  for _, groupChanges in ipairs(groupsToChange) do
    for _, keybindChange in ipairs(groupChanges.keybindChanges) do
      table.insert(keybindChanges, keybindChange)
    end
  end
  return keybindChanges
end

local function findChangingKeysAndActions(keybindChanges)
  local keysSetupWillChange, actionsSetupWillBind = {}, {}
  for _, keybindChange in ipairs(keybindChanges) do
    keysSetupWillChange[keybindChange.key] = true
    actionsSetupWillBind[keybindChange.wantedAction] = true
  end
  return keysSetupWillChange, actionsSetupWillBind
end

local function doesActionKeepAKey(action, keysOfEachAction, keysSetupWillChange)
  for _, key in ipairs(keysOfEachAction[action] or {}) do
    if not keysSetupWillChange[key] then
      return true
    end
  end
  return false
end

local function isActionLosingItsKey(action, keysOfEachAction, keysSetupWillChange, actionsSetupWillBind)
  return not actionsSetupWillBind[action] and not doesActionKeepAKey(action, keysOfEachAction, keysSetupWillChange)
end

-- Actions that will have no key at all once every group is changed, with the
-- keys that did them, e.g. { { action = "REPLY", keyLabels = { "R" } } }, in
-- change order. keysOfEachAction: { [action] = every key bound to it now }.
function KeybindPlan.findActionsLosingTheirKey(groupsToChange, keysOfEachAction)
  local keybindChanges = listKeybindChanges(groupsToChange)
  local keysSetupWillChange, actionsSetupWillBind = findChangingKeysAndActions(keybindChanges)
  local actionsLosingTheirKey, entriesByAction = {}, {}
  for _, keybindChange in ipairs(keybindChanges) do
    local action = keybindChange.currentAction
    if action and isActionLosingItsKey(action, keysOfEachAction, keysSetupWillChange, actionsSetupWillBind) then
      if not entriesByAction[action] then
        entriesByAction[action] = { action = action, keyLabels = {} }
        table.insert(actionsLosingTheirKey, entriesByAction[action])
      end
      table.insert(entriesByAction[action].keyLabels, keybindChange.keyLabel or keybindChange.key)
    end
  end
  return actionsLosingTheirKey
end

function KeybindPlan.isEveryKeybindSetUp(allGroupChanges)
  for _, groupChanges in ipairs(allGroupChanges) do
    if groupChanges.status ~= "set up" then
      return false
    end
  end
  return true
end

local function describeGroupStatus(groupChanges)
  local groupName = groupChanges.group.name
  if groupChanges.status == "partly set up" then
    return groupName .. " " .. groupChanges.correctCount .. " of " .. groupChanges.totalCount .. " set up"
  end
  return groupName .. " " .. groupChanges.status
end

-- The keybind half of /wasd setup status, e.g. "Keybinds set up (WASD keys and number row)."
-- or "Keybinds: WASD keys set up, number row 7 of 12 set up."
function KeybindPlan.describeKeybindStatus(allGroupChanges)
  local groupNames, groupStatuses = {}, {}
  for _, groupChanges in ipairs(allGroupChanges) do
    table.insert(groupNames, groupChanges.group.name)
    table.insert(groupStatuses, describeGroupStatus(groupChanges))
  end
  if KeybindPlan.isEveryKeybindSetUp(allGroupChanges) then
    return "Keybinds set up (" .. table.concat(groupNames, " and ") .. ")."
  end
  return "Keybinds: " .. table.concat(groupStatuses, ", ") .. "."
end

-- What every setup key is bound to now, ready to restore later:
-- { [key] = action | false }.
function KeybindPlan.copyKeybinds(keybindGroups, currentActions)
  local keybindCopy = {}
  for _, group in ipairs(keybindGroups) do
    for _, keybind in ipairs(group.keybinds) do
      keybindCopy[keybind.key] = currentActions[keybind.key] or false
    end
  end
  return keybindCopy
end

local function isKeyBefore(firstChange, secondChange)
  return firstChange.key < secondChange.key
end

-- The keys to put back, sorted by key: { { key, action } }, action nil to unbind.
function KeybindPlan.findRestoreChanges(keybindCopy)
  local restoreChanges = {}
  for key, action in pairs(keybindCopy) do
    table.insert(restoreChanges, { key = key, action = action or nil })
  end
  table.sort(restoreChanges, isKeyBefore)
  return restoreChanges
end

-- The stance bar button an action fires, or nil.
function KeybindPlan.findStanceButtonNumber(action)
  return tonumber(action:match("^SHAPESHIFTBUTTON(%d+)$"))
end

-- A short, plain name for an action, for the setup window.
-- formName: the stance button's form, or nil if unknown (for example the
-- account-wide stance keys on a class without those forms).
-- gameActionName: the game's own name for it (GetBindingName).
function KeybindPlan.nameAction(action, formName, gameActionName)
  local actionButtonNumber = action:match("^ACTIONBUTTON(%d+)$")
  if actionButtonNumber then
    return "Action bar 1 button " .. actionButtonNumber
  end
  actionButtonNumber = action:match("^MULTIACTIONBAR1BUTTON(%d+)$")
  if actionButtonNumber then
    return "Action bar 2 button " .. actionButtonNumber
  end
  local stanceButtonNumber = KeybindPlan.findStanceButtonNumber(action)
  if stanceButtonNumber then
    return formName or ("Stance bar button " .. stanceButtonNumber)
  end
  return gameActionName
end
