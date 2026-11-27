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

-- Fills keys missing from savedSettings with the defaults (a new empty table
-- for each table default) and never overwrites a saved value. Returns the
-- saved table, or a new one when savedSettings is nil.
function SavedSettings.fillMissingSettings(savedSettings)
  savedSettings = savedSettings or {}
  for key, defaultValue in pairs(SavedSettings.DEFAULTS) do
    if savedSettings[key] == nil then
      savedSettings[key] = type(defaultValue) == "table" and {} or defaultValue
    end
  end
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
