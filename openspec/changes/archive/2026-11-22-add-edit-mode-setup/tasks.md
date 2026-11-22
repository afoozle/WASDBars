# Tasks: First-time setup and Edit Mode layout check

## 1. Logic and tests
- [x] 1.1 `Logic/LayoutCheck.lua` with `problems`, `overlaps`, `statusLine` (design.md section 1)
- [x] 1.2 `layout_check_spec.lua`: good layout has no fixes; each failing setting gives its fix in order; action bar 2 off; unknown readings skipped; overlap and touching rects; status lines

## 2. UI and commands
- [x] 2.1 Readings, `checkLayout`, `layoutStatus`, `run` and the once-per-character offer (design.md sections 2 and 3); `setupOffered` default
- [x] 2.2 Options page with Run setup (design.md section 4)
- [x] 2.3 `/wasd setup`, `/wasd setup layout`, status line
- [x] 2.4 `make check` passes

## 3. In-game checks
- [x] 3.1 Zoolefa: no offer at login (keys set up); `/wasd setup status` shows both key groups and the layout line; `/wasd setup layout` lists only real problems
- [x] 3.2 Not run in game (layout reported OK); the failing-check lines are unit tested and moved to `polish-look-and-messages` for a look in game
- [x] 3.3 Options → AddOns → WASDBars shows the page; Run setup says the keys are already set up and shows the layout check
- [x] 3.4 Rogue alt: the offer appears once; Set up runs the key popups and the layout check; not offered again after `/reload`. First try recorded the character as "Deutscheb-" (realm name not ready at login); fixed to the character GUID. Popup and chat wording judged rubbish; noted in `polish-look-and-messages`
- [x] 3.5 No BugSack errors

## 4. Wrap-up
- [ ] 4.1 Merge and archive
