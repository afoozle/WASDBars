# Tasks: Performance recording for Claude Code

## 1. Verify
- [ ] 1.1 In game: `/dump C_AddOnProfiler ~= nil` and `/dump Enum.AddOnProfilerMetric`; record the metric names in design.md section 1
- [ ] 1.2 Find the account folder under `_forever_/WTF/Account/` on the Mac

## 2. Build
- [ ] 2.1 `Core/Perf.lua` (design.md section 2)
- [ ] 2.2 `/wasd perf start <label>`, `stop`, `clear`
- [ ] 2.3 Add `## SavedVariables: WASDBarsPerfDB` to the TOC and `WASDBarsPerfDB` to `.luacheckrc` globals
- [ ] 2.4 Add the Performance section to CLAUDE.md (design.md section 4)
- [ ] 2.5 `make check` passes

## 3. In-game checks
- [ ] 3.1 Without recording, nothing new runs (no ticker exists)
- [ ] 3.2 `/wasd perf start idle`, wait 2 minutes, `/wasd perf stop`, `/reload`: `WASDBars.lua` in the account's SavedVariables folder contains one session with about 120 rows
- [ ] 3.3 Record `bear-pull`; ask Claude Code to check performance; it finds the file, reads it and summarises what it shows without any numbers being pasted in
- [ ] 3.4 Record 6 sessions: only the newest 5 are kept; a 12-minute session keeps 600 rows
- [ ] 3.5 Copy a recording from the Windows PC to the Mac; Claude Code reads it the same way
- [ ] 3.6 No BugSack errors

## 4. Wrap-up
- [ ] 4.1 Merge and archive
