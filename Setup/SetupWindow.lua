local ADDON, ns = ...
local SetupWindow = {}
ns.SetupWindow = SetupWindow

-- The window listing every change setup will make. Set up runs them; Not now,
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
    table.insert(
      descriptions,
      actionLosingItsKey.actionName .. " (" .. table.concat(actionLosingItsKey.keyLabels, ", ") .. ")"
    )
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
