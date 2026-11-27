local ADDON, ns = ...
local SetupWindow = {}
ns.SetupWindow = SetupWindow

-- The window listing every change setup will make, and the "Reload to finish"
-- window after it. Set up runs the changes; Not now,
-- the close button and Escape do nothing.
local WINDOW_WIDTH, PADDING, INDENT = 440, 18, 16
local GOLD, ORANGE, WHITE = { 1, 0.82, 0 }, { 1, 0.5, 0.25 }, { 1, 1, 1 }

local setupWindow
-- runs when Set up is clicked
local onSetUpClicked

local function runSetUp()
  local runSetUpNow = onSetUpClicked
  setupWindow:Hide()
  runSetUpNow()
end

local function hideSetupWindow()
  setupWindow:Hide()
end

local function createButton(parent, text, onClick)
  local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
  button:SetSize(120, 24)
  button:SetText(text)
  button:SetScript("OnClick", onClick)
  return button
end

local function createSetupWindow()
  local window = CreateFrame("Frame", "WASDBarsSetupWindow", UIParent, "BasicFrameTemplateWithInset")
  window:SetSize(WINDOW_WIDTH, 200)
  window:SetPoint("TOP", 0, -135)
  window:SetFrameStrata("DIALOG")
  window:SetToplevel(true)
  window:EnableMouse(true)
  window:SetMovable(true)
  window:SetClampedToScreen(true)
  window:RegisterForDrag("LeftButton")
  window:SetScript("OnDragStart", window.StartMoving)
  window:SetScript("OnDragStop", window.StopMovingOrSizing)
  window:Hide()
  -- Escape closes it, like the game's own windows
  table.insert(UISpecialFrames, window:GetName())
  window.TitleText:SetText("Set up WASDBars")
  window.fontStrings = {}
  createButton(window, "Set up", runSetUp):SetPoint("BOTTOMRIGHT", window, "BOTTOM", -6, 14)
  createButton(window, "Not now", hideSetupWindow):SetPoint("BOTTOMLEFT", window, "BOTTOM", 6, 14)
  return window
end

-- the next line's number and how far down the window it goes, while the window is filled
local lineCount, nextLineY

-- Places a line below the last one, reusing the window's font strings.
local function addText(fontName, text, indent, spaceAfter, color)
  lineCount = lineCount + 1
  local fontString = setupWindow.fontStrings[lineCount] or setupWindow:CreateFontString(nil, "OVERLAY")
  setupWindow.fontStrings[lineCount] = fontString
  fontString:SetFontObject(fontName)
  fontString:SetJustifyH("LEFT")
  fontString:SetWidth(WINDOW_WIDTH - 2 * PADDING - indent)
  fontString:ClearAllPoints()
  fontString:SetPoint("TOPLEFT", PADDING + indent, -nextLineY)
  fontString:SetText(text)
  fontString:SetTextColor(unpack(color or WHITE))
  fontString:Show()
  nextLineY = nextLineY + fontString:GetStringHeight() + spaceAfter
end

local function addLine(fontName, text, spaceAfter, color)
  addText(fontName, text, INDENT, spaceAfter, color)
end

local function addHeading(text)
  addText("GameFontNormalLarge", text, 0, 6, GOLD)
end

local function addLayoutLines(neededLayoutStepTexts)
  addHeading("Layout")
  for i, stepText in ipairs(neededLayoutStepTexts) do
    local spaceAfter = i == #neededLayoutStepTexts and 14 or 4
    addLine("GameFontHighlight", "- " .. stepText, spaceAfter)
  end
end

local function describeActionsLosingTheirKey(actionsLosingTheirKey)
  local descriptions = {}
  for _, actionLosingItsKey in ipairs(actionsLosingTheirKey) do
    table.insert(descriptions, actionLosingItsKey.actionName .. " (" .. table.concat(actionLosingItsKey.keyLabels, ", ") .. ")")
  end
  return table.concat(descriptions, ", ")
end

local function addKeybindLines(groupsToChange, actionsLosingTheirKey)
  addHeading("Keys")
  for _, groupChanges in ipairs(groupsToChange) do
    addLine("GameFontNormal", groupChanges.group.heading, 2, GOLD)
    addLine("GameFontHighlight", groupChanges.group.detail, 8)
  end
  if #actionsLosingTheirKey > 0 then
    addLine("GameFontNormal", "These will no longer have a key:", 4, ORANGE)
    addLine("GameFontHighlight", describeActionsLosingTheirKey(actionsLosingTheirKey), 4)
    addLine("GameFontDisableSmall", "Rebind them in Key Bindings if you use them.", 8)
  end
end

-- neededLayoutStepTexts: SetupSteps.describeLayoutStep for each step;
-- groupsToChange and actionsLosingTheirKey: Keybinds.lua. Shown again, it is
-- filled with the new changes.
function SetupWindow.showSetupChanges(neededLayoutStepTexts, groupsToChange, actionsLosingTheirKey, runSetup)
  setupWindow = setupWindow or createSetupWindow()
  lineCount, nextLineY = 0, 34
  if #neededLayoutStepTexts > 0 then
    addLayoutLines(neededLayoutStepTexts)
  end
  if #groupsToChange > 0 then
    addKeybindLines(groupsToChange, actionsLosingTheirKey)
  end
  for i = lineCount + 1, #setupWindow.fontStrings do
    setupWindow.fontStrings[i]:Hide()
  end
  setupWindow:SetHeight(nextLineY + 48)
  onSetUpClicked = runSetup
  setupWindow:Show()
end

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

  local reloadButton = CreateFrame("Button", "WASDBarsReloadButton", frame, "SecureActionButtonTemplate, UIPanelButtonTemplate")
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
function SetupWindow.askForReload(whatWasDone)
  ns.CombatQueue.runOutOfCombat("reload-prompt", function()
    showReloadFrame(whatWasDone)
  end)
end
