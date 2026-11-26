local ADDON, ns = ...
local Options = {}
ns.Options = Options

-- The addon's page under AddOns in the game's options, built from the game's
-- standard settings rows. Each setting reads and writes WASDBarsDB directly.
local function checkbox(category, key, name, tooltip, onChange)
  local setting = Settings.RegisterProxySetting(
    category,
    "WASDBars_" .. key,
    Settings.VarType.Boolean,
    name,
    ns.Settings.defaults[key],
    function()
      return ns.db[key]
    end,
    function(value)
      ns.db[key] = value
      onChange(value)
    end
  )
  Settings.CreateCheckbox(category, setting, tooltip)
end

local function button(layout, name, buttonText, onClick, tooltip)
  layout:AddInitializer(CreateSettingsButtonInitializer(name, buttonText, onClick, tooltip, true))
end

local function openEditMode()
  if InCombatLockdown() then
    ns.print("Edit Mode can't be opened in combat.")
    return
  end
  HideUIPanel(SettingsPanel)
  ShowUIPanel(EditModeManagerFrame)
end

ns.Events.on("PLAYER_LOGIN", function()
  local category, layout = Settings.RegisterVerticalLayoutCategory("WASDBars")
  Options.category = category

  layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Display"))
  button(
    layout,
    "Move and resize",
    "Open Edit Mode",
    openEditMode,
    "Select WASDBars in Edit Mode to drag it, or click it to change its scale."
  )

  layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Appearance"))
  checkbox(
    category,
    "showMovementKeys",
    "Show movement keys",
    "Show the W, A, S and D arrow keys between the action buttons.",
    ns.MovementKeys.setShown
  )
  checkbox(
    category,
    "largeHotkeys",
    "Large hotkey text",
    "Show each key's name large at the bottom of its button. Off uses the game's small corner text.",
    ns.Cluster.refreshHotkeys
  )

  layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Setup"))
  button(layout, "Set up", "Run setup", function()
    ns.Setup.open()
  end, "Set up the WASDBars layout and keybinds. Shows every change first.")
  button(layout, "Undo setup", "Restore", function()
    ns.Setup.restore()
  end, "Switch back to your previous layout, and optionally your keybinds.")

  Settings.RegisterAddOnCategory(category)
end)

function Options.open()
  if Options.category then
    Settings.OpenToCategory(Options.category:GetID())
  end
end
