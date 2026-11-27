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

-- A line: { fontName, text, indent, spaceAfter, color }.
local function addLine(lines, fontName, text, spaceAfter, color)
  table.insert(lines, { fontName = fontName, text = text, indent = INDENT, spaceAfter = spaceAfter, color = color })
end

local function addHeading(lines, text)
  table.insert(lines, { fontName = "GameFontNormalLarge", text = text, indent = 0, spaceAfter = 6, color = GOLD })
end

local function addLayoutLines(lines, neededLayoutStepTexts)
  addHeading(lines, "Layout")
  for i, stepText in ipairs(neededLayoutStepTexts) do
    local spaceAfter = i == #neededLayoutStepTexts and 14 or 4
    addLine(lines, "GameFontHighlight", "- " .. stepText, spaceAfter)
  end
end

local function describeActionsLosingTheirKey(actionsLosingTheirKey)
  local descriptions = {}
  for _, actionLosingItsKey in ipairs(actionsLosingTheirKey) do
    table.insert(descriptions, actionLosingItsKey.actionName .. " (" .. table.concat(actionLosingItsKey.keyLabels, ", ") .. ")")
  end
  return table.concat(descriptions, ", ")
end

local function addKeybindLines(lines, groupsToChange, actionsLosingTheirKey)
  addHeading(lines, "Keys")
  for _, groupChanges in ipairs(groupsToChange) do
    addLine(lines, "GameFontNormal", groupChanges.group.heading, 2, GOLD)
    addLine(lines, "GameFontHighlight", groupChanges.group.detail, 8)
  end
  if #actionsLosingTheirKey > 0 then
    addLine(lines, "GameFontNormal", "These will no longer have a key:", 4, ORANGE)
    addLine(lines, "GameFontHighlight", describeActionsLosingTheirKey(actionsLosingTheirKey), 4)
    addLine(lines, "GameFontDisableSmall", "Rebind them in Key Bindings if you use them.", 8)
  end
end

-- Fills the window top to bottom, reusing its font strings.
local function arrangeLines(lines)
  local y = 34
  for i, line in ipairs(lines) do
    local fontString = setupWindow.fontStrings[i] or setupWindow:CreateFontString(nil, "OVERLAY")
    setupWindow.fontStrings[i] = fontString
    fontString:SetFontObject(line.fontName)
    fontString:SetJustifyH("LEFT")
    fontString:SetWidth(WINDOW_WIDTH - 2 * PADDING - line.indent)
    fontString:ClearAllPoints()
    fontString:SetPoint("TOPLEFT", PADDING + line.indent, -y)
    fontString:SetText(line.text)
    fontString:SetTextColor(unpack(line.color or WHITE))
    fontString:Show()
    y = y + fontString:GetStringHeight() + line.spaceAfter
  end
  for i = #lines + 1, #setupWindow.fontStrings do
    setupWindow.fontStrings[i]:Hide()
  end
  setupWindow:SetHeight(y + 48)
end

function SetupWindow.isSetupWindowShown()
  return setupWindow ~= nil and setupWindow:IsShown()
end

-- neededLayoutStepTexts: SetupSteps.describeLayoutStep for each step;
-- groupsToChange and actionsLosingTheirKey: Keybinds.lua.
function SetupWindow.showSetupChanges(neededLayoutStepTexts, groupsToChange, actionsLosingTheirKey, runSetup)
  setupWindow = setupWindow or createSetupWindow()
  local lines = {}
  if #neededLayoutStepTexts > 0 then
    addLayoutLines(lines, neededLayoutStepTexts)
  end
  if #groupsToChange > 0 then
    addKeybindLines(lines, groupsToChange, actionsLosingTheirKey)
  end
  arrangeLines(lines)
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
