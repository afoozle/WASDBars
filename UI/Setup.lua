local ADDON, ns = ...
local Setup = {}
ns.Setup = Setup

local OFFER = "WASDBARS_OFFER_SETUP"

local function settingReader()
  local settings = Enum and Enum.EditModeActionBarSetting
  if not (settings and MainActionBar and MainActionBar.GetSettingValue) then
    return function() end
  end
  return function(name)
    if settings[name] == nil then
      return nil
    end
    local ok, value = pcall(MainActionBar.GetSettingValue, MainActionBar, settings[name])
    if ok then
      return value
    end
  end
end

local function asBool(value)
  if value == nil then
    return nil
  end
  return value == true or value == 1
end

local function screenRect(frame)
  local left, bottom, width, height = frame:GetRect()
  if not left then
    return nil
  end
  local scale = frame:GetEffectiveScale()
  return { left * scale, bottom * scale, width * scale, height * scale }
end

-- What the active Edit Mode layout looks like right now, read from the game's bars.
local function readings()
  local read = settingReader()
  local bar2Shown = MultiBarBottomLeft:IsShown()
  local overlap
  if bar2Shown and MainActionBar then
    local a, b = screenRect(MainActionBar), screenRect(MultiBarBottomLeft)
    if a and b then
      overlap = ns.LayoutCheck.overlaps(a, b)
    end
  end
  return {
    numIcons = read("NumIcons"),
    alwaysShowButtons = asBool(read("AlwaysShowButtons")),
    hideBarArt = asBool(read("HideBarArt")),
    hideBarScrolling = asBool(read("HideBarScrolling")),
    bar2Shown = bar2Shown,
    bar1OverlapsBar2 = overlap,
  }
end

local function problems()
  return ns.LayoutCheck.problems(readings())
end

function Setup.layoutStatus()
  return ns.LayoutCheck.statusLine(problems())
end

-- Lists the manual Edit Mode steps still needed. Never changes the layout.
function Setup.checkLayout()
  local fixes = problems()
  if #fixes == 0 then
    ns.print("action bar layout is set up.")
    return
  end
  local layout = LibStub("LibEditMode"):GetActiveLayoutName() or "current"
  ns.print("in Edit Mode, in your '" .. layout .. "' layout:")
  for _, fix in ipairs(fixes) do
    DEFAULT_CHAT_FRAME:AddMessage("  " .. fix)
  end
end

-- The whole setup: WASD keys, number row, then the layout check.
function Setup.run()
  ns.Bindings.requestAll(Setup.checkLayout)
end

local function characterKey()
  return UnitName("player") .. "-" .. GetRealmName()
end

local function keysSetUp()
  for _, group in ipairs(ns.BindingGroups) do
    if ns.BindingPlan.build(group, GetBindingAction).state ~= "applied" then
      return false
    end
  end
  return true
end

StaticPopupDialogs[OFFER] = {
  text = "Set up WASDBars?\nThis binds your keys to the WASD cluster and action bar 2, "
    .. "and checks your Edit Mode layout. Each step asks first.",
  button1 = "Set up",
  button2 = "Not now",
  OnAccept = function()
    C_Timer.After(0, Setup.run)
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}

-- Offered once per character, and only while its keys aren't set up.
ns.Events.on("PLAYER_LOGIN", function()
  local key = characterKey()
  if ns.db.setupOffered[key] or keysSetUp() then
    return
  end
  ns.combatQueue:run("setup-offer", function()
    ns.db.setupOffered[key] = true
    StaticPopup_Show(OFFER)
  end)
end)
