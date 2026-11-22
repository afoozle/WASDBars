local ADDON, ns = ...

-- The addon's page in the game's AddOns settings. add-options-panel builds on it.
ns.Events.on("PLAYER_LOGIN", function()
  local panel = CreateFrame("Frame")
  local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
  title:SetPoint("TOPLEFT", 16, -16)
  title:SetText("WASDBars")

  local text = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
  text:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
  text:SetJustifyH("LEFT")
  text:SetText("Bind your keys to the WASD cluster and action bar 2, and check your Edit Mode layout.")

  local button = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
  button:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -12)
  button:SetSize(140, 24)
  button:SetText("Run setup")
  button:SetScript("OnClick", ns.Setup.run)

  Settings.RegisterAddOnCategory(Settings.RegisterCanvasLayoutCategory(panel, "WASDBars"))
end)
