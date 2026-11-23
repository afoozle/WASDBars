# Tasks: Clean up after v1.0.0

## 1. Fixes
- [x] 1.1 Separate combat-queue keys for the keybind apply and window (design.md section 1)
- [x] 1.2 Chain `onDone` when the keybind window is already open

## 2. Less code
- [x] 2.1 Keep only the spell-ID branch of `formName` (Forever returns the spell ID fourth: recorded in the key-binding-setup design, and form names showed in game)
- [x] 2.2 MovementKeys: template only, one arrow per direction
- [x] 2.3 `C_AddOns.GetAddOnMetadata` only; `.luacheckrc` updated
- [x] 2.4 Perf: no profiler guards
- [x] 2.5 LayoutCheck: one expected value per check; tests still pass
- [x] 2.6 Slash locals, inline combat queue, inline `UnitGUID`, unused stub removed
- [x] 2.7 Stop tracking `.idea/`

## 3. StyLua
- [x] 3.1 `.stylua-version`, `setup-dev.sh` download, `Makefile` (design.md section 4)
- [ ] 3.2 CI reads `.stylua-version`; CI passes
- [x] 3.3 `make setup` then `make check` on the Mac uses `.tools/bin/stylua` 2.6.0

## 4. Specs and docs
- [x] 4.1 Spec deltas; Purpose lines updated
- [x] 4.2 `openspec/project.md`, CLAUDE.md, README (design.md section 5)
- [x] 4.3 CHANGELOG `1.0.1`

## 5. In-game checks
- [ ] 5.1 `/reload`: no errors; W, A, S, D look as before (arrows centred, same key art as T)
- [ ] 5.2 `/wasd setup status` still reports keybinds and layout in one line
- [ ] 5.3 Keybind window shows form names (e.g. "Bear Form") under actions that lose their key, if any are listed
- [ ] 5.4 In combat (e.g. on a target dummy), `/wasd setup`: chat says "Will apply after combat."; after combat, keybinds already set up and the layout check both show; no errors

## 6. Release
- [ ] 6.1 Merge, tag `v1.0.1`; the Release workflow passes
- [ ] 6.2 Archive this change
