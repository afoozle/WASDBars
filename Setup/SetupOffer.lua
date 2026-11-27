local ADDON, ns = ...
local SetupOffer = {}
ns.SetupOffer = SetupOffer

-- Setup is offered once per character, when its keys or its layout aren't set
-- up. Otherwise, a character not on the WASDBars layout gets a one-line
-- reminder at every login.
local OFFER_POPUP = "WASDBARS_OFFER_SETUP"

local hasCheckedThisLogin = false

local function openSetupWindowNextFrame()
  C_Timer.After(0, ns.Setup.openSetupWindow)
end

StaticPopupDialogs[OFFER_POPUP] = {
  text = "Set up WASDBars?\n\nIt moves action bar 1's buttons into the WASD shape, "
    .. "makes a WASDBars Edit Mode layout and binds your keys. "
    .. "You'll see every change before anything happens.",
  button1 = "Set up",
  button2 = "Not now",
  OnAccept = openSetupWindowNextFrame,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}

local function showOffer()
  ns.db.setupOffered[UnitGUID("player")] = true
  StaticPopup_Show(OFFER_POPUP)
end

local function remindIfOffWasdLayout()
  if ns.Setup.isOffWasdLayout() then
    ns.ChatMessages.printMessage("Not set up on this character. Type /wasd setup to set it up.")
  end
end

-- The realm name isn't ready yet at PLAYER_LOGIN; the GUID is.
local function offerSetupOrRemind()
  if ns.db.setupOffered[UnitGUID("player")] or not ns.Setup.isAnythingLeftToSetUp() then
    remindIfOffWasdLayout()
    return
  end
  ns.CombatQueue.runOutOfCombat("setup-offer", showOffer)
end

-- On every Edit Mode update: layouts arrive after login, so only the first
-- one per login does anything.
function SetupOffer.offerSetupOrRemindOncePerLogin()
  if hasCheckedThisLogin then
    return
  end
  hasCheckedThisLogin = true
  C_Timer.After(0, offerSetupOrRemind)
end
