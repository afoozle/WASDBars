# Tasks: Options panel

## 1. Build
- [x] 1.1 `showMovementKeys` and `largeHotkeys` defaults (both on)
- [x] 1.2 `UI/Options.lua` with the rows in design.md section 2, replacing the Run setup page
- [x] 1.3 `MovementKeys.setShown`, `Cluster.refreshHotkeys` with the original style remembered
- [x] 1.4 `/wasd options`
- [x] 1.5 `make check` passes

## 2. In-game checks
- [x] 2.1 `/wasd options` opens the WASDBars page with Display, Appearance and Setup sections (the long movement keys label was cut off; shortened to "Show movement keys")
- [x] 2.2 Both checkboxes show and hide straight away and are kept after `/reload`
- [x] 2.3 Open Edit Mode opens Edit Mode with WASDBars selectable; no blocked actions entering or leaving it, or in combat afterwards
- [x] 2.4 Set up keybinds and Check layout work
- [x] 2.5 No BugSack errors

## 3. Wrap-up
- [ ] 3.1 Merge and archive
