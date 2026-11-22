local ADDON, ns = ...
local LayoutGeometry = {}
ns.LayoutGeometry = LayoutGeometry

-- Turns the layout table into pixel positions.
-- baseSize: the game's action button size (ActionButton1:GetWidth() in game).
-- Returns { keys = { { key, cx, cy, scale }, ... }, width, height }, where
-- cx/cy are each key's centre relative to the cluster's top-left (y grows
-- downwards). Every key gets the same square cell centred on its grid point, so
-- smaller keys just have more space round them, and the rows keep the keyboard's
-- stagger. The cluster box tightly covers every cell.
function LayoutGeometry.compute(layout, baseSize)
  local step = baseSize + layout.gap
  local minX, minY, maxX, maxY = math.huge, math.huge, -math.huge, -math.huge
  for _, key in ipairs(layout.keys) do
    minX, minY = math.min(minX, key.x), math.min(minY, key.y)
    maxX, maxY = math.max(maxX, key.x), math.max(maxY, key.y)
  end

  local keys = {}
  for i, key in ipairs(layout.keys) do
    keys[i] = {
      key = key,
      cx = (key.x - minX) * step + baseSize / 2,
      cy = (key.y - minY) * step + baseSize / 2,
      scale = layout.sizes[key.size],
    }
  end

  return {
    keys = keys,
    width = (maxX - minX) * step + baseSize,
    height = (maxY - minY) * step + baseSize,
  }
end
