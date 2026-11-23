local ADDON, ns = ...
local LayoutCheck = {}
ns.LayoutCheck = LayoutCheck

-- Each check reads one field of `readings` and passes when it equals `want`;
-- a nil field means the game couldn't tell us, and that check is skipped.
-- `fix` is the manual Edit Mode step.
local CHECKS = {
  {
    field = "numIcons",
    want = 12,
    fix = "Action Bar 1: set # of Icons to 12 (otherwise the cluster's last buttons are hidden).",
  },
  { field = "alwaysShowButtons", want = true, fix = "Action Bar 1: turn on Always Show Buttons." },
  { field = "hideBarArt", want = true, fix = "Action Bar 1: turn on Hide Bar Art." },
  { field = "hideBarScrolling", want = true, fix = "Action Bar 1: turn on Hide Bar Scrolling." },
  { field = "bar2Shown", want = true, fix = "Action Bar 2: turn it on." },
  {
    field = "bar1OverlapsBar2",
    want = false,
    fix = "Action Bar 1: drag it away from Action Bar 2 (it blocks Action Bar 2's tooltips).",
  },
}

-- readings: { numIcons, alwaysShowButtons, hideBarArt, hideBarScrolling,
-- bar2Shown, bar1OverlapsBar2 }. Returns the fix for each check that fails.
function LayoutCheck.problems(readings)
  local fixes = {}
  for _, check in ipairs(CHECKS) do
    local value = readings[check.field]
    if value ~= nil and value ~= check.want then
      table.insert(fixes, check.fix)
    end
  end
  return fixes
end

-- Rects are { left, bottom, width, height } in the same units; touching edges don't overlap.
function LayoutCheck.overlaps(a, b)
  return a[1] < b[1] + b[3] and b[1] < a[1] + a[3] and a[2] < b[2] + b[4] and b[2] < a[2] + a[4]
end

-- The layout half of /wasd setup status.
function LayoutCheck.statusSentence(fixes)
  if #fixes == 0 then
    return "Edit Mode layout ready."
  end
  return "Edit Mode layout " .. LayoutCheck.needs(fixes) .. " (/wasd setup layout)."
end

-- "needs 1 change" / "needs 2 changes"
function LayoutCheck.needs(fixes)
  return "needs " .. #fixes .. (#fixes == 1 and " change" or " changes")
end
