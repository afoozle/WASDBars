# Proposal: Clean up after v1.0.0

## Why
A review of the v1.0.0 release found a combat-queue bug that can silently drop confirmed keybinds, specs and docs that no longer match the code, fallbacks for clients that don't exist, and StyLua versions that differ between the Mac and CI. Cleaning these up now keeps the codebase small and the specs trustworthy before anything else is built. Released as `v1.0.1`.

## What Changes
- **Fixes:** confirming keybinds and opening the keybind window use separate combat-queue keys, so a request in combat can't replace a confirmed apply; a setup request while the window is already open keeps its follow-up (the layout check) instead of dropping it
- **Less code:** remove the movement keys' copied-art fallback, second-choice arrows and `pcall`; the `GetAddOnMetadata` shim; the two-way form name lookup (keep the branch Forever uses); the profiler-missing guards and their spec scenario; `LayoutCheck`'s per-check functions (one expected value each); the public `Slash.commands`/`Slash.setup` tables; `ns.createCombatQueue` and `characterKey` wrappers; an unused test stub
- **StyLua:** one pinned version in `.stylua-version`; `make setup` downloads that exact StyLua into `.tools/`, `make format`/`format-check` use it, and CI reads the same file
- **Repo:** stop tracking `.idea/`
- **Specs and docs:** match the code (Run setup button, dev build wording, slash command extensibility, movement keys title, capability wording instead of "this change", combat message case, setup prerequisites); `openspec/project.md`, CLAUDE.md and README brought up to date (globals, load order, folder layout, hotkey relabelling, "only if public" wording)

## Impact
- Code: `UI/Bindings.lua`, `UI/MovementKeys.lua`, `UI/Setup.lua`, `Logic/LayoutCheck.lua`, `Core/Init.lua`, `Core/Events.lua`, `Core/Slash.lua`, `Core/Perf.lua`, `.luacheckrc`, `tests/helpers/wow_stubs.lua`
- Tooling: `.stylua-version`, `scripts/setup-dev.sh`, `Makefile`, `.github/workflows/ci.yml`, `.gitignore`
- Specs: `addon-foundation`, `edit-mode-setup`, `key-binding-setup`, `performance-recording`, `wasd-layout`
- Docs: `openspec/project.md`, CLAUDE.md, README, CHANGELOG (`1.0.1`)
