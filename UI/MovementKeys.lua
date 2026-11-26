local ADDON, ns = ...
local MovementKeys = {}
ns.MovementKeys = MovementKeys

-- The game's tutorial arrows, drawn centred, one per direction.
local ARROW_SIZE = 0.6 -- of the key
local ARROWS = { up = "NPE_ArrowUp", down = "NPE_ArrowDown", left = "NPE_ArrowLeft", right = "NPE_ArrowRight" }

-- Places target exactly where source sits on its button (the game draws some
-- button art larger than the button), relative to our key frame instead.
local function copyPlacement(target, source, key)
  local count = source:GetNumPoints()
  if count == 0 then
    target:SetAllPoints()
    return
  end
  target:SetSize(source:GetSize())
  for i = 1, count do
    local point, _, relativePoint, x, y = source:GetPoint(i)
    target:SetPoint(point, key, relativePoint, x, y)
  end
end

-- Copies a game texture's art (atlas or file) and placement onto target.
local function copyArt(target, source, key)
  copyPlacement(target, source, key)
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
local function templateKey(parent)
  local key = CreateFrame("CheckButton", nil, parent, "ActionButtonTemplate")
  key:EnableMouse(false)
  local source = _G.ActionButton1
  for _, name in ipairs({ "SlotArt", "SlotBackground" }) do
    if key[name] and source[name] then
      key[name]:SetShown(source[name]:IsShown())
    end
  end
  local normal, sourceNormal = key:GetNormalTexture(), source:GetNormalTexture()
  if normal and sourceNormal then
    copyArt(normal, sourceNormal, key)
  end
  for _, name in ipairs({ "icon", "Icon", "HotKey", "Count", "Name", "cooldown", "Cooldown", "Border" }) do
    if key[name] then
      key[name]:Hide()
    end
  end
  return key
end

local function createKey(parent, k, baseSize)
  local key = templateKey(parent)
  -- Full button size, shrunk with SetScale like the action buttons, so the art
  -- and arrow shrink together.
  key:SetSize(baseSize, baseSize)
  key:SetScale(k.scale)
  key:SetPoint("CENTER", parent, "TOPLEFT", k.cx / k.scale, -k.cy / k.scale)

  local arrow = key:CreateTexture(nil, "OVERLAY")
  arrow:SetPoint("CENTER")
  local atlas = ARROWS[k.key.movement]
  arrow:SetAtlas(atlas)
  -- keep the art's own shape, fitted inside the arrow box
  local info = C_Texture.GetAtlasInfo(atlas)
  local fit = baseSize * ARROW_SIZE / math.max(info.width, info.height)
  arrow:SetSize(info.width * fit, info.height * fit)

  return key
end

-- Runs after UI/Cluster.lua's PLAYER_LOGIN handler, which builds the cluster.
-- Plain decorative frames, so they are safe to create at any time.
ns.Events.on("PLAYER_LOGIN", function()
  local cluster = ns.Cluster
  MovementKeys.frames = {}
  for _, k in ipairs(cluster.geometry.keys) do
    if k.key.movement then
      local key = createKey(cluster.frame, k, cluster.baseSize)
      key:SetShown(ns.db.showMovementKeys)
      MovementKeys.frames[k.key.label] = key
    end
  end
end)

-- Plain decorative frames, so this is safe in combat.
function MovementKeys.setShown(shown)
  for _, key in pairs(MovementKeys.frames or {}) do
    key:SetShown(shown)
  end
end
