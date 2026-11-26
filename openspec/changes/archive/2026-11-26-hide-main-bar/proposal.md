# Proposal: Replace action bar 1 with action bar 2

## Why
On the WASDBars layout, action bar 1 is an empty frame: its buttons are in the cluster and action bar 2 sits exactly on top of it. Its Edit Mode box still shows, and action bar 2 looks plainer than action bar 1 did, because only action bar 1 has the game's bar art and Hide Bar Art setting.

## What Changes
- **Action bar 1 see-through:** on the WASDBars layout, action bar 1 (and its Edit Mode box) is fully transparent. It isn't hidden, so the game's bottom bar stack (XP bar, action bar 3, stance, pet…) stays exactly where it is, in and out of Edit Mode.
- **Action bar 1's art on action bar 2:** on the WASDBars layout, WASDBars draws the game's bar border and button dividers around action bar 2, with the game's own textures and rules, and restyles action bar 2's buttons to the main-bar frame. No page arrows.
- **Hide Bar Art for action bar 2:** a "Hide Bar Art" checkbox in LibEditMode's box under action bar 2's Edit Mode settings, on the WASDBars layout only. Its starting value is action bar 1's Hide Bar Art in the layout setup copies from; an existing WASDBars layout starts with the art shown.
- **Setup window:** one more line, "Replace action bar 1 with action bar 2", after the buttons line.
- Leaving the WASDBars layout puts it all back, like the buttons (`ask-before-moving-buttons`).

## Depends on
`ask-before-moving-buttons`. Built on the same branch and merged with it, at the player's request.

## Impact
- New capability: `main-bar-replacement`
- Changed capabilities: `edit-mode-setup` (window line), `wasd-layout` ("Other bars left alone")
- New: `Logic/Dividers.lua`, `UI/BarArt.lua` and tests; changed: `Logic/LayoutPlan.lua`, `Logic/Settings.lua`, `UI/EditMode.lua`, `UI/Setup.lua`, the TOC
- Research: `research.md`
