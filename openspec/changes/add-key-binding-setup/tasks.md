# Tasks: Key binding setup

## 1. Data, logic and tests
- [ ] 1.1 `Data/BindingGroups.lua` (design.md section 1); set mouse button names from the layout change's in-game checks
- [ ] 1.2 `Logic/BindingPlan.lua` with `build` and `status` (design.md section 2)
- [ ] 1.3 `binding_plan_spec.lua`: fresh setup lists every key with its current and new binding names; already-applied group has no changes; partial setup counts correct keys; keys already correct are left out; unbound keys show no current name
- [ ] 1.4 `binding_groups_spec.lua`: no key appears twice across both groups; WASD group covers `ACTIONBUTTON1`–`12` once each; numbers group covers `MULTIACTIONBAR1BUTTON1`–`10` once each

## 2. UI and commands
- [ ] 2.1 `UI/BindingConfirm.lua` popup, apply and save (design.md section 3)
- [ ] 2.2 Action bar 2 reminder
- [ ] 2.3 `ns.Bindings.status` and `ns.Bindings.request`
- [ ] 2.4 Register `/wasd setup keys` and `/wasd setup status`
- [ ] 2.5 `make check` passes

## 3. In-game checks
- [ ] 3.1 `/wasd setup status` reports the current state correctly before any changes
- [ ] 3.2 `/wasd setup keys`: the WASD popup lists every key and what it's bound to now; Cancel changes nothing
- [ ] 3.3 Confirm: Q, E, R, T, F, G, Z, X, C, V and both mouse side buttons use action bar 1 in every form; cluster labels update
- [ ] 3.4 The number row popup follows; Confirm: 1–0 use action bar 2 in every form
- [ ] 3.5 Both survive `/reload` and a full relog
- [ ] 3.6 Running either again says it's already set up
- [ ] 3.7 In combat: the request waits and the popup appears when combat ends
- [ ] 3.8 With action bar 2 turned off, the reminder appears and the bar is not turned on automatically
- [ ] 3.9 No BugSack errors

## 4. Wrap-up
- [ ] 4.1 Merge and archive
