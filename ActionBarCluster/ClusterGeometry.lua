local ADDON, ns = ...
local ClusterGeometry = {}
ns.ClusterGeometry = ClusterGeometry

-- Turns the cluster keys into pixel positions.
-- buttonSize: the game's action button size (ActionButton1:GetWidth() in game).
-- Returns { measuredKeys = { { clusterKey, centreX, centreY, scale }, ... }, width, height },
-- where centreX/centreY are each key's centre relative to the cluster's
-- top-left (y grows downwards). Every key gets the same square cell centred
-- on its grid point, so smaller keys just have more space round them, and the
-- rows keep the keyboard's stagger. The cluster box tightly covers every cell.
function ClusterGeometry.measureClusterKeys(clusterKeys, buttonSize)
  local minColumn, minRow, maxColumn, maxRow = math.huge, math.huge, -math.huge, -math.huge
  for _, clusterKey in ipairs(clusterKeys.keys) do
    minColumn, minRow = math.min(minColumn, clusterKey.column), math.min(minRow, clusterKey.row)
    maxColumn, maxRow = math.max(maxColumn, clusterKey.column), math.max(maxRow, clusterKey.row)
  end

  local measuredKeys = {}
  for i, clusterKey in ipairs(clusterKeys.keys) do
    measuredKeys[i] = {
      clusterKey = clusterKey,
      centreX = (clusterKey.column - minColumn) * buttonSize + buttonSize / 2,
      centreY = (clusterKey.row - minRow) * buttonSize + buttonSize / 2,
      scale = clusterKeys.keySizes[clusterKey.size],
    }
  end

  return {
    measuredKeys = measuredKeys,
    width = (maxColumn - minColumn) * buttonSize + buttonSize,
    height = (maxRow - minRow) * buttonSize + buttonSize,
  }
end
