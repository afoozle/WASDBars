# Design: Layout setup

## 1. Dependencies
- TOC: `## Dependencies: LibEditMode, LibEditModeOverride`.
- `.pkgmeta`: `required-dependencies:` with `libeditmode` and `libeditmodeoverride` (CurseForge slugs), so the CurseForge app installs both.
- LibEditModeOverride (plusmouse, MIT, supports Forever 1.60.1): `LoadLayouts`, `SetFrameSetting`, `ReanchorFrame`, `SetActiveLayout`, `ApplyChanges`. `ApplyChanges` saves with `C_EditMode.SaveLayouts` and then opens and closes Edit Mode so the game applies the layout; it refuses in combat. `LoadLayouts` needs `EDIT_MODE_LAYOUTS_UPDATED` to have fired (`IsReady()`).

## 2. Saved data (`Logic/Settings.lua` defaults)
- `setUp`: character GUID → true once that character's layout step finished with the layout ready (turns on the mouse fix, section 6).
- `restore`: character GUID → `{ layout = <previous layout name>, bar2 = <was action bar 2 on> }`, written when Set up is pressed and the layout part runs; cleared by restore.
- `keyCopy`: nil, or `{ [key] = command | false }` for the 24 keys in `Data/BindingGroups.lua`, taken from the plans' `current` field the first time Set up actually changes keys; cleared by a restore that puts the keys back. Account-wide (one copy), matching the decision that restore puts back the account-wide binds.

## 3. What "ready" means (`Logic/LayoutPlan.lua`, pure, replaces `Logic/LayoutCheck.lua`)
`LayoutPlan.actions(readings)` returns the actions still needed, in popup order, each `{ id, text }`. `readings` (nil = the game couldn't tell; that check is skipped):
- `activeLayout` (name), `wasdbarsExists`, `atLayoutCap`
- `bar1` = `{ numIcons, alwaysShowButtons, hideBarArt, hideBarScrolling, orientation, numRows, iconSize, iconPadding }`
- `bar2` = `{ shown, numIcons, orientation, numRows, iconSize, iconPadding, onBar1 }` (`onBar1`: action bar 2's first button within 1 pixel of action bar 1's first button holder, scaled rects)
- `endCapsHidden` = `{ left, right }`

Actions:
1. `create` "Create a WASDBars layout from '<name>' and switch to it" (no "WASDBars"), or `switch` "Switch to your WASDBars layout" (exists, not active). With `create`, also `place` "Put the WASD keys bottom left and move the chat window up".
2. `bar1` "Action Bar 1: 12 icons, always show buttons, hide bar art and scrolling" if any of the four is off.
3. `bar2Shape` "Action Bar 2: same size and shape as Action Bar 1, 12 icons" if any differs.
4. `bar2Place` "Put Action Bar 2 on Action Bar 1" if `create`, or if `onBar1` is false.
5. `endCaps` "Hide the gryphons" if either shows.
6. `bar2On` "Turn on Action Bar 2" if not shown.

After `create`/`switch`, the other checks are judged against the "WASDBars" layout: readings for settings come from LibEditModeOverride's loaded "WASDBars" layout (`GetFrameSetting`), not from the live frames. `LayoutPlan.statusSentence(readings, actions)`: "Edit Mode layout ready." / "Not on the WASDBars layout (/wasd setup layout)." / "WASDBars layout needs N changes (/wasd setup layout)."

## 4. Copying the layout (`Logic/LayoutCopy.lua`, pure)
`LayoutCopy.build(presets, saved, name, accountType)` where `presets` is `EditModePresetLayoutManager:GetCopyOfPresetLayouts()` and `saved` is `C_EditMode.GetLayouts()` (custom layouts only; `activeLayout` counts presets first, the same indexing LibEditModeOverride uses). Returns `{ layouts, activeLayout }` ready for `C_EditMode.SaveLayouts`: all layouts with a deep copy of the active one renamed `name`, type account, inserted after the last account layout (LibEditModeOverride's `AddLayout` index rule), and `activeLayout` pointing at it. UI side: `C_EditMode.SaveLayouts(result)`, `C_EditMode.SetActiveLayout(result.activeLayout)`, then `LoadLayouts()` again before the edits. At the account cap (`Constants.EditModeConsts.EditModeMaxLayoutsPerType`), setup says "WASDBars: You have the most Edit Mode layouts the game allows. Delete one, then run /wasd setup layout." and stops.

## 5. Applying (`UI/Setup.lua`)
Order, all inside one `ns.combatQueue:run("setup-apply", fn)`:
1. Save `restore[guid]` (current layout name, action bar 2 shown) if not already saved; save `keyCopy` if nil and keys will change.
2. Copy or switch (section 4, or `SetActiveLayout("WASDBars")`).
3. `LoadLayouts()`, then `SetFrameSetting` for action bar 1 (`MainActionBar`), action bar 2 (`MultiBarBottomLeft`, settings copied from action bar 1's values in "WASDBars") and the end caps (`Enum.EditModeMainActionBarEndCapSetting.Hidden`).
4. Positions (only with `create`, or `bar2Place`): action bar 2 by `ReanchorFrame(MultiBarBottomLeft, "BOTTOMLEFT", UIParent, "BOTTOMLEFT", x, y)` from `MainActionBarButtonContainer1`'s scaled rect less action bar 2's offset from its own first button; chat by `ReanchorFrame(ChatFrame1, ...)` raised by the cluster's scaled height plus 8; the cluster by `ns.Placement.save(ns.db.layouts, "WASDBars", { point = "BOTTOMLEFT", x, y })`.
5. `ApplyChanges()`.
6. `Settings.SetValue("PROXY_SHOW_ACTIONBAR_2", true)`, the game's own path for the Action Bars setting.
7. Keybinds (unchanged `apply` from `UI/Bindings.lua`).
8. Read again; if ready, `setUp[guid] = true` and the mouse fix runs.

Edit Mode open (`EditModeManagerFrame:IsShown()`): "WASDBars: Close Edit Mode, then run /wasd setup layout." and nothing changes.

## 6. Mouse fix (`UI/Setup.lua`)
At `PLAYER_LOGIN` (after the cluster takes the buttons) and straight after setup, for characters with `setUp[guid]`, through `ns.combatQueue:run("bar1-mouse", fn)`: `MainActionBar:EnableMouse(false)` and `MainActionBar.Selection:EnableMouse(false)`. Nothing is saved by the game, so it runs every login. Restore stops it from the next login (no attempt to turn it back on).

## 7. Setup window and offer
- **One window** (the keybind window from `UI/Bindings.lua`, retitled "Set up WASDBars"): a **Layout** heading with section 3's actions, then a **Keys** heading with the existing keybind steps and "These will no longer have a key:". Headings with nothing under them are left out. Set up applies section 5; Not now, the close button and Escape change nothing.
- Nothing to do: "WASDBars: Everything is set up." (and the mouse fix runs, which also sets `setUp` if missing).
- **Offer:** at `PLAYER_LOGIN`, once LibEditModeOverride is ready, if `setupOffered[guid]` isn't set and either the keys or the layout aren't set up, show the offer popup (combat queue), record the offer. Set up opens the window.
- Switching to another layout later shows nothing; the status line says so.

## 8. Restore (`Logic/Restore.lua` pure, UI in `UI/Setup.lua`)
`Restore.plan(saved, keyCopy, currentLayouts)` returns the actions for popup 1 and whether popup 2 applies.
- Popup 1 "Restore WASDBars changes?": lists "Switch back to '<layout>'" (or "Switch to Modern ('<layout>' no longer exists)") and "Turn Action Bar 2 off" if it was off. Restore: `SetActiveLayout` + `ApplyChanges`, `Settings.SetValue("PROXY_SHOW_ACTIONBAR_2", saved.bar2)`, clear `restore[guid]` and `setUp[guid]`.
- Popup 2 "Restore your keybinds too?" (only with `keyCopy`): Yes sets each of the 24 keys back (`SetBinding(key, command)`, or `SetBinding(key)` for unbound), `SaveBindings(GetCurrentBindingSet())`, clears `keyCopy`. No and Escape leave them.
- Then: "WASDBars: Restored. You can delete the WASDBars layout in Edit Mode whenever you like. Turn WASDBars off in the AddOns list, or uninstall it, then reload to finish."
- No `restore[guid]`: "WASDBars: Nothing to restore on this character."
- Same combat and Edit Mode rules as setup.

## 9. Why not hide action bar 1 (`hide-main-bar`, optional)
Bartender4 hides `MainActionBar` with `HideBase()` and a hidden parent (never `:Hide()`, which taints Edit Mode frames). On WoW Forever, `EditModeManagerFrameMixin:UpdateBottomActionBarPositions` stacks every default-positioned bar on action bar 1 and skips hidden bars, so the stack would drop into action bar 1's spot, and jump back up whenever Edit Mode opens (which shows every bar). With the mouse fix, action bar 1 has no visible or clickable part left; the only gain would be its Edit Mode box, which the selection fix already makes unclickable.

## 10. Commands and status
- `/wasd setup` and `/wasd setup layout`: the window (section 7). `/wasd setup keys` is removed.
- `/wasd setup status`: keybind sentence + section 3's status sentence.
- `/wasd restore`: section 8.
- Options page Setup section: Run setup ("Set up the WASDBars layout and keybinds. Shows every change first.") and Restore ("Switch back to your previous layout, and optionally your keybinds.").
