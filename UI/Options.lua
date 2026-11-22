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
  button(layout, "Keybinds", "Set up keybinds", function()
    ns.Bindings.request()
  end, "Bind the keys around WASD to action bar 1 and the number row to action bar 2. Shows what changes first.")
  button(layout, "Edit Mode layout", "Check layout", function()
    ns.Setup.checkLayout()
  end, "List any Edit Mode settings that don't suit WASDBars. Changes nothing.")

  Settings.RegisterAddOnCategory(category)
end)

function Options.open()
  if Options.category then
    Settings.OpenToCategory(Options.category:GetID())
  end
end
