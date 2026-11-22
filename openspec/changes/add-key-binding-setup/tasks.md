# Tasks: Key binding setup

## 1. Data, logic and tests
- [x] 1.1 `Data/BindingGroups.lua` (design.md section 1)
- [x] 1.2 `Logic/BindingPlan.lua` with `build` and `statusLine` (design.md section 2)
- [x] 1.3 `binding_plan_spec.lua`: fresh setup lists every key with its current and new command; already-applied group has no changes; partial setup counts correct keys and leaves them out; unbound keys show no current command; status lines
- [x] 1.4 `binding_groups_spec.lua`: no key appears twice across both groups; WASD group covers `ACTIONBUTTON1`–`12` in order; numbers group covers `MULTIACTIONBAR1BUTTON1`–`12` in order

## 2. UI and commands
- [x] 2.1 `UI/Bindings.lua` popup, apply and save, action bar 2 reminder, `request`, `requestAll`, `status` (design.md section 3)
- [x] 2.2 `/wasd setup keys` and `/wasd setup status`
- [x] 2.3 `make check` passes

## 3. In-game checks
- [ ] 3.1 `/wasd setup status` reports the current state; `/wasd setup keys` WASD popup lists the changes; Cancel changes nothing and the number row popup follows
- [ ] 3.2 Confirm both: the cluster's key labels match the keys; 1–0, `-`, `=` fire action bar 2
- [ ] 3.3 After `/reload`, `/wasd setup status` says both are set up and `/wasd setup keys` says they're already set up
- [ ] 3.4 One-off spell move (design.md section 5)
- [ ] 3.5 No BugSack errors

## 4. Wrap-up
- [ ] 4.1 Merge and archive
