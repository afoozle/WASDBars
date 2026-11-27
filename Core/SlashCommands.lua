local ADDON, ns = ...
local SlashCommands = {}
ns.SlashCommands = SlashCommands

-- For /wasd help only, in the order shown.
SlashCommands.HELP_LINES = {
  { command = "debug", help = "turn extra chat output on or off (this session only)" },
  { command = "help", help = "list these commands" },
  { command = "options", help = "open the WASDBars options" },
  { command = "perf", help = "'start <label>', 'stop' or 'clear' a performance recording for Claude Code" },
  { command = "restore", help = "switch back to your layout from before setup, and optionally your keybinds" },
  { command = "setup", help = "set up the WASDBars layout and keybinds; 'status' to check them" },
  { command = "version", help = "show the addon version" },
}

local function showHelp()
  ns.ChatMessages.printMessage("Commands:")
  for _, helpLine in ipairs(SlashCommands.HELP_LINES) do
    DEFAULT_CHAT_FRAME:AddMessage("  /wasd " .. helpLine.command .. " - " .. helpLine.help)
  end
end

local function showVersion()
  local releaseVersion = ns.AddonVersion.readReleaseVersion(C_AddOns.GetAddOnMetadata(ADDON, "Version"))
  ns.ChatMessages.printMessage(releaseVersion and ("Version " .. releaseVersion .. ".") or "Dev build.")
end

local function switchDebugOutput()
  if ns.ChatMessages.isDebugOutputOn() then
    ns.ChatMessages.turnDebugOutputOff()
    ns.ChatMessages.printMessage("Debug output off.")
  else
    ns.ChatMessages.turnDebugOutputOn()
    ns.ChatMessages.printMessage("Debug output on.")
  end
end

local function runPerformanceCommand(arguments)
  local performanceCommand, label = arguments:match("^(%S*)%s*(.-)$")
  performanceCommand = performanceCommand:lower()
  if performanceCommand == "start" then
    ns.PerformanceRecorder.startRecording(label)
  elseif performanceCommand == "stop" then
    ns.PerformanceRecorder.stopRecording()
  elseif performanceCommand == "clear" then
    ns.PerformanceRecorder.clearRecordings()
  else
    ns.ChatMessages.printMessage("Use /wasd perf start <label>, /wasd perf stop or /wasd perf clear.")
  end
end

local function runSetupCommand(arguments)
  local setupCommand = arguments:lower()
  if setupCommand == "" then
    ns.Setup.openSetupWindow()
  elseif setupCommand == "status" then
    ns.ChatMessages.printMessage(ns.Setup.describeSetupStatus())
  else
    ns.ChatMessages.printMessage("Use /wasd setup, or /wasd setup status.")
  end
end

local function reportUnknownCommand(command)
  ns.ChatMessages.printMessage("'" .. command .. "' isn't a command I recognise.")
  showHelp()
end

-- Everything typed after /wasd.
function SlashCommands.runSlashCommand(text)
  local command, arguments = (text or ""):match("^%s*(%S*)%s*(.-)%s*$")
  command = command:lower()
  if command == "" or command == "help" then
    showHelp()
  elseif command == "version" then
    showVersion()
  elseif command == "debug" then
    switchDebugOutput()
  elseif command == "perf" then
    runPerformanceCommand(arguments)
  elseif command == "options" then
    ns.OptionsPage.openOptionsPage()
  elseif command == "setup" then
    runSetupCommand(arguments)
  elseif command == "restore" then
    ns.Restore.askToRestore()
  else
    reportUnknownCommand(command)
  end
end
