# Tasks: Layout setup

## 0. Before building
- [x] 0.1 Probe on the rogue (2026-11-24): with Action Bar 2 on Action Bar 1 and bar art hidden, `MainActionBar:EnableMouse(false)` makes Action Bar 2 clickable; `MainActionBar.Selection:EnableMouse(false)` lets it be selected in Edit Mode; both survive closing and reopening Edit Mode; reload undoes both. No BugGrabber errors
- [x] 0.2 Settle the open points (`/wasd setup keys` removed; options page Run setup and Restore) and write the `key-binding-setup` and `options-panel` deltas

## 1. Dependencies and data
- [x] 1.1 TOC `## Dependencies: LibEditMode, LibEditModeOverride`; `.pkgmeta` `required-dependencies` (design.md section 1); `INSTALL.md` lists both
- [x] 1.2 `Logic/Settings.lua` defaults `setUp`, `restore`, `keyCopy` (design.md section 2)

## 2. Logic and tests
- [x] 2.1 `Logic/LayoutPlan.lua` and `layout_plan_spec.lua`: each action from its readings, in order; create vs switch; nil readings skipped; status sentences (design.md section 3). Remove `Logic/LayoutCheck.lua` and its tests
- [x] 2.2 `Logic/LayoutCopy.lua` and `layout_copy_spec.lua`: copy of a preset and of a custom layout, renamed and account-typed, inserted after the last account layout, active index; source unchanged (design.md section 4)
- [x] 2.3 `Logic/Restore.lua` and `restore_spec.lua`: actions for saved layout present or gone, action bar 2 was on or off, keybind question only with a key copy (design.md section 8)

## 3. UI and commands
- [x] 3.1 Readings from LibEditModeOverride and the live frames; applying (design.md section 5)
- [x] 3.2 Mouse fix at login and after setup (design.md section 6)
- [x] 3.3 One setup window, offer, Edit Mode open refusal (design.md section 7)
- [x] 3.4 Restore popups and messages (design.md section 8)
- [x] 3.5 Commands, status and options page buttons (design.md section 10)
- [x] 3.6 `make check` passes

## 4. Docs
- [x] 4.1 `openspec/project.md`: "only writes its own WASDBars layout, after the player confirms"; the mouse fix; restore; LibEditModeOverride under dependencies
- [x] 4.2 `README.md`: setup and how to roll back (`/wasd restore`)
- [ ] 4.3 At archive: update the Purpose lines of `edit-mode-setup` ("never writes Edit Mode layouts") and `key-binding-setup` (`/wasd setup keys`) in `openspec/specs/`

## 5. In-game checks (Mac)
Reset first: on both characters pick Modern in Edit Mode, delete "UI", "DeutchebAnkh Layout" and "WASDTestLayout", turn Action Bar 2 off; on the druid untick Character Specific Keybindings; reset the account-wide keybinds to default. Claude Code clears `setupOffered` in `WASDBars.lua` while logged out. Install LibEditModeOverride from CurseForge.
- [ ] 5.1 Druid, first login: the offer appears; the window shows Layout and Keys headings with plain actions and what loses its key
- [ ] 5.2 Not now: nothing changes; not offered again after `/reload`. Clear `setupOffered` again
- [ ] 5.3 Set up: "WASDBars" is active and listed as an account layout; Modern unchanged
- [ ] 5.4 Action Bar 2 is exactly where Action Bar 1's buttons were, same size; no gryphons; the cluster is bottom left and the chat window sits above it; nothing overlaps at the Mac's resolution
- [ ] 5.5 Action Bar 2: tooltips, clicks and drag and drop work; in Edit Mode it can be selected and Action Bar 1 can't; still true after `/reload`
- [ ] 5.6 Keys: Q E R T F G Z X C V and both mouse side buttons fire the cluster, 1–= fire Action Bar 2, in caster, Bear and Cat
- [ ] 5.7 XP bar, stance bar and pet bar are where they were before setup
- [ ] 5.8 Move the chat window, turn Hide Bar Art off, run `/wasd setup layout`: only Hide Bar Art is listed; the chat stays put
- [ ] 5.9 Drag Action Bar 2 off Action Bar 1, run `/wasd setup layout`: "Put Action Bar 2 on Action Bar 1" is listed and works
- [ ] 5.10 Edit Mode open + `/wasd setup`: refused with the message; nothing changes
- [ ] 5.11 Start a fight, run `/wasd setup` and confirm in combat: "Will apply after combat", applied when it ends
- [ ] 5.12 Switch to Modern: no offer; `/wasd setup status` says not on the WASDBars layout. Switch back
- [ ] 5.13 Rogue, first login: offer appears; window lists only switching to WASDBars and turning on Action Bar 2 (keys shared and already set up); after Set up, 5.4–5.5 hold
- [ ] 5.14 Rogue `/wasd restore`: popup 1 lists switching back to Modern and turning Action Bar 2 off; then the keybind question; answer No: Modern active, Action Bar 2 off, keys unchanged, "WASDBars" still listed; chat explains turning the addon off
- [ ] 5.15 Rogue after `/reload`: Action Bar 1 catches the mouse again (mouse fix off); `/wasd restore` says nothing to restore
- [ ] 5.16 Druid `/wasd restore`, answer Yes to keybinds: Modern active, Action Bar 2 off, keys back to the defaults
- [ ] 5.17 No BugSack errors; no "Interface action blocked"

## 6. Wrap-up
- [ ] 6.1 Merge and archive
