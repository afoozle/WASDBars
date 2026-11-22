# Proposal: Key binding setup

## Why
The layout only makes sense if the keys are bound to match it. Setting 22 keybinds by hand in the game's Key Bindings menu is slow and easy to get wrong. The addon can do it in one confirmed step and show whether the binds are currently correct.

## What Changes
- Two binding groups, defined as data:
  - **WASD keys:** Q, E, R, T, F, G, Z, X, C, V → `ACTIONBUTTON1`–`10`; front mouse side button → `ACTIONBUTTON11`; back → `ACTIONBUTTON12`
  - **Number row:** 1–9, 0 → `MULTIACTIONBAR1BUTTON1`–`10` (action bar 2)
- Pure planning logic (`Logic/BindingPlan.lua`): given a group and the current bindings, works out what will change, what will be replaced, and whether the group is already fully applied
- A confirmation popup listing every key and what it's currently bound to before anything changes
- Applying saves the binds so they persist across reloads and logins
- A reminder if action bar 2 isn't turned on (this change never turns it on; `add-edit-mode-setup` arranges it)
- Commands: `/wasd setup keys` (asks for the WASD group, then the number row, each confirmed separately) and `/wasd setup status`. This is the keybind part of the first-time setup; `add-edit-mode-setup` adds the Edit Mode part and the first-login offer, and can re-run either part on its own.
- Public functions (`ns.Bindings.status(group)`, `ns.Bindings.request(group, onDone)`) for the first-time setup and the options panel

## Open questions for this change's grilling
- Should `-` and `=` be bound to action bar 2's buttons 11 and 12, so action bar 2 fully replaces the old number row?
- Save the binds to the account-wide or per-character binding set? (`SaveBindings(GetCurrentBindingSet())` keeps whichever the player uses now.)

## Depends on
`add-position-and-scale`

## Impact
- New capability spec: `key-binding-setup`
- New files: `Data/BindingGroups.lua`, `Logic/BindingPlan.lua`, `UI/BindingConfirm.lua`
- The only keybinds the addon ever changes are the 22 listed above, and only after confirmation
