# Tasks: Arrange action bar 1 in the WASD shape

## 1. Spike findings
- [x] 1.1 Copy the relevant spike findings into design.md section 1
- [ ] 1.2 By hand in Edit Mode, Action Bar 1: "Hide Bar Art", "Hide Bar Scrolling", "Always Show Buttons", "# of Icons" 12; drag Action Bar 2 into Action Bar 1's old spot

## 2. Logic, data and tests
- [x] 2.1 `Data/Layout.lua` (design.md section 2)
- [x] 2.2 `Logic/LayoutGeometry.lua` (design.md section 3)
- [x] 2.3 `layout_geometry_spec.lua`: keys centred on their grid points; scales follow the size tiers; stagger preserved; cluster size covers every key; button 11 above button 12 and right of the keyboard keys
- [x] 2.4 `layout_data_spec.lua`: buttons 1–12 each used once; every non-movement key has a size tier; movement keys have a direction

## 3. Frames
- [x] 3.1 `UI/Cluster.lua`: container anchored to action bar 2, `applyLayout` at login, the `EDIT_MODE_LAYOUTS_UPDATED` check (design.md section 4)
- [x] 3.2 `UI/MovementKeys.lua`: game slot art, letters and game arrows (design.md section 5)
- [x] 3.3 Add new files to the TOC in load order; update `.luacheckrc` read globals
- [x] 3.4 `make check` passes

## 4. In-game checks
- [ ] 4.1 The cluster appears just above action bar 2, left-aligned with it, with Q, E, R, T, F, G, Z, X, C, V in keyboard positions around W/A/S/D, and buttons 11 and 12 in a column to the right; action bar 2, micro menu and bags are where they were
- [ ] 4.2 Size order is visible and rows line up; tweak gap and anchor offset by eye
- [ ] 4.3 W/A/S/D show game slot art, their letter and the right arrow; empty action slots still show (Always Show Buttons)
- [ ] 4.4 Moving action bar 2 in Edit Mode moves the cluster with it
- [ ] 4.5 Caster → Bear → Cat → Prowl → caster, in and out of combat: buttons stay in place and show each form's abilities
- [ ] 4.6 Feedback still works on the moved buttons: cooldown swipe on Bash, blue Maul at low rage, red Growl out of range, Maul highlight while queued, potion count, tooltips
- [ ] 4.7 Drag and drop still works: drop Swipe on E in Bear (only the Bear bar changes), swap two buttons, drag one off, Shift-drag with "Lock Action Bars" on; nothing happens in combat
- [ ] 4.8 Keys: the thumb buttons use actions 11 and 12, and existing binds still fire (the full WASD binds come with `add-key-binding-setup`)
- [ ] 4.9 `/reload`, zone, change bar page, and switch or edit an Edit Mode layout: the layout holds (mounting: check once the druid has a mount, about level 40; the spike couldn't test it)
- [ ] 4.10 On a class with no forms, the buttons behave normally
- [ ] 4.11 BugSack shows no errors and no "Interface action blocked" messages after all of the above

## 5. Wrap-up
- [ ] 5.1 Merge and archive
