local ADDON, ns = ...
local AddonVersion = ns.AddonVersion
local SlashCommands = {}
ns.SlashCommands = SlashCommands

-- For /wasd help only, in the order shown.
local HELP_LINES = {
  { command = "help", help = "list these commands" },
  { command = "options", help = "open the WASDBars options" },
  { command = "restore", help = "switch back to your layout from before setup, and optionally your keybinds" },
  { command = "setup", help = "set up the WASDBars layout and keybinds" },
  { command = "version", help = "show the addon version" },
}

local function showHelp()
  ns.ChatMessages.printMessage("Commands:")
  for _, helpLine in ipairs(HELP_LINES) do
    DEFAULT_CHAT_FRAME:AddMessage("  /wasd " .. helpLine.command .. " - " .. helpLine.help)
  end
end

local function showVersion()
  local releaseVersion = AddonVersion.readReleaseVersion(C_AddOns.GetAddOnMetadata(ADDON, "Version"))
  ns.ChatMessages.printMessage(releaseVersion and ("Version " .. releaseVersion .. ".") or "Dev build.")
end

-- Everything typed after /wasd.
function SlashCommands.runSlashCommand(text)
  local command = (text or ""):match("^%s*(%S*)"):lower()
  if command == "" or command == "help" then
    showHelp()
  elseif command == "version" then
    showVersion()
  elseif command == "options" then
    ns.OptionsPage.openOptionsPage()
  elseif command == "setup" then
    ns.Setup.openSetupWindow()
  elseif command == "restore" then
    ns.Restore.askToRestore()
  else
    ns.ChatMessages.printMessage("'" .. command .. "' isn't a command I recognise.")
    showHelp()
  end
end
