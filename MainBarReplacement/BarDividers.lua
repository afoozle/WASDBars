local ADDON, ns = ...
local BarDividers = {}
ns.BarDividers = BarDividers

-- Which of a bar's buttons get a divider just before them, by the rule the
-- game uses on action bar 1 (MainActionBarMixin:UpdateDividers): none on more
-- than one row or with padding above the minimum; otherwise every shown
-- button whose previous button is shown.
-- isButtonShown: booleans in button order. Returns button indices.
function BarDividers.findButtonsNeedingDivider(isButtonShown, rowCount, padding, minimumPadding)
  local buttonsNeedingDivider = {}
  if rowCount > 1 or padding > minimumPadding then
    return buttonsNeedingDivider
  end
  for i = 2, #isButtonShown do
    if isButtonShown[i] and isButtonShown[i - 1] then
      table.insert(buttonsNeedingDivider, i)
    end
  end
  return buttonsNeedingDivider
end
