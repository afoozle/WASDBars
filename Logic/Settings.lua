local ADDON, ns = ...
local Settings = {}
ns.Settings = Settings

-- Account-wide defaults.
Settings.defaults = {
  -- Edit Mode layout name -> { point, x, y, scale } (see Logic/Placement.lua)
  layouts = {},
  -- character GUID -> true once the first-time setup has been offered on that character
  setupOffered = {},
  -- character GUID -> { layout = name, bar2 = was action bar 2 on } from before setup, for /wasd restore
  restore = {},
  -- "account" or a character GUID (Restore.keyCopyOwner) -> the 24 setup keys' binds from
  -- before setup first changed them ({ [key] = command | false })
  keyCopies = {},
  -- action bar 2's Hide Bar Art on the WASDBars layout (UI/BarArt.lua)
  bar2HideArt = false,
  -- options page (UI/Options.lua)
  showMovementKeys = true,
  largeHotkeys = true,
}

local function copy(value)
  if type(value) ~= "table" then
    return value
  end
  local result = {}
  for k, v in pairs(value) do
    result[k] = copy(v)
  end
  return result
end

-- Fills keys missing from saved with copies of the defaults (recursing into
-- nested tables) and never overwrites a saved value. Returns the saved table,
-- or a new one when saved is nil.
function Settings.merge(saved, defaults)
  if saved == nil then
    saved = {}
  end
  for k, v in pairs(defaults) do
    if saved[k] == nil then
      saved[k] = copy(v)
    elseif type(saved[k]) == "table" and type(v) == "table" then
      Settings.merge(saved[k], v)
    end
  end
  return saved
end
