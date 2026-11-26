# Tasks: Ask before moving the buttons

## 1. Logic and tests
- [x] 1.1 `Logic/LayoutPlan.lua` and `layout_plan_spec.lua`: the "buttons" action after create or switch, never otherwise (design.md section 4)
- [x] 1.2 `Logic/Settings.lua` and its tests: `setUp` default removed (design.md section 7)

## 2. UI
- [x] 2.1 `UI/Cluster.lua`: `take` and `release`, one combat queue key, cluster hidden at login, hotkey hook and safety check only on "WASDBars" (design.md section 2)
- [x] 2.2 `UI/EditMode.lua`: the `layout` callback takes or releases the buttons
- [x] 2.3 `UI/Setup.lua`: mouse fix follows the layout; offer text; login reminder; restore message; `setUp` removed; old saves' `setUp` cleared (design.md sections 3–7)
- [x] 2.4 `make check` passes

## 3. Docs
- [x] 3.1 `openspec/project.md` (architecture: the buttons and mouse fix follow the WASDBars layout) and `README.md` (setup asks before moving anything; restore)
- [ ] 3.2 At archive: update the `edit-mode-setup` Purpose line in `openspec/specs/`

## 4. In-game checks (Mac)
- [ ] 4.1 Run together with `hide-main-bar`: every **[buttons]** and **[both]** check in `openspec/changes/hide-main-bar/tasks.md` section 4 passes (the combat layout switch is left out: Edit Mode can't open in combat)

## 5. Wrap-up
- [ ] 5.1 Merge and archive, with `hide-main-bar` (same branch)
