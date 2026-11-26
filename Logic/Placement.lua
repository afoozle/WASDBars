local ADDON, ns = ...
local Placement = {}
ns.Placement = Placement

Placement.MIN_SCALE = 0.5
Placement.MAX_SCALE = 2.0

local POINTS = {
  CENTER = true,
  TOP = true,
  BOTTOM = true,
  LEFT = true,
  RIGHT = true,
  TOPLEFT = true,
  TOPRIGHT = true,
  BOTTOMLEFT = true,
  BOTTOMRIGHT = true,
}

-- n limited to MIN_SCALE..MAX_SCALE, or nil if n isn't a number.
function Placement.clampScale(n)
  if type(n) ~= "number" or n ~= n then
    return nil
  end
  return math.max(Placement.MIN_SCALE, math.min(Placement.MAX_SCALE, n))
end

-- Returns point, x, y, scale for an Edit Mode layout: the saved values where
-- they are valid, otherwise the defaults. A damaged entry never errors.
-- defaultPosition: { point = ..., x = ..., y = ... }
function Placement.forLayout(layouts, layoutName, defaultPosition, defaultScale)
  local point, x, y = defaultPosition.point, defaultPosition.x, defaultPosition.y
  local scale = defaultScale
  local saved = type(layouts) == "table" and layoutName ~= nil and layouts[layoutName]
  if type(saved) == "table" then
    if POINTS[saved.point] and type(saved.x) == "number" and type(saved.y) == "number" then
      point, x, y = saved.point, saved.x, saved.y
    end
    scale = Placement.clampScale(saved.scale) or defaultScale
  end
  return point, x, y, scale
end

-- Merges fields (point, x, y and/or scale) into the layout's saved entry,
-- creating it (or replacing a damaged one) if needed.
function Placement.save(layouts, layoutName, fields)
  local entry = layouts[layoutName]
  if type(entry) ~= "table" then
    entry = {}
    layouts[layoutName] = entry
  end
  for k, v in pairs(fields) do
    entry[k] = v
  end
end
