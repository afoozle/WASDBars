# Proposal: Move and scale the display

## Why
The cluster's best spot depends on the player's screen and UI. They need to move it, resize it and put it back, without risking errors in combat.

## What Changes
- Unlock mode with a visible drag handle; drag to move; lock to hide the handle
- Scale from 0.5 to 2.0
- Reset to default position and scale
- Every change goes through the combat queue
- Commands: `/wasd unlock`, `/wasd lock`, `/wasd scale <number>`, `/wasd reset`
- Small public API (`ns.Display`) that the options panel (`add-options-panel`) can reuse later

## Depends on
`add-wasd-layout`

## Impact
- New capability spec: `display-positioning`
- New file: `UI/Mover.lua`; `Settings.clampScale` added to `Logic/Settings.lua`
- New settings: `point`, `scale`, `locked`

## Open question for this change's grilling
The player would like to move and position the cluster through the game's own Edit Mode (Forever has the modern Edit Mode, confirmed by the spike), not only with `/wasd unlock`. Edit Mode has no official addon API; options include a library such as LibEditMode, or a lightweight "show our mover while Edit Mode is open" hook on `EditModeManagerFrame`. Decide when this change starts.
