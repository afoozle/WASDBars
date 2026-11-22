# Design: Polish the look and the messages

## 1. Layout (`Logic/LayoutGeometry.lua`, `Data/Layout.lua`)
- `sizes = { big = 1.0, small = 0.8 }`; every key (movement keys too) names its size.
- Every key gets the same square cell centred on its grid point (`x * step`, `y * step`, `step = baseSize + gap`); smaller keys sit in the middle of theirs. The rows keep a real keyboard's offsets (A row a quarter key right of the Q row, Z row half a key further), so E, D and C run on a slant.
- `gap` is 2 pixels (was 4).
- First tried packing each row with an even gap; in game that lost the keyboard slant (R, F and C stacked in a column) and made small keys take less room than big ones. The player asked for equal cells, the real stagger, and less space between big keys instead.

## 2. Key labels
- `UI/MovementKeys.lua`: no letters (the arrows matter more); no alpha fade. The slot background and border copy the real button's art size and anchors (`copyPlacement`): the game draws that art larger than the button, and stretching it to the bare frame made W/A/S/D look smaller than the 0.8 action buttons. Arrows are the tutorial arrows `NPE_ArrowUp/Down/Left/Right` (drawn centred, one per direction), kept to their own shape within 0.6 of the key; the page arrows (rotated for left and right) are only a fallback, because their art isn't centred.
- `UI/Cluster.lua`: each cluster button's `HotKey` font string gets its own font at 18 with `THICKOUTLINE`, anchored `BOTTOM` (0, 3), centred, button width. This client spells mouse buttons out ("Mouse Button 5"), which showed as "M..."; `Logic/HotkeyText.lua` shortens them to "M5" after the game sets the text. Applied with the layout, after the game's `UpdateHotkeys` (`hooksecurefunc`) and on `UPDATE_BINDINGS`.

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
