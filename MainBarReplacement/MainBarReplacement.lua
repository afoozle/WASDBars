local ADDON, ns = ...
local BarDividers = ns.BarDividers
local WasdLayoutSettings = ns.WasdLayoutSettings
local MainBarReplacement = {}
ns.MainBarReplacement = MainBarReplacement

-- On the WASDBars layout action bar 2 takes action bar 1's place. Action bar 1
-- goes see-through: hiding it would make Edit Mode drop the bottom bar stack
-- into its spot. Action bar 2 gets action bar 1's border, dividers and button
-- frames, drawn the way the game draws them on action bar 1 (see
-- openspec/changes/archive/2026-11-26-hide-main-bar/research.md).
-- LibEditMode (a TOC dependency) adds action bar 2's Hide Bar Art checkbox.
local LibEditMode = LibStub("LibEditMode")

local isOnWasdLayout = false
local isActionBar1SeeThrough = false
-- whether action bar 2's buttons have action bar 1's frames; the game's own
-- look until the art is first shown
local areButtonsStyledLikeActionBar1 = false
local isRedrawWaitingForCombat = false
local artHolder, border, dividerPools
-- action bar 1's own mouse state, from before WASDBars changed it
local gameMouseState

-- The two branches of the game's UpdateButtonArt.
local ACTION_BAR_1_BUTTON_STYLE = {
  isSlotArtShown = true,
  normalAtlas = "UI-HUD-ActionBar-IconFrame",
  pushedAtlas = "UI-HUD-ActionBar-IconFrame-Down",
  width = 46,
  height = 45,
}
local ACTION_BAR_2_BUTTON_STYLE = {
  isSlotArtShown = false,
  normalAtlas = "UI-HUD-ActionBar-IconFrame-AddRow",
  pushedAtlas = "UI-HUD-ActionBar-IconFrame-AddRow-Down",
  width = 51,
  height = 51,
}

local function applyButtonStyle(button, buttonStyle)
  button.SlotArt:SetShown(buttonStyle.isSlotArtShown)
  button.SlotBackground:SetShown(not buttonStyle.isSlotArtShown)
  button:SetNormalAtlas(buttonStyle.normalAtlas)
  button.NormalTexture:SetDrawLayer("OVERLAY")
  button.NormalTexture:SetSize(buttonStyle.width, buttonStyle.height)
  button:SetPushedAtlas(buttonStyle.pushedAtlas)
  button.PushedTexture:SetDrawLayer("OVERLAY")
  button.PushedTexture:SetSize(buttonStyle.width, buttonStyle.height)
end

local function styleButtonsLikeActionBar1()
  for _, button in ipairs(MultiBarBottomLeft.actionButtons) do
    applyButtonStyle(button, ACTION_BAR_1_BUTTON_STYLE)
  end
  areButtonsStyledLikeActionBar1 = true
end

local function styleButtonsLikeActionBar2()
  for _, button in ipairs(MultiBarBottomLeft.actionButtons) do
    applyButtonStyle(button, ACTION_BAR_2_BUTTON_STYLE)
  end
  areButtonsStyledLikeActionBar1 = false
end

-- Inside action bar 2, so it follows the bar's position, scale and visibility.
-- At the bar's own frame level, below the button holders, like action bar 1's
-- dividers. The bar sizes itself to its children unless they opt out.
local function createArtHolder()
  local actionBar2 = MultiBarBottomLeft
  artHolder = CreateFrame("Frame", nil, actionBar2)
  artHolder:SetAllPoints()
  artHolder:SetFrameLevel(actionBar2:GetFrameLevel())
  artHolder.ignoreInLayout = true
  border = artHolder:CreateTexture(nil, "BACKGROUND", nil, -3)
  border:SetAtlas("UI-HUD-ActionBar-Frame")
  border:SetPoint("TOPLEFT", actionBar2, "TOPLEFT", -6, 6)
  border:SetPoint("BOTTOMRIGHT", actionBar2, "BOTTOMRIGHT", 4, -5)
  dividerPools = {
    horizontal = CreateFramePool("FRAME", artHolder, "HorizontalDividerTemplate"),
    vertical = CreateFramePool("FRAME", artHolder, "VerticalDividerTemplate"),
  }
end

local function placeHorizontalDivider(divider, button)
  divider:SetPoint("TOP", button, "TOP", 0, 0)
  divider:SetPoint("BOTTOM", button, "BOTTOM", 0, 0)
  divider:SetPoint("RIGHT", button, "LEFT", 5, 0)
end

local function placeVerticalDivider(divider, button)
  divider:SetPoint("LEFT", button, "LEFT", 0, 0)
  divider:SetPoint("RIGHT", button, "RIGHT", 0, 0)
  divider:SetPoint("BOTTOM", button, "TOP", 0, -5)
end

local function drawActionBar2Dividers()
  local actionBar2 = MultiBarBottomLeft
  local isButtonShown = {}
  for i, button in ipairs(actionBar2.actionButtons) do
    isButtonShown[i] = button:IsShown()
  end
  local buttonsNeedingDivider = BarDividers.findButtonsNeedingDivider(
    isButtonShown,
    actionBar2.numRows or 1,
    actionBar2.buttonPadding or 0,
    actionBar2.minButtonPadding or 0
  )
  for _, buttonIndex in ipairs(buttonsNeedingDivider) do
    local button = actionBar2.actionButtons[buttonIndex]
    local divider
    if actionBar2.isHorizontal then
      divider = dividerPools.horizontal:Acquire()
      divider:ClearAllPoints()
      placeHorizontalDivider(divider, button)
    else
      divider = dividerPools.vertical:Acquire()
      divider:ClearAllPoints()
      placeVerticalDivider(divider, button)
    end
    divider:Show()
  end
end

-- Edit Mode's icon size scales each button's holder.
local function drawActionBar2Border()
  border:SetScale(MultiBarBottomLeft.actionButtons[1].container:GetScale())
end

local function releaseActionBar2Dividers()
  dividerPools.horizontal:ReleaseAll()
  dividerPools.vertical:ReleaseAll()
end

local function drawActionBar2Art()
  if not artHolder then
    createArtHolder()
  end
  artHolder:Show()
  releaseActionBar2Dividers()
  drawActionBar2Border()
  drawActionBar2Dividers()
  if not areButtonsStyledLikeActionBar1 then
    styleButtonsLikeActionBar1()
  end
end

local function removeActionBar2Art()
  if artHolder then
    artHolder:Hide()
    releaseActionBar2Dividers()
  end
  if areButtonsStyledLikeActionBar1 then
    styleButtonsLikeActionBar2()
  end
end

-- After action bar 2 or the setting changes. In combat it waits for combat
-- to end (anchoring to the secure buttons may not be allowed then).
local function redrawActionBar2Art()
  if InCombatLockdown() then
    isRedrawWaitingForCombat = true
    return
  end
  isRedrawWaitingForCombat = false
  if isOnWasdLayout and not ns.db.bar2HideArt then
    drawActionBar2Art()
  else
    removeActionBar2Art()
  end
end

-- A whole-system update ends in UpdateSystem, which redraws once.
local function redrawAfterSettingChange(_, _, isEntireSystemUpdate)
  if not isEntireSystemUpdate then
    redrawActionBar2Art()
  end
end

local function makeActionBar1SeeThrough()
  MainActionBar:SetAlpha(0)
end

local function makeActionBar1Visible()
  MainActionBar:SetAlpha(1)
end

local function saveGameMouseState()
  if not gameMouseState then
    gameMouseState = {
      isActionBarMouseEnabled = MainActionBar:IsMouseEnabled(),
      isSelectionMouseEnabled = MainActionBar.Selection:IsMouseEnabled(),
    }
  end
end

-- Action bar 1 is empty on the WASDBars layout (the cluster has its buttons);
-- it and its Edit Mode selection stop catching the mouse so action bar 2 on
-- top of it works.
local function disableMouseOnActionBar1()
  saveGameMouseState()
  MainActionBar:EnableMouse(false)
  MainActionBar.Selection:EnableMouse(false)
end

local function restoreMouseOnActionBar1()
  saveGameMouseState()
  MainActionBar:EnableMouse(gameMouseState.isActionBarMouseEnabled)
  MainActionBar.Selection:EnableMouse(gameMouseState.isSelectionMouseEnabled)
end

local function findBottomLeftOnScreen(frame)
  local left, bottom = frame:GetLeft(), frame:GetBottom()
  if not left then
    return nil
  end
  local effectiveScale = frame:GetEffectiveScale()
  return left * effectiveScale, bottom * effectiveScale
end

-- Screen pixels from action bar 2's first button to action bar 1's first
-- button holder, or nil if either isn't laid out.
local function measureOffsetToActionBar1()
  local holderX, holderY = findBottomLeftOnScreen(_G.MainActionBarButtonContainer1)
  local buttonX, buttonY = findBottomLeftOnScreen(_G.MultiBarBottomLeftButton1)
  if not (holderX and buttonX) then
    return nil
  end
  return holderX - buttonX, holderY - buttonY
end

local function readHideBarArt()
  return ns.db.bar2HideArt
end

local function saveHideBarArt(_, isArtHidden)
  ns.db.bar2HideArt = isArtHidden
  redrawActionBar2Art()
end

local function isAwayFromWasdLayout(layoutName)
  return layoutName ~= WasdLayoutSettings.WASD_LAYOUT_NAME
end

function MainBarReplacement.replaceActionBar1()
  isOnWasdLayout = true
  isActionBar1SeeThrough = true
  ns.CombatQueue.runOutOfCombat("bar1-mouse", disableMouseOnActionBar1)
  ns.CombatQueue.runOutOfCombat("bar1-alpha", makeActionBar1SeeThrough)
  redrawActionBar2Art()
end

function MainBarReplacement.restoreActionBar1()
  isOnWasdLayout = false
  ns.CombatQueue.runOutOfCombat("bar1-mouse", restoreMouseOnActionBar1)
  if isActionBar1SeeThrough then
    isActionBar1SeeThrough = false
    ns.CombatQueue.runOutOfCombat("bar1-alpha", makeActionBar1Visible)
  end
  redrawActionBar2Art()
end

-- At login. The bar's own copies of the Edit Mode functions, not the shared mixin.
function MainBarReplacement.keepActionBar2ArtUpToDate()
  local actionBar2 = MultiBarBottomLeft
  hooksecurefunc(actionBar2, "UpdateSystem", redrawActionBar2Art)
  hooksecurefunc(actionBar2, "UpdateSystemSetting", redrawAfterSettingChange)
  hooksecurefunc(actionBar2, "UpdateShownButtons", redrawActionBar2Art)
end

-- When combat ends.
function MainBarReplacement.redrawActionBar2ArtIfWaiting()
  if isRedrawWaitingForCombat then
    redrawActionBar2Art()
  end
end

-- At login: action bar 2's checkbox, on the WASDBars layout only.
function MainBarReplacement.addHideBarArtCheckbox()
  LibEditMode:AddSystemSettings(Enum.EditModeSystem.ActionBar, {
    {
      kind = LibEditMode.SettingType.Checkbox,
      name = "Hide Bar Art",
      default = false,
      get = readHideBarArt,
      set = saveHideBarArt,
      hidden = isAwayFromWasdLayout,
    },
  }, Enum.EditModeActionBarSystemIndices.Bar2)
end

-- On a new layout, action bar 2's art starts as action bar 1's was in the
-- source layout. layoutSettings: WasdLayoutSettings.readLayoutSettings, read
-- before setup turns action bar 1's art off.
function MainBarReplacement.matchActionBar2ArtToActionBar1(layoutSettings)
  ns.db.bar2HideArt = layoutSettings.actionBar1.hideBarArt == 1
end

function MainBarReplacement.isActionBar2On()
  return (GetActionBarToggles()) and true or false
end

function MainBarReplacement.turnOnActionBar2()
  Settings.SetValue("PROXY_SHOW_ACTIONBAR_2", true)
end

function MainBarReplacement.turnOffActionBar2()
  Settings.SetValue("PROXY_SHOW_ACTIONBAR_2", false)
end

-- Within a pixel of action bar 1's buttons, or nil when either bar isn't laid out.
function MainBarReplacement.isActionBar2OnActionBar1()
  local offsetX, offsetY = measureOffsetToActionBar1()
  if not offsetX then
    return nil
  end
  return math.abs(offsetX) <= 1 and math.abs(offsetY) <= 1
end

-- The Edit Mode anchor that puts action bar 2's buttons on action bar 1's, or
-- nil when either bar isn't laid out.
function MainBarReplacement.findActionBar2AnchorOnActionBar1()
  local offsetX, offsetY = measureOffsetToActionBar1()
  if not offsetX then
    return nil
  end
  local actionBar2 = MultiBarBottomLeft
  local effectiveScale = actionBar2:GetEffectiveScale()
  return {
    point = "BOTTOMLEFT",
    relativeTo = "UIParent",
    relativePoint = "BOTTOMLEFT",
    offsetX = actionBar2:GetLeft() + offsetX / effectiveScale,
    offsetY = actionBar2:GetBottom() + offsetY / effectiveScale,
  }
end
