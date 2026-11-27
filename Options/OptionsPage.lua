local ADDON, ns = ...
local SavedSettings = ns.SavedSettings
local OptionsPage = {}
ns.OptionsPage = OptionsPage

-- The addon's page under AddOns in the game's options, built from the game's
-- standard settings rows. Each setting reads and writes WASDBarsDB directly.
local optionsCategory

local function readShowMovementKeys()
  return ns.db.showMovementKeys
end

local function saveShowMovementKeys(isShown)
  ns.db.showMovementKeys = isShown
  if isShown then
    ns.MovementKeys.showMovementKeys()
  else
    ns.MovementKeys.hideMovementKeys()
  end
end

local function readLargeHotkeys()
  return ns.db.largeHotkeys
end

local function saveLargeHotkeys(isLarge)
  ns.db.largeHotkeys = isLarge
  if isLarge then
    ns.ActionBarCluster.showLargeHotkeys()
  else
    ns.ActionBarCluster.showGameHotkeys()
  end
end

local function openEditModeFromOptions()
  if ns.CombatQueue.isInCombat() then
    ns.ChatMessages.printMessage("Edit Mode can't be opened in combat.")
    return
  end
  ns.EditModeLayouts.openEditMode()
end

local function openSetupWindow()
  ns.Setup.openSetupWindow()
end

local function askToRestore()
  ns.Restore.askToRestore()
end

-- settingName: the WASDBarsDB key, which also names the game's setting.
local function addCheckbox(settingName, label, tooltip, readValue, saveValue)
  local setting = Settings.RegisterProxySetting(
    optionsCategory,
    "WASDBars_" .. settingName,
    Settings.VarType.Boolean,
    label,
    SavedSettings.DEFAULTS[settingName],
    readValue,
    saveValue
  )
  Settings.CreateCheckbox(optionsCategory, setting, tooltip)
end

local function addButton(optionsLayout, label, buttonText, onClick, tooltip)
  optionsLayout:AddInitializer(CreateSettingsButtonInitializer(label, buttonText, onClick, tooltip, true))
end

local function addHeading(optionsLayout, heading)
  optionsLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer(heading))
end

-- At login.
function OptionsPage.addOptionsPage()
  local optionsLayout
  optionsCategory, optionsLayout = Settings.RegisterVerticalLayoutCategory("WASDBars")

  addHeading(optionsLayout, "Display")
  addButton(
    optionsLayout,
    "Move and resize",
    "Open Edit Mode",
    openEditModeFromOptions,
    "Select WASDBars in Edit Mode to drag it, or click it to change its scale."
  )

  addHeading(optionsLayout, "Appearance")
  addCheckbox(
    "showMovementKeys",
    "Show movement keys",
    "Show the W, A, S and D arrow keys between the action buttons.",
    readShowMovementKeys,
    saveShowMovementKeys
  )
  addCheckbox(
    "largeHotkeys",
    "Large hotkey text",
    "Show each key's name large at the bottom of its button. Off uses the game's small corner text.",
    readLargeHotkeys,
    saveLargeHotkeys
  )

  addHeading(optionsLayout, "Setup")
  addButton(
    optionsLayout,
    "Set up",
    "Run setup",
    openSetupWindow,
    "Set up the WASDBars layout and keybinds. Shows every change first."
  )
  addButton(
    optionsLayout,
    "Undo setup",
    "Restore",
    askToRestore,
    "Switch back to your previous layout, and optionally your keybinds."
  )

  Settings.RegisterAddOnCategory(optionsCategory)
end

-- /wasd options.
function OptionsPage.openOptionsPage()
  if optionsCategory then
    Settings.OpenToCategory(optionsCategory:GetID())
  end
end
