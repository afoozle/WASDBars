local ADDON, ns = ...
local KeybindPlan = {}
ns.KeybindPlan = KeybindPlan

-- "Action" is what a key does (the game calls it a command).
-- currentActions: { [key] = action } for every bound setup key (Keybinds.lua).

-- { group, keybindChanges = { { key, keyLabel, wantedAction, currentAction } } }.
-- Keys already right are left out; currentAction is nil for an unbound key.
local function findGroupChanges(group, currentActions)
  local groupChanges = { group = group, keybindChanges = {} }
  for _, keybind in ipairs(group.keybinds) do
    local currentAction = currentActions[keybind.key]
    if currentAction ~= keybind.action then
      table.insert(groupChanges.keybindChanges, {
        key = keybind.key,
        keyLabel = keybind.keyLabel,
        wantedAction = keybind.action,
        currentAction = currentAction,
      })
    end
  end
  return groupChanges
end

-- The groups with keys not yet bound as setup wants, with those keys' changes.
function KeybindPlan.findGroupsToChange(keybindGroups, currentActions)
  local groupsToChange = {}
  for _, group in ipairs(keybindGroups) do
    local groupChanges = findGroupChanges(group, currentActions)
    if #groupChanges.keybindChanges > 0 then
      table.insert(groupsToChange, groupChanges)
    end
  end
  return groupsToChange
end

local function doesActionKeepAKey(action, keysOfEachAction, keysSetupWillChange)
  for _, key in ipairs(keysOfEachAction[action] or {}) do
    if not keysSetupWillChange[key] then
      return true
    end
  end
  return false
end

-- Actions that will have no key at all once every group is changed, with the
-- keys that did them, e.g. { { action = "REPLY", keyLabels = { "R" } } }, in
-- change order. keysOfEachAction: { [action] = every key bound to it now }.
function KeybindPlan.findActionsLosingTheirKey(groupsToChange, keysOfEachAction)
  local keybindChanges, keysSetupWillChange, actionsSetupWillBind = {}, {}, {}
  for _, groupChanges in ipairs(groupsToChange) do
    for _, keybindChange in ipairs(groupChanges.keybindChanges) do
      table.insert(keybindChanges, keybindChange)
      keysSetupWillChange[keybindChange.key] = true
      actionsSetupWillBind[keybindChange.wantedAction] = true
    end
  end
  local actionsLosingTheirKey, entriesByAction = {}, {}
  for _, keybindChange in ipairs(keybindChanges) do
    local action = keybindChange.currentAction
    if action and not actionsSetupWillBind[action] and not doesActionKeepAKey(action, keysOfEachAction, keysSetupWillChange) then
      if not entriesByAction[action] then
        entriesByAction[action] = { action = action, keyLabels = {} }
        table.insert(actionsLosingTheirKey, entriesByAction[action])
      end
      table.insert(entriesByAction[action].keyLabels, keybindChange.keyLabel or keybindChange.key)
    end
  end
  return actionsLosingTheirKey
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
