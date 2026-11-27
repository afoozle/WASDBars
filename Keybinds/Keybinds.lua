local ADDON, ns = ...
local KeybindGroups = ns.KeybindGroups
local KeybindPlan = ns.KeybindPlan
local KeybindCopies = ns.KeybindCopies
local Keybinds = {}
ns.Keybinds = Keybinds

-- The game's keybinds for the setup keys. Applying and restoring them is out
-- of combat only; their callers refuse in combat (Setup/SetupGuards.lua).

-- { [key] = action } for every setup key that has one.
local function readCurrentActions()
  local currentActions = {}
  for _, group in ipairs(KeybindGroups) do
    for _, keybind in ipairs(group.keybinds) do
      local action = GetBindingAction(keybind.key)
      if action ~= "" then
        currentActions[keybind.key] = action
      end
    end
  end
  return currentActions
end

-- { [action] = every key bound to it now }, for the actions setup would take a key from.
local function readKeysOfEachAction(groupsToChange)
  local keysOfEachAction = {}
  for _, groupChanges in ipairs(groupsToChange) do
    for _, keybindChange in ipairs(groupChanges.keybindChanges) do
      local action = keybindChange.currentAction
      if action and not keysOfEachAction[action] then
        keysOfEachAction[action] = { GetBindingKey(action) }
      end
    end
  end
  return keysOfEachAction
end

-- The form's spell ID is the fourth return.
local function findFormName(stanceButtonNumber)
  if not stanceButtonNumber then
    return nil
  end
  local spellId = select(4, GetShapeshiftFormInfo(stanceButtonNumber))
  return spellId and C_Spell.GetSpellName(spellId)
end

-- The groups with keys left to change (KeybindPlan.findGroupsToChange).
function Keybinds.findGroupsToChange()
  return KeybindPlan.findGroupsToChange(KeybindGroups, readCurrentActions())
end

-- KeybindPlan.findActionsLosingTheirKey, with each action's name for the window.
function Keybinds.findActionsLosingTheirKey(groupsToChange)
  local actionsLosingTheirKey = KeybindPlan.findActionsLosingTheirKey(groupsToChange, readKeysOfEachAction(groupsToChange))
  for _, actionLosingItsKey in ipairs(actionsLosingTheirKey) do
    actionLosingItsKey.actionName = Keybinds.nameAction(actionLosingItsKey.action)
  end
  return actionsLosingTheirKey
end

-- Saves to whichever binding set the character already uses (account or character).
function Keybinds.applyKeybindChanges(groupsToChange)
  for _, groupChanges in ipairs(groupsToChange) do
    for _, keybindChange in ipairs(groupChanges.keybindChanges) do
      SetBinding(keybindChange.key, keybindChange.wantedAction)
    end
  end
  SaveBindings(GetCurrentBindingSet())
end

function Keybinds.copyCurrentKeybinds()
  return KeybindPlan.copyKeybinds(KeybindGroups, readCurrentActions())
end

-- keybindCopy: from copyCurrentKeybinds.
function Keybinds.restoreKeybinds(keybindCopy)
  for _, restoreChange in ipairs(KeybindPlan.findRestoreChanges(keybindCopy)) do
    if restoreChange.action then
      SetBinding(restoreChange.key, restoreChange.action)
    else
      SetBinding(restoreChange.key)
    end
  end
  SaveBindings(GetCurrentBindingSet())
end

-- Whose key copy this character uses (KeybindCopies.findCopyOwner).
function Keybinds.findCopyOwner()
  return KeybindCopies.findCopyOwner(GetCurrentBindingSet(), CHARACTER_BINDINGS, UnitGUID("player"))
end

function Keybinds.nameAction(action)
  local formName = findFormName(KeybindPlan.findStanceButtonNumber(action))
  return KeybindPlan.nameAction(action, formName, GetBindingName(action))
end
