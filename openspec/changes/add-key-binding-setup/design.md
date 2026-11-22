# Design: Key binding setup

## 1. Data (`Data/BindingGroups.lua`)
`ns.BindingGroups` is an ordered list, in the order `/wasd setup keys` asks:
- `{ id = "wasd", title = "WASD keys", binds = ... }`: Q, E, R, T, F, G, Z, X, C, V → `ACTIONBUTTON1`–`10`; `BUTTON5` → `ACTIONBUTTON11` (label "Mouse front"); `BUTTON4` → `ACTIONBUTTON12` (label "Mouse back")
- `{ id = "numbers", title = "Number row", binds = ... }`: 1–9, 0, `-`, `=` → `MULTIACTIONBAR1BUTTON1`–`12`, built in a loop

## 2. Planning (`Logic/BindingPlan.lua`, pure, unit tested)
- `BindingPlan.build(group, getBindingAction)` returns `{ changes = { { key, label, command, current } }, correct, total, state }`. `current` is the key's command now (`nil` if unbound); keys already right are left out of `changes`; `state` is `"applied"`, `"partial"` or `"not applied"`.
- `BindingPlan.statusLine(group, plan)`: "WASD keys: set up", "Number row: 7 of 12 set up" or "Number row: not set up".
- Binding a key only replaces that key's old command; other keys bound to the same command keep it.

## 3. Confirmation and apply (`UI/Bindings.lua`)
- `ns.Bindings.request(group, onDone)` runs through `ns.combatQueue:run("bind-" .. id, ...)`, so in combat the popup waits until combat ends. If nothing needs changing it prints "<title>: already set up." Otherwise it shows the `WASDBARS_CONFIRM_BINDS` StaticPopup: the title, then one line per change, such as "Q: Action Button 7 -> Action Button 1", using the game's own names (`GetBindingName`). The game font has no arrow character.
- Confirm: through the combat queue, `SetBinding(key, command)` for each change (this unbinds the key's old command), then `SaveBindings(GetCurrentBindingSet())`, then "WASDBars: <title> set up." For the number row, if `MultiBarBottomLeft` isn't shown, a reminder to turn on action bar 2 in Edit Mode; the bar is never turned on.
- Confirm and Cancel both call `onDone` a frame later (`C_Timer.After(0, ...)`), so the next popup isn't hidden along with the one just clicked.
- `ns.Bindings.requestAll(onDone)` asks for each group in turn. `ns.Bindings.status(group)` returns the status line.

## 4. Commands (`Core/Slash.lua`)
- `Slash.setup` maps parts to functions: `keys` (`requestAll`) and `status` (one line per group). `add-edit-mode-setup` adds `layout` and its own status line.
- `/wasd setup <part>`; anything else prints how to use it.

## 5. One-off spell move (not addon code)
Rebinding changes which slot each key fires (Q went from slot 7 to slot 1). During the in-game checks:
1. A `/run` line saves every form's slot contents into `WASDBarsDB`, and the player reloads.
2. Claude Code reads the file and writes a one-off `/run` swap script for the player's bars.
