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
- [ ] 3.2 At archive: `main-bar-replacement` Purpose line in `openspec/specs/`

## 4. In-game checks (Mac), together with `ask-before-moving-buttons`
One session for both changes. **[buttons]** checks `ask-before-moving-buttons`, **[art]** checks this change. Claude reads `WASDBars.lua` and `!BugGrabber.lua` after each `/reload`.

**A. Druid (Zoolefa), already set up: nothing should break**
- [ ] 4.1 [buttons] Log in: the cluster is where it was with all 12 buttons; no reminder, no offer; action bar 2's tooltips and clicks work; Bear and Cat change the cluster
- [ ] 4.2 [art] Action bar 1 can't be seen. Open Edit Mode: no box for action bar 1; the XP bar and stance bar are in the same place in and out of Edit Mode
- [ ] 4.3 [art] Action bar 2 has action bar 1's border, dividers between buttons and button frames, and its buttons still show icons, cooldowns and hotkeys normally
- [ ] 4.4 [art] Edit Mode, select action bar 2: a box under its settings has "Hide Bar Art". Tick it: the border, dividers and button frames go. Untick: they're back. Tick it, `/reload`: still ticked, no art. Untick again
- [ ] 4.5 [art] Action bar 2's icon padding to 3: dividers go, border stays round the bar; back to 2: dividers back. Icon size up a step: the border grows with the bar. Put both back
- [ ] 4.6 [art] Fight a mob using action bar 2 and shifting forms: no errors, the art stays right
- [ ] 4.7 [buttons] `/reload`: as 4.1; Claude checks the old `setUp` entry is gone

**B. Rogue (Deutscheb): restore and switching layouts**
- [ ] 4.8 [buttons] Log in: as 4.1, with Stealth swapping the cluster's abilities
- [ ] 4.9 [both] `/wasd restore`, No to keys: back on Modern straight away; the buttons are on action bar 1 at normal size with the game's hotkey text; action bar 1 shows normally; action bar 2 has its own plain look, no border; the cluster and movement keys are gone; the new restore message
- [ ] 4.10 [buttons] On Modern: the buttons work and Stealth swaps the bar; action bar 1 catches the mouse normally; Edit Mode has no WASDBars element; selecting action bar 2 shows no Hide Bar Art checkbox (note whether an empty box shows)
- [ ] 4.11 [buttons] Options: toggling "Show movement keys" and "Large hotkey text" shows nothing and doesn't change action bar 1's hotkey text
- [ ] 4.12 [buttons] `/reload`: one reminder line, no offer; Claude checks the rogue's restore entry is gone
- [ ] 4.13 [both] Switch to WASDBars in Edit Mode, then back to Modern: everything follows both ways, the cluster returns to its spot, no reload needed

**C. Rogue as a brand-new character**
- [ ] 4.14 [buttons] At character select, Claude clears the rogue's `setupOffered`. Log in: normal action bar 1, no cluster; the offer mentions moving the buttons; no reminder
- [ ] 4.15 [buttons] Not now: nothing changes. `/reload`: no offer, one reminder
- [ ] 4.16 [both] `/wasd setup`: Layout lists "Switch to your WASDBars layout", "Move action bar 1's buttons into the WASD shape", "Replace action bar 1 with action bar 2". Not now: nothing changes
- [ ] 4.17 [both] `/wasd setup`, Set up: the buttons move into the cluster, action bar 1 goes see-through, action bar 2 has the art and works (tooltips, clicks, selecting it in Edit Mode); "Set up." in chat
- [ ] 4.18 [both] `/reload`: all of it holds; no reminder

**D. Wrap-up**
- [ ] 4.19 Claude reads `!BugGrabber.lua`: no errors, no "Interface action blocked"

Not covered in game: setup creating the WASDBars layout (and the art's starting value from the source layout), and switching layouts in combat.

## 4b. Trimmed run (2026-11-26, the player's call: critical checks only, on the rogue)
- [x] 4b.1 Set-up rogue: cluster, action bar 1 invisible, art on action bar 2; Edit Mode: no action bar 1 box, bottom bars still; Hide Bar Art toggles
- [x] 4b.2 `/wasd restore`, No to keys: Modern, buttons back at normal size, plain action bar 2, Stealth swaps action bar 1
- [x] 4b.3 Fresh login (`setupOffered` cleared): normal bar, offer mentions the buttons; Not now changes nothing
- [x] 4b.4 `/wasd setup`, Set up: everything moves; first fight hit a blocked `StanceBar:SetShownBase()` (setup's layout apply, see `ask-before-moving-buttons` design.md section 8). After `/reload`, three fights (two from Stealth): no errors, no taint log
- [x] 4b.5 After `/reload` the UI holds
- [ ] 4b.6 Reload to finish: restore, `/wasd setup`, Set up; the reload window shows; its button reloads the UI; fight a mob; no errors (a first try with `ReloadUI()` was blocked as a protected call)

The full list above (4.1–4.19) was replaced by this run.

## 5. Wrap-up
- [ ] 5.1 Merge both changes and archive both
