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

-- A short, plain name for what a command does, for the confirmation popup.
-- getBindingName: the game's GetBindingName(command).
-- getFormName: returns the name of stance bar form n, or nil if unknown
-- (for example the account-wide 1/2 form binds on a class without those forms).
function BindingPlan.commandName(command, getBindingName, getFormName)
  local n = command:match("^ACTIONBUTTON(%d+)$")
  if n then
    return "Action bar 1 button " .. n
  end
  n = command:match("^MULTIACTIONBAR1BUTTON(%d+)$")
  if n then
    return "Action bar 2 button " .. n
  end
  n = command:match("^SHAPESHIFTBUTTON(%d+)$")
  if n then
    return getFormName(tonumber(n)) or ("Stance bar button " .. n)
  end
  return getBindingName(command)
end

-- Actions that will have no key at all once every plan is applied, with the
-- keys that did them, e.g. { { command = "REPLY", keys = { "R" } } }, in plan order.
-- getBindingKey: the game's GetBindingKey(command), returning every key bound to it.
function BindingPlan.lostActions(plans, getBindingKey)
  local changing, rebound = {}, {}
  for _, plan in ipairs(plans) do
    for _, change in ipairs(plan.changes) do
      changing[change.key] = true
      rebound[change.command] = true
    end
  end

  local lost, byCommand = {}, {}
  for _, plan in ipairs(plans) do
    for _, change in ipairs(plan.changes) do
      local command = change.current
      if command and not rebound[command] then
        local entry = byCommand[command]
        if entry == nil then
          local kept = false
          for _, key in ipairs({ getBindingKey(command) }) do
            if not changing[key] then
              kept = true
            end
          end
          entry = not kept and { command = command, keys = {} } or false
          byCommand[command] = entry
          if entry then
            table.insert(lost, entry)
          end
        end
        if entry then
          table.insert(entry.keys, change.label or change.key)
        end
      end
    end
  end
  return lost
end

-- The keybind half of /wasd setup status, e.g. "Keybinds set up (WASD keys and number row)."
-- or "Keybinds: WASD keys set up, number row 7 of 12 set up."
function BindingPlan.statusSentence(groups, plans)
  local parts, allApplied = {}, true
  for i, group in ipairs(groups) do
    local plan = plans[i]
    if plan.state == "applied" then
      table.insert(parts, group.name .. " set up")
    elseif plan.state == "partial" then
      allApplied = false
      table.insert(parts, group.name .. " " .. plan.correct .. " of " .. plan.total .. " set up")
    else
      allApplied = false
      table.insert(parts, group.name .. " not set up")
    end
  end
  if allApplied then
    local names = {}
    for _, group in ipairs(groups) do
      table.insert(names, group.name)
    end
    return "Keybinds set up (" .. table.concat(names, " and ") .. ")."
  end
  return "Keybinds: " .. table.concat(parts, ", ") .. "."
end
