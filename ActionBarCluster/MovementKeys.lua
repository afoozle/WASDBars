local ADDON, ns = ...
local MovementKeys = {}
ns.MovementKeys = MovementKeys

-- The W, A, S and D keys: plain decorative frames with the game's tutorial
-- arrows, so they are safe to create, show and hide at any time.
local ARROW_SIZE = 0.6 -- of the key
local ARROW_ATLASES = { up = "NPE_ArrowUp", down = "NPE_ArrowDown", left = "NPE_ArrowLeft", right = "NPE_ArrowRight" }

local movementKeyFrames = {}

-- Places target exactly where source sits on its button (the game draws some
-- button art larger than the button), relative to our key frame instead.
local function copyArtPlacement(target, source, keyFrame)
  local pointCount = source:GetNumPoints()
  if pointCount == 0 then
    target:SetAllPoints()
    return
  end
  target:SetSize(source:GetSize())
  for i = 1, pointCount do
    local point, _, relativePoint, x, y = source:GetPoint(i)
    target:SetPoint(point, keyFrame, relativePoint, x, y)
  end
end

-- Copies a game texture's art (atlas or file) and placement onto target.
local function copyArt(target, source, keyFrame)
  copyArtPlacement(target, source, keyFrame)
  local atlas = source:GetAtlas()
  if atlas then
    target:SetAtlas(atlas)
  else
    target:SetTexture(source:GetTexture())
    target:SetTexCoord(source:GetTexCoord())
  end
end

-- Built from the game's own (non-secure) action button template so it is drawn
-- exactly like an empty slot, with the same art visible as on the cluster's
-- own buttons. Never clickable.
local function createEmptyKeyFrame(parent)
  local keyFrame = CreateFrame("CheckButton", nil, parent, "ActionButtonTemplate")
  keyFrame:EnableMouse(false)
  local templateButton = _G.ActionButton1
  for _, artName in ipairs({ "SlotArt", "SlotBackground" }) do
    if keyFrame[artName] and templateButton[artName] then
      keyFrame[artName]:SetShown(templateButton[artName]:IsShown())
    end
  end
  local normalTexture, templateNormalTexture = keyFrame:GetNormalTexture(), templateButton:GetNormalTexture()
  if normalTexture and templateNormalTexture then
    copyArt(normalTexture, templateNormalTexture, keyFrame)
  end
  for _, partName in ipairs({ "icon", "Icon", "HotKey", "Count", "Name", "cooldown", "Cooldown", "Border" }) do
    if keyFrame[partName] then
      keyFrame[partName]:Hide()
    end
  end
  return keyFrame
end

-- Keeps the art's own shape, fitted inside the arrow box.
local function drawArrow(keyFrame, movementDirection, buttonSize)
  local arrow = keyFrame:CreateTexture(nil, "OVERLAY")
  arrow:SetPoint("CENTER")
  local atlas = ARROW_ATLASES[movementDirection]
  arrow:SetAtlas(atlas)
  local atlasInfo = C_Texture.GetAtlasInfo(atlas)
  local fit = buttonSize * ARROW_SIZE / math.max(atlasInfo.width, atlasInfo.height)
  arrow:SetSize(atlasInfo.width * fit, atlasInfo.height * fit)
end

-- Full button size, shrunk with SetScale like the action buttons, so the art
-- and arrow shrink together.
local function createMovementKey(clusterFrame, measuredKey, buttonSize)
  local keyFrame = createEmptyKeyFrame(clusterFrame)
  keyFrame:SetSize(buttonSize, buttonSize)
  keyFrame:SetScale(measuredKey.scale)
  keyFrame:SetPoint(
    "CENTER",
    clusterFrame,
    "TOPLEFT",
    measuredKey.centreX / measuredKey.scale,
    -measuredKey.centreY / measuredKey.scale
  )
  drawArrow(keyFrame, measuredKey.clusterKey.movementDirection, buttonSize)
  return keyFrame
end

-- At login, after the cluster is built.
function MovementKeys.drawMovementKeys()
  local clusterFrame, buttonSize = ns.ActionBarCluster.clusterFrame, ns.ActionBarCluster.buttonSize
  for _, measuredKey in ipairs(ns.ActionBarCluster.measuredCluster.measuredKeys) do
    if measuredKey.clusterKey.movementDirection then
      local keyFrame = createMovementKey(clusterFrame, measuredKey, buttonSize)
      keyFrame:SetShown(ns.db.showMovementKeys)
      table.insert(movementKeyFrames, keyFrame)
    end
  end
end

function MovementKeys.showMovementKeys()
  for _, keyFrame in ipairs(movementKeyFrames) do
    keyFrame:Show()
  end
end

function MovementKeys.hideMovementKeys()
  for _, keyFrame in ipairs(movementKeyFrames) do
    keyFrame:Hide()
  end
end
