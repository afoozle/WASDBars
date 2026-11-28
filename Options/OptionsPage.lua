local ADDON, ns = ...
local SavedSettings = ns.SavedSettings
local OptionsPage = {}
ns.OptionsPage = OptionsPage

-- The addon's page under AddOns in the game's options, built from the game's
-- standard settings rows. Each setting reads and writes WASDBarsDB directly.
local optionsCategory

local function openEditModeFromOptions()
  if InCombatLockdown() then
    ns.ChatMessages.printMessage("Edit Mode can't be opened in combat.")
    return
  end
  HideUIPanel(SettingsPanel)
  ShowUIPanel(EditModeManagerFrame)
end

-- settingName: the WASDBarsDB key, which also names the game's setting.
-- onChange runs after the new value is saved.
local function addCheckbox(settingName, label, tooltip, onChange)
  local setting = Settings.RegisterProxySetting(
    optionsCategory,
    "WASDBars_" .. settingName,
    Settings.VarType.Boolean,
    label,
    SavedSettings.DEFAULTS[settingName],
    function()
      return ns.db[settingName]
    end,
    function(value)
      ns.db[settingName] = value
      onChange()
    end
  )
  Settings.CreateCheckbox(optionsCategory, setting, tooltip)
end

-- At login.
function OptionsPage.addOptionsPage()
  local optionsLayout
  optionsCategory, optionsLayout = Settings.RegisterVerticalLayoutCategory("WASDBars")

  optionsLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Display"))
  optionsLayout:AddInitializer(
    CreateSettingsButtonInitializer(
      "Move and resize",
      "Open Edit Mode",
      openEditModeFromOptions,
      "Select WASDBars in Edit Mode to drag it, or click it to change its scale.",
      true
    )
  )

  optionsLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Appearance"))
  addCheckbox(
    "showMovementKeys",
    "Show movement keys",
    "Show the W, A, S and D arrow keys between the action buttons.",
    ns.MovementKeys.updateMovementKeysShown
  )
  addCheckbox(
    "largeHotkeys",
    "Large hotkey text",
    "Show each key's name large at the bottom of its button. Off uses the game's small corner text.",
    ns.ActionBarCluster.refreshHotkeys
  )

  optionsLayout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Setup"))
  optionsLayout:AddInitializer(
    CreateSettingsButtonInitializer("Set up", "Run setup", ns.Setup.openSetupWindow, "Set up the WASDBars layout and keybinds. Shows every change first.", true)
  )
  optionsLayout:AddInitializer(
    CreateSettingsButtonInitializer(
      "Undo setup",
      "Restore",
      ns.Restore.askToRestore,
      "Switch back to your previous layout, and optionally your keybinds.",
      true
    )
  )

  Settings.RegisterAddOnCategory(optionsCategory)
end

-- /wasd options. The game blocks addons from opening its options in combat.
function OptionsPage.openOptionsPage()
  if InCombatLockdown() then
    ns.ChatMessages.printMessage("Options can't be opened in combat.")
    return
  end
  Settings.OpenToCategory(optionsCategory:GetID())
end
