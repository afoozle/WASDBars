local ADDON, ns = ...
local ClusterPositions = {}
ns.ClusterPositions = ClusterPositions

-- Where the cluster sits on each Edit Mode layout, in the saved table it's
-- given: layout name -> { point, x, y, scale }.

ClusterPositions.MIN_SCALE = 0.5
ClusterPositions.MAX_SCALE = 2.0

local VALID_POINTS = {
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

local function isValidPosition(savedPosition)
  return VALID_POINTS[savedPosition.point] and type(savedPosition.x) == "number" and type(savedPosition.y) == "number"
end

-- The layout's saved entry, created (or a damaged one replaced) if needed.
local function findOrCreateSavedPosition(savedPositions, layoutName)
  local savedPosition = savedPositions[layoutName]
  if type(savedPosition) ~= "table" then
    savedPosition = {}
    savedPositions[layoutName] = savedPosition
  end
  return savedPosition
end

-- scale limited to MIN_SCALE..MAX_SCALE, or nil if it isn't a number.
function ClusterPositions.limitScale(scale)
  if type(scale) ~= "number" or scale ~= scale then
    return nil
  end
  return math.max(ClusterPositions.MIN_SCALE, math.min(ClusterPositions.MAX_SCALE, scale))
end

-- { point, x, y, scale } for an Edit Mode layout: the saved values where they
-- are valid, otherwise the defaults. A damaged entry never errors.
-- defaultPosition: { point, x, y }
function ClusterPositions.findClusterPosition(savedPositions, layoutName, defaultPosition, defaultScale)
  local clusterPosition =
    { point = defaultPosition.point, x = defaultPosition.x, y = defaultPosition.y, scale = defaultScale }
  local savedPosition = type(savedPositions) == "table" and layoutName ~= nil and savedPositions[layoutName]
  if type(savedPosition) ~= "table" then
    return clusterPosition
  end
  if isValidPosition(savedPosition) then
    clusterPosition.point, clusterPosition.x, clusterPosition.y = savedPosition.point, savedPosition.x, savedPosition.y
  end
  clusterPosition.scale = ClusterPositions.limitScale(savedPosition.scale) or defaultScale
  return clusterPosition
end

function ClusterPositions.saveClusterPosition(savedPositions, layoutName, point, x, y)
  local savedPosition = findOrCreateSavedPosition(savedPositions, layoutName)
  savedPosition.point, savedPosition.x, savedPosition.y = point, x, y
end

function ClusterPositions.saveClusterScale(savedPositions, layoutName, scale)
  findOrCreateSavedPosition(savedPositions, layoutName).scale = ClusterPositions.limitScale(scale)
end
