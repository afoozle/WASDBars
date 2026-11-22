local ADDON, ns = ...
local Slash = {}
ns.Slash = Slash

-- name -> { help = "one line", run = function(args) }. Later changes add
-- their own commands by inserting into this table.
Slash.commands = {}
local commands = Slash.commands

local function showHelp()
  local names = {}
  for name in pairs(commands) do
    table.insert(names, name)
  end
  table.sort(names)
  ns.print("Commands:")
  for _, name in ipairs(names) do
    DEFAULT_CHAT_FRAME:AddMessage("  /wasd " .. name .. " - " .. commands[name].help)
  end
end

commands.help = { help = "list these commands", run = showHelp }

commands.version = {
  help = "show the addon version",
  run = function()
    local version = ns.addonVersion()
    ns.print(version and ("Version " .. version .. ".") or "Dev build.")
  end,
}

commands.debug = {
  help = "turn extra chat output on or off (this session only)",
  run = function()
    ns.debugEnabled = not ns.debugEnabled
    ns.print("Debug output " .. (ns.debugEnabled and "on" or "off") .. ".")
  end,
}

commands.perf = {
  help = "'start <label>', 'stop' or 'clear' a performance recording for Claude Code",
  run = function(args)
    local action, label = args:match("^(%S*)%s*(.-)$")
    action = action:lower()
    if action == "start" then
      ns.Perf.start(label)
    elseif action == "stop" then
      ns.Perf.stop()
    elseif action == "clear" then
      ns.Perf.clear()
    else
      ns.print("Use /wasd perf start <label>, /wasd perf stop or /wasd perf clear.")
    end
  end,
}

commands.options = {
  help = "open the WASDBars options",
  run = function()
    ns.Options.open()
  end,
}

-- /wasd setup <part>; plain /wasd setup runs the whole setup.
Slash.setup = {
  [""] = function()
    ns.Setup.run()
  end,
  keys = function()
    ns.Bindings.request()
  end,
  layout = function()
    ns.Setup.checkLayout()
  end,
  status = function()
    ns.print(ns.Bindings.statusSentence() .. " " .. ns.Setup.layoutStatusSentence())
  end,
}

commands.setup = {
  help = "run the whole setup; 'keys', 'layout' or 'status' for one part",
  run = function(args)
    local part = Slash.setup[args:lower()]
    if part then
      part()
    else
      ns.print("Use /wasd setup, or /wasd setup keys, layout or status.")
    end
  end,
}

SLASH_WASDBARS1 = "/wasd"
SlashCmdList.WASDBARS = function(msg)
  local name, args = (msg or ""):match("^%s*(%S*)%s*(.-)%s*$")
  name = name:lower()
  if name == "" then
    showHelp()
    return
  end
  local command = commands[name]
  if not command then
    ns.print("'" .. name .. "' isn't a command I recognise.")
    showHelp()
    return
  end
  command.run(args)
end
