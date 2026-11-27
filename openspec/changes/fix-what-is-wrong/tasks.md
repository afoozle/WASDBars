# Tasks: Fix what is wrong

## 1. Keybind copy per binding set
- [x] 1.1 Test first: two characters, one on character keybinds; each restores its own keys, and restoring one doesn't drop the other's copy
- [x] 1.2 Key the copy by binding set (account, or the character when it uses character keybinds); restore reads and clears the same copy
- [x] 1.3 Spec delta (`edit-mode-setup` / `key-binding-setup`)

## 2. Small code fixes
- [x] 2.1 Remove `/wasd setup layout`; messages and tests say `/wasd setup`
- [x] 2.2 Reload window title "WASDBars"
- [x] 2.3 Stale comments: BarArt research path, Settings header

## 3. Docs
- [x] 3.1 INSTALL: check-in-game steps and uninstalling
- [x] 3.2 README and CHANGELOG 1.1.0: Hide Bar Art wording
- [ ] 3.2a At release time: correct the published v1.1.0 release notes to match (`gh release edit v1.1.0`)
- [x] 3.3 TOC Notes; `add-curseforge-publishing` wording, version examples, dependencies
- [x] 3.4 Specs: `edit-mode-setup` (`/wasd setup`), `display-positioning` (WASDBars layout only), `key-binding-setup` (key copy per binding set)
- [ ] 3.4a When archiving: `display-positioning` Purpose says "saved per Edit Mode layout"; reword to match
- [x] 3.5 project.md roadmap rows and note
- [x] 3.6 `openspec validate fix-what-is-wrong`, `make check`

## 4. In game
Covered by the one session at the end of `simplify-after-restructure`. Checks this change adds:
- [ ] 4.1 `/wasd setup layout` says to use `/wasd setup`; `/wasd setup` works
- [ ] 4.2 `/wasd restore` ends with a window titled "WASDBars"
- [ ] 4.3 Restore keybinds: keys back as before setup
