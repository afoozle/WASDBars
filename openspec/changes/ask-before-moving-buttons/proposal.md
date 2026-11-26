# Proposal: Ask before moving the buttons

## Why
Today the cluster takes action bar 1's buttons at every login (`UI/Cluster.lua`, `PLAYER_LOGIN`), before the player has agreed to anything. Setup is offered afterwards, asking only about the Edit Mode layout and the keybinds. A new player sees their main bar jump into the WASD shape before being asked, and saying "Not now" leaves the buttons moved anyway. The player's consent to moving their bar should come first and be respected: if they say no, nothing changes.

## What Changes
- **The buttons follow the WASDBars layout:** action bar 1's buttons are in the cluster exactly while the "WASDBars" Edit Mode layout is active, and back on the game's action bar 1 on any other layout. They move as soon as the layout changes (through the combat queue). The cluster, its movement keys, its Edit Mode element and the action bar 1 mouse fix go with them. Being on the WASDBars layout is the player's consent; switching away is opting out.
- **Setup asks first:** while the character isn't on the WASDBars layout, the setup window lists "Move action bar 1's buttons into the WASD shape" with the other changes, approved by the same Set up button. The offer popup says so too. "Not now" changes nothing.
- **Login reminder:** at every login on a character that isn't on the WASDBars layout, one chat line: `WASDBars: Not set up on this character. Type /wasd setup to set it up.` Not on the login where the setup offer appears. It keeps appearing after a restore, as a quiet nudge to uninstall.
- **Restore puts the buttons back:** `/wasd restore` switches back to the old layout, so the buttons go back to action bar 1 straight away, with no reload. Its final message no longer says to turn the addon off: `WASDBars: Restored. You can delete the WASDBars layout in Edit Mode whenever you like. Type /wasd setup to set it up again.`
- **No "set up" flag:** `WASDBarsDB.setUp` goes; "set up" for the buttons and the mouse fix means "on the WASDBars layout".

## Depends on
`add-layout-setup`

## Impact
- Changed capabilities: `wasd-layout` (when the buttons are in the cluster), `edit-mode-setup` (window line, offer text, login reminder, mouse fix, restore)
- Changed: `UI/Cluster.lua`, `UI/EditMode.lua`, `UI/Setup.lua`, `Logic/LayoutPlan.lua`, `Logic/Settings.lua`, their tests
- A character that said "Not now" before this update gets its normal action bar 1 back and the login reminder; no special handling (design for fresh installs)
- Action-button code changes, so `tasks.md` ends with an in-game checklist covering a fresh character, Not now, setup, layout switching, restore, reload and combat
