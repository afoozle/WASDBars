# Tasks: Options panel

## 1. Verify
- [ ] 1.1 In game, check the `Settings` functions listed in design.md section 1 exist and note their signatures

## 2. Build
- [ ] 2.1 Add `showMovementKeys` and `showMouseOutline` defaults (both on)
- [ ] 2.2 `UI/Options.lua`: category, section headers and every control in design.md section 3
- [ ] 2.3 Wire the movement-key and mouse-outline checkboxes to show/hide those frames
- [ ] 2.4 `/wasd` and `/wasd options` open the panel
- [ ] 2.5 `make check` passes

## 3. In-game checks
- [ ] 3.1 WASDBars appears under AddOns in the game's options, and `/wasd` opens it
- [ ] 3.2 Every control shows the current value; changes are kept after `/reload`
- [ ] 3.3 Scale slider resizes the display live and shows a percentage; "Reset position and scale" works and the slider returns to 100%
- [ ] 3.4 "Unlock to move" shows the drag handle; unticking locks it; ticking it in combat is refused and the box flips back
- [ ] 3.5 Movement keys and mouse outline checkboxes hide and show them; the side-button actions stay when the outline is hidden
- [ ] 3.6 "Set up WASD keys…" and "Set up number row…" open the binding confirmation
- [ ] 3.7 Change the scale with `/wasd scale 1.5`, then open the panel: the slider shows 150%
- [ ] 3.8 No BugSack errors

## 4. Wrap-up
- [ ] 4.1 Update README with screenshots, merge, archive
