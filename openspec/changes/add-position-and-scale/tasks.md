# Tasks: Move and scale the display

## 1. Logic and tests
- [ ] 1.1 Add `point`, `scale`, `locked` defaults and `Settings.clampScale` (design.md section 1)
- [ ] 1.2 Extend `settings_spec.lua`: `clampScale` keeps values in range, limits values below 0.5 and above 2.0, returns nil for non-numbers

## 2. Frames and commands
- [ ] 2.1 `UI/Mover.lua` (design.md section 2)
- [ ] 2.2 `ns.Display` API (design.md section 3)
- [ ] 2.3 Apply saved point and scale at login, falling back to defaults if the saved point is invalid
- [ ] 2.4 Register `/wasd unlock`, `lock`, `scale`, `reset`
- [ ] 2.5 `make check` passes

## 3. In-game checks
- [ ] 3.1 `/wasd unlock` shows the handle; drag; `/wasd lock`; `/reload`; position kept
- [ ] 3.2 Can't drag off screen
- [ ] 3.3 `/wasd scale 1.5` resizes everything evenly; size order and layout unchanged
- [ ] 3.4 `/wasd scale 5` sets 2.0 and says it was limited; `/wasd scale big` shows the allowed range
- [ ] 3.5 In combat: `/wasd scale 1.2` then `/wasd scale 1.3` gives one "will apply after combat" message and applies 1.3 when combat ends; `/wasd unlock` is refused with a message
- [ ] 3.6 `/wasd reset` restores bottom centre at scale 1.0
- [ ] 3.7 No BugSack errors

## 4. Wrap-up
- [ ] 4.1 Merge and archive
