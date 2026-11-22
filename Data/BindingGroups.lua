local ADDON, ns = ...

-- The only keybinds the addon ever changes, in the order `/wasd setup keys`
-- asks for them. `question` heads the confirmation popup; `label` replaces
-- the game's key name in messages.
ns.BindingGroups = {
  {
    id = "wasd",
    title = "WASD keys",
    question = "Bind Q E R T F G Z X C V and the mouse side buttons to the WASD cluster?",
    binds = {
      { key = "Q", command = "ACTIONBUTTON1" },
      { key = "E", command = "ACTIONBUTTON2" },
      { key = "R", command = "ACTIONBUTTON3" },
      { key = "T", command = "ACTIONBUTTON4" },
      { key = "F", command = "ACTIONBUTTON5" },
      { key = "G", command = "ACTIONBUTTON6" },
      { key = "Z", command = "ACTIONBUTTON7" },
      { key = "X", command = "ACTIONBUTTON8" },
      { key = "C", command = "ACTIONBUTTON9" },
      { key = "V", command = "ACTIONBUTTON10" },
      { key = "BUTTON5", command = "ACTIONBUTTON11", label = "Mouse front" },
      { key = "BUTTON4", command = "ACTIONBUTTON12", label = "Mouse back" },
    },
  },
  {
    id = "numbers",
    title = "Number row",
    question = "Bind 1-0, - and = to action bar 2?",
    binds = {},
  },
}

-- 1-9, 0, - and = fire action bar 2's buttons 1-12
for i, key in ipairs({ "1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "-", "=" }) do
  table.insert(ns.BindingGroups[2].binds, { key = key, command = "MULTIACTIONBAR1BUTTON" .. i })
end
