local ADDON, ns = ...
local LayoutGeometry = {}
ns.LayoutGeometry = LayoutGeometry

local function isNeighbour(prev, key)
  return prev and prev.y == key.y and math.abs(key.x - prev.x - 1) < 1e-9
end

-- Turns the layout table into pixel positions.
-- baseSize: the game's action button size (ActionButton1:GetWidth() in game).
-- Returns { keys = { { key, cx, cy, scale }, ... }, width, height }, where
-- cx/cy are each key's centre relative to the cluster's top-left (y grows
-- downwards) and the cluster box tightly covers every key.
-- Rows are packed: a key one grid step right of its neighbour sits `gap` pixels
-- from it, whatever their sizes. The first key of each run (the start of a row,
-- or after a jump such as the mouse column) is centred on its grid point, which
-- keeps the keyboard stagger.
function LayoutGeometry.compute(layout, baseSize)
  local step = baseSize + layout.gap

  local order = {}
  for i in ipairs(layout.keys) do
    order[i] = i
  end
  table.sort(order, function(a, b)
    local ka, kb = layout.keys[a], layout.keys[b]
    if ka.y ~= kb.y then
      return ka.y < kb.y
    end
    return ka.x < kb.x
  end)

  local keys = {}
  local prev, prevPlaced
  for _, i in ipairs(order) do
    local key = layout.keys[i]
    local scale = layout.sizes[key.size]
    local cx = key.x * step
    if isNeighbour(prev, key) then
      cx = prevPlaced.cx + (prevPlaced.scale + scale) / 2 * baseSize + layout.gap
    end
    keys[i] = { key = key, cx = cx, cy = key.y * step, scale = scale }
    prev, prevPlaced = key, keys[i]
  end

  local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
  for _, k in ipairs(keys) do
    local half = k.scale * baseSize / 2
    minX, minY = math.min(minX, k.cx - half), math.min(minY, k.cy - half)
    maxX, maxY = math.max(maxX, k.cx + half), math.max(maxY, k.cy + half)
  end
  for _, k in ipairs(keys) do
    k.cx, k.cy = k.cx - minX, k.cy - minY
  end

  return { keys = keys, width = maxX - minX, height = maxY - minY }
end
