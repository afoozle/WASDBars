# Tasks: Replace action bar 1 with action bar 2

## 1. Logic and tests
- [x] 1.1 `Logic/Dividers.lua` and `dividers_spec.lua` (design.md section 4)
- [x] 1.2 `Logic/LayoutPlan.lua` and its tests: the "replace" line after "buttons" (design.md section 7)
- [x] 1.3 `Logic/Settings.lua`: `bar2HideArt` default false (design.md section 6)

## 2. UI
- [x] 2.1 `UI/BarArt.lua`: see-through, border, dividers, button style, hooks, combat wait, checkbox (design.md sections 2–5)
- [x] 2.2 `UI/EditMode.lua` calls `BarArt.follow`; `UI/Setup.lua` sets the starting value on create; TOC lists the new files
- [x] 2.3 `make check` passes

## 3. Docs
- [x] 3.1 `openspec/project.md` roadmap and architecture; `README.md`
- [x] 3.2 At archive: `main-bar-replacement` Purpose line in `openspec/specs/`

## 4. In-game checks (Mac), together with `ask-before-moving-buttons`
A planned 19-check list was cut to the critical run below (the player's call). Not covered in game: setup creating the WASDBars layout (and the art's starting value from the source layout), switching layouts in combat, divider changes with padding and icon size (the rule is unit tested), the options toggles on Modern, and the login reminder.

## 4b. Trimmed run (2026-11-26, the player's call: critical checks only, on the rogue)
- [x] 4b.1 Set-up rogue: cluster, action bar 1 invisible, art on action bar 2; Edit Mode: no action bar 1 box, bottom bars still; Hide Bar Art toggles
- [x] 4b.2 `/wasd restore`, No to keys: Modern, buttons back at normal size, plain action bar 2, Stealth swaps action bar 1
- [x] 4b.3 Fresh login (`setupOffered` cleared): normal bar, offer mentions the buttons; Not now changes nothing
- [x] 4b.4 `/wasd setup`, Set up: everything moves; first fight hit a blocked `StanceBar:SetShownBase()` (setup's layout apply, see `ask-before-moving-buttons` design.md section 8). After `/reload`, three fights (two from Stealth): no errors, no taint log
- [x] 4b.5 After `/reload` the UI holds
- [x] 4b.6 Reload to finish: restore, `/wasd setup`, Set up; the reload window shows; its button reloads the UI; fight a mob; no errors (a first try with `ReloadUI()` was blocked as a protected call). Passed: two clean kills, BugGrabber clean
- [x] 4b.7 Restore ends with the same window: not run in game (the player's call); it is the same reload window and button that passed in 4b.6

## 5. Wrap-up
- [x] 5.1 Merge both changes and archive both
