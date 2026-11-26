# Design: Clean up after v1.0.0

## 1. Keybind combat-queue keys
`UI/Bindings.lua` queues two different jobs under `"keybinds"`: Confirm's apply and `Bindings.request`'s window. A newer job with the same key replaces the waiting one, so confirming in combat and then running `/wasd setup` before combat ends drops the confirmed binds. Use `"keybinds-apply"` and `"keybinds-window"`.

When `Bindings.request(onDone)` finds the window already open, chain the new `onDone` after the window's own instead of dropping it, so `/wasd setup`'s layout check still runs when the window closes.

## 2. One-client code
WoW Forever is a single retail-style client; the spike and every in-game check since ran on it. Code that only exists for other clients goes:
- `UI/MovementKeys.lua`: build keys from `ActionButtonTemplate` directly (no `pcall`, no `copiedKey`), one `NPE_Arrow*` atlas per direction, no `C_Texture` guard. `copyArt`/`copyPlacement` stay for the NormalTexture copy.
- `Core/Init.lua`: `C_AddOns.GetAddOnMetadata` only; drop `GetAddOnMetadata` from `.luacheckrc`.
- `UI/Bindings.lua` `formName`: keep only the spell-ID return (the fourth), which the key-binding-setup design recorded and the game showed as form names.
- `Core/Perf.lua`: no profiler-missing guards; the spec's "Profiler not available" scenario goes too.

## 3. Smaller simplifications
- `Logic/LayoutCheck.lua`: each check is `{ field, want, fix }` and fails when `value ~= want` (12, true or false).
- `Core/Slash.lua`: `commands` and the setup parts are locals; the addon-foundation spec no longer promises adding commands without editing the file.
- `Core/Events.lua` creates the combat queue inline; `ns.createCombatQueue` goes. `UI/Setup.lua` calls `UnitGUID("player")` directly.
- `tests/helpers/wow_stubs.lua`: drop the unused `SetBinding` stub.
- Kept on purpose: the settings deep merge, `Logic/HotkeyText.lua`, and one handler's error stopping the others for that event.

## 4. StyLua version
- `.stylua-version` at the root holds the version (`2.6.0`).
- `scripts/setup-dev.sh` downloads `stylua-macos-<arch>.zip` for that version from StyLua's GitHub releases into `.tools/stylua/<version>/` and links `.tools/bin/stylua` to it. If `.tools/bin/stylua` already reports that version, it does nothing. Homebrew's StyLua is no longer used.
- `Makefile`: `STYLUA := .tools/bin/stylua`; `format` and `format-check` use it, and fail with "run make setup" if it's missing or the wrong version.
- `ci.yml` reads `.stylua-version` into the `stylua-action` `version` input.
- Changing version: edit `.stylua-version`, `make setup`, `make format`, commit.

## 5. Docs
- `openspec/project.md`: the build-only-what-the-personal-tool-needs wording without "only if public", the globals list with `WASDBarsPerfDB`, no `_Forever` TOC suffix, Edit Mode settled, hotkey text restyled (mouse buttons shortened), folder layout matching the repo, the real load order.
- CLAUDE.md: the real load order (Core Init/Events → Logic → Data → UI → Core Perf/Slash), StyLua from `make setup`.
- README: StyLua is a pinned download, not Homebrew.
- Spec Purpose lines that mention the Run setup button are updated directly.
