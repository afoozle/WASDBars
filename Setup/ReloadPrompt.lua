local ADDON, ns = ...
local ReloadPrompt = {}
ns.ReloadPrompt = ReloadPrompt

-- After setup or restore has switched or changed the layout: applying it from
-- addon code taints the game's bar code (the stance bar is blocked in combat)
-- until a reload.
-- Addons can't reload the UI themselves on this client (ReloadUI is
-- protected), but a secure button running the /reload macro can, when the
-- player clicks it. It holds a protected button, so this frame is its own
-- (not the setup window, which Escape and dragging would have to move in
-- combat), is only shown out of combat, and has no close button.
local reloadFrame

local function createReloadFrame()
  local frame = CreateFrame("Frame", "WASDBarsReloadFrame", UIParent, "BasicFrameTemplateWithInset")
  frame:SetSize(320, 96)
  frame:SetPoint("TOP", 0, -135)
  frame:SetFrameStrata("DIALOG")
  frame:SetToplevel(true)
  frame:EnableMouse(true)
  frame:Hide()
  frame.TitleText:SetText("WASDBars")
  frame.CloseButton:Hide()
  frame.text = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
  frame.text:SetPoint("TOP", 0, -34)

  local reloadButton =
    CreateFrame("Button", "WASDBarsReloadButton", frame, "SecureActionButtonTemplate, UIPanelButtonTemplate")
  reloadButton:SetSize(160, 24)
  reloadButton:SetPoint("BOTTOM", 0, 14)
  reloadButton:SetText("Reload to finish")
  reloadButton:SetAttribute("type", "macro")
  reloadButton:SetAttribute("macrotext", "/reload")
  reloadButton:RegisterForClicks("AnyUp", "AnyDown")
  return frame
end

local function showReloadFrame(whatWasDone)
  reloadFrame = reloadFrame or createReloadFrame()
  reloadFrame.text:SetText(whatWasDone .. ". Reload the UI to finish.")
  reloadFrame:Show()
end

-- whatWasDone: "Set up" or "Restored".
function ReloadPrompt.askForReload(whatWasDone)
  ns.CombatQueue.runOutOfCombat("reload-prompt", function()
    showReloadFrame(whatWasDone)
  end)
end
