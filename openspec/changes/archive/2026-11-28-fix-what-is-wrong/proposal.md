# Proposal: Fix what is wrong

## Why
A whole-repo review (2026-11-27) found a bug and text that tells players the wrong thing. Fix those surgically before the structure work in `restructure-into-features`, so it starts from correct behaviour and docs.

## What Changes
Surgical fixes only: no files moved, nothing renamed, no refactoring.
- **Keybind copy per binding set:** setup saves the keys before setup once for the account, but restore works per character. A character on its own (character-specific) keybinds gets its own copy, and restores its own keys
- **`/wasd setup layout` removed:** it's the same as `/wasd setup`; messages and the `edit-mode-setup` spec say `/wasd setup`
- **Restore's reload window** is titled "WASDBars", not "Set up WASDBars"
- **Stale comments:** BarArt's research path (now in the archive), the Settings header note
- **Docs that are wrong:**
  - INSTALL: the buttons move only after setup, not at login; uninstalling starts with `/wasd restore`
  - README and the v1.1.0 CHANGELOG entry (and its GitHub release notes): ticking Hide Bar Art removes the art, not unticking
  - TOC Notes and `add-curseforge-publishing`: "form action bar" wording, stale version examples, LibEditModeOverride missing as a dependency
  - `display-positioning` spec: the cluster shows on the WASDBars layout only
  - project.md roadmap: rows for every change, a note that specs describe current behaviour

Duplicated docs, tooling tidying and dead code wait for `simplify-after-restructure`.

## Depends on
`hide-main-bar`

## Impact
- `UI/Setup.lua`, `UI/SetupWindow.lua`, `UI/BarArt.lua`, `Logic/Settings.lua`, `Logic/LayoutPlan.lua`, `Logic/Restore.lua` (if the key copy needs it), `Core/Slash.lua`, `WASDBars.toc`, tests
- `README.md`, `INSTALL.md`, `CHANGELOG.md`, `openspec/project.md`, specs `edit-mode-setup`, `display-positioning`, `key-binding-setup`, `add-curseforge-publishing`
- Built on branch `deep-clean` with `restructure-into-features` and `simplify-after-restructure`; one in-game session for all three at the end, then one release, v1.1.1
