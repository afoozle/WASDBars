local ADDON, ns = ...
local HotkeyText = {}
ns.HotkeyText = HotkeyText

-- This client spells mouse buttons out in hotkey text ("Mouse Button 5");
-- shortens them to "M5", keeping any modifier prefix ("s-Mouse Button 4" -> "s-M4").
function HotkeyText.shorten(text)
  if type(text) ~= "string" then
    return text
  end
  return (text:gsub("Mouse Button (%d+)", "M%1"):gsub("Middle Mouse", "M3"))
end
