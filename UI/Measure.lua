local ADDON, ns = ...

-- Temporary: /wasd measure saves on-screen sizes and positions to
-- WASDBarsDB.measure (written on /reload) so Claude Code can read them.

local function rect(region)
  if not (region and region.GetRect) then
    return nil
  end
  local left, bottom, width, height = region:GetRect()
  if not left then
    return "no rect"
  end
  local owner = region.GetEffectiveScale and region or region:GetParent()
  local scale = owner:GetEffectiveScale()
  return string.format("l=%.1f b=%.1f w=%.1f h=%.1f", left * scale, bottom * scale, width * scale, height * scale)
end

local function points(region)
  local list = {}
  for i = 1, region:GetNumPoints() do
    local point, relative, relativePoint, x, y = region:GetPoint(i)
    local name = relative and (relative.GetName and relative:GetName() or tostring(relative)) or "nil"
    table.insert(list, string.format("%s %s %s %.1f %.1f", point, name, relativePoint, x, y))
  end
  return table.concat(list, " | ")
end

local function button(b)
  local hotkey = b.HotKey
  local normal = b:GetNormalTexture()
  return {
    frame = rect(b),
    scale = b:GetScale(),
    icon = rect(b.icon or b.Icon),
    normal = rect(normal),
    normalAtlas = normal and normal.GetAtlas and normal:GetAtlas(),
    slotBackground = rect(b.SlotBackground),
    slotArt = rect(b.SlotArt),
    iconMask = rect(b.IconMask),
    hotkey = hotkey and rect(hotkey),
    hotkeyText = hotkey and hotkey:GetText(),
    hotkeyJustify = hotkey and hotkey:GetJustifyH(),
    hotkeyPoints = hotkey and points(hotkey),
    hotkeyStringWidth = hotkey and hotkey:GetStringWidth(),
  }
end

function ns.measure()
  local m = { uiScale = UIParent:GetEffectiveScale(), baseSize = ns.Cluster.baseSize, gap = ns.Layout.gap }
  m.cluster = rect(ns.Cluster.frame)
  m.buttons = {}
  for i = 1, 12 do
    m.buttons[i] = button(_G["ActionButton" .. i])
  end
  m.keys = {}
  for label, key in pairs(ns.MovementKeys.frames) do
    m.keys[label] = {
      frame = rect(key),
      scale = key:GetScale(),
      normal = key.GetNormalTexture and rect(key:GetNormalTexture()),
      slotBackground = rect(key.SlotBackground),
      slotArt = rect(key.SlotArt),
      arrow = rect(key.arrow),
    }
  end
  m.otherBars = {}
  for _, bar in ipairs({ "MultiBarBottomLeft", "MultiBarBottomRight", "MultiBarRight", "MultiBarLeft" }) do
    for i = 1, 3 do
      local b = _G[bar .. "Button" .. i]
      if b and b:IsVisible() then
        m.otherBars[bar .. i] = button(b)
      end
    end
  end
  WASDBarsDB.measure = m
  ns.print("Measured. /reload to save it.")
end
