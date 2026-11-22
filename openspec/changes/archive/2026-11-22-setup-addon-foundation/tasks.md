# Tasks: Set up the addon foundation

## 1. Repository
- [x] 1.1 `git init` in this folder, default branch `main` (no remote yet)
- [x] 1.2 Add `.gitignore`, `.gitattributes`, `.editorconfig` (design.md section 7)
- [x] 1.3 Add a short README (what it is, dev setup, make targets) and CLAUDE.md (design.md section 8)
- [x] 1.4 Commit `.agents/`, `.claude/` and `skills-lock.json` along with the rest

## 2. Tooling
- [x] 2.1 `scripts/setup-dev.sh` (design.md section 6) and run `make setup`
- [x] 2.2 `.luacheckrc` (design.md section 5)
- [x] 2.3 `.stylua.toml`
- [x] 2.4 `.busted` and the two test helpers (design.md section 4)
- [x] 2.5 `Makefile` (design.md section 6)

## 3. Addon skeleton
- [x] 3.1 `WASDBars.toc` at the repo root (design.md section 2)
- [x] 3.2 `Core/Init.lua`: namespace, `ns.print`, `ns.debug` (prints only when debug is on), the combat queue
- [x] 3.3 `Core/Events.lua`: event frame, `ns.Events.on(event, fn)`, `ADDON_LOADED` merges `WASDBarsDB` with defaults, `PLAYER_REGEN_ENABLED` flushes the combat queue
- [x] 3.4 `Logic/Settings.lua`: `defaults` and `merge`
- [x] 3.5 `Logic/CombatQueue.lua` (design.md section 3)
- [x] 3.6 `Core/Slash.lua`: `/wasd` with the command registry, `help`, `version` and `debug` (design.md section 9)

## 4. Unit tests
- [x] 4.1 `settings_spec.lua`: fills missing keys; keeps saved values; merges nested tables; handles nil saved table
- [x] 4.2 `combat_queue_spec.lua`: runs immediately out of combat; defers in combat; notifies once per combat; a newer job with the same key replaces the waiting one and keeps its place; flush runs in order and empties the queue; a second combat notifies again
- [x] 4.3 `make check` passes

## 5. In-game checks (Mac)
- [x] 5.1 Claude Code links the repo into AddOns as `WASDBars`; it appears in the AddOns list at character select, not marked out of date
- [x] 5.2 Log in: no errors in BugSack
- [x] 5.3 `/wasd help` lists `help`, `version` and `debug`; `/wasd version` prints "dev build"; `/wasd nonsense` says it wasn't recognised
- [x] 5.4 `/reload`, then `/dump WASDBarsDB`: table exists with default values

## 6. Wrap-up
- [x] 6.1 Archive this change
