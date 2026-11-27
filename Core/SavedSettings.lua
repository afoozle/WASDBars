local ADDON, ns = ...
local SavedSettings = {}
ns.SavedSettings = SavedSettings

-- Account-wide defaults for WASDBarsDB.
SavedSettings.DEFAULTS = {
  -- Edit Mode layout name -> { point, x, y, scale } (ActionBarCluster/ClusterPositions.lua)
  layouts = {},
  -- character GUID -> true once the first-time setup has been offered on that character
  setupOffered = {},
  -- character GUID -> { layout = name, bar2 = was action bar 2 on } from before setup, for /wasd restore
  restore = {},
  -- "account" or a character GUID (Keybinds/KeybindCopies.lua) -> the 24 setup keys' actions from
  -- before setup first changed them ({ [key] = action | false })
  keyCopies = {},
  -- action bar 2's Hide Bar Art on the WASDBars layout (MainBarReplacement/MainBarReplacement.lua)
  bar2HideArt = false,
  -- options page (Options/OptionsPage.lua)
  showMovementKeys = true,
  largeHotkeys = true,
}

local function copyTable(value)
  if type(value) ~= "table" then
    return value
  end
  local copy = {}
  for key, nestedValue in pairs(value) do
    copy[key] = copyTable(nestedValue)
  end
  return copy
end

local function fillMissingValues(saved, defaults)
  for key, defaultValue in pairs(defaults) do
    if saved[key] == nil then
      saved[key] = copyTable(defaultValue)
    elseif type(saved[key]) == "table" and type(defaultValue) == "table" then
      fillMissingValues(saved[key], defaultValue)
    end
  end
end

-- Fills keys missing from savedSettings with copies of the defaults (into
-- nested tables too) and never overwrites a saved value. Returns the saved
-- table, or a new one when savedSettings is nil.
function SavedSettings.fillMissingSettings(savedSettings)
  savedSettings = savedSettings or {}
  fillMissingValues(savedSettings, SavedSettings.DEFAULTS)
  return savedSettings
end

-- v1.1.0 kept a single account-wide key copy.
function SavedSettings.moveV110KeybindCopyToAccount(savedSettings)
  if savedSettings.keyCopy then
    savedSettings.keyCopies.account = savedSettings.keyCopy
    savedSettings.keyCopy = nil
  end
end

-- WASDBarsPerfDB, with its list of recordings (Performance/PerformanceLog.lua).
function SavedSettings.createRecordingsList(savedRecordings)
  savedRecordings = savedRecordings or {}
  savedRecordings.sessions = savedRecordings.sessions or {}
  return savedRecordings
end
