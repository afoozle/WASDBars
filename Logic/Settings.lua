local ADDON, ns = ...
local Settings = {}
ns.Settings = Settings

-- Account-wide defaults. Later changes add their own keys here.
Settings.defaults = {
  -- Edit Mode layout name -> { point, x, y, scale } (see Logic/Placement.lua)
  layouts = {},
  -- "Name-Realm" -> true once the first-time setup has been offered on that character
  setupOffered = {},
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
