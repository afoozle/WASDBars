local ADDON, ns = ...
local Bindings = {}
ns.Bindings = Bindings

local WIDTH, PAD, INDENT = 440, 18, 16
local window

local function plans()
  local list = {}
  for i, group in ipairs(ns.BindingGroups) do
    list[i] = ns.BindingPlan.build(group, GetBindingAction)
  end
  return list
end

-- Older clients return the form's name second; newer ones its spell ID fourth.
local function formName(n)
  local _, name, _, spellID = GetShapeshiftFormInfo(n)
  if type(name) == "string" then
    return name
  end
  if type(spellID) == "number" and C_Spell and C_Spell.GetSpellName then
    return C_Spell.GetSpellName(spellID)
  end
end

local function actionName(command)
  return ns.BindingPlan.commandName(command, GetBindingName, formName)
end

local function apply(steps)
  for _, step in ipairs(steps) do
    for _, change in ipairs(step.plan.changes) do
      SetBinding(change.key, change.command)
    end
  end
  -- keeps whichever set the character already uses (account or character)
  SaveBindings(GetCurrentBindingSet())
  ns.print("Keybinds set up.")
  for _, step in ipairs(steps) do
    if step.group.id == "numbers" and not MultiBarBottomLeft:IsShown() then
      ns.print("Action bar 2 is turned off. Turn it on in Edit Mode to see the number row.")
    end
  end
end

local function createWindow()
  local f = CreateFrame("Frame", "WASDBarsKeybindWindow", UIParent, "BasicFrameTemplateWithInset")
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
    f.TitleText:SetText("Set up WASDBars keybinds")
  end
  f.lines = {}

  local confirm = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  confirm:SetSize(120, 24)
  confirm:SetPoint("BOTTOMRIGHT", f, "BOTTOM", -6, 14)
  confirm:SetText("Confirm")
  confirm:SetScript("OnClick", function()
    local steps = f.steps
    ns.combatQueue:run("keybinds", function()
      apply(steps)
    end)
    f:Hide()
  end)

  local cancel = CreateFrame("Button", nil, f, "UIPanelButtonTemplate")
  cancel:SetSize(120, 24)
  cancel:SetPoint("BOTTOMLEFT", f, "BOTTOM", 6, 14)
  cancel:SetText("Cancel")
  cancel:SetScript("OnClick", function()
    f:Hide()
  end)

  -- Confirm, Cancel, the close button and Escape all end up here.
  f:SetScript("OnHide", function()
    local onDone = f.onDone
    f.onDone, f.steps = nil, nil
    if onDone then
      onDone()
    end
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
    if line[5] then
      text:SetTextColor(unpack(line[5]))
    end
    text:Show()
    y = y + text:GetStringHeight() + line[4]
  end
  for i = #lines + 1, #f.lines do
    f.lines[i]:Hide()
  end
  f:SetHeight(y + 48)
end

local function show(steps, lost, onDone)
  window = window or createWindow()
  local lines = {}
  for i, step in ipairs(steps) do
    table.insert(lines, { "GameFontNormal", i .. ". " .. step.group.heading, 0, 4 })
    table.insert(lines, { "GameFontHighlight", step.group.detail, INDENT, 12 })
  end
  if #lost > 0 then
    local names = {}
    for _, entry in ipairs(lost) do
      table.insert(names, actionName(entry.command) .. " (" .. table.concat(entry.keys, ", ") .. ")")
    end
    table.insert(lines, { "GameFontNormal", "These will no longer have a key:", 0, 4, { 1, 0.5, 0.25 } })
    table.insert(lines, { "GameFontHighlight", table.concat(names, ", "), INDENT, 4 })
    table.insert(lines, { "GameFontDisableSmall", "Rebind them in Key Bindings if you use them.", INDENT, 8 })
  end
  layout(window, lines)
  window.steps, window.onDone = steps, onDone
  window:Show()
end

-- Shows the keybind window for every group that isn't set up yet. onDone runs
-- once the window closes (Confirm or not), or straight away if there's nothing to do.
function Bindings.request(onDone)
  ns.combatQueue:run("keybinds", function()
    if window and window:IsShown() then
      return
    end
    local all, steps = plans(), {}
    for i, group in ipairs(ns.BindingGroups) do
      if #all[i].changes > 0 then
        table.insert(steps, { group = group, plan = all[i] })
      end
    end
    if #steps == 0 then
      ns.print("Keybinds are already set up.")
      if onDone then
        onDone()
      end
      return
    end
    local stepPlans = {}
    for i, step in ipairs(steps) do
      stepPlans[i] = step.plan
    end
    show(steps, ns.BindingPlan.lostActions(stepPlans, GetBindingKey), onDone)
  end)
end

function Bindings.isSetUp()
  for _, plan in ipairs(plans()) do
    if plan.state ~= "applied" then
      return false
    end
  end
  return true
end

function Bindings.statusSentence()
  return ns.BindingPlan.statusSentence(ns.BindingGroups, plans())
end
