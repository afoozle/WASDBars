# performance-recording Specification

## Purpose

On-demand recordings of the game's built-in addon profiler numbers for WASDBars (`/wasd perf`), saved where Claude Code can read them, so performance can be checked without the player copying numbers across.

## Requirements

### Requirement: No cost when not recording
Recording SHALL be off by default, and no timer or extra work SHALL run until the player starts a recording.

#### Scenario: Not recording
- **WHEN** no recording has been started
- **THEN** no recording timer exists

### Requirement: Small saved data
Saved recordings SHALL be limited to the 5 most recent sessions and the newest 600 rows (10 minutes) per session.

#### Scenario: Long session
- **WHEN** a recording runs for 12 minutes
- **THEN** the session keeps the newest 600 rows

#### Scenario: Many sessions
- **WHEN** a 6th session is recorded
- **THEN** the oldest session is removed

### Requirement: Claude Code reads recordings directly
`CLAUDE.md` SHALL tell Claude Code where the recording file is, what it contains, a rough guide to what good numbers look like, and how to use a recording to find and fix a problem and then ask for another recording, so the player never has to copy numbers across.

#### Scenario: Checking performance
- **WHEN** the player records a session, reloads and asks Claude Code to check performance
- **THEN** Claude Code reads the file from the game folder and reports what it shows, with no numbers pasted in by the player

### Requirement: Recording the profiler's numbers
`/wasd perf start <label>`, `/wasd perf stop` and `/wasd perf clear` SHALL start, stop and delete recordings of WoW Forever's built-in addon profiler. Each second of a recording SHALL save every profiler metric for WASDBars, all addons' recent average, frame rate, combat state, form and whether there is a target; stopping SHALL save the session-level numbers and remind the player to `/reload`. The addon SHALL NOT time its own functions.

#### Scenario: Recording a session
- **WHEN** the player types `/wasd perf start bear-pull`, tanks a pull, types `/wasd perf stop` and reloads
- **THEN** the account's `WASDBars.lua` SavedVariables file contains a session labelled `bear-pull` with per-second rows and a summary
