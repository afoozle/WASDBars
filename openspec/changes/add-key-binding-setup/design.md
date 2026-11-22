# Design: Key binding setup

## 1. Data (`Data/BindingGroups.lua`)
```lua
ns.BindingGroups = {
  wasd = {
    title = "WASD keys (action bar 1)",
    binds = {
      { key = "Q", command = "ACTIONBUTTON1" },  { key = "E", command = "ACTIONBUTTON2" },
      { key = "R", command = "ACTIONBUTTON3" },  { key = "T", command = "ACTIONBUTTON4" },
      { key = "F", command = "ACTIONBUTTON5" },  { key = "G", command = "ACTIONBUTTON6" },
      { key = "Z", command = "ACTIONBUTTON7" },  { key = "X", command = "ACTIONBUTTON8" },
      { key = "C", command = "ACTIONBUTTON9" },  { key = "V", command = "ACTIONBUTTON10" },
      { key = "BUTTON5", command = "ACTIONBUTTON11", label = "Mouse front" },
      { key = "BUTTON4", command = "ACTIONBUTTON12", label = "Mouse back" },
    },
  },
  numbers = {
    title = "Number row (action bar 2)",
    binds = {},  -- filled below
  },
}
local numberKeys = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
for i, key in ipairs(numberKeys) do
  table.insert(ns.BindingGroups.numbers.binds, { key = key, command = "MULTIACTIONBAR1BUTTON" .. i })
end
```
Mouse button names are data so they can be swapped if the layout change's in-game checks showed the front button is `BUTTON4`.

## 2. Planning (`Logic/BindingPlan.lua`)
`BindingPlan.build(group, getBindingAction, getBindingText)` returns:
```lua
{
  changes = { { key, label, from = "current binding name or nil", to = "new binding name" }, ... },
  alreadyApplied = true/false,   -- every key already bound to its command
  correct = n, total = n,        -- for status messages
}
```
Names come from the game: `getBindingText(command, "BINDING_NAME_")` (the real `GetBindingText`), so "STRAFELEFT" shows as the game's own wording. Keys already bound correctly are left out of `changes`. Binding a key only replaces that key's old command; other keys bound to the same command keep it. Pure and unit tested with table-backed stubs.

`BindingPlan.status(group, getBindingAction)` returns `"applied"`, `"partial"` (with `correct` and `total`) or `"not applied"`.

## 3. Confirmation and apply (`UI/BindingConfirm.lua`)
- `ns.Bindings.request(group, onDone)`: `onDone` is called after Confirm or Cancel, so the first-time setup can chain the next step. Out of combat only (in combat: queue it under the key `"bind-" .. group` and show the popup when combat ends). Build the plan. If already applied, say so and stop. Otherwise show a StaticPopup whose text is the group title followed by one line per change, for example "Q: Strafe Left → Action Button 1" (at most 12 lines, so no scrolling is needed), with Confirm / Cancel.
- On Confirm: for each change `SetBinding(key, command)`; then `SaveBindings(GetCurrentBindingSet())`; print "WASDBars: <group title> set up." For the number row, if action bar 2 isn't shown (`MultiBarBottomLeft` hidden or its setting off), print a reminder to turn it on in the game's interface options.
- On Cancel: nothing changes.
- `SetBinding` automatically unbinds the key from its previous command, so no separate unbind step is needed.

## 4. Commands
- `/wasd setup keys`: request the WASD group, then (when that popup closes) the number row
- `/wasd setup status`: one line per group, for example "WASD keys: set up" or "Number row: 7 of 10 set up" (`add-edit-mode-setup` adds a line for the Edit Mode layout)
