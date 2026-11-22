# Design: Performance recording for Claude Code

## 1. Where the numbers come from
WoW Forever's built-in addon profiler (`C_AddOnProfiler`) is always on and measures every addon. `C_AddOnProfiler.GetAddOnMetric("WASDBars", metric)` returns WASDBars' numbers in milliseconds; `C_AddOnProfiler.GetOverallMetric(metric)` returns the total for all addons. Rather than naming metrics, the recorder reads every entry of `Enum.AddOnProfilerMetric` (`Logic/PerfLog.lua`, `readMetrics`), so the saved rows show whatever this client measures, keyed by name.

Forever (interface 16001) lists: `RecentAverageTime`, `SessionAverageTime`, `EncounterAverageTime`, `LastTime`, `PeakTime`, and `CountTimeOver1Ms`/`5Ms`/`10Ms`/`50Ms`/`100Ms`/`500Ms`/`1000Ms`. The peak and counts are since login, not since the recording started.

First recordings (2026-11-22, Zoolefa in Cat Form): idle 146 s and a 48 s fight (11 s in combat). WASDBars' recent average was 0.0000 ms nearly throughout (max 0.0003 ms) against 0.10–0.15 ms for all addons; session average 0.0005 ms. Its peak of 3.2 ms and 5 frames over 1 ms are since login, most likely building the cluster at login. Frame rate didn't move with WASDBars' numbers.

WASDBars doesn't time its own functions. If the numbers ever point to a problem, Claude Code finds the cause by reading the code and, if needed, asking for a recording with one feature switched off.

## 2. Recorder (`Core/Perf.lua`, limits in `Logic/PerfLog.lua`)
- **Off by default.** Nothing runs until `/wasd perf start`.
- `/wasd perf start <label>`: if `C_AddOnProfiler` doesn't exist, say so and stop. Otherwise start a new session and a 1-second `C_Timer.NewTicker`.
- Each tick saves one row:

  | Field | Source |
  |---|---|
  | `t` | seconds since start |
  | `wasdbars` | every profiler metric for WASDBars, by name |
  | `allRecentAverage` | all addons' `RecentAverageTime` |
  | `fps` | `GetFramerate()` |
  | `combat` | `InCombatLockdown()` |
  | `form` | `GetShapeshiftForm()` |
  | `target` | `UnitExists("target")` |

- `/wasd perf stop`: cancel the ticker, save every metric for WASDBars and for all addons as the summary, and print "WASDBars: Recording '<label>' saved. Type /reload to write it to disk."
- `/wasd perf clear`: empty `WASDBarsPerfDB`.
- Session record:
  ```lua
  { label = "bear-pull", started = "2026-11-22 20:14", seconds = 312,
    addonVersion = "dev build", interface = 16001,
    summary = { wasdbars = { ...session metrics... }, allAddons = { ... } },
    samples = { ...rows... } }
  ```
- Limits: newest 600 samples per session (10 minutes), newest 5 sessions. Older data is dropped.
- Labels are free text; suggested ones are listed in CLAUDE.md (`idle`, `bear-pull`, `form-spam`, `cat-dps`), optionally prefixed `pc-` for recordings made on the Windows PC.

## 3. Where the file is
`<game>/_forever_/WTF/Account/AFOOZLE/SavedVariables/WASDBars.lua`, written on `/reload`, logout or exit. It's plain Lua data (`WASDBarsPerfDB = { ... }`) that Claude Code reads as text. On the Mac the game folder is `/Applications/World of Warcraft/_forever_/` (see `openspec/project.md`). Recordings made on the Windows PC can be copied to the Mac and read the same way.

## 4. CLAUDE.md "Performance" section
- How to ask the player for a recording: "/wasd perf start bear-pull, do the pull, /wasd perf stop, /reload"
- Where the file is (section 3); read it, don't run it
- What good looks like (rough guide, to adjust with experience): WASDBars' recent average stays well under 0.1 ms in combat and is a small share of the all-addons total; no regular peaks above 1 ms; frame rate doesn't dip when WASDBars' numbers rise
- The loop: compare in-combat rows with idle rows, link spikes to what was happening (combat, form change, target), find the likely cause in the code, fix it, run `make check`, ask for the same recording again, and compare
- Keep findings in the commit message so earlier numbers can be compared later

## 5. When to use it
On demand only: when something feels slow, after a change that adds hooks or event handling, and once before a public release. Changes' in-game checklists don't include a recording.
