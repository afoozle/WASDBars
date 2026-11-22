# Design: Spike — can we take over the game's action buttons?

Rough and throwaway. No tests, no lint, no structure beyond what the test needs.

## Findings
Run on 2026-11-22, on the Mac, build 1.60.1.71037. Six sessions (four on a level 21 druid, two on a rogue alt).

- **Result: pass.** Buttons 1–10 stayed in the spike frame through everything tested: caster/Bear/Cat/Prowl in and out of combat, button feedback (cooldowns, rage colouring, range, Maul queue highlight, tooltips), keys, drag and drop (per-form slots, swap, drag off), bar page change, hearth, `/reload`, game options, Edit Mode (opening it and changing main bar settings), and a class without forms. Mounting wasn't tested (no mount yet).
- **Errors:** none. BugGrabber recorded nothing over six sessions. No `taint.log` was written (taint logging was turned on with `/console taintLog 1`; either nothing was tainted or the file wasn't created; BugGrabber shows no blocked actions either way).
- **Nothing ever put the buttons back.** 157 hooked functions and 5 events, thousands of calls (including Edit Mode layout updates and main bar `UpdateGridLayout`, `UpdateShownButtons`, `Layout`, in and out of combat): 0 times found out of place. One apply at login per session was enough; nothing was ever deferred.
- **Interface:** `16001`. `WOW_PROJECT_ID` = `WOW_PROJECT_CAMELOT` (18).
- **UI is the modern (retail-style) one:** `MainActionBar` (no `MainMenuBar`, no `MainMenuBarArtFrame`), `EditModeManagerFrame` and `C_EditMode` exist and manage the bars; `Settings`, `C_AddOnProfiler`, `ActionBarActionButtonMixin`, `ActionBarController`, `StanceBar`, `PetActionBar`, `MicroButtonAndBagsBar`, `MultiBarBottomLeft/Right` exist. `UIParent_ManageFramePositions` and `ActionButton_UpdateHotkeys` do **not** exist.
- **How the main bar holds buttons:** each `ActionButtonN` sits in its own `MainActionBarButtonContainerN` (a child of `MainActionBar`). Buttons are protected, 45×45, and have `useparent-actionpage = true`. Re-parented to a plain frame with no `actionpage` attribute, paging still followed form correctly in and out of combat (Bear showed actions 97–106).
- **Action bar 2** (`MultiBarBottomLeft`) is parented to `UIParent`, not to the main bar, so main bar changes can't affect it.
- **Leftover main bar art:** all anonymous textures on `MainActionBar` and its unnamed children (atlases `UI-HUD-ActionBar-Frame`, `UI-HUD-ActionBar-Gryphon-Left/Right`, `UI-HUD-ActionBar-PageUp/DownArrow-*`, `UI-HUD-ActionBar-Frame-Divider-ThreeSlice-*`). The empty `MainActionBarButtonContainer1–10` draw nothing. Edit Mode already has main bar settings for this (`UpdateSystemSettingHideBarArt`, `UpdateSystemSettingHideBarScrolling`), so hiding the art can be the game's own Edit Mode options instead of addon code.
- **Surprises / notes for later changes:**
  - The Fwd/Back hotkey relabel can't hook `ActionButton_UpdateHotkeys`; it would hook the button mixin's `UpdateHotkeys` method instead.
  - The player wants to position the cluster with Edit Mode (noted in `add-position-and-scale`).
  - Buttons 11 and 12 weren't moved by the spike; the layout change checks them.

## 1. Files
```
spike/WASDBarsSpike/
  WASDBarsSpike.toc       ## Interface: 16001, ## SavedVariables: WASDBarsSpikeDB
  Spike.lua
```
Linked into `/Applications/World of Warcraft/_forever_/Interface/AddOns/WASDBarsSpike`.

## 2. What the spike does
- At `PLAYER_LOGIN` (out of combat), creates `WASDBarsSpikeFrame` near the bottom centre and, for buttons 1–10, `SetParent` → `ClearAllPoints` → `SetPoint` → `SetScale`, in a rough WASD shape (Q E R T / F G / Z X C V around a gap for W A S D). Keys touching WASD at scale 1.0, the outer ones (T, G, V) at 0.85.
- Hooks (`hooksecurefunc`, never replacing) every likely "put the buttons back" function that exists on this client: the main bar's own layout methods and Edit Mode's layout updates. Each hook counts its calls and, if a button has left the spike frame, re-applies the layout (straight away out of combat, otherwise on `PLAYER_REGEN_ENABLED`).
- Also re-checks on `PLAYER_ENTERING_WORLD`, `UPDATE_BONUS_ACTIONBAR`, `ACTIONBAR_PAGE_CHANGED` and `UPDATE_SHAPESHIFT_FORM`, counting how often a button was found out of place.
- Nothing is hidden: the main bar art stays, so the spike only tests moving buttons.

## 3. Commands
- `/spike apply`: re-apply the layout now (out of combat)
- `/spike reset`: put the buttons back on the main bar (out of combat), to compare
- `/spike status`: print which hooks or events found the buttons moved back, and how often
- `/spike dump`: record facts into `WASDBarsSpikeDB` and remind the player to `/reload`. It also runs automatically on logout and `/reload`, and keeps the last 20 sessions, so a reload mid-test doesn't lose earlier counts. It records:
  - build info, `WOW_PROJECT_ID`, which project constants exist
  - which frames and functions exist (`MainMenuBar`, `MainActionBar`, `EditModeManagerFrame`, `ActionBarController`, `MultiBarBottomLeft`, …)
  - each button's parent, points, scale and whether it is protected
  - the main bar's children and regions (names and textures) as candidates for leftover art
  - hook call counts and "found out of place" counts per hook or event, including how many happened in combat

## 4. Reading the results
- Facts: `_forever_/WTF/Account/<ACCOUNT>/SavedVariables/WASDBarsSpike.lua`
- Errors and blocked actions: BugGrabber's saved errors in `_forever_/WTF/Account/<ACCOUNT>/SavedVariables/!BugGrabber.lua`
- Taint: `_forever_/Logs/taint.log`, after `/console taintLog 1`
- What the player saw: reported by eye

## 5. Pass / fail
**Pass:** the buttons stay in the spike frame through the checklist (or the game only puts them back through something a hook catches, and the layout comes back by the end of combat at the latest), button behaviour is unchanged, and no blocked-action or protected-function errors appear.
**Fail:** anything else. Stop and rethink the project.
