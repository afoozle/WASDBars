# Tasks: Arrange action bar 1 in the WASD shape

## 1. Spike findings
- [x] 1.1 Copy the relevant spike findings into design.md section 1
- [ ] 1.2 By hand in Edit Mode: Action Bar 1 "Hide Bar Art" and "Hide Bar Scrolling"; drag Action Bar 2 into Action Bar 1's old spot

## 2. Logic, data and tests
- [ ] 2.1 `Data/Layout.lua` (design.md section 2)
- [ ] 2.2 `Logic/LayoutGeometry.lua` (design.md section 3)
- [ ] 2.3 `layout_geometry_spec.lua`: keys centred on their grid points; scales follow the size tiers; stagger preserved; cluster size covers every key; front mouse button above back on the outline's left edge
- [ ] 2.4 `layout_data_spec.lua`: buttons 1–12 each used once; every non-movement key has a size tier; movement keys have a direction

## 3. Frames
- [ ] 3.1 `UI/Cluster.lua`: container, `applyLayout` at login, the `EDIT_MODE_LAYOUTS_UPDATED` check, Fwd/Back labels (design.md section 4)
- [ ] 3.2 `UI/MovementKeys.lua` with arrows only
- [ ] 3.3 `UI/MouseOutline.lua`
- [ ] 3.4 Add new files to the TOC in load order; update `.luacheckrc` read globals
- [ ] 3.5 `make check` passes

## 4. In-game checks
- [ ] 4.1 The cluster appears bottom centre with Q, E, R, T, F, G, Z, X, C, V in keyboard positions around small W/A/S/D arrows; action bar 2, micro menu and bags are where they were
- [ ] 4.2 Size order is visible and rows line up
- [ ] 4.3 Mouse outline shows, front-button action above back, labelled "Fwd" and "Back"
- [ ] 4.4 Caster → Bear → Cat → Prowl → caster, in and out of combat: buttons stay in place and show each form's abilities
- [ ] 4.5 Feedback still works on the moved buttons: cooldown swipe on Bash, blue Maul at low rage, red Growl out of range, Maul highlight while queued, potion count, tooltips
- [ ] 4.6 Drag and drop still works: drop Swipe on E in Bear (only the Bear bar changes), swap two buttons, drag one off, Shift-drag with "Lock Action Bars" on; nothing happens in combat
- [ ] 4.7 Keys still work: pressing each WASD-cluster key and both thumb buttons uses the right action
- [ ] 4.8 `/reload`, zone, change bar page, and switch or edit an Edit Mode layout: the layout holds (mounting: check once the druid has a mount, about level 40; the spike couldn't test it)
- [ ] 4.9 On a class with no forms, the buttons behave normally
- [ ] 4.10 BugSack shows no errors and no "Interface action blocked" messages after all of the above

## 5. Wrap-up
- [ ] 5.1 Merge and archive
