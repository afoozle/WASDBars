local ADDON, ns = ...
local Bindings = {}
ns.Bindings = Bindings

local POPUP = "WASDBARS_CONFIRM_BINDS"

local function plan(group)
  return ns.BindingPlan.build(group, GetBindingAction)
end

local function formName(n)
  local spellID = select(4, GetShapeshiftFormInfo(n))
  return spellID and C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(spellID)
end

local function describe(group, changes)
  local lines = { group.question, "", "These keys stop doing what they do now:" }
  for _, change in ipairs(changes) do
    local now = change.current and ns.BindingPlan.commandName(change.current, GetBindingName, formName) or "nothing"
    table.insert(lines, (change.label or change.key) .. ": " .. now)
  end
  return table.concat(lines, "\n")
end

local function apply(group, changes)
  for _, change in ipairs(changes) do
    SetBinding(change.key, change.command)
  end
  -- keeps whichever set the character already uses (account or character)
  SaveBindings(GetCurrentBindingSet())
  ns.print(group.title .. " set up.")
  if group.id == "numbers" and not MultiBarBottomLeft:IsShown() then
    ns.print("action bar 2 is turned off. Turn it on in Edit Mode to see the number row.")
  end
end

-- Show the next popup a frame later, so it isn't hidden along with the one just clicked.
local function finish(onDone)
  if onDone then
    C_Timer.After(0, onDone)
  end
end

StaticPopupDialogs[POPUP] = {
  text = "%s",
  button1 = "Confirm",
  button2 = "Cancel",
  OnAccept = function(_, data)
    ns.combatQueue:run("bind-" .. data.group.id, function()
      apply(data.group, data.changes)
    end)
    finish(data.onDone)
  end,
  OnCancel = function(_, data)
    finish(data.onDone)
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}

-- group: an entry of ns.BindingGroups. onDone runs after Confirm or Cancel,
-- or straight away when the group is already set up.
function Bindings.request(group, onDone)
  ns.combatQueue:run("bind-" .. group.id, function()
    local changes = plan(group).changes
    if #changes == 0 then
      ns.print(group.title .. ": already set up.")
      finish(onDone)
      return
    end
    StaticPopup_Show(POPUP, describe(group, changes), nil, { group = group, changes = changes, onDone = onDone })
  end)
end

function Bindings.status(group)
  return ns.BindingPlan.statusLine(group, plan(group))
end

-- Asks for each group in turn: the next popup shows once the previous one closes.
function Bindings.requestAll(onDone)
  local i = 0
  local function nextGroup()
    i = i + 1
    local group = ns.BindingGroups[i]
    if group then
      Bindings.request(group, nextGroup)
    elseif onDone then
      onDone()
    end
  end
  nextGroup()
end
