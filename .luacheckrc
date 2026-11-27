std = "lua51"
max_line_length = 160
max_cyclomatic_complexity = 10
exclude_files = { "tests/helpers/**", ".lua/**", ".luarocks/**", ".release/**", ".tools/**", "openspec/**", ".agents/**", ".claude/**" }
-- every addon file starts with `local ADDON, ns = ...`, even when ADDON is unused
ignore = { "211/ADDON" }
-- SlashCmdList is the game's, but registering /wasd writes a field into it
globals = { "WASDBarsDB", "WASDBarsPerfDB", "SLASH_WASDBARS1", "StaticPopupDialogs", "SlashCmdList" }
read_globals = {
  -- grows with each change; only list what is actually used
  "CreateFrame",
  "CreateFramePool",
  "UIParent",
  "InCombatLockdown",
  "DEFAULT_CHAT_FRAME",
  "C_AddOns",
  "LibStub",
  "GetBindingAction",
  "GetBindingName",
  "SetBinding",
  "SaveBindings",
  "GetCurrentBindingSet",
  "CHARACTER_BINDINGS",
  "MultiBarBottomLeft",
  "StaticPopup_Show",
  "GetBindingKey",
  "C_Timer",
  "GetShapeshiftFormInfo",
  "C_Spell",
  "Enum",
  "MainActionBar",
  "UnitGUID",
  "hooksecurefunc",
  "UISpecialFrames",
  "C_Texture",
  "CreateSettingsButtonInitializer",
  "CreateSettingsListSectionHeaderInitializer",
  "HideUIPanel",
  "ShowUIPanel",
  "SettingsPanel",
  "EditModeManagerFrame",
  "C_AddOnProfiler",
  "GetTime",
  "GetFramerate",
  "GetShapeshiftForm",
  "UnitExists",
  "GetBuildInfo",
  "date",
  "Settings",
  "C_EditMode",
  "EditModePresetLayoutManager",
  "GetActionBarToggles",
  "ChatFrame1",
  "Constants",
}
files["tests/**"] = { std = "+busted" }
