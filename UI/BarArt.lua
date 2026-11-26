local ADDON, ns = ...
local BarArt = {}
ns.BarArt = BarArt

-- On the WASDBars layout action bar 2 takes action bar 1's place. Action bar 1
-- goes see-through: hiding it would make Edit Mode drop the bottom bar stack
-- into its spot. Action bar 2 gets action bar 1's border, dividers and button
-- frames, drawn the way the game draws them on action bar 1 (see
-- openspec/changes/hide-main-bar/research.md). LibEditMode (a TOC dependency)
-- adds action bar 2's Hide Bar Art checkbox.
local LibEditMode = LibStub("LibEditMode")

local onLayout = false
local seeThrough = false
-- whether action bar 2's buttons have action bar 1's frames; the game's own
-- look until the art is first shown
local styled = false
local dirty = false
local holder, border, pools

-- The two branches of the game's UpdateButtonArt (art on, art off).
local STYLE = {
  [true] = { normal = "UI-HUD-ActionBar-IconFrame", pushed = "UI-HUD-ActionBar-IconFrame-Down", w = 46, h = 45 },
  [false] = {
    normal = "UI-HUD-ActionBar-IconFrame-AddRow",
    pushed = "UI-HUD-ActionBar-IconFrame-AddRow-Down",
    w = 51,
    h = 51,
  },
}

local function styleButton(button, art)
  if not (button.SlotArt and button.SlotBackground) then
    return
  end
  local style = STYLE[art]
  button.SlotArt:SetShown(art)
  button.SlotBackground:SetShown(not art)
  button:SetNormalAtlas(style.normal)
  button.NormalTexture:SetDrawLayer("OVERLAY")
  button.NormalTexture:SetSize(style.w, style.h)
  button:SetPushedAtlas(style.pushed)
  button.PushedTexture:SetDrawLayer("OVERLAY")
  button.PushedTexture:SetSize(style.w, style.h)
end

-- Inside action bar 2, so it follows the bar's position, scale and visibility.
-- At the bar's own frame level, below the button holders, like action bar 1's
-- dividers. The bar sizes itself to its children unless they opt out.
local function build()
  local bar = MultiBarBottomLeft
  holder = CreateFrame("Frame", nil, bar)
  holder:SetAllPoints()
  holder:SetFrameLevel(bar:GetFrameLevel())
  holder.ignoreInLayout = true
  border = holder:CreateTexture(nil, "BACKGROUND", nil, -3)
  border:SetAtlas("UI-HUD-ActionBar-Frame")
  border:SetPoint("TOPLEFT", bar, "TOPLEFT", -6, 6)
  border:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 4, -5)
  pools = {
    horizontal = CreateFramePool("FRAME", holder, "HorizontalDividerTemplate"),
    vertical = CreateFramePool("FRAME", holder, "VerticalDividerTemplate"),
  }
end

local function placeDividers(bar)
  local shown = {}
  for i, button in ipairs(bar.actionButtons) do
    shown[i] = button:IsShown()
  end
  local pool = bar.isHorizontal and pools.horizontal or pools.vertical
  local between = ns.Dividers.between(shown, bar.numRows or 1, bar.buttonPadding or 0, bar.minButtonPadding or 0)
  for _, i in ipairs(between) do
    local button = bar.actionButtons[i]
    local divider = pool:Acquire()
    divider:ClearAllPoints()
    if bar.isHorizontal then
      divider:SetPoint("TOP", button, "TOP", 0, 0)
      divider:SetPoint("BOTTOM", button, "BOTTOM", 0, 0)
      divider:SetPoint("RIGHT", button, "LEFT", 5, 0)
    else
      divider:SetPoint("LEFT", button, "LEFT", 0, 0)
      divider:SetPoint("RIGHT", button, "RIGHT", 0, 0)
      divider:SetPoint("BOTTOM", button, "TOP", 0, -5)
    end
    divider:Show()
  end
end

-- After action bar 2 or the setting changes. In combat it waits for combat
-- to end (anchoring to the secure buttons may not be allowed then).
local function redraw()
  if InCombatLockdown() then
    dirty = true
    return
  end
  dirty = false
  local bar = MultiBarBottomLeft
  local art = onLayout and not ns.db.bar2HideArt
  if art and not holder then
    build()
  end
  if holder then
    holder:SetShown(art)
    pools.horizontal:ReleaseAll()
    pools.vertical:ReleaseAll()
  end
  if art then
    -- Edit Mode's icon size scales each button's holder
    border:SetScale(bar.actionButtons[1].container:GetScale())
    placeDividers(bar)
  end
  if art ~= styled then
    for _, button in ipairs(bar.actionButtons) do
      styleButton(button, art)
    end
    styled = art
  end
end

-- Called from UI/EditMode.lua whenever the active layout changes.
function BarArt.follow(on)
  onLayout = on
  if on or seeThrough then
    seeThrough = on
    ns.combatQueue:run("bar1-alpha", function()
      MainActionBar:SetAlpha(on and 0 or 1)
    end)
  end
  redraw()
end

ns.Events.on("PLAYER_LOGIN", function()
  local bar = MultiBarBottomLeft
  -- the bar's own copies of the Edit Mode functions, not the shared mixin
  hooksecurefunc(bar, "UpdateSystem", redraw)
  hooksecurefunc(bar, "UpdateSystemSetting", function(_, _, entireSystemUpdate)
    -- a whole-system update ends in UpdateSystem, which redraws once
    if not entireSystemUpdate then
      redraw()
    end
  end)
  hooksecurefunc(bar, "UpdateShownButtons", redraw)

  LibEditMode:AddSystemSettings(Enum.EditModeSystem.ActionBar, {
    {
      kind = LibEditMode.SettingType.Checkbox,
      name = "Hide Bar Art",
      default = false,
      get = function()
        return ns.db.bar2HideArt
      end,
      set = function(_, value)
        ns.db.bar2HideArt = value
        redraw()
      end,
      hidden = function(layoutName)
        return layoutName ~= ns.LayoutPlan.NAME
      end,
    },
  }, Enum.EditModeActionBarSystemIndices.Bar2)
end)

ns.Events.on("PLAYER_REGEN_ENABLED", function()
  if dirty then
    redraw()
  end
end)
