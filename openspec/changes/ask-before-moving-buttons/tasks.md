# Tasks: Ask before moving the buttons

## 1. Logic and tests
- [x] 1.1 `Logic/LayoutPlan.lua` and `layout_plan_spec.lua`: the "buttons" action after create or switch, never otherwise (design.md section 4)
- [x] 1.2 `Logic/Settings.lua` and its tests: `setUp` default removed (design.md section 7)

## 2. UI
- [x] 2.1 `UI/Cluster.lua`: `take` and `release`, one combat queue key, cluster hidden at login, hotkey hook and safety check only on "WASDBars" (design.md section 2)
- [x] 2.2 `UI/EditMode.lua`: the `layout` callback takes or releases the buttons
- [x] 2.3 `UI/Setup.lua`: mouse fix follows the layout; offer text; login reminder; restore message; `setUp` removed; old saves' `setUp` cleared (design.md sections 3–7)
- [x] 2.4 `make check` passes

## 3. Docs
- [x] 3.1 `openspec/project.md` (architecture: the buttons and mouse fix follow the WASDBars layout) and `README.md` (setup asks before moving anything; restore)
- [ ] 3.2 At archive: update the `edit-mode-setup` Purpose line in `openspec/specs/`

## 4. In-game checks (Mac)
Before starting: on the rogue, clear its `setupOffered` entry in `WASDBars.lua` (logged out), so it gets the first-login path.
- [ ] 4.1 Rogue, first login on Modern: normal action bar 1; no cluster, movement keys or WASDBars Edit Mode element; the offer mentions moving the buttons; no reminder in chat
- [ ] 4.2 Not now: nothing changes. `/reload`: no offer; one reminder line
- [ ] 4.3 `/wasd setup`: the window lists moving the buttons under Layout. Set up: the buttons move into the cluster straight away; Action Bar 2 works (tooltips, clicks, Edit Mode selection)
- [ ] 4.4 Switch to Modern in Edit Mode: the buttons are back on action bar 1 at normal size with the game's hotkey text; the cluster is gone; action bar 1 catches the mouse; the buttons work and follow form changes (druid)
- [ ] 4.5 Switch back to WASDBars: the cluster is back where it was, with the buttons; no reminder after `/reload`
- [ ] 4.6 Switch layouts during combat (if the game allows it): the buttons move when combat ends, no errors
- [ ] 4.7 `/wasd restore`, No to keys: back on the old layout, buttons on action bar 1 with no reload; the new restore message. `/reload`: reminder shows
- [ ] 4.8 Druid on WASDBars after the update: nothing changes from before; no reminder, no offer
- [ ] 4.9 No BugSack errors; no "Interface action blocked"

## 5. Wrap-up
- [ ] 5.1 Merge and archive
