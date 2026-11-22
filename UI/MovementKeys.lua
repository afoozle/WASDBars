local ADDON, ns = ...
local MovementKeys = {}
ns.MovementKeys = MovementKeys

local DIM = 0.6

-- Up and down use the main bar's page arrows; left and right rotate the up arrow.
local ARROWS = {
  up = { atlas = "UI-HUD-ActionBar-PageUpArrow-Up", rotation = 0 },
  down = { atlas = "UI-HUD-ActionBar-PageDownArrow-Up", rotation = 0 },
  left = { atlas = "UI-HUD-ActionBar-PageUpArrow-Up", rotation = math.pi / 2 },
  right = { atlas = "UI-HUD-ActionBar-PageUpArrow-Up", rotation = -math.pi / 2 },
}

-- Copies a game texture's art (atlas or file) onto target; false if there is none.
local function copyArt(target, source)
  if not source then
    return false
  end
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

local function createKey(parent, k, baseSize)
  local template = _G.ActionButton1
  -- Built at full button size and shrunk with SetScale like the action buttons,
  -- so the art, letter and arrow all shrink together.
  local key = CreateFrame("Frame", nil, parent)
  key:SetSize(baseSize, baseSize)
  key:SetScale(k.scale)
  key:SetPoint("CENTER", parent, "TOPLEFT", k.cx / k.scale, -k.cy / k.scale)
  key:SetAlpha(DIM)

  local background = key:CreateTexture(nil, "BACKGROUND")
  background:SetAllPoints()
  if not copyArt(background, template.SlotBackground) then
    ns.debug("no slot background art for movement keys")
  end

  local border = key:CreateTexture(nil, "ARTWORK")
  border:SetAllPoints()
  if not copyArt(border, template:GetNormalTexture()) then
    ns.debug("no button border art for movement keys")
  end

  local arrowInfo = ARROWS[k.key.movement]
  local arrow = key:CreateTexture(nil, "OVERLAY")
  arrow:SetPoint("CENTER")
  arrow:SetSize(baseSize * 0.5, baseSize * 0.5)
  if arrowInfo and arrow:SetAtlas(arrowInfo.atlas) ~= false then
    arrow:SetRotation(arrowInfo.rotation)
  else
    ns.debug("no arrow art for " .. k.key.label)
  end

  local letter = key:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
  letter:SetPoint("TOPLEFT", 4, -3)
  letter:SetText(k.key.label)

  return key
end

-- Runs after UI/Cluster.lua's PLAYER_LOGIN handler, which builds the cluster.
-- Plain decorative frames, so they are safe to create at any time.
ns.Events.on("PLAYER_LOGIN", function()
  local cluster = ns.Cluster
  MovementKeys.frames = {}
  for _, k in ipairs(cluster.geometry.keys) do
    if k.key.movement then
      table.insert(MovementKeys.frames, createKey(cluster.frame, k, cluster.baseSize))
    end
  end
end)
