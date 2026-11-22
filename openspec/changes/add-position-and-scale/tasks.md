# Tasks: Move and scale the display in Edit Mode

## 1. Logic and tests
- [ ] 1.1 `layouts` default; default position and scale in `Data/Layout.lua`, replacing `anchor` (design.md section 2)
- [ ] 1.2 `Logic/Placement.lua`: `clampScale`, `forLayout`, `save` (design.md section 3)
- [ ] 1.3 `placement_spec.lua`: clampScale keeps values in range, limits below 0.5 and above 2.0, nil for non-numbers; forLayout uses saved values, falls back to defaults for a missing layout or damaged fields, clamps a saved scale; save creates and merges

## 2. Frames
- [ ] 2.1 TOC `## Dependencies: LibEditMode`; `UI/EditMode.lua` (design.md section 4)
- [ ] 2.2 Cluster no longer anchored to action bar 2 (design.md section 5)
- [ ] 2.3 Update project.md (helper libraries rule, dependencies), README and CLAUDE.md (LibEditMode is required)
- [ ] 2.4 `make check` passes

## 3. In-game checks
- [ ] 3.1 In Edit Mode, "WASDBars" can be selected and dragged; it stays on screen
- [ ] 3.2 Moving action bar 2 no longer moves the cluster
- [ ] 3.3 Scale slider resizes the cluster evenly; position and scale survive `/reload`
- [ ] 3.4 Reset To Default Position and the settings reset restore the default; set the default position's numbers from the player's placement
- [ ] 3.5 No BugSack errors

## 4. Wrap-up
- [ ] 4.1 Merge and archive
