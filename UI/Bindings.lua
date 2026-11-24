local ADDON, ns = ...
local Bindings = {}
ns.Bindings = Bindings

local function plans()
  local list = {}
  for i, group in ipairs(ns.BindingGroups) do
    list[i] = ns.BindingPlan.build(group, GetBindingAction)
  end
  return list
end

-- The form's spell ID is the fourth return.
local function formName(n)
  local spellID = select(4, GetShapeshiftFormInfo(n))
  return spellID and C_Spell.GetSpellName(spellID)
end

function Bindings.actionName(command)
  return ns.BindingPlan.commandName(command, GetBindingName, formName)
end

-- The groups still to set up, as { { group, plan } }, and the actions that
-- would be left with no key (BindingPlan.lostActions).
function Bindings.steps()
  local all, steps, stepPlans = plans(), {}, {}
  for i, group in ipairs(ns.BindingGroups) do
    if #all[i].changes > 0 then
      table.insert(steps, { group = group, plan = all[i] })
      table.insert(stepPlans, all[i])
    end
  end
  return steps, ns.BindingPlan.lostActions(stepPlans, GetBindingKey)
end

-- Out of combat only: called through the setup's combat queue job.
function Bindings.apply(steps)
  for _, step in ipairs(steps) do
    for _, change in ipairs(step.plan.changes) do
      SetBinding(change.key, change.command)
    end
  end
  -- keeps whichever set the character already uses (account or character)
  SaveBindings(GetCurrentBindingSet())
end

function Bindings.isSetUp()
  for _, plan in ipairs(plans()) do
    if plan.state ~= "applied" then
      return false
    end
  end
  return true
end

function Bindings.statusSentence()
  return ns.BindingPlan.statusSentence(ns.BindingGroups, plans())
end
