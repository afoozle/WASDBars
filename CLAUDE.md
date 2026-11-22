# WASDBars

A WoW: Forever addon (interface `16001`, Lua 5.1) that arranges the game's own action bar 1 buttons into the shape of the keys around WASD. Personal tool for a feral druid; other classes must not break.

**Read `openspec/project.md` first.** It has the goals, roadmap, conventions and the Mac game paths.

## Roadmap and changes
- Work is planned as OpenSpec changes in `openspec/changes/`, built in the order of the roadmap table in `openspec/project.md`. Finished changes are in `openspec/changes/archive/`; the next change is the first roadmap row that isn't archived.
- **Grill each change's spec at the start of work on it**, using what earlier changes learned (the spike's findings are in `openspec/changes/archive/2026-11-22-spike-button-takeover/design.md`).
- One branch per change, named after it. Conventional commits. A change is done when `make check` passes and its in-game checks (end of its `tasks.md`) pass; then merge to `main` and archive it to `openspec/changes/archive/<date>-<change>/`.

## Commands
- `make setup`: install dev tools (once)
- `make lint`, `make format`, `make format-check`, `make test`
- `make check`: lint + format-check + test; must pass before committing

## Code rules
- The repo root is the addon folder; the game loads only what `WASDBars.toc` lists, in the order `Core` → `Logic` → `Data` → `UI`.
- Every addon file starts with `local ADDON, ns = ...`. No globals except `WASDBarsDB`, `SLASH_WASDBARS1`, named StaticPopup dialogs and frames named `WASDBars...`.
- **Logic/UI split:** pure logic goes in `Logic/`, makes no WoW calls when it loads, and receives any game functions as arguments, so busted can test it with the stubs in `tests/helpers/wow_stubs.lua`. Don't force the split onto code that is mostly game calls.
- **No per-frame work:** react to events only.
- **Combat queue:** anything that moves, sizes, reparents or shows/hides the action buttons or the cluster, or changes keybinds, goes through `ns.combatQueue:run(key, fn)`.
- Add to the game's functions with `hooksecurefunc`; never replace them.
- Never change keybind or action-button code without updating the in-game checklist in the change's `tasks.md`.
- User messages are plain language, prefixed `WASDBars:`. Fail quietly.

## In-game results (read these yourself; never ask the player to paste)
- Game folder: `/Applications/World of Warcraft/_forever_/`
- AddOns: `_forever_/Interface/AddOns/` (`WASDBars` is a symlink to this repo; never overwrite a real folder there)
- SavedVariables (written on `/reload`, logout or exit): `_forever_/WTF/Account/AFOOZLE/SavedVariables/`
  - `WASDBars.lua`: the addon's settings
  - `!BugGrabber.lua`: Lua errors and blocked actions
- Taint log: `_forever_/Logs/taint.log` (only with `/console taintLog 1`)
- The player installs third-party addons (BugGrabber, BugSack) through CurseForge.
- Step the player through in-game checks a few at a time.
