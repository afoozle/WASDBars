local ADDON, ns = ...
local BindingPlan = {}
ns.BindingPlan = BindingPlan

-- getBindingAction: the game's GetBindingAction(key), "" when the key is unbound.
-- Returns { changes = { { key, label, command, current } }, correct, total, state }
-- where current is the key's command now (nil if unbound) and state is
-- "applied", "partial" or "not applied". Keys already right are left out of changes.
function BindingPlan.build(group, getBindingAction)
  local plan = { changes = {}, correct = 0, total = #group.binds }
  for _, bind in ipairs(group.binds) do
    local current = getBindingAction(bind.key)
    if current == bind.command then
      plan.correct = plan.correct + 1
    else
      table.insert(plan.changes, {
        key = bind.key,
        label = bind.label,
        command = bind.command,
        current = (current ~= "" and current) or nil,
      })
    end
  end
  if plan.correct == plan.total then
    plan.state = "applied"
  elseif plan.correct > 0 then
    plan.state = "partial"
  else
    plan.state = "not applied"
  end
  return plan
end

-- One line for /wasd setup status, e.g. "Number row: 7 of 12 set up".
function BindingPlan.statusLine(group, plan)
  if plan.state == "applied" then
    return group.title .. ": set up"
  elseif plan.state == "partial" then
    return group.title .. ": " .. plan.correct .. " of " .. plan.total .. " set up"
  end
  return group.title .. ": not set up"
end
