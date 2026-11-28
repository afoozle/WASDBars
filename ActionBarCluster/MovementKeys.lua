local ADDON, ns = ...
local MovementKeys = {}
ns.MovementKeys = MovementKeys

-- The W, A, S and D keys: plain decorative frames with the game's tutorial
-- arrows, so they are safe to create, show and hide at any time.
local ARROW_SIZE = 0.6 -- of the key
local ARROW_ATLASES = { up = "NPE_ArrowUp", down = "NPE_ArrowDown", left = "NPE_ArrowLeft", right = "NPE_ArrowRight" }

-- holds the four keys, so they show and hide together
local movementKeysHolder

-- Built from the game's own (non-secure) action button template so it is drawn
-- like an empty slot on the cluster. Never clickable.
local function createEmptyKeyFrame(parent)
  local keyFrame = CreateFrame("CheckButton", nil, parent, "ActionButtonTemplate")
  keyFrame:EnableMouse(false)
  ns.MainBarReplacement.styleButtonWithoutBarArt(keyFrame)
  for _, partName in ipairs({ "icon", "HotKey", "Count", "Name", "cooldown", "Border" }) do
    keyFrame[partName]:Hide()
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
  local keyFrame = createEmptyKeyFrame(movementKeysHolder)
  keyFrame:SetSize(buttonSize, buttonSize)
  keyFrame:SetScale(measuredKey.scale)
  keyFrame:SetPoint("CENTER", clusterFrame, "TOPLEFT", measuredKey.centreX / measuredKey.scale, -measuredKey.centreY / measuredKey.scale)
  drawArrow(keyFrame, measuredKey.clusterKey.movementDirection, buttonSize)
end

-- At login, after the cluster is built.
function MovementKeys.drawMovementKeys()
  local clusterFrame, buttonSize = ns.ActionBarCluster.clusterFrame, ns.ActionBarCluster.buttonSize
  movementKeysHolder = CreateFrame("Frame", nil, clusterFrame)
  movementKeysHolder:SetAllPoints()
  for _, measuredKey in ipairs(ns.ActionBarCluster.measuredCluster.measuredKeys) do
    if measuredKey.clusterKey.movementDirection then
      createMovementKey(clusterFrame, measuredKey, buttonSize)
    end
  end
  MovementKeys.updateMovementKeysShown()
end

-- After the "Show movement keys" option changes.
function MovementKeys.updateMovementKeysShown()
  movementKeysHolder:SetShown(ns.db.showMovementKeys)
end
