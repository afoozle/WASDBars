# Tasks: Simplify after restructure

## 1. Review
- [x] 1.1 Grill: how the review is run and decided
  - A fresh agent reviews; Claude checks each finding, fixes the clear ones in small commits, and asks the player only about findings that change behaviour or remove a safety check
  - Weighted towards cutting code: about 3,160 lines after the restructure is too many for this addon
  - Remove guards for game parts that always exist on WoW Forever 16001 (a visible error beats a quiet failure); keep LibEditModeOverride's ready check (timing)
  - Remove the v1.0.0 `setUp` cleanup; keep the v1.1.0 key copy migration until at least the next minor release
  - Files may name the logic and data modules they use once at the top (`local KeybindPlan = ns.KeybindPlan`); the TOC lists every logic and data file before any game file; game files still reach other game files through `ns` inside functions
- [ ] 1.2 Review and fixes
  - Second review, aiming under 1,800 executable lines: the performance recorder and `/wasd setup status` are removed; one `refuseLayoutChange` for setup and restore (with Edit Mode open and nothing to restore, `/wasd restore` now says to close Edit Mode); `/wasd setup` with the window open fills it again
  - At archive: delete `openspec/specs/performance-recording/` (every requirement removed) and drop "checked with `/wasd setup status`" from key-binding-setup's Purpose
- [ ] 1.3 `max_cyclomatic_complexity = 10` in `.luacheckrc`; `make check` passes

## 2. In game (all three changes at once)
Smoke pass of everything the addon does, since every file changed. Claude reads `!BugGrabber.lua` and `WASDBars.lua` after the `/reload` that ends each round (snapshots from before the pass are in the session scratchpad). Any Lua error or blocked action fails the round.

- [x] 2.1 **Login** (feral druid on the WASDBars layout; `/reload` at the end)
  - No errors at login; the cluster is in its WASD shape where it was before
  - W, A, S and D look like the cluster's empty slots, with arrows
  - Large hotkey text, mouse buttons shortened
  - Action bar 2 sits on action bar 1 with the same art as before; action bar 1 behind it can't be clicked or hovered
  - Read after: the v1.1.0 `keyCopy` has moved to `keyCopies.account`; no `WASDBarsPerfDB`
- [x] 2.2 **Edit Mode** (`/reload` at the end)
  - Drag the cluster, change its scale; both stay after closing Edit Mode
  - The buttons stay in the cluster while Edit Mode is open, and after editing another bar (the stray-button check is gone)
  - Action bar 2: change its icon size, then toggle Hide Bar Art; the art follows each change
  - Switch to Modern: buttons go back to action bar 1, and action bar 1 shows and clicks; switch back: cluster and bar 2 return
- [ ] 2.3 **Combat** (target dummy or a mob; bear and cat)
  - Shifting forms swaps the cluster's buttons; the stance bar works in combat
  - In combat: `/wasd setup` and `/wasd restore` say they can't run in combat; Open Edit Mode on the options page says it can't open in combat
  - ~~In combat, rebind one cluster key~~ dropped: not a real case
  - Found: `/wasd options` in combat was blocked by the game (`OpenSettingsPanel()`, there since the options page was added); it now says the options can't be opened in combat. Re-check: `/wasd options` in combat, and the game's own options → AddOns → WASDBars → Open Edit Mode in combat
- [ ] 2.4 **Commands and options** (`/reload` at the end)
  - `/wasd help` lists help, options, restore, setup, version (no perf); `/wasd version` says "Dev build."; `/wasd nonsense` says it's not a command and shows the help
  - `/wasd setup`, `/wasd setup status` and `/wasd setup layout` each say everything is set up (or open the setup window)
  - `/wasd options`: three headings; turn Show movement keys off and on, and Large hotkey text off (game's corner text) and on, and each changes straight away
- [ ] 2.5 **Restore**
  - With Edit Mode open, `/wasd restore` says to close Edit Mode
  - `/wasd restore`: the popup names your old layout; Restore switches to it, buttons go back to action bar 1, action bar 2 goes back to how it was
  - "Restore your keybinds too?" Yes: Q is Turn Left, R is Reply, 1–= are action bar 1 again
  - The reload window is titled "WASDBars"; Reload to finish reloads
  - Read after: `restore` and `keyCopies.account` for this character are cleared
- [ ] 2.6 **Setup**
  - `/wasd setup`: the window lists the Layout steps and both Keys groups, with "These will no longer have a key" (e.g. Chat Reply (R)); lines are spaced as before
  - Type `/wasd setup` again: still one window, filled the same
  - Not now: nothing changes; `/wasd setup` again, then Set up: the WASDBars layout is active, buttons in the cluster, bar 2 on bar 1, keys bound; Reload to finish
  - After the reload, everything from 2.1 holds; `/wasd setup` says everything is set up
  - Read after: a new restore point and key copy were saved
- [ ] 2.7 **Another character** (an alt that hasn't been offered setup, ideally not a druid)
  - At login, the setup offer shows once; Not now
  - `/reload`: no offer, a one-line "not set up" reminder instead
  - No errors; action bar 1 untouched; if it has stances, `/wasd setup` names stance keys losing their key by form
- [ ] 2.8 Re-run only the checks that failed

## 3. Finish
- [ ] 3.1 Merge `deep-clean`; archive the three changes; CHANGELOG and release v1.1.1
