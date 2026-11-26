# Tasks: Performance recording for Claude Code

## 1. Build
- [x] 1.1 `Logic/PerfLog.lua` (sample and session limits, read every metric) with `perf_log_spec.lua`
- [x] 1.2 `Core/Perf.lua` (design.md section 2); `ns.addonVersion` shared with `/wasd version`
- [x] 1.3 `/wasd perf start <label>`, `stop`, `clear`
- [x] 1.4 `## SavedVariables: WASDBarsPerfDB` in the TOC, `WASDBarsPerfDB` in `.luacheckrc` globals
- [x] 1.5 Performance section in CLAUDE.md (design.md section 4)
- [x] 1.6 `make check` passes

## 2. In-game checks
- [x] 2.1 `/wasd perf start idle`, wait about 2 minutes, `/wasd perf stop`, `/reload`: one session with about 120 rows; record the metric names this client lists in design.md section 1
- [x] 2.2 Record a short fight; Claude Code reads the file and summarises it with nothing pasted in
- [x] 2.3 No BugSack errors

## 3. Wrap-up
- [ ] 3.1 Merge and archive
