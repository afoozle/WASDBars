local ADDON, ns = ...
local Restore = {}
ns.Restore = Restore

-- What every key in the binding groups is bound to now: { [key] = command },
-- with false for an unbound key. getBindingAction: the game's GetBindingAction.
function Restore.keyCopy(groups, getBindingAction)
  local copy = {}
  for _, group in ipairs(groups) do
    for _, bind in ipairs(group.binds) do
      local command = getBindingAction(bind.key)
      copy[bind.key] = command ~= "" and command or false
    end
  end
  return copy
end

-- The keys to put back, sorted: { { key, command } }, command nil to unbind.
function Restore.keyChanges(copy)
  local list = {}
  for key, command in pairs(copy) do
    table.insert(list, { key = key, command = command or nil })
  end
  table.sort(list, function(a, b)
    return a.key < b.key
  end)
  return list
end

-- The layout a restore switches to: the saved name if it still exists,
-- otherwise the first preset (Modern). Returns name, missing.
-- data: LayoutCopy.combine(...)
function Restore.target(data, savedName, presetType)
  for _, layout in ipairs(data.layouts) do
    if layout.layoutName == savedName then
      return savedName, false
    end
  end
  for _, layout in ipairs(data.layouts) do
    if layout.layoutType == presetType then
      return layout.layoutName, true
    end
  end
  return nil, true
end

-- The lines for the restore popup.
function Restore.lines(target, missing, savedName, bar2WasOn)
  local lines = {}
  if missing then
    table.insert(lines, "Switch to " .. target .. " ('" .. savedName .. "' no longer exists)")
  else
    table.insert(lines, "Switch back to '" .. target .. "'")
  end
  if not bar2WasOn then
    table.insert(lines, "Turn Action Bar 2 off")
  end
  return lines
end
