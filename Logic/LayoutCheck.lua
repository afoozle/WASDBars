local ADDON, ns = ...
local LayoutCheck = {}
ns.LayoutCheck = LayoutCheck

-- Each check reads one field of `readings`; a nil field means the game
-- couldn't tell us, and that check is skipped. `fix` is the manual Edit Mode step.
local CHECKS = {
  {
    field = "numIcons",
    ok = function(v)
      return v == 12
    end,
    fix = "Action Bar 1: set # of Icons to 12 (otherwise the cluster's last buttons are hidden).",
  },
  {
    field = "alwaysShowButtons",
    ok = function(v)
      return v
    end,
    fix = "Action Bar 1: turn on Always Show Buttons.",
  },
  {
    field = "hideBarArt",
    ok = function(v)
      return v
    end,
    fix = "Action Bar 1: turn on Hide Bar Art.",
  },
  {
    field = "hideBarScrolling",
    ok = function(v)
      return v
    end,
    fix = "Action Bar 1: turn on Hide Bar Scrolling.",
  },
  {
    field = "bar2Shown",
    ok = function(v)
      return v
    end,
    fix = "Action Bar 2: turn it on.",
  },
  {
    field = "bar1OverlapsBar2",
    ok = function(v)
      return not v
    end,
    fix = "Action Bar 1: drag it away from Action Bar 2 (it blocks Action Bar 2's tooltips).",
  },
}

-- readings: { numIcons, alwaysShowButtons, hideBarArt, hideBarScrolling,
-- bar2Shown, bar1OverlapsBar2 }. Returns the fix for each check that fails.
function LayoutCheck.problems(readings)
  local fixes = {}
  for _, check in ipairs(CHECKS) do
    local value = readings[check.field]
    if value ~= nil and not check.ok(value) then
      table.insert(fixes, check.fix)
    end
  end
  return fixes
end

-- Rects are { left, bottom, width, height } in the same units; touching edges don't overlap.
function LayoutCheck.overlaps(a, b)
  return a[1] < b[1] + b[3] and b[1] < a[1] + a[3] and a[2] < b[2] + b[4] and b[2] < a[2] + a[4]
end

-- One line for /wasd setup status.
function LayoutCheck.statusLine(fixes)
  if #fixes == 0 then
    return "Action bar layout: OK"
  end
  local things = #fixes == 1 and "1 thing" or (#fixes .. " things")
  return "Action bar layout: " .. things .. " to fix (/wasd setup layout)"
end
