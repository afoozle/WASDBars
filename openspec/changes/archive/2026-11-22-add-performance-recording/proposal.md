# Proposal: Performance recording for Claude Code

## Why
The player wants a simple way to check WASDBars isn't hurting frame rate, and for Claude Code to read the numbers itself instead of the player copying them across. WoW Forever has a built-in addon profiler that is always measuring every addon, so the addon doesn't need to time anything itself. It only needs to save those numbers somewhere Claude Code can read. Addons can't write files, but the game saves an addon's SavedVariables to a plain text file on `/reload` or logout, which Claude Code can read on the Mac.

## What Changes
- `/wasd perf start <label>`, `/wasd perf stop`, `/wasd perf clear`
- While recording, once per second, save the built-in profiler's numbers for WASDBars, plus frame rate, combat state, form and whether there is a target
- On stop, save the profiler's session-level numbers for WASDBars and for all addons combined (for comparison)
- Saved to account-wide SavedVariables `WASDBarsPerfDB`, kept small (5 most recent sessions, 10 minutes of samples each)
- A short "Performance" section in CLAUDE.md: where the file is, what's in it, what good looks like, and the loop (ask for a recording, read the file, fix, ask for another)
- No other addons, no report scripts, no limits files or baselines
- Used on demand (when something feels slow, or once before a public release), not on every change

## Decided when grilled (2026-11-22)
- Every metric the profiler lists (`Enum.AddOnProfilerMetric`) is recorded by name, rather than a guessed few.
- No Windows PC check here (no PC install yet; belongs with `add-curseforge-publishing`).
- The 5-session / 600-row limits are unit tested instead of recorded in game.

## Depends on
`add-options-panel`

## Impact
- New capability spec: `performance-recording`
- New file: `Core/Perf.lua`
- TOC: `## SavedVariables: WASDBarsPerfDB`; `.luacheckrc`: add it to `globals`
- CLAUDE.md: Performance section
