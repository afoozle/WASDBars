local ADDON, ns = ...
local ClusterKeys = ns.ClusterKeys
local ClusterPositions = {}
ns.ClusterPositions = ClusterPositions

-- Where the cluster sits on each Edit Mode layout, in the saved table it's
-- given: layout name -> { point, x, y, scale }. Either half may be missing:
-- the scale slider can be used before the cluster is ever dragged.

ClusterPositions.MIN_SCALE = 0.5
ClusterPositions.MAX_SCALE = 2.0

-- { point, x, y, scale } for an Edit Mode layout: the saved values, or the
-- defaults (ClusterKeys.lua).
function ClusterPositions.findClusterPosition(savedPositions, layoutName)
  local savedPosition = savedPositions[layoutName] or {}
  local position = savedPosition.point and savedPosition or ClusterKeys.defaultPosition
  return { point = position.point, x = position.x, y = position.y, scale = savedPosition.scale or ClusterKeys.defaultScale }
end

function ClusterPositions.saveClusterPosition(savedPositions, layoutName, point, x, y)
  savedPositions[layoutName] = savedPositions[layoutName] or {}
  local savedPosition = savedPositions[layoutName]
  savedPosition.point, savedPosition.x, savedPosition.y = point, x, y
end

function ClusterPositions.saveClusterScale(savedPositions, layoutName, scale)
  savedPositions[layoutName] = savedPositions[layoutName] or {}
  savedPositions[layoutName].scale = scale
end
