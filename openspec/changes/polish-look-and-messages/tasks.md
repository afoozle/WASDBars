# Tasks: Polish the look and the messages

## 1. Logic and tests
- [x] 1.1 Two sizes, equal cells, 2px gap in `LayoutGeometry` and `Data/Layout.lua`; tests for cells, spacing and the keyboard slant (packing tried first, dropped after the in-game look)
- [x] 1.2 `BindingPlan.lostActions` and `statusSentence`; stance fallback name; tests
- [x] 1.3 `LayoutCheck.statusSentence` and `needs`; tests

## 2. UI
- [x] 2.1 Movement keys opaque, real button art size, centred tutorial arrows, no letters; hotkey text styled bottom centre, mouse buttons as M4/M5 (`Logic/HotkeyText.lua` + test)
- [x] 2.2 Keybind window replaces the popups (design.md section 3)
- [x] 2.3 Chat messages per design.md section 4; setup offer text
- [x] 2.4 `make check` passes

## 3. In-game checks
- [x] 3.1 Cluster: equal cells, E/D/C on a slant, tighter big keys, W/A/S/D arrows clear, W/A/S/D the same size as T/G/V with centred arrows, mouse hotkeys M4/M5; hotkey text readable at bottom centre and turns red out of range
- [x] 3.2 `/wasd setup status` is one line; `/wasd setup` with everything done prints two lines
- [x] 3.3 Edit Mode: turn Hide Bar Art off; `/wasd setup layout` lists it readably; turn it back on
- [x] 3.4 Rogue alt: the offer appeared and was saved under the character GUID; the keybind window showed both steps and the lost-key list (stance binds correctly not listed: the game also binds them to Ctrl-F keys). The player confirmed rather than escaping; Deutscheb uses the account-wide binding set, so the binds were saved there
- [x] 3.5 No BugSack errors

## 4. Wrap-up
- [ ] 4.1 Merge and archive
