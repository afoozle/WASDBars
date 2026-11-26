local ADDON, ns = ...
local Dividers = {}
ns.Dividers = Dividers

-- Which of a bar's buttons get a divider just before them, by the rule the
-- game uses on action bar 1 (MainActionBarMixin:UpdateDividers): none with the
-- art hidden, more than one row, or padding above the minimum; otherwise
-- every shown button whose previous button is shown.
-- shown: booleans in button order. Returns button indices.
function Dividers.between(shown, rows, padding, minPadding, hideArt)
  local list = {}
  if hideArt or rows > 1 or padding > minPadding then
    return list
  end
  for i = 2, #shown do
    if shown[i] and shown[i - 1] then
      table.insert(list, i)
    end
  end
  return list
end
