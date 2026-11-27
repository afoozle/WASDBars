local ADDON, ns = ...
local RestoreSteps = {}
ns.RestoreSteps = RestoreSteps

-- The layout a restore switches to: the saved one if it still exists,
-- otherwise the first preset (Modern). Returns layoutName, isSavedLayoutMissing.
-- restorePoint: RestorePoints.findRestorePoint.
function RestoreSteps.findLayoutToRestore(allLayouts, restorePoint, presetLayoutType)
  if ns.LayoutList.findLayoutIndex(allLayouts, restorePoint.layout) then
    return restorePoint.layout, false
  end
  return ns.LayoutList.findFirstPresetLayoutName(allLayouts, presetLayoutType), true
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
