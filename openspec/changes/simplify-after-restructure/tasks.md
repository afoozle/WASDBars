# Tasks: Simplify after restructure

## 1. Review
- [x] 1.1 Grill: how the review is run and decided
  - A fresh agent reviews; Claude checks each finding, fixes the clear ones in small commits, and asks the player only about findings that change behaviour or remove a safety check
  - Weighted towards cutting code: about 3,160 lines after the restructure is too many for this addon
  - Remove guards for game parts that always exist on WoW Forever 16001 (a visible error beats a quiet failure); keep LibEditModeOverride's ready check (timing)
  - Remove the v1.0.0 `setUp` cleanup; keep the v1.1.0 key copy migration until at least the next minor release
  - Files may name the logic and data modules they use once at the top (`local KeybindPlan = ns.KeybindPlan`); the TOC lists every logic and data file before any game file; game files still reach other game files through `ns` inside functions
- [ ] 1.2 Review and fixes
  - Second review, aiming under 1,800 executable lines: the performance recorder and `/wasd setup status` are removed; one `refuseLayoutChange` for setup and restore (with Edit Mode open and nothing to restore, `/wasd restore` now says to close Edit Mode); `/wasd setup` with the window open fills it again
  - At archive: delete `openspec/specs/performance-recording/` (every requirement removed) and drop "checked with `/wasd setup status`" from key-binding-setup's Purpose
- [ ] 1.3 `max_cyclomatic_complexity = 10` in `.luacheckrc`; `make check` passes

## 2. In game (all three changes at once)
- [ ] 2.1 Full test list shown up front, covering the three changes. Include: the W, A, S and D keys look like the cluster's empty slots (now drawn with the no-bar-art button style), and buttons stay in the cluster through Edit Mode edits (the stray-button check is gone); `/wasd setup` with the window open refreshes it; the setup window's lines are laid out as before; large and game hotkey text both still look right; `/wasd restore` with Edit Mode open says to close it; the options page's headings and buttons still work
- [ ] 2.2 Re-run only checks that failed

## 3. Finish
- [ ] 3.1 Merge `deep-clean`; archive the three changes; CHANGELOG and release v1.1.1
