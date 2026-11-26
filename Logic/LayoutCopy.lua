local ADDON, ns = ...
local LayoutCopy = {}
ns.LayoutCopy = LayoutCopy

-- Edit Mode's layout list the way LibEditModeOverride keeps it: the preset
-- layouts first, then the saved ones, with activeLayout indexing the whole list.
-- presets: EditModePresetLayoutManager:GetCopyOfPresetLayouts()
-- saved: C_EditMode.GetLayouts() ({ layouts = custom layouts, activeLayout })
function LayoutCopy.combine(presets, saved)
  local layouts = {}
  for _, layout in ipairs(presets) do
    table.insert(layouts, layout)
  end
  for _, layout in ipairs(saved.layouts) do
    table.insert(layouts, layout)
  end
  return { layouts = layouts, activeLayout = saved.activeLayout }
end

-- Index of the layout called name, or nil.
function LayoutCopy.find(data, name)
  for index, layout in ipairs(data.layouts) do
    if layout.layoutName == name then
      return index
    end
  end
end

-- How many layouts are of this type.
function LayoutCopy.count(data, layoutType)
  local n = 0
  for _, layout in ipairs(data.layouts) do
    if layout.layoutType == layoutType then
      n = n + 1
    end
  end
  return n
end

local function deepCopy(value)
  if type(value) ~= "table" then
    return value
  end
  local result = {}
  for k, v in pairs(value) do
    result[k] = deepCopy(v)
  end
  return result
end

-- Adds a copy of the active layout called name, of layoutType, and makes it
-- active. It goes after the last layout of that type (or after the presets),
-- where Edit Mode itself puts new layouts. Returns its index.
function LayoutCopy.add(data, name, layoutType, presetType)
  local copy = deepCopy(data.layouts[data.activeLayout])
  copy.layoutName = name
  copy.layoutType = layoutType
  local after = 0
  for index, layout in ipairs(data.layouts) do
    if layout.layoutType == layoutType or layout.layoutType == presetType then
      after = index
    end
  end
  table.insert(data.layouts, after + 1, copy)
  data.activeLayout = after + 1
  return after + 1
end
