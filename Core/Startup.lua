local ADDON, ns = ...
local SavedSettings = ns.SavedSettings

-- Loaded last: connects game events to the features and runs the login steps.
local LibEditMode = LibStub("LibEditMode")

local eventFrame = CreateFrame("Frame")
-- event name -> handlers, run in the order added
local eventHandlers = {}

local function listenFor(eventName, handler)
  if not eventHandlers[eventName] then
    eventHandlers[eventName] = {}
    eventFrame:RegisterEvent(eventName)
  end
  table.insert(eventHandlers[eventName], handler)
end

local function runEventHandlers(_, eventName, ...)
  for _, handler in ipairs(eventHandlers[eventName]) do
    handler(...)
  end
end

-- Saved settings exist from here.
local function loadSavedSettings(addonName)
  if addonName ~= ADDON then
    return
  end
  WASDBarsDB = SavedSettings.fillMissingSettings(WASDBarsDB)
  SavedSettings.moveV110KeybindCopyToAccount(WASDBarsDB)
  ns.db = WASDBarsDB
  WASDBarsPerfDB = SavedSettings.createRecordingsList(WASDBarsPerfDB)
  ns.ChatMessages.printDebugMessage("loaded")
end

-- Fires when the active layout changes, including at login.
local function followActiveLayout(layoutName)
  ns.WasdLayoutMode.followActiveLayout(layoutName)
end

local function buildAddon()
  ns.ActionBarCluster.buildActionBarCluster()
  ns.MovementKeys.drawMovementKeys()
  ns.ClusterEditModeElement.addClusterToEditMode()
  ns.MainBarReplacement.keepActionBar2ArtUpToDate()
  ns.MainBarReplacement.addHideBarArtCheckbox()
  ns.OptionsPage.addOptionsPage()
  LibEditMode:RegisterCallback("layout", followActiveLayout)
  ns.WasdLayoutMode.followActiveLayout(ns.EditModeLayouts.findActiveLayoutName())
end

local function finishCombat()
  ns.CombatQueue.runWaitingJobs()
  ns.MainBarReplacement.redrawActionBar2ArtIfWaiting()
end

local function checkAfterEditModeUpdate()
  ns.ActionBarCluster.moveStrayActionButtonsIntoCluster()
  ns.SetupOffer.offerSetupOrRemindOncePerLogin()
end

local function refreshHotkeys()
  ns.ActionBarCluster.refreshHotkeys()
end

local function runSlashCommand(text)
  ns.SlashCommands.runSlashCommand(text)
end

eventFrame:SetScript("OnEvent", runEventHandlers)
listenFor("ADDON_LOADED", loadSavedSettings)
listenFor("PLAYER_LOGIN", buildAddon)
listenFor("PLAYER_REGEN_ENABLED", finishCombat)
listenFor("UPDATE_BINDINGS", refreshHotkeys)
listenFor("EDIT_MODE_LAYOUTS_UPDATED", checkAfterEditModeUpdate)

SLASH_WASDBARS1 = "/wasd"
SlashCmdList.WASDBARS = runSlashCommand
