local ADDON, ns = ...
local HotkeyText = {}
ns.HotkeyText = HotkeyText

-- This client spells mouse buttons out in hotkey text ("Mouse Button 5");
-- shortens them to "M5", keeping any modifier prefix ("s-Mouse Button 4" -> "s-M4").
function HotkeyText.shortenMouseButtonNames(hotkeyText)
  if type(hotkeyText) ~= "string" then
    return hotkeyText
  end
  return (hotkeyText:gsub("Mouse Button (%d+)", "M%1"):gsub("Middle Mouse", "M3"))
end
