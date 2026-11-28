local ADDON, ns = ...
local WasdLayoutSettings = ns.WasdLayoutSettings
local ClusterPositions = ns.ClusterPositions
local WasdLayoutMode = {}
ns.WasdLayoutMode = WasdLayoutMode

-- Being on the WASDBars layout is the player's consent to moving action bar
-- 1's buttons and replacing action bar 1 with action bar 2, so both follow it.

local function enterWasdLayoutMode()
  ns.ActionBarCluster.moveActionButtonsIntoCluster()
  ns.MainBarReplacement.replaceActionBar1()
end

local function leaveWasdLayoutMode()
  ns.ActionBarCluster.moveActionButtonsBackToActionBar1()
  ns.MainBarReplacement.restoreActionBar1()
end

-- When the active layout changes (including at login), and after the
-- cluster's position or scale is saved.
function WasdLayoutMode.followActiveLayout(layoutName)
  ns.ActionBarCluster.repositionActionBarCluster(ClusterPositions.findClusterPosition(ns.db.layouts, layoutName))
  if layoutName == WasdLayoutSettings.WASD_LAYOUT_NAME then
    enterWasdLayoutMode()
  else
    leaveWasdLayoutMode()
  end
end
