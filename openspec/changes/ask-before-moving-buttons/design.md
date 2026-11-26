# Design: Ask before moving the buttons

Decided in the grill (2026-11-26). Game code references are to Forever's UI source, `Gethe/wow-ui-source` branch `forever`, commit `d9c22e32cb240afb82bb2ecefbb78ef935333f59`.

## 1. The rule
The buttons are in the cluster exactly while the active Edit Mode layout is named "WASDBars" (`ns.LayoutPlan.NAME`); on any other layout they are on action bar 1. LibEditMode's `layout` callback already fires on every active layout change, including at login (`UI/EditMode.lua`); it now also decides where the buttons go. Being on the WASDBars layout is consent, whether setup switched the character there or the player picked it in Edit Mode. Keybinds don't come into it.

## 2. Taking and returning the buttons (`UI/Cluster.lua`)
- `Cluster.take()`: today's `applyLayout`, then show the cluster.
- `Cluster.release()`: for each cluster button, `SetParent(button.container)`, `SetScale(1)`, `ClearAllPoints()`, `SetPoint("CENTER")`, and put the game's hotkey style back (the existing `restore(hotkey)`); then hide the cluster.
  - This is how the game first places them: each button is created inside its holder `MainActionBarButtonContainerN` and anchored `CENTER` (`Blizzard_ActionBar/Shared/ActionBar.lua:14,31-33`). Icon size scales the holder, not the button (`Blizzard_EditMode/Shared/EditModeSystemTemplates.lua:1087`), so scale 1 is right. The holders never move, so the bar's grid layout needn't run again. In-game check confirms.
- Both run through the combat queue under the **same key** (`"buttons"`), so only the last one asked for runs after combat.
- `Cluster.inPlace` records which state was last applied. The `UpdateHotkeys` hook styles the hotkey only while the buttons are in the cluster. The `EDIT_MODE_LAYOUTS_UPDATED` safety check re-takes buttons only while on the WASDBars layout.
- The cluster frame is still built at `PLAYER_LOGIN`, but starts hidden. Its LibEditMode selection and the movement keys are children of it, so they hide with it.

## 3. Mouse fix (`UI/Setup.lua`)
Follows the layout too: on the WASDBars layout, `MainActionBar` and its `Selection` stop catching the mouse; on any other layout they get back the mouse state they had before (read once with `IsMouseEnabled` before the first change). Through the combat queue (`"bar1-mouse"`), as today.

## 4. Setup window and offer
- `Logic/LayoutPlan.lua`: when the step is "create" or "switch", `actions` adds `{ id = "buttons", text = "Move action bar 1's buttons into the WASD shape" }` right after the create or switch line. Nothing applies it directly: switching to the layout moves the buttons (section 1).
- Offer popup text: "Set up WASDBars?\n\nIt moves action bar 1's buttons into the WASD shape, makes a WASDBars Edit Mode layout and binds your keys. You'll see every change before anything happens."
- Offer rule unchanged: once per character (`setupOffered`), when the layout or keys need anything.
- `Setup.open` with nothing to do no longer marks anything; it says everything is set up. A character with nothing to do is already on the WASDBars layout.

## 5. Login reminder (`UI/Setup.lua`)
In the existing first-`EDIT_MODE_LAYOUTS_UPDATED` handler (layouts are known by then): if the offer is shown on this login, nothing else; otherwise, if the active layout isn't WASDBars, print `Not set up on this character. Type /wasd setup to set it up.` (`ns.print` adds the `WASDBars:` prefix). It runs once per UI load, so a `/reload` shows it again too.

## 6. Restore
The restore popup switches the layout (as today); the layout callback then releases the buttons and lifts the mouse fix. Remove the `setUp` clearing. Final message: `Restored. You can delete the WASDBars layout in Edit Mode whenever you like. Type /wasd setup to set it up again.`

## 7. Saved data
`Logic/Settings.lua`: remove the `setUp` default. On load, set `WASDBarsDB.setUp = nil` so old saves drop it (`Settings.merge` keeps unknown keys).
