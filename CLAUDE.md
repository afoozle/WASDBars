# WASDBars

A WoW: Forever addon (interface `16001`, Lua 5.1) that arranges the game's own action bar 1 buttons into the shape of the keys around WASD. Personal tool for a feral druid; other classes must not break.

**Read `openspec/project.md` first.** It has the goals, roadmap, conventions and the Mac game paths.

## Roadmap and changes
- Work is planned as OpenSpec changes in `openspec/changes/`, built in the order of the roadmap table in `openspec/project.md`. Finished changes are in `openspec/changes/archive/`; the next change is the first roadmap row that isn't archived.
- **Grill each change's spec at the start of work on it**, using what earlier changes learned (the spike's findings are in `openspec/changes/archive/2026-11-22-spike-button-takeover/design.md`).
- One branch per change, named after it. Conventional commits, with no `Co-Authored-By` or other AI attribution lines. A change is done when `make check` passes and its in-game checks (end of its `tasks.md`) pass; then merge to `main` and archive it to `openspec/changes/archive/<date>-<change>/`.

## Releasing
Only when the player asks. On `main` with `make check` passing: add a `CHANGELOG.md` section (fixes bump the patch number, features the minor), commit, `git tag vX.Y.Z`, push `main` and the tag. Watch the Release workflow with `gh run watch`; read failures with `gh run view --log-failed`. Check the zip's contents with a dry run (`gh workflow run release.yml`, then `gh run download`) after changing `.pkgmeta` or adding top-level files. Day-to-day testing never needs a package: the Mac's AddOns folder links to this repo.

## Commands
- `make setup`: install dev tools (once, and again after changing `.stylua-version`; CI uses the same StyLua version)
- `make lint`, `make format`, `make format-check`, `make test`
- `make check`: lint + format-check + test; must pass before committing

## Code rules
- The repo root is the addon folder; the game loads only what `WASDBars.toc` lists. Folders are by feature (`ActionBarCluster/`, `Keybinds/`, `Setup/`, …); `tests/` mirrors them. `Core/Startup.lua` loads last and is the only file that connects game events.
- Every addon file starts with `local ADDON, ns = ...`. No globals except `WASDBarsDB`, `SLASH_WASDBARS1`, named StaticPopup dialogs and frames named `WASDBars...`.
- **Logic files and game files:** decisions go in logic files of plain functions (data in, data out, no game calls, no game functions passed in), and busted tests every one. Game files call WoW directly, stay thin and are checked in-game: they read the game into plain data, ask a logic function, and act on the answer. No dependency injection and no fakes of the game.
- **Modules, not instances:** each file is one table on `ns` (`ns.Keybinds`) called with a dot. The TOC lists every logic and data file before any game file, so a file may name the logic and data modules it uses once at the top (`local KeybindPlan = ns.KeybindPlan`). Game files reach other game files through `ns`, only inside functions.
- **Naming:** files and modules are nouns naming what they own; functions start with the verb and name the purpose, not details that may change (`repositionActionBarCluster`). Full-word names for variables, parameters and fields.
- **No boolean parameters** that switch what a function does: write two functions.
- **No functions inside functions**, except a short anonymous callback passed straight to the game or the combat queue whose body is one call.
- **No tables of rules:** small named functions called in order. Plain data tables are fine.
- **No per-frame work:** react to events only.
- **Combat queue:** anything that moves, sizes, reparents or shows/hides the action buttons or the cluster, or changes keybinds, goes through `ns.CombatQueue.runOutOfCombat(jobName, job)`. Setup and restore refuse in combat instead.
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
- The player installs third-party addons (BugGrabber, BugSack, and runtime dependencies such as LibEditMode) through CurseForge. Helper libraries are welcome when they mean less addon code; declare them as TOC dependencies, never copy them into the repo.
- Step the player through in-game checks a few at a time.
