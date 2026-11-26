# Project Context

## Purpose
WASDBars is a small World of Warcraft: Forever addon that rearranges the game's own action bar 1 buttons (the bar that changes with form) into the physical shape of the keys around WASD (Q, E, R, T, F, G, Z, X, C, V plus two mouse side buttons), instead of the default straight bar. The game's buttons keep all their normal behaviour; the addon only arranges, sizes and decorates them. It also helps set up the matching keybinds.

**It's a personal tool first:** built for the author's feral druid (bear tank / cat), who plays with WASD movement. Other classes must not break, but other players' setups don't drive the design. Publishing it for other players is an optional final step, not a goal.

**Lean by default:** build only what's needed now, and remove code that only exists for other clients or for needs that never came.

## Roadmap (build in this order)
Each change builds on the ones before it. Grill the change's spec at the start of work on it, using what earlier changes learned. Implement, check in game, merge and archive one change before starting the next.

**Personal version**

| # | Change | Capability | What it adds |
|---|---|---|---|
| 0 | `spike-button-takeover` ✅ passed 2026-11-22, archived | none (throwaway) | A rough, throwaway addon that proves the game's action buttons can be moved into the WASD shape on Forever and stay there. Go/no-go for the whole project; its findings feed every later change |
| 1 | `setup-addon-foundation` ✅ done 2026-11-22, archived | `addon-foundation` | git repo in standard addon layout, lint, formatting, unit tests, CLAUDE.md, core skeleton (settings, events, combat queue, slash command) |
| 2 | `add-wasd-layout` ✅ done 2026-11-22, archived | `wasd-layout` | Move the game's action buttons 1–12 into the WASD shape with size tiers and movement keys (letters and arrows) |
| 3 | `add-position-and-scale` ✅ done 2026-11-22, archived | `display-positioning` | Move, scale and reset the display as its own Edit Mode element (LibEditMode) |
| 4 | `add-key-binding-setup` ✅ done 2026-11-22, archived | `key-binding-setup` | Confirmed setup of the WASD-cluster binds and the number-row binds, 1–0, - and = to action bar 2 (`/wasd setup keys`) |
| 5 | `add-edit-mode-setup` ✅ done 2026-11-22, archived | `edit-mode-setup` | First-time setup offered once per character (keys, then a read-only Edit Mode layout check that lists manual fixes), `/wasd setup`, and a Run setup button in the AddOns settings |
| 6 | `polish-look-and-messages` ✅ done 2026-11-22, archived | changes to `wasd-layout`, `key-binding-setup`, `edit-mode-setup` | Tighter key spacing, clearer key labels, and binding popups and chat messages that read well |

**Optional extras**

| # | Change | Capability | What it adds |
|---|---|---|---|
| 7 | `add-options-panel` ✅ done 2026-11-22, archived | `options-panel` | Options in the game's own settings window: Open Edit Mode, show movement keys, large hotkey text, setup buttons |
| 8 | `add-performance-recording` ✅ done 2026-11-22, archived | `performance-recording` | Save WoW Forever's built-in profiler numbers for WASDBars so Claude Code can read them; used on demand |
| 9 | `add-github-releases` ✅ done 2026-11-23, archived | `github-releases` | Packager, CI, and versioned GitHub Releases built from tags |
| 10 | `add-layout-setup` ✅ done 2026-11-24, archived | changes to `edit-mode-setup`, `key-binding-setup`, `options-panel` | Setup makes the Edit Mode changes itself in its own "WASDBars" layout (LibEditModeOverride), keys and layout in one window, action bar 1 stops catching the mouse, and `/wasd restore` |
| 11 | `ask-before-moving-buttons` | changes to `wasd-layout`, `edit-mode-setup` | Action bar 1's buttons move into the cluster only after the player confirms setup, never before; "Not now" leaves the game's bar as it was, and `/wasd restore` puts the buttons back |
| 12 | `hide-main-bar` | `main-bar-replacement`; changes to `edit-mode-setup`, `wasd-layout` | On the WASDBars layout action bar 1 goes see-through (not hidden, so the bottom bar stack stays put) and action bar 2 gets action bar 1's border, dividers and button frames, with its own Hide Bar Art checkbox (LibEditMode). Built on the `ask-before-moving-buttons` branch and merged with it |
| 13 | `add-curseforge-publishing` | `curseforge-publishing` | Uploads to CurseForge (dependencies already declared in `.pkgmeta` by `add-layout-setup`) |
| 14 | `upstream-layout-copy` | none | Pull request to LibEditModeOverride: `AddLayout` copying a chosen layout, then swap WASDBars' own copy step for it |

If the spike fails there is no fallback build: stop and rethink (for example, configure an existing bar addon into this shape and keep only the keybind and decoration parts).

## Tech Stack
- Lua 5.1 (WoW addon runtime)
- The game's own action buttons (`ActionButton1`–`ActionButton12`), arranged by the addon
- Target client: WoW Forever, interface `16001`, one plain `WASDBars.toc`. Forever (`WOW_PROJECT_ID == WOW_PROJECT_CAMELOT`) has the modern retail UI: retail-style frames, Edit Mode and the built-in addon profiler (confirmed by the spike). It's the only client, so no fallbacks for others
- Helper libraries are welcome when they mean less addon code. The player installs them from CurseForge and WASDBars declares them as TOC dependencies; they are never copied into the repo. In use: LibEditMode (bundles LibStub) and LibEditModeOverride. The addon still never replaces the game's action buttons, so no LibActionButton
- Development tooling (not shipped): luacheck, StyLua (pinned in `.stylua-version`), busted; GitHub Actions and the BigWigs packager for CI and releases

## Folder Layout
Standard WoW addon repository layout: **the repo root is the addon folder**. The TOC sits at the root and the game only loads files the TOC lists, so development files alongside are harmless. Folders are created when first needed.
```
WASDBars/                      repo root = addon folder
  WASDBars.toc
  Core/                        init, events, perf recording, slash command
  Logic/                       pure Lua, no WoW API calls at load time; unit tested
  Data/                        editable data tables (layout, binding groups)
  UI/                          the cluster, movement keys, Edit Mode, setup window, setup and restore, options
  tests/                       busted unit tests + WoW API stubs
  scripts/                     dev setup
  openspec/                    specs and changes
  .github/workflows/           CI and releases
  .agents/  .claude/  skills-lock.json      Claude Code skills for this repo
  .pkgmeta                     packager config (what goes in the release zip)
  .luacheckrc  .stylua.toml  .stylua-version  .busted  .editorconfig  .gitattributes  .gitignore
  Makefile  README.md  INSTALL.md  CHANGELOG.md  LICENSE  CLAUDE.md
```

## Project Conventions

### Code Style
- Every addon file starts with `local ADDON, ns = ...`; the only globals are the SavedVariables tables (`WASDBarsDB`, `WASDBarsPerfDB`), the `SLASH_WASDBARS1` slash command, named StaticPopup dialogs, and named frames, which always start with `WASDBars` (for example `WASDBarsCluster`)
- **Logic/UI split, only where it pays:** genuinely pure logic (layout maths, binding plans, settings merge, combat queue) lives in `Logic/` as functions that receive any WoW API functions as arguments, so it can be unit tested. Don't force the split onto code that is mostly game calls.
- Load order is set in the TOC: `Core` (Init, Events) → `Logic` → `Data` → `UI` → `Core` (Perf, Slash, which use the rest)
- StyLua formatting; luacheck must pass with zero warnings
- Plain-language user messages, prefixed `WASDBars:`
- **No per-frame work:** the addon reacts to events only; nothing runs every frame

### Architecture Patterns
- The addon **arranges the game's own action buttons**; it never creates action buttons, and never manages spells or macros. Everything an action button does (feedback, form following, drag and drop) is the game's
- The addon only adds to the game's functions with `hooksecurefunc`; it never replaces them
- The addon changes keybinds only through setup and restore, only after the player confirms, and only the keys listed in the keybind layout below
- The addon only ever writes its own account-wide "WASDBars" Edit Mode layout, and only after the player confirms setup (`add-layout-setup`); it never changes another layout. The cluster is its own Edit Mode element through LibEditMode
- Being on the WASDBars layout is the player's consent: action bar 1's buttons are in the cluster only while it is active, and back on action bar 1 on any other layout. The same goes for the mouse fix (on the WASDBars layout, action bar 1's empty frame and its Edit Mode selection stop catching the mouse, because action bar 2 sits on top of it) and for replacing action bar 1 with action bar 2 (action bar 1 see-through, action bar 1's art drawn on action bar 2)
- `/wasd restore` switches a character back to its layout from before setup (so the buttons go back to action bar 1) and, if the player says yes, the keys
- Anything that moves, sizes or reparents the action buttons or the cluster, or changes keybinds, goes through the combat queue: run now if out of combat, otherwise run on `PLAYER_REGEN_ENABLED` with a single "will apply after combat" message. Exception: setup and restore refuse in combat instead

### Versioning
Releases are built from `v*` tags by GitHub Actions with the BigWigs packager (`.pkgmeta`) and published as GitHub Releases; see CLAUDE.md for the steps. The TOC has `## Version: @project-version@`; the packager replaces it with the tag, and in a git checkout `/wasd version` shows "Dev build."

### Testing Strategy
- **Unit tests (busted):** every `Logic/` module, run locally with `make check`, using stubs in `tests/helpers/wow_stubs.lua`. GitHub Actions runs the same checks on every push and pull request.
- **In-game checks:** anything involving frames, the game's buttons or keybinds, using `/reload` and BugGrabber + BugSack. Each change's tasks.md ends with its in-game checklist. Claude Code reads BugGrabber's saved errors from the game's SavedVariables folder rather than having them copied across.
- **Performance:** on demand only, once `add-performance-recording` exists
- A change is done when `make check` passes and its in-game checks pass

### Git Workflow
- `main` branch; one branch per change named after it (for example `add-wasd-layout`)
- Conventional commit messages (`feat:`, `fix:`, `chore:`, `test:`, `docs:`, `perf:`)
- GitHub remote: https://github.com/afoozle/WASDBars (`origin`, over SSH); push `main` only
- When a change is finished: merge and archive the OpenSpec change

### Working with Claude Code
`CLAUDE.md` at the root tells Claude Code how this project works: the OpenSpec roadmap (grill each change at its start), the make targets, the Logic/UI split, and where to find the game folder, BugGrabber's saved errors and the taint log. Claude Code links the repo into the game's AddOns folder when asked. The player installs third-party addons (BugGrabber, BugSack) through CurseForge.

## Machines
- **MacBook:** development and play. All building and in-game checking happens here. Paths (Claude Code reads these directly; the player never copies data across):
  - Game folder: `/Applications/World of Warcraft/_forever_/`
  - AddOns: `_forever_/Interface/AddOns/` (WASDBars is a symlink to the repo root)
  - SavedVariables (written on `/reload`, logout or exit): `_forever_/WTF/Account/AFOOZLE/SavedVariables/` (`WASDBars.lua`, BugGrabber's errors in `!BugGrabber.lua`)
  - Taint log: `_forever_/Logs/taint.log` (only if `/console taintLog 1` is on and something was tainted)
  - Test characters: Zoolefa (druid, level 21, no mount until about level 40) and Deutscheb (rogue alt)
- **Windows PC:** installs from GitHub by following `INSTALL.md` (a release zip or a git clone in the Forever AddOns folder; LibEditMode and LibEditModeOverride through CurseForge).
- WASDBars settings are account-wide on each machine (`SavedVariables: WASDBarsDB`); they don't sync between machines. Keybinds follow the game's own keybind saving.

## Domain Context
- Action bar 1 is the game's main bar, made of `ActionButton1`–`ActionButton12`. When a druid shifts form, the game switches what those same buttons show (Bear, Cat and Prowl each have their own bar), so moving the buttons moves every form's bar at once.
- Action bar 2 (shown in game menus as "Action Bar 2" or "Bottom Left") never pages with form. Its keybind commands are `MULTIACTIONBAR1BUTTON1`–`MULTIACTIONBAR1BUTTON12`.
- The player's target keybind layout:

  | Key | Binding command | Bar |
  |---|---|---|
  | 1–9, 0, -, = | `MULTIACTIONBAR1BUTTON1`–`12` | Action bar 2 (same in every form) |
  | Q, E, R, T, F, G, Z, X, C, V | `ACTIONBUTTON1`–`10` | Action bar 1 (changes with form) |
  | Mouse front side button (usually `BUTTON5`) | `ACTIONBUTTON11` | Action bar 1 |
  | Mouse back side button (usually `BUTTON4`) | `ACTIONBUTTON12` | Action bar 1 |
  | W, A, S, D | movement | – |

- The number row is shown by the game's own action bar 2. WASDBars never draws it; setup turns it on and places it exactly on action bar 1 in the WASDBars layout.
- Keybind labels on the buttons are the game's own text, restyled larger and centred, with mouse buttons shortened ("Mouse Button 5" → M5).
- Addons can't write files directly. The only way data leaves the game is SavedVariables, which the game writes to the `WTF` folder on `/reload`, logout or exit.

## Important Constraints
- **Combat lockdown:** the game's action buttons (and the frame holding them) cannot be moved, resized, reparented or shown/hidden by addon code in combat, and `SetBinding` cannot be called in combat. Touching them carelessly can make the game block actions ("Interface action blocked").
- Never change a keybind without the player confirming; always show what will be replaced.
- Fail quietly: no chat spam, no errors with Lua error reporting off.

## External Dependencies
- Runtime: LibEditMode and LibEditModeOverride (CurseForge, installed by the player; TOC dependencies and `.pkgmeta` required dependencies).
- Development (Mac): Homebrew, Python 3, a pinned StyLua in `.tools/`, and a project-local Lua 5.1 + LuaRocks (luacheck, busted), installed by `make setup`. BugGrabber + BugSack in game.
