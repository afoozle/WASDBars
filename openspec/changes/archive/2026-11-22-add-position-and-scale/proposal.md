# Proposal: Move and scale the display in Edit Mode

## Why
The cluster's best spot depends on the player's screen and UI. They need to move it, resize it and put it back, independently of the game's bars, without risking errors in combat. The player wants to do this in the game's own Edit Mode.

## What Changes
- The cluster becomes its own Edit Mode element ("WASDBars") through **LibEditMode**, installed by the player from CurseForge and declared as a TOC dependency. It is positioned against the screen and no longer follows action bar 2.
- Drag it with Edit Mode open; it is kept on screen
- A **Scale** slider (0.5–2.0, steps of 0.05) in the cluster's Edit Mode settings box
- Position and scale are saved per Edit Mode layout name; a layout with nothing saved uses the default (bottom left, above the bars)
- Reset through LibEditMode's own "Reset To Default Position" and reset-settings buttons
- Anything applied outside Edit Mode (layout changes, login) goes through the combat queue
- No slash commands for any of this

## Decided when grilled (2026-11-22)
- LibEditMode over a hand-made Edit Mode look-alike or slash-command handle: less addon code is better, and helper libraries are fine when they simplify the addon (project.md updated).
- The library is a CurseForge-installed dependency, not copied into the repo.
- Saved per Edit Mode layout, like every other Edit Mode element.
- `/wasd unlock`, `lock`, `scale`, `reset`, the `ns.Display` API and the `locked` setting are dropped; Edit Mode covers them.
- The default position's exact numbers come from where the player places the cluster during the in-game checks.

## Depends on
`add-wasd-layout`

## Impact
- New capability spec: `display-positioning`
- New files: `Logic/Placement.lua`, `UI/EditMode.lua`
- TOC: `## Dependencies: LibEditMode`
- New setting: `layouts` (per-layout position and scale)
- `wasd-layout`: the cluster no longer anchors to action bar 2
