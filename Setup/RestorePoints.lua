local ADDON, ns = ...
local RestorePoints = {}
ns.RestorePoints = RestorePoints

-- Per character, the layout and action bar 2 from before setup, in the saved
-- table it's given: character GUID -> { layout = layout name, bar2 = was action bar 2 on }.

-- Only the first is kept: a later setup must not overwrite where the character started.
function RestorePoints.saveRestorePointOnce(savedRestorePoints, playerGuid, layoutName, wasActionBar2On)
  savedRestorePoints[playerGuid] = savedRestorePoints[playerGuid] or { layout = layoutName, bar2 = wasActionBar2On }
end

function RestorePoints.findRestorePoint(savedRestorePoints, playerGuid)
  return savedRestorePoints[playerGuid]
end

function RestorePoints.forgetRestorePoint(savedRestorePoints, playerGuid)
  savedRestorePoints[playerGuid] = nil
end
