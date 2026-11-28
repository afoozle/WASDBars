local ADDON, ns = ...
local ClusterKeys = ns.ClusterKeys
local ClusterPositions = ns.ClusterPositions
local ClusterEditModeElement = {}
ns.ClusterEditModeElement = ClusterEditModeElement

-- LibEditMode (a TOC dependency, installed from CurseForge) makes the cluster
-- its own Edit Mode element. It drags the frame and reports the new point;
-- saving and applying per Edit Mode layout is ours (ns.db.layouts).
local LibEditMode = LibStub("LibEditMode")

-- At login, after the cluster is built.
function ClusterEditModeElement.addClusterToEditMode()
  local clusterFrame = ns.ActionBarCluster.clusterFrame
  clusterFrame:SetMovable(true)
  clusterFrame:SetClampedToScreen(true)
  LibEditMode:AddFrame(clusterFrame, function(_, layoutName, point, x, y)
    ClusterPositions.saveClusterPosition(ns.db.layouts, layoutName, point, x, y)
  end, ClusterKeys.defaultPosition, "WASDBars")
  LibEditMode:AddFrameSettings(clusterFrame, {
    {
      kind = LibEditMode.SettingType.Slider,
      name = "Scale",
      default = ClusterKeys.defaultScale,
      minValue = ClusterPositions.MIN_SCALE,
      maxValue = ClusterPositions.MAX_SCALE,
      valueStep = 0.05,
      get = function(layoutName)
        return ClusterPositions.findClusterPosition(ns.db.layouts, layoutName).scale
      end,
      set = function(layoutName, scale)
        ClusterPositions.saveClusterScale(ns.db.layouts, layoutName, scale)
        ns.WasdLayoutMode.followActiveLayout(layoutName)
      end,
    },
  })
end
