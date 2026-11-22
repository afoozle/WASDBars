# Design: Edit Mode setup and first-time setup

Draft; refine when this change is grilled and after the feasibility check.

## 1. Feasibility check (do first)
A throwaway test, like the spike but smaller, out of combat:
1. Read the layouts with `C_EditMode.GetLayouts()`; find the active one and the systems for Action Bar 1 (`Enum.EditModeSystem.ActionBar`, main bar index) and Action Bar 2.
2. Copy the active layout into a new account layout named "WASDBars"; set Action Bar 1's hide-art and hide-scrolling settings and Action Bar 2's anchor to Action Bar 1's old position; `C_EditMode.SaveLayouts(...)`, then `C_EditMode.SetActiveLayout(...)`.
3. Check: the change shows (straight away, or after `/reload`), it survives `/reload` and relog, the WASD cluster is unaffected, opening Edit Mode afterwards shows the "WASDBars" layout with those settings, and BugSack shows no taint or blocked actions (including when entering Edit Mode or combat afterwards).
4. Record which `Enum` values and setting IDs Forever uses, and whether a reload is needed.

**Pass:** build section 2. **Fail:** build section 3's first-time setup with the manual-steps fallback only.

The addon only uses `C_EditMode` functions and never writes to `EditModeManagerFrame` or its tables, to avoid taint.

## 2. Edit Mode arrangement (`ns.EditModeSetup`)
- `ns.EditModeSetup.status()`: `"applied"` if the active layout is "WASDBars" with the expected settings, otherwise `"not applied"`.
- `ns.EditModeSetup.request(onDone)`: out of combat only (in combat: queue under `"setup-layout"`). If already applied, say so. Otherwise show a StaticPopup listing what will change ("Create Edit Mode layout 'WASDBars' from '<current>'", "Action Bar 1: hide art and page arrows", "Action Bar 2: move to where Action Bar 1 was") with Confirm / Cancel. Confirm applies it (and reloads if the check found that necessary, telling the player first). `onDone` runs afterwards.
- Pure parts (finding the right systems in a layout table, building the modified copy) live in `Logic/EditModeLayout.lua` and are unit tested with a captured layout table from the feasibility check.

## 3. First-time setup
- At `PLAYER_LOGIN`, if `WASDBarsDB.setupOffered` isn't set and not in combat: show "Set up WASDBars? This will bind keys and arrange your action bars." with Set up / Not now. Either answer sets `setupOffered`.
- Set up runs `ns.Bindings.request("wasd")` → `ns.Bindings.request("numbers")` → `ns.EditModeSetup.request()`, each step starting when the previous popup closes. Each keeps its own confirmation; cancelling one step moves on to the next.

## 4. Commands
- `/wasd setup`: run the whole first-time setup again
- `/wasd setup keys`: keybind part only (from `add-key-binding-setup`)
- `/wasd setup layout`: Edit Mode part only (or the manual steps if the fallback is in use)
- `/wasd setup status`: keybind lines plus "Action bar layout: set up / not set up"
