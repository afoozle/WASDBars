# Tasks: Move and scale the display in Edit Mode

## 1. Logic and tests
- [x] 1.1 `layouts` default; default position and scale in `Data/Layout.lua`, replacing `anchor` (design.md section 2)
- [x] 1.2 `Logic/Placement.lua`: `clampScale`, `forLayout`, `save` (design.md section 3)
- [x] 1.3 `placement_spec.lua`: clampScale keeps values in range, limits below 0.5 and above 2.0, nil for non-numbers; forLayout uses saved values, falls back to defaults for a missing layout or damaged fields, clamps a saved scale; save creates and merges

## 2. Frames
- [x] 2.1 TOC `## Dependencies: LibEditMode`; `UI/EditMode.lua` (design.md section 4)
- [x] 2.2 Cluster no longer anchored to action bar 2 (design.md section 5)
- [x] 2.3 Update project.md (helper libraries rule, dependencies), README and CLAUDE.md (LibEditMode is required)
- [x] 2.4 `make check` passes

## 3. In-game checks
- [x] 3.1 In Edit Mode, "WASDBars" can be selected and dragged; it stays on screen
- [x] 3.2 Moving action bar 2 no longer moves the cluster
- [x] 3.3 Scale slider resizes the cluster evenly; position and scale survive `/reload`
- [x] 3.4 Reset To Default Position and the settings reset restore the default; set the default position's numbers from the player's placement (default set to BOTTOMLEFT 200, 81; the reset buttons are LibEditMode's own and were not tried separately)
- [x] 3.5 No BugSack errors

## 4. Wrap-up
- [ ] 4.1 Merge and archive
