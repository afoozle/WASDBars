local ADDON, ns = ...
local EditMode = {}
ns.EditMode = EditMode

-- LibEditMode (a TOC dependency, installed from CurseForge) makes the cluster
-- its own Edit Mode element. It drags the frame and reports the new point;
-- saving and applying per Edit Mode layout is ours.
local LibEditMode = LibStub("LibEditMode")

local function placement(layoutName)
  return ns.Placement.forLayout(ns.db.layouts, layoutName, ns.Layout.position, ns.Layout.scale)
end

-- Scale first, then the point: the offsets are in the frame's scaled units.
-- Being on the WASDBars layout is the player's consent to moving action bar
-- 1's buttons and replacing action bar 1 with action bar 2, so the buttons,
-- the mouse fix and action bar 2's art follow it.
local function apply(layoutName)
  local frame = ns.Cluster.frame
  local point, x, y, scale = placement(layoutName)
  ns.combatQueue:run("placement", function()
    frame:SetScale(scale)
    frame:ClearAllPoints()
    frame:SetPoint(point, UIParent, point, x, y)
  end)
  local onLayout = layoutName == ns.LayoutPlan.NAME
  ns.Cluster.follow(onLayout)
  ns.Setup.mouseFix(onLayout)
  ns.BarArt.follow(onLayout)
end

-- Runs after UI/Cluster.lua's PLAYER_LOGIN handler, which builds the cluster.
ns.Events.on("PLAYER_LOGIN", function()
  local frame = ns.Cluster.frame
  frame:SetMovable(true)
  frame:SetClampedToScreen(true)

  LibEditMode:AddFrame(frame, function(_, layoutName, point, x, y)
    ns.Placement.save(ns.db.layouts, layoutName, { point = point, x = x, y = y })
  end, ns.Layout.position, "WASDBars")

  LibEditMode:AddFrameSettings(frame, {
    {
      kind = LibEditMode.SettingType.Slider,
      name = "Scale",
      default = ns.Layout.scale,
      minValue = ns.Placement.MIN_SCALE,
      maxValue = ns.Placement.MAX_SCALE,
      valueStep = 0.05,
      get = function(layoutName)
        return (select(4, placement(layoutName)))
      end,
      set = function(layoutName, value)
        ns.Placement.save(ns.db.layouts, layoutName, { scale = ns.Placement.clampScale(value) })
        apply(layoutName)
      end,
    },
  })

  -- Fires when the active layout changes, including at login.
  LibEditMode:RegisterCallback("layout", apply)
  apply(LibEditMode:GetActiveLayoutName())
end)

-- Applies the active layout's saved position again, after setup saves one.
function EditMode.refresh()
  apply(LibEditMode:GetActiveLayoutName())
end
