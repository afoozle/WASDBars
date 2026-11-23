## MODIFIED Requirements

### Requirement: Dev build version
The addon SHALL report the packaged version without the leading `v`, and SHALL report itself as a dev build when run from a git checkout (the TOC version not replaced by the packager).

#### Scenario: Version
- **WHEN** the player types `/wasd version` with the addon linked from a git checkout
- **THEN** chat shows "WASDBars: Dev build."

### Requirement: Mac development setup
The project SHALL provide one setup command for the MacBook that installs a pinned StyLua and a project-local Lua 5.1 with luacheck and busted, without depending on the system or Homebrew Lua version. The StyLua version SHALL be set in one file, `.stylua-version`, which CI uses too.

#### Scenario: Fresh Mac
- **WHEN** `make setup` is run on a Mac with Homebrew, Python 3 and a C compiler
- **THEN** `make check` runs, using the StyLua version in `.stylua-version`

#### Scenario: Missing prerequisite
- **WHEN** Homebrew, Python 3 or a C compiler is missing
- **THEN** setup stops with a message saying what to install

#### Scenario: StyLua version changed
- **WHEN** `.stylua-version` is changed and `make setup` is run
- **THEN** `make format` and `make format-check` use the new version, as does CI

### Requirement: Combat-safe deferral
The addon SHALL provide a single queue for work that can't happen in combat. Work requested out of combat SHALL run immediately. Work requested in combat SHALL run, in order, as soon as combat ends, and the player SHALL see one "WASDBars: Will apply after combat." message per combat, not one per request. Work is named, and a newer request with the same name SHALL replace the waiting one.

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
The addon SHALL register `/wasd` with `help`, `version` and `debug` subcommands, alongside the commands of the other capabilities. `debug` SHALL turn extra chat output on or off for the current session.

#### Scenario: Help
- **WHEN** the player types `/wasd help`
- **THEN** chat lists every available subcommand with a one-line description

#### Scenario: Unknown subcommand
- **WHEN** the player types `/wasd nonsense`
- **THEN** chat says the command wasn't recognised and shows the help list
