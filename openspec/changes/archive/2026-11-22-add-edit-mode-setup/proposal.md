# Proposal: First-time setup and Edit Mode layout check

## Why
With action bar 1's buttons moved into the WASD cluster, a few Edit Mode settings matter: action bar 1 needs 12 icons and always-shown buttons (or cluster buttons go missing), its art and page arrows look odd, action bar 2 must be on, and action bar 1's empty frame mustn't sit over action bar 2. A new character also needs its keybinds. The addon should offer the setup once per character and point out what's still off, without writing Edit Mode layouts itself.

## What Changes
- **First-time setup:** at a character's first login with WASDBars, if its keys aren't already set up, a popup offers "Set up WASDBars?" with Set up / Not now. Set up runs the WASD keys and number row popups (`add-key-binding-setup`) and then the layout check. Either answer is remembered per character.
- **Layout check** (`/wasd setup layout`), read-only: looks at the active Edit Mode layout and lists the manual step for each problem: Action Bar 1 "# of Icons" not 12, "Always Show Buttons", "Hide Bar Art" or "Hide Bar Scrolling" off, Action Bar 2 off, Action Bar 1 overlapping Action Bar 2.
- `/wasd setup` runs the whole setup; `/wasd setup keys` and `/wasd setup layout` one part; `/wasd setup status` adds "Action bar layout: OK" or "N things to fix".
- A minimal WASDBars page in the game's AddOns settings with a **Run setup** button (the start of `add-options-panel`).

## Decided when grilled (2026-11-22)
- The addon never writes Edit Mode layouts: the player already keeps an account-wide "UI" layout arranged by hand, and layouts follow the account, so creating a "WASDBars" layout would redo that work at the most taint risk and code. No feasibility spike.
- The offer is per character, because keybinds are; a character whose keys are already set up isn't asked.
- A Run setup button in the AddOns settings, as well as the slash command.

## Depends on
`add-key-binding-setup`

## Impact
- New capability spec: `edit-mode-setup`
- New files: `Logic/LayoutCheck.lua`, `UI/Setup.lua`, `UI/Options.lua`
- New setting: `setupOffered` (per character, in the account-wide settings)
