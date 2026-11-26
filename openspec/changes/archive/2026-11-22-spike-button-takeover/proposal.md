# Proposal: Spike — can we take over the game's action buttons?

## Why
The whole design depends on one assumption: on WoW Forever, an addon can move the game's own `ActionButton1`–`12` into a new shape and they stay there, keeping all their behaviour, with no blocked-action errors. There is no fallback build. If this doesn't hold, the project stops and is rethought. So it gets proved first, before any repo tooling, with a rough addon built to be thrown away.

## What Changes
- A throwaway addon, `WASDBarsSpike`, in `spike/WASDBarsSpike/`, linked into the game's AddOns folder
- It moves `ActionButton1`–`10` (the left-hand WASD keys only; mouse side buttons are out of the spike) into a rough WASD shape with two sizes
- It re-applies the shape when the game puts the buttons back, and counts how often that happens
- `/spike dump` saves what it can detect about the client and the main bar to SavedVariables, so Claude Code reads the facts from the game folder rather than having them copied across
- Errors are caught by the player's BugGrabber + BugSack and by the game's taint log; Claude Code reads both from the game folder
- Findings go in `design.md` ("Findings"), and the change is archived with no capability spec

## Depends on
Nothing. This runs before `setup-addon-foundation`.

## Impact
- No capability spec; nothing from the spike ships
- The findings decide whether `add-wasd-layout` goes ahead, and fill in the facts it needs (how the main bar lays out its buttons, what resets them, the art frame names, Edit Mode)
- After the spike, the next step is to simplify anything in the later changes that the findings show is over-engineered
