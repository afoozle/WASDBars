# key-binding-setup Specification

## Purpose

The keybinds that match the WASD cluster and action bar 2: two groups (WASD keys and the number row), set up as the Keys part of the setup window, saved per binding set for `/wasd restore`, and never changed without the player confirming.

## Requirements

### Requirement: Binding groups
The addon SHALL define two binding groups: "WASD keys" (Q, E, R, T, F, G, Z, X, C, V to Action Buttons 1–10, front mouse side button to Action Button 11, back to Action Button 12) and "Number row" (1–9, 0, - and = to action bar 2 buttons 1–12). These SHALL be the only keybinds the addon ever changes.

#### Scenario: Groups don't overlap
- **WHEN** both groups are applied
- **THEN** no key is bound by both, and every listed command has exactly one of the listed keys

### Requirement: Spells are never moved
The keybind setup SHALL NOT pick up, place or swap anything on the action bars.

#### Scenario: Spells stay in their slots
- **WHEN** the player confirms the WASD keys
- **THEN** every action slot holds what it held before

### Requirement: Keybinds in the setup window
The setup window's Keys heading SHALL describe each binding group still to be set up and list every action that would be left with no key at all, with the keys that did it. Keybinds SHALL change only when the player clicks Set up, and SHALL be saved to the binding set the character already uses (account-wide or character-specific).

#### Scenario: Confirm
- **WHEN** the player types `/wasd setup` and clicks Set up
- **THEN** Q, E, R, T, F, G, Z, X, C, V and both mouse side buttons use action bar 1, and 1–0, - and = use action bar 2
- **AND** they still do after `/reload` and after logging out and back in

#### Scenario: Not now
- **WHEN** the player clicks Not now, the close button, or presses Escape
- **THEN** no keybinds change

#### Scenario: Showing what gets replaced
- **WHEN** R is bound to Chat Reply, no other key is, and the player opens the setup window
- **THEN** the window lists "Chat Reply (R)" under the actions that will no longer have a key

#### Scenario: Not warning about actions still bound
- **WHEN** Q is bound to Turn Left and A is too
- **THEN** Turn Left isn't listed as losing its key

#### Scenario: Keys already set up
- **WHEN** every key in both groups is already correct
- **THEN** the setup window has no Keys heading

#### Scenario: Replacing another addon's or the game's bind
- **WHEN** 1 is bound to a shapeshift form and the player confirms
- **THEN** 1 fires action bar 2's first button and the form bind is gone

#### Scenario: Window already open
- **WHEN** the setup window is open and the player types `/wasd setup`
- **THEN** no second window opens; the open one is filled again with the changes still needed

### Requirement: Key copy for restore
The first time setup changes any of the 24 keys, the addon SHALL save what each of the 24 keys was bound to before (or that it was unbound), so `/wasd restore` can put them back. Characters on the account's keybinds SHALL share one copy; a character on its own (character-specific) keybinds SHALL have its own. A later setup SHALL NOT replace a copy while it exists; a restore that puts the keys back SHALL clear only the copy it used.

#### Scenario: Second character
- **WHEN** a second character on the same account-wide keybinds runs setup and its keys are already set up
- **THEN** the saved copy still holds the keys from before the first setup

#### Scenario: Character keybinds
- **WHEN** one character on the account's keybinds and another on its own keybinds have both set up, and the second restores its keybinds
- **THEN** the second character's keys go back to what they were before its own setup, and the account copy is kept

#### Scenario: Unbound key
- **WHEN** T was unbound before setup and the player restores the keybinds
- **THEN** T is unbound again
