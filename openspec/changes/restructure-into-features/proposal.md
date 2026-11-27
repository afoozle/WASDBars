# Proposal: Restructure into features

## Why
The code is organised by layer (`Logic/`, `Data/`, `UI/`), the game calls are scattered through the UI files so most of the risky code has no tests, and names read backwards or hide what they do. The player wants ordinary object-oriented structure that reads plainly and tests without a running game.

## What Changes
Behaviour stays the same. The structure and names change:
- **Folders by feature**, not by layer; `tests/` mirrors them
- **Each feature is an object** created with constructor injection of every game part it uses, functions and frames alike. Nothing in a feature reaches for a WoW global; tests build it with fakes. One wiring file creates every object with the real game parts, in load order
- **Naming rules**, written into `CLAUDE.md`:
  - objects are nouns naming what they own (`EditModeLayouts`, `Keybinds`)
  - methods start with the verb and name the purpose, not details that may change (`repositionActionBarCluster()`)
  - no boolean parameters that switch what a function does: two functions instead
  - variables are full words saying what the thing is
  - no functions declared inside functions
  - no tables holding rules: small named functions called in order; plain data tables are fine
- Tests for what's untested today, including `lostActions` across both key groups and the layout steps nothing covers
- `CLAUDE.md` and `openspec/project.md` describe the new structure

**Design first:** `design.md` lists each feature folder and its object, every public method (name, purpose, parameters), the game parts each object is built with, the wiring order, the test file for each object and where every piece of today's code ends up. Claude writes it; a fresh agent checks it against the rules; the player reviews it before any code.

## Depends on
`fix-what-is-wrong`

## Impact
Every addon file, every test, the TOC, `.luacheckrc`, `CLAUDE.md`, `openspec/project.md`, and file references in the specs.
