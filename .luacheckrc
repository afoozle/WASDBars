std = "lua51"
max_line_length = 120
exclude_files = { "tests/helpers/**", ".lua/**", ".tools/**", "openspec/**", ".agents/**", ".claude/**" }
globals = { "WASDBarsDB", "SLASH_WASDBARS1", "StaticPopupDialogs" }
read_globals = {
  -- grows with each change; only list what is actually used
  "CreateFrame",
  "UIParent",
  "InCombatLockdown",
  "SlashCmdList",
  "DEFAULT_CHAT_FRAME",
  "C_AddOns",
  "GetAddOnMetadata",
}
files["tests/**"] = { std = "+busted" }
