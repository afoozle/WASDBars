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
    keybinds = {
      { key = "1", action = "MULTIACTIONBAR1BUTTON1" },
      { key = "2", action = "MULTIACTIONBAR1BUTTON2" },
      { key = "3", action = "MULTIACTIONBAR1BUTTON3" },
      { key = "4", action = "MULTIACTIONBAR1BUTTON4" },
      { key = "5", action = "MULTIACTIONBAR1BUTTON5" },
      { key = "6", action = "MULTIACTIONBAR1BUTTON6" },
      { key = "7", action = "MULTIACTIONBAR1BUTTON7" },
      { key = "8", action = "MULTIACTIONBAR1BUTTON8" },
      { key = "9", action = "MULTIACTIONBAR1BUTTON9" },
      { key = "0", action = "MULTIACTIONBAR1BUTTON10" },
      { key = "-", action = "MULTIACTIONBAR1BUTTON11" },
      { key = "=", action = "MULTIACTIONBAR1BUTTON12" },
    },
  },
}
