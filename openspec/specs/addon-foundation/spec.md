# addon-foundation Specification

## Purpose

The groundwork every WASDBars feature builds on: the standard addon repository layout, Mac dev tooling (lint, formatting, unit tests), testable logic modules, saved settings, a combat-safe work queue, the `/wasd` slash command and guidance for Claude Code.

## Requirements

### Requirement: Standard addon repository layout
The project SHALL use the standard WoW addon repository layout: the repo root is the addon folder, with `WASDBars.toc` at the root. Development files (tests, scripts, specs, tooling config) SHALL live alongside the addon files and SHALL NOT be listed in the TOC.

#### Scenario: Linked into the game
- **WHEN** the repo is symlinked into the Mac's AddOns folder as `WASDBars`
- **THEN** the game lists WASDBars as a Forever addon, not out of date, and loads only the files in the TOC
- **AND** edits in the repo show up in game after `/reload`

### Requirement: Dev build version
Until a packager exists, the addon SHALL report itself as a dev build.

#### Scenario: Version
- **WHEN** the player types `/wasd version`
- **THEN** chat shows "dev build"

### Requirement: Mac development setup
The project SHALL provide one setup command for the MacBook that installs StyLua and a project-local Lua 5.1 with luacheck and busted, without depending on the system or Homebrew Lua version.

#### Scenario: Fresh Mac
- **WHEN** `make setup` is run on a Mac with Homebrew and Python 3
- **THEN** `make check` runs

#### Scenario: Missing prerequisite
- **WHEN** Homebrew or Python 3 is missing
- **THEN** setup stops with a message saying what to install

### Requirement: Linting, formatting and unit tests
The project SHALL provide one command that runs linting (luacheck), a formatting check (StyLua) and unit tests (busted).

#### Scenario: All checks pass
- **WHEN** `make check` is run on a clean checkout
- **THEN** luacheck reports zero warnings, StyLua reports no formatting changes, and all unit tests pass

#### Scenario: Accidental global
- **WHEN** an addon file assigns to an undeclared global variable
- **THEN** `make lint` fails and names the file and line

### Requirement: Testable logic modules
Logic that doesn't need the game SHALL live in `Logic/` as functions that receive any game functions they need as arguments and make no game calls when the file loads. The test harness SHALL load these files the same way the game does (with the addon name and a shared namespace table).

#### Scenario: Loading a logic file in tests
- **WHEN** a test loads `Logic/Settings.lua` through the test helper
- **THEN** `ns.Settings` is available and no WoW globals were needed

### Requirement: Addon loads cleanly
The addon SHALL load in WoW Forever with no errors, create its account-wide saved settings filled with defaults, and keep any values the player already saved.

#### Scenario: First login
- **WHEN** a character logs in with the addon installed for the first time
- **THEN** no Lua errors occur
- **AND** `WASDBarsDB` exists with every default value

#### Scenario: Existing settings kept
- **WHEN** a saved setting differs from its default and the player reloads
- **THEN** the saved value is kept and any newly added defaults are filled in

#### Scenario: Shared across characters
- **WHEN** a setting is changed on one character and the player logs in on another on the same machine
- **THEN** the second character sees the changed value

### Requirement: Combat-safe deferral
The addon SHALL provide a single queue for work that can't happen in combat. Work requested out of combat SHALL run immediately. Work requested in combat SHALL run, in order, as soon as combat ends, and the player SHALL see one "WASDBars: will apply after combat." message per combat, not one per request. Work is named, and a newer request with the same name SHALL replace the waiting one.

#### Scenario: Out of combat
- **WHEN** work is queued while not in combat
- **THEN** it runs immediately and no message is shown

#### Scenario: In combat
- **WHEN** three different pieces of work are queued during one combat
- **THEN** one message is shown
- **AND** all three run in the order requested when combat ends

#### Scenario: Same work requested twice
- **WHEN** the scale is changed to 1.2 and then 1.3 during one combat
- **THEN** only the 1.3 change runs when combat ends

### Requirement: Slash command
The addon SHALL register `/wasd` with `help`, `version` and `debug` subcommands, and SHALL let later features add subcommands without editing the slash command file. `debug` SHALL turn extra chat output on or off for the current session.

#### Scenario: Help
- **WHEN** the player types `/wasd help`
- **THEN** chat lists every available subcommand with a one-line description

#### Scenario: Unknown subcommand
- **WHEN** the player types `/wasd nonsense`
- **THEN** chat says the command wasn't recognised and shows the help list

### Requirement: Guidance for Claude Code
The repo SHALL include a `CLAUDE.md` that points to the OpenSpec project context and roadmap and lists the make targets, the core coding rules, and where to read in-game results.

#### Scenario: Starting a session
- **WHEN** Claude Code opens the repo
- **THEN** `CLAUDE.md` tells it to read `openspec/project.md`, which change is next, and how to run the checks
