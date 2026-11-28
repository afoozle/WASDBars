local ADDON, ns = ...

-- The only keybinds the addon ever changes, in the order the setup window
-- lists them. `name` is used in chat; `heading` and `detail` describe the step
-- in the setup window; `keyLabel` replaces the game's key name in messages.
ns.KeybindGroups = {
  {
    name = "WASD keys",
    heading = "Action bar 1 on the keys around WASD",
    detail = "Q E R T F G Z X C V and both mouse side buttons fire the WASD cluster's buttons.",
    keybinds = {
      { key = "Q", action = "ACTIONBUTTON1" },
      { key = "E", action = "ACTIONBUTTON2" },
      { key = "R", action = "ACTIONBUTTON3" },
      { key = "T", action = "ACTIONBUTTON4" },
      { key = "F", action = "ACTIONBUTTON5" },
      { key = "G", action = "ACTIONBUTTON6" },
      { key = "Z", action = "ACTIONBUTTON7" },
      { key = "X", action = "ACTIONBUTTON8" },
      { key = "C", action = "ACTIONBUTTON9" },
      { key = "V", action = "ACTIONBUTTON10" },
      { key = "BUTTON5", action = "ACTIONBUTTON11", keyLabel = "Mouse front" },
      { key = "BUTTON4", action = "ACTIONBUTTON12", keyLabel = "Mouse back" },
    },
  },
  {
    name = "number row",
    heading = "Action bar 2 on the number row",
    detail = "1-9, 0, - and = fire action bar 2's buttons 1-12.",
    keybinds = {},
  },
}

-- 1-9, 0, - and = fire action bar 2's buttons 1-12
for i, key in ipairs({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=" }) do
  table.insert(ns.KeybindGroups[2].keybinds, { key = key, action = "MULTIACTIONBAR1BUTTON" .. i })
end
