# Proposal: Restructure into features

## Why
The code is organised by layer (`Logic/`, `Data/`, `UI/`), the game calls are scattered through the UI files so most of the risky code has no tests, and names read backwards or hide what they do. The player wants a plain structure that reads well, with the logic testable without a running game.

## What Changes
Behaviour stays the same. The structure and names change:
- **Folders by feature**, not by layer; `tests/` mirrors them
- **Logic files and game files.** Decisions live in logic files of plain functions: data in, data out, no game calls, all tested by busted. Game files call WoW directly, stay thin, and are checked in-game. No dependency injection and no test fakes of the game. One startup file connects game events
- **Naming rules**, written into `CLAUDE.md`:
  - files and modules are nouns naming what they own (`EditModeLayouts`, `Keybinds`)
  - functions start with the verb and name the purpose, not details that may change (`repositionActionBarCluster()`)
  - no boolean parameters that switch what a function does: two functions instead
  - variables are full words saying what the thing is
  - no functions declared inside functions
  - no tables holding rules: small named functions called in order; plain data tables are fine
- Tests for what's untested today, including `lostActions` across both key groups and the layout steps nothing covers
- `CLAUDE.md` and `openspec/project.md` describe the new structure

**Design first:** `design.md` lists each feature folder and its files, every public function (name, purpose, parameters), which files are logic and which talk to the game, the startup order, the test file for each logic file and where every piece of today's code ends up. Claude writes it; a fresh agent checks it against the rules; the player reviews it before any code.

## Depends on
`fix-what-is-wrong`

## Impact
Every addon file, every test, the TOC, `.luacheckrc`, `CLAUDE.md`, `openspec/project.md`, and file references in the specs.
