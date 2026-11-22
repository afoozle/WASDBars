local ADDON, ns = ...
local MovementKeys = {}
ns.MovementKeys = MovementKeys

-- The game's own arrows, first choice first. The tutorial arrows are drawn
-- centred, one per direction; the main bar's page arrows are the fallback,
-- rotated for left and right, but their art isn't centred.
local ARROW_SIZE = 0.6 -- of the key
local ARROWS = {
  up = { { atlas = "NPE_ArrowUp" }, { atlas = "UI-HUD-ActionBar-PageUpArrow-Up" } },
  down = { { atlas = "NPE_ArrowDown" }, { atlas = "UI-HUD-ActionBar-PageDownArrow-Up" } },
  left = { { atlas = "NPE_ArrowLeft" }, { atlas = "UI-HUD-ActionBar-PageUpArrow-Up", rotation = math.pi / 2 } },
  right = { { atlas = "NPE_ArrowRight" }, { atlas = "UI-HUD-ActionBar-PageUpArrow-Up", rotation = -math.pi / 2 } },
}

local function atlasInfo(name)
  return C_Texture and C_Texture.GetAtlasInfo and C_Texture.GetAtlasInfo(name)
end

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

-- Copies a game texture's art (atlas or file) and placement onto target; false if there is none.
local function copyArt(target, source, key)
  if not source then
    return false
  end
  copyPlacement(target, source, key)
  local atlas = source.GetAtlas and source:GetAtlas()
  if atlas then
    target:SetAtlas(atlas)
    return true
  end
  local file = source:GetTexture()
  if file then
    target:SetTexture(file)
    target:SetTexCoord(source:GetTexCoord())
    return true
  end
  return false
end

-- Built from the game's own (non-secure) action button template so it is drawn
-- exactly like an empty slot, with the same art visible as on the cluster's
-- own buttons. Never clickable.
local function templateKey(parent)
  local ok, key = pcall(CreateFrame, "CheckButton", nil, parent, "ActionButtonTemplate")
  if not ok then
    return nil
  end
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

-- Fallback if the template isn't available: copies the slot art piece by piece.
local function copiedKey(parent, baseSize)
  local template = _G.ActionButton1
  local key = CreateFrame("Frame", nil, parent)
  key:SetSize(baseSize, baseSize)
  local background = key:CreateTexture(nil, "BACKGROUND")
  if not copyArt(background, template.SlotBackground, key) then
    ns.debug("no slot background art for movement keys")
  end
  local border = key:CreateTexture(nil, "ARTWORK")
  if not copyArt(border, template:GetNormalTexture(), key) then
    ns.debug("no button border art for movement keys")
  end
  return key
end

local function createKey(parent, k, baseSize)
  local key = templateKey(parent)
  if key then
    ns.debug(k.key.label .. ": built from the action button template")
  else
    key = copiedKey(parent, baseSize)
  end
  -- Full button size, shrunk with SetScale like the action buttons, so the art
  -- and arrow shrink together.
  key:SetSize(baseSize, baseSize)
  key:SetScale(k.scale)
  key:SetPoint("CENTER", parent, "TOPLEFT", k.cx / k.scale, -k.cy / k.scale)

  local arrow = key:CreateTexture(nil, "OVERLAY")
  arrow:SetPoint("CENTER")
  local placed = false
  for _, choice in ipairs(ARROWS[k.key.movement] or {}) do
    local info = atlasInfo(choice.atlas)
    if info then
      arrow:SetAtlas(choice.atlas)
      -- keep the art's own shape, fitted inside the arrow box
      local box = baseSize * ARROW_SIZE
      local fit = box / math.max(info.width, info.height)
      arrow:SetSize(info.width * fit, info.height * fit)
      if choice.rotation then
        arrow:SetRotation(choice.rotation)
      end
      ns.debug(k.key.label .. " arrow: " .. choice.atlas)
      placed = true
      break
    end
  end
  if not placed then
    ns.debug("no arrow art for " .. k.key.label)
  end

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
