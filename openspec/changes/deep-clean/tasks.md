# Tasks: Deep clean

## 1. Review
- [x] 1.1 Grill (2026-11-27)
- [ ] 1.2 Four fresh agents in parallel: code and tests; docs and specs; tooling; structure (complexity, `ns` dependency cycles, pragmatic SOLID)
- [ ] 1.3 Verify every finding against the code; write them to `findings.md`, numbered and grouped by area, each with what's wrong, `file:line`, the fix (before/after code for code changes) and a blank `Decision:` line
- [ ] 1.4 Player fills in the decisions; ask about any left blank

## 2. Fix
- [ ] 2.1 `.luacheckrc`: `max_cyclomatic_complexity = 10`; refactor `BindingPlan.lostActions`, `LayoutPlan.actions` and Setup's `apply` under it
- [ ] 2.2 `Logic/` refactors: fill test gaps first against the old code, then refactor; tests pass unedited (an edited test is flagged to the player as a behaviour change)
- [ ] 2.3 Fix the other accepted findings; `UI/` behaviour unchanged unless the finding says so
- [ ] 2.4 `add-curseforge-publishing`: replace the stale `v1.1.0-beta.1` example
- [ ] 2.5 Spec deltas for corrected capability specs; `openspec validate deep-clean` passes; `make check` passes

## 3. In game (once, at the end)
- [ ] 3.1 Full test list shown up front: the smallest set covering each changed code path; setup and restore on Deutscheb if touched
- [ ] 3.2 Re-run only checks that failed

## 4. Finish
- [ ] 4.1 Merge, archive, release v1.1.1
