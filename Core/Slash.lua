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
  ns.print("commands:")
  for _, name in ipairs(names) do
    DEFAULT_CHAT_FRAME:AddMessage("  /wasd " .. name .. " - " .. commands[name].help)
  end
end

commands.help = { help = "list these commands", run = showHelp }

commands.version = {
  help = "show the addon version",
  run = function()
    local getMetadata = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
    local version = getMetadata(ADDON, "Version")
    if not version or version == "@project-version@" then
      ns.print("dev build")
    else
      ns.print((version:gsub("^v", "")))
    end
  end,
}

commands.debug = {
  help = "turn extra chat output on or off (this session only)",
  run = function()
    ns.debugEnabled = not ns.debugEnabled
    ns.print("debug output " .. (ns.debugEnabled and "on" or "off") .. ".")
  end,
}

-- /wasd setup <part>. Later changes add parts (and status lines) here.
Slash.setup = {
  keys = function()
    ns.Bindings.requestAll()
  end,
  status = function()
    for _, group in ipairs(ns.BindingGroups) do
      ns.print(ns.Bindings.status(group))
    end
  end,
}

commands.setup = {
  help = "'keys' binds the WASD keys and number row; 'status' shows what's set up",
  run = function(args)
    local part = Slash.setup[args:lower()]
    if part then
      part()
    else
      ns.print("use /wasd setup keys or /wasd setup status.")
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
