# Tasks: Edit Mode setup and first-time setup

## 1. Feasibility check
- [ ] 1.1 Throwaway test (design.md section 1); capture a layout table from `C_EditMode.GetLayouts()` for unit tests
- [ ] 1.2 Record the findings at the top of design.md; pass → section 2, fail → manual-steps fallback only

## 2. Logic and tests
- [ ] 2.1 `Logic/EditModeLayout.lua`: find the action bar systems, build the "WASDBars" copy, check whether it's applied
- [ ] 2.2 Unit tests using the captured layout table: copy keeps the player's other settings; only Action Bar 1 art/scrolling/always-show/icon-count and Action Bar 2 position change; preset layouts are never chosen for writing; status detects applied / not applied

## 3. UI and commands
- [ ] 3.1 `ns.EditModeSetup.status` / `request` with the confirmation popup (design.md section 2)
- [ ] 3.2 First-time setup offer and the keys → numbers → layout chain (design.md section 3); `setupOffered` default
- [ ] 3.3 `/wasd setup`, `/wasd setup layout`; extend `/wasd setup status`
- [ ] 3.4 Default cluster position sits above action bar 2 in its new spot
- [ ] 3.5 `make check` passes

## 4. In-game checks
- [ ] 4.1 Reset first: clear `setupOffered`, switch Edit Mode back to a preset layout
- [ ] 4.2 First login offer appears; "Not now" changes nothing and isn't offered again after `/reload`
- [ ] 4.3 `/wasd setup`: keys popup, number row popup, then Edit Mode popup, in order; Cancel on any step changes nothing for that step
- [ ] 4.4 Confirm the layout step: "WASDBars" layout active, main bar art and page arrows gone, action bar 2 in action bar 1's old spot, cluster above it; survives `/reload` and relog
- [ ] 4.5 The game's preset layouts are unchanged
- [ ] 4.6 Running `/wasd setup layout` again says it's already set up; `/wasd setup status` is correct
- [ ] 4.7 In combat: the request waits and the popup appears when combat ends
- [ ] 4.8 Enter combat and open Edit Mode afterwards: no BugSack errors or blocked actions

## 5. Wrap-up
- [ ] 5.1 Merge and archive
