# Proposal: Edit Mode setup and first-time setup

## Why
With action bar 1's buttons moved into the WASD cluster, the screen should look like this: the main bar's art and page arrows gone, action bar 2 (the number row, same in every form) where action bar 1 used to be, and the WASD cluster above it. Edit Mode can do all of this, but doing it by hand is fiddly. The addon can do it in one confirmed step, and offer it together with the keybinds as a first-time setup, so a new character (or a new machine) is ready in one go.

## What Changes
- **Feasibility check first:** confirm on Forever that an addon can create its own Edit Mode layout through `C_EditMode` (copy the active layout, change the settings below, save, switch to it) without taint or blocked actions. If not, this change keeps only the first-time setup and the manual steps (see Fallback).
- **Edit Mode arrangement** (`/wasd setup layout`), shown and confirmed before applying:
  - Creates (or updates) an Edit Mode layout named "WASDBars", based on the player's current layout, and switches to it. The game's preset layouts are never edited.
  - In that layout: Action Bar 1 "Hide Bar Art" and "Hide Bar Scrolling" on; Action Bar 2 positioned where Action Bar 1 was.
  - The WASD cluster's default position sits above action bar 2.
- **First-time setup:** at the first login with WASDBars, a popup offers "Set up WASDBars? This will bind keys and arrange your action bars." with Set up / Not now. Set up runs the keybind setup (`add-key-binding-setup`), then the Edit Mode arrangement, each with its own confirmation. Either answer is remembered so it isn't offered again.
- `/wasd setup` runs both parts again; `/wasd setup keys` and `/wasd setup layout` run one part; `/wasd setup status` includes whether the Edit Mode arrangement is in place.

## Fallback
If the feasibility check fails (or writing layouts proves fragile), `/wasd setup layout` prints the manual steps instead: in Edit Mode, select Action Bar 1, tick "Hide Bar Art" and "Hide Bar Scrolling", then drag Action Bar 2 into Action Bar 1's old spot.

## Depends on
`add-key-binding-setup`

## Open questions for this change's grilling
- Is the "setup offered" flag account-wide (asked once per machine) or per character? Keybinds and Edit Mode layouts can each be per character, so a new alt might need its own setup.
- What happens to the cluster's position if the player has already moved it (`add-position-and-scale`) when setup runs?

## Impact
- New capability spec: `edit-mode-setup`
- New files: `UI/EditModeSetup.lua`, `UI/FirstTimeSetup.lua` (names may merge once the feasibility check is done)
- New setting: `setupOffered`
- The only Edit Mode layout the addon ever writes is its own "WASDBars" layout, and only after confirmation
