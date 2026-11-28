local ADDON, ns = ...
local LayoutList = ns.LayoutList
local RestoreSteps = {}
ns.RestoreSteps = RestoreSteps

-- Restore points: per character, the layout and action bar 2 from before
-- setup, in the saved table it's given: character GUID -> { layout = layout
-- name, bar2 = was action bar 2 on }. Only the first is kept: a later setup
-- must not overwrite where the character started.
function RestoreSteps.saveRestorePointOnce(savedRestorePoints, playerGuid, layoutName, wasActionBar2On)
  savedRestorePoints[playerGuid] = savedRestorePoints[playerGuid] or { layout = layoutName, bar2 = wasActionBar2On }
end

-- The layout a restore switches to: the saved one if it still exists,
-- otherwise the first preset (Modern). Returns layoutName, isSavedLayoutMissing.
-- restorePoint: from saveRestorePointOnce.
function RestoreSteps.findLayoutToRestore(allLayouts, restorePoint, presetLayoutType)
  if LayoutList.findLayoutIndex(allLayouts, restorePoint.layout) then
    return restorePoint.layout, false
  end
  return LayoutList.findFirstPresetLayoutName(allLayouts, presetLayoutType), true
end

-- The restore popup's lines.
function RestoreSteps.describeRestore(layoutToRestore, isSavedLayoutMissing, restorePoint)
  local restoreLines = {}
  if isSavedLayoutMissing then
    table.insert(restoreLines, "Switch to " .. layoutToRestore .. " ('" .. restorePoint.layout .. "' no longer exists)")
  else
    table.insert(restoreLines, "Switch back to '" .. layoutToRestore .. "'")
  end
  if not restorePoint.bar2 then
    table.insert(restoreLines, "Turn Action Bar 2 off")
  end
  return restoreLines
end
