# Tasks: Spike — can we take over the game's action buttons?

## 1. Build (Claude Code)
- [x] 1.1 Write `spike/WASDBarsSpike/` (design.md sections 1–3)
- [x] 1.2 Link it into the Mac's AddOns folder

## 2. Play (on the Mac)
- [x] 2.1 Once: `/console taintLog 1`; make sure BugGrabber and BugSack are enabled
- [x] 2.2 Log in on the druid: buttons 1–10 sit in a rough WASD shape; no BugSack errors
- [x] 2.3 Caster → Bear → Cat → Prowl → caster, out of combat, then in combat: buttons stay put and show each form's abilities
- [x] 2.4 Feedback on moved buttons: a cooldown swipe, rage colouring (Maul blue at low rage), red when out of range, the Maul highlight while queued, tooltips
- [x] 2.5 Pressing the bound keys uses the right actions
- [x] 2.6 Drag and drop: drop a spell on a moved button in Bear (only the Bear bar changes), swap two, drag one off
- [x] 2.7 `/reload`, zone, mount, change bar page, open and close the game's options and Edit Mode (if it has one): buttons stay put or come back (mount not tested: no mount yet)
- [x] 2.8 Log in on a class without forms: buttons behave normally
- [x] 2.9 `/spike dump`, then `/reload`

## 3. Read and decide (Claude Code)
- [x] 3.1 Read the spike's SavedVariables, BugGrabber's saved errors and the taint log
- [x] 3.2 Fill in Findings in design.md and make the pass/fail call with the player
- [ ] 3.3 Pass: simplify the later changes using the findings (carried forward: done before `setup-addon-foundation` starts). Fail: stop and rethink
- [x] 3.4 Unlink and delete `spike/`, archive this change
