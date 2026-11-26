## REMOVED Requirements

### Requirement: Record the built-in profiler's numbers
**Reason:** Replaced by "Recording the profiler's numbers", which drops the "Profiler not available" scenario: WoW Forever always has the profiler.
**Migration:** None.

## ADDED Requirements

### Requirement: Recording the profiler's numbers
`/wasd perf start <label>`, `/wasd perf stop` and `/wasd perf clear` SHALL start, stop and delete recordings of WoW Forever's built-in addon profiler. Each second of a recording SHALL save every profiler metric for WASDBars, all addons' recent average, frame rate, combat state, form and whether there is a target; stopping SHALL save the session-level numbers and remind the player to `/reload`. The addon SHALL NOT time its own functions.

#### Scenario: Recording a session
- **WHEN** the player types `/wasd perf start bear-pull`, tanks a pull, types `/wasd perf stop` and reloads
- **THEN** the account's `WASDBars.lua` SavedVariables file contains a session labelled `bear-pull` with per-second rows and a summary
