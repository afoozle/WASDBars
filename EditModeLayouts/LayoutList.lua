local ADDON, ns = ...
local LayoutList = {}
ns.LayoutList = LayoutList

-- Edit Mode's layout list the way LibEditModeOverride keeps it, and the way
-- C_EditMode.SaveLayouts takes it: { layouts, activeLayout }, the preset
-- layouts first, then the saved ones, with activeLayout indexing the whole list.

local function copyTable(value)
  if type(value) ~= "table" then
    return value
  end
  local copy = {}
  for key, nestedValue in pairs(value) do
    copy[key] = copyTable(nestedValue)
  end
  return copy
end

-- presetLayouts: EditModePresetLayoutManager:GetCopyOfPresetLayouts()
-- savedLayouts: C_EditMode.GetLayouts() ({ layouts = custom layouts, activeLayout })
function LayoutList.combinePresetAndSavedLayouts(presetLayouts, savedLayouts)
  local layouts = {}
  for _, layout in ipairs(presetLayouts) do
    table.insert(layouts, layout)
  end
  for _, layout in ipairs(savedLayouts.layouts) do
    table.insert(layouts, layout)
  end
  return { layouts = layouts, activeLayout = savedLayouts.activeLayout }
end

function LayoutList.findActiveLayout(allLayouts)
  return allLayouts.layouts[allLayouts.activeLayout]
end

-- Index of the layout called layoutName, or nil.
function LayoutList.findLayoutIndex(allLayouts, layoutName)
  for index, layout in ipairs(allLayouts.layouts) do
    if layout.layoutName == layoutName then
      return index
    end
  end
  return nil
end

function LayoutList.findFirstPresetLayoutName(allLayouts, presetLayoutType)
  for _, layout in ipairs(allLayouts.layouts) do
    if layout.layoutType == presetLayoutType then
      return layout.layoutName
    end
  end
  return nil
end

function LayoutList.hasRoomForAnotherLayout(allLayouts, layoutType, maxLayoutsPerType)
  local layoutCount = 0
  for _, layout in ipairs(allLayouts.layouts) do
    if layout.layoutType == layoutType then
      layoutCount = layoutCount + 1
    end
  end
  return layoutCount < maxLayoutsPerType
end

-- Adds a copy of the active layout called newLayoutName, of layoutType, and
-- makes it active. It goes after the last layout of that type (or after the
-- presets), where Edit Mode itself puts new layouts.
function LayoutList.copyActiveLayout(allLayouts, newLayoutName, layoutType, presetLayoutType)
  local layoutCopy = copyTable(LayoutList.findActiveLayout(allLayouts))
  layoutCopy.layoutName = newLayoutName
  layoutCopy.layoutType = layoutType
  local insertAfter = 0
  for index, layout in ipairs(allLayouts.layouts) do
    if layout.layoutType == layoutType or layout.layoutType == presetLayoutType then
      insertAfter = index
    end
  end
  table.insert(allLayouts.layouts, insertAfter + 1, layoutCopy)
  allLayouts.activeLayout = insertAfter + 1
end

-- In the list only; EditModeLayouts.saveAllLayouts saves it.
function LayoutList.makeLayoutActive(allLayouts, layoutName)
  allLayouts.activeLayout = LayoutList.findLayoutIndex(allLayouts, layoutName)
end
