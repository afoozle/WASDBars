# Proposal: Key binding setup

## Why
The layout only makes sense if the keys are bound to match it. Setting 22 keybinds by hand in the game's Key Bindings menu is slow and easy to get wrong. The addon can do it in one confirmed step and show whether the binds are currently correct.

## What Changes
- Two binding groups, defined as data:
  - **WASD keys:** Q, E, R, T, F, G, Z, X, C, V → `ACTIONBUTTON1`–`10`; front mouse side button → `ACTIONBUTTON11`; back → `ACTIONBUTTON12`
  - **Number row:** 1–9, 0, `-`, `=` → `MULTIACTIONBAR1BUTTON1`–`12` (action bar 2)
- Pure planning logic (`Logic/BindingPlan.lua`): given a group and the current bindings, works out what will change, what will be replaced, and whether the group is already fully applied
- A confirmation popup listing every key and what it's currently bound to before anything changes
- Applying saves the binds so they persist across reloads and logins
- A reminder if action bar 2 isn't turned on (this change never turns it on; `add-edit-mode-setup` arranges it)
- Commands: `/wasd setup keys` (asks for the WASD group, then the number row, each confirmed separately) and `/wasd setup status`. This is the keybind part of the first-time setup; `add-edit-mode-setup` adds the Edit Mode part and the first-login offer, and can re-run either part on its own.
- Public functions (`ns.Bindings.status(group)`, `ns.Bindings.request(group, onDone)`, `ns.Bindings.requestAll(onDone)`) for the first-time setup and the options panel

## Decided when grilled (2026-11-22)
- Keys bound to something else (for example 1 and 2 to shapeshift forms) are simply replaced; the popup shows it, and the player puts form spells on action bar 2.
- `-` and `=` join the number row, so action bar 2 replaces the whole old number row (24 keys in all).
- Binds are saved to whichever set the character already uses (`SaveBindings(GetCurrentBindingSet())`); other characters are untouched until set up there.
- The addon never moves spells. Moving the player's spells to match the new binds is a one-off `/run` script written during the in-game checks, not addon code.
- Mouse buttons: front `BUTTON5` → 11, back `BUTTON4` → 12 (matches the player's current binds).

## Depends on
`add-position-and-scale`

## Impact
- New capability spec: `key-binding-setup`
- New files: `Data/BindingGroups.lua`, `Logic/BindingPlan.lua`, `UI/BindingConfirm.lua`
- The only keybinds the addon ever changes are the 22 listed above, and only after confirmation
