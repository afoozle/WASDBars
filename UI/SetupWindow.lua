local ADDON, ns = ...
local SetupWindow = {}
ns.SetupWindow = SetupWindow

local WIDTH, PAD, INDENT = 440, 18, 16
local window

local function createWindow()
  local f = CreateFrame("Frame", "WASDBarsSetupWindow", UIParent, "BasicFrameTemplateWithInset")
  f:SetSize(WIDTH, 200)
  f:SetPoint("TOP", 0, -135)
  f:SetFrameStrata("DIALOG")
  f:SetToplevel(true)
  f:EnableMouse(true)
  f:SetMovable(true)
  f:SetClampedToScreen(true)
  f:RegisterForDrag("LeftButton")
  f:SetScript("OnDragStart", f.StartMoving)
  f:SetScript("OnDragStop", f.StopMovingOrSizing)
  f:Hide()
  -- Escape closes it, like the game's own windows
  table.insert(UISpecialFrames, f:GetName())
  if f.TitleText then
    f.TitleText:SetText("Set up WASDBars")
  end
  f.lines = {}

  local setUp = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  setUp:SetSize(120, 24)
  setUp:SetPoint("BOTTOMRIGHT", f, "BOTTOM", -6, 14)
  setUp:SetText("Set up")
  setUp:SetScript("OnClick", function()
    local onSetUp = f.onSetUp
    f:Hide()
    onSetUp()
  end)

  local notNow = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  notNow:SetSize(120, 24)
  notNow:SetPoint("BOTTOMLEFT", f, "BOTTOM", 6, 14)
  notNow:SetText("Not now")
  notNow:SetScript("OnClick", function()
    f:Hide()
  end)
  return f
end

-- Fills the window top to bottom; each line is { font, text, indent, spaceAfter, color }.
local function layout(f, lines)
  local y = 34
  for i, line in ipairs(lines) do
    local text = f.lines[i] or f:CreateFontString(nil, "OVERLAY")
    f.lines[i] = text
    text:SetFontObject(line[1])
    text:SetJustifyH("LEFT")
    text:SetWidth(WIDTH - 2 * PAD - line[3])
    text:ClearAllPoints()
    text:SetPoint("TOPLEFT", PAD + line[3], -y)
    text:SetText(line[2])
    text:SetTextColor(unpack(line[5] or { 1, 1, 1 }))
    text:Show()
    y = y + text:GetStringHeight() + line[4]
  end
  for i = #lines + 1, #f.lines do
    f.lines[i]:Hide()
  end
  f:SetHeight(y + 48)
end

function SetupWindow.isShown()
  return window ~= nil and window:IsShown()
end

-- actions: LayoutPlan.actions; steps, lost: Bindings.steps(). onSetUp runs
-- when Set up is clicked; Not now, the close button and Escape do nothing.
function SetupWindow.show(actions, steps, lost, onSetUp)
  window = window or createWindow()
  local gold = { 1, 0.82, 0 }
  local lines = {}
  if #actions > 0 then
    table.insert(lines, { "GameFontNormalLarge", "Layout", 0, 6, gold })
    for _, action in ipairs(actions) do
      table.insert(lines, { "GameFontHighlight", "- " .. action.text, INDENT, 4 })
    end
    lines[#lines][4] = 14
  end
  if #steps > 0 then
    table.insert(lines, { "GameFontNormalLarge", "Keys", 0, 6, gold })
    for _, step in ipairs(steps) do
      table.insert(lines, { "GameFontNormal", step.group.heading, INDENT, 2, gold })
      table.insert(lines, { "GameFontHighlight", step.group.detail, INDENT, 8 })
    end
    if #lost > 0 then
      local names = {}
      for _, entry in ipairs(lost) do
        table.insert(names, ns.Bindings.actionName(entry.command) .. " (" .. table.concat(entry.keys, ", ") .. ")")
      end
      table.insert(lines, { "GameFontNormal", "These will no longer have a key:", INDENT, 4, { 1, 0.5, 0.25 } })
      table.insert(lines, { "GameFontHighlight", table.concat(names, ", "), INDENT, 4 })
      table.insert(lines, { "GameFontDisableSmall", "Rebind them in Key Bindings if you use them.", INDENT, 8 })
    end
  end
  layout(window, lines)
  window.onSetUp = onSetUp
  window:Show()
end
