std = "lua51"
max_line_length = 120
exclude_files = { "tests/helpers/**", ".lua/**", ".tools/**", "openspec/**", ".agents/**", ".claude/**" }
-- every addon file starts with `local ADDON, ns = ...`, even when ADDON is unused
ignore = { "211/ADDON" }
-- SlashCmdList is the game's, but registering /wasd writes a field into it
globals = { "WASDBarsDB", "SLASH_WASDBARS1", "StaticPopupDialogs", "SlashCmdList" }
read_globals = {
  -- grows with each change; only list what is actually used
  "CreateFrame",
  "UIParent",
  "InCombatLockdown",
  "DEFAULT_CHAT_FRAME",
  "C_AddOns",
  "GetAddOnMetadata",
  "LibStub",
  "GetBindingAction",
  "GetBindingName",
  "SetBinding",
  "SaveBindings",
  "GetCurrentBindingSet",
  "MultiBarBottomLeft",
  "StaticPopup_Show",
  "C_Timer",
  "GetShapeshiftFormInfo",
  "C_Spell",
  "Enum",
  "MainActionBar",
  "UnitGUID",
  "hooksecurefunc",
  "UISpecialFrames",
  "Settings",
}
files["tests/**"] = { std = "+busted" }
