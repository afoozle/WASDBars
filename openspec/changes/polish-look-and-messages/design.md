# Design: Polish the look and the messages

## 1. Layout (`Logic/LayoutGeometry.lua`, `Data/Layout.lua`)
- `sizes = { big = 1.0, small = 0.8 }`; every key (movement keys too) names its size.
- Keys are sorted into rows; a key exactly one grid step right of the previous key in its row is placed `gap` pixels from it (`prev.cx + (prev.scale + scale) / 2 * baseSize + gap`). Any other key, the first in a row or after a jump like the mouse column, is centred on its grid point (`x * step`). Rows stay `step` apart vertically.
- The cluster box is fitted tightly round the keys' scaled extents.

## 2. Key labels
- `UI/MovementKeys.lua`: no alpha fade; the letter is the `GameFontHighlightLarge` font at 20 with `THICKOUTLINE` (scaled with the key).
- `UI/Cluster.lua`: each cluster button's `HotKey` font string gets its own font at 18 with `THICKOUTLINE`, anchored `BOTTOM` (0, 3), full button width, centred. Applied with the layout, and again after the game's `UpdateHotkeys` (`hooksecurefunc`) in case it re-lays the text out. Font strings aren't protected, but this runs with the layout through the combat queue anyway.

## 3. Keybind window (`UI/Bindings.lua`)
- `WASDBarsKeybindWindow`, `BasicFrameTemplateWithInset`, 440 wide, top centre, `DIALOG` strata, movable, clamped, in `UISpecialFrames` (Escape closes it).
- Text lines are font strings stacked top to bottom; the window's height fits them.
- Content: for each group with changes, "n. <heading>" (gold) and its detail (white, indented). Then, if any, "These will no longer have a key:" (orange), the lost actions joined with commas, and "Rebind them in Key Bindings if you use them." (grey).
- `BindingPlan.lostActions(plans, getBindingKey)`: actions that are some changing key's current command, aren't a target of the setup, and have no key outside the changing keys. Each with the keys that did it, in order.
- Confirm applies every shown step through the combat queue (`"keybinds"`), saves, prints "Keybinds set up." and the action bar 2 reminder if needed. Confirm, Cancel, the close button and Escape all hide the window; `OnHide` runs `onDone` once.
- `Bindings.request(onDone)` (all groups), `Bindings.isSetUp()`, `Bindings.statusSentence()`.

## 4. Messages
| When | Chat |
|---|---|
| Confirm | `Keybinds set up.` |
| Nothing to do | `Keybinds are already set up.` |
| Layout fine | `Your Edit Mode layout is ready.` |
| Layout problems | `Your Edit Mode layout needs 2 changes:` then `  - <fix>` lines |
| Status | `Keybinds set up (WASD keys and number row). Edit Mode layout ready.` / `Keybinds: WASD keys set up, number row 7 of 12 set up. Edit Mode layout needs 1 change (/wasd setup layout).` |
| Action bar 2 off | `Action bar 2 is turned off. Turn it on in Edit Mode to see the number row.` |
| Combat | `Will apply after combat.` |
| Slash | `Commands:`, `Dev build.`, `Version x.`, `Debug output on.`, `Use /wasd setup, or /wasd setup keys, layout or status.` |

`BindingPlan.statusSentence(groups, plans)` and `LayoutCheck.statusSentence(fixes)` / `LayoutCheck.needs(fixes)` build these.
