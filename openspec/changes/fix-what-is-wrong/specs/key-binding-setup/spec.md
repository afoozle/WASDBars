## MODIFIED Requirements

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
