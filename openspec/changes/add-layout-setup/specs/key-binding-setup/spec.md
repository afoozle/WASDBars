## REMOVED Requirements

### Requirement: Confirmed setup
**Reason:** Keybinds are no longer a separate step with their own window and `/wasd setup keys` command; they are the Keys part of the one setup window, so the player sees and confirms keys and layout together.
**Migration:** See "Keybinds in the setup window". `/wasd setup` lists only the keys still off.

### Requirement: Action bar 2 not changed by keybind setup
**Reason:** Setup now turns Action Bar 2 on itself (`edit-mode-setup` "Action Bar 2 turned on").
**Migration:** None needed; the reminder to turn on Action Bar 2 goes.

## ADDED Requirements

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
- **THEN** no second window opens

### Requirement: Key copy for restore
The first time setup changes any of the 24 keys, the addon SHALL save, account-wide, what each of the 24 keys was bound to before (or that it was unbound), so `/wasd restore` can put them back. A later setup SHALL NOT replace that copy while it exists; a restore that puts the keys back SHALL clear it.

#### Scenario: Second character
- **WHEN** a second character on the same account-wide keybinds runs setup and its keys are already set up
- **THEN** the saved copy still holds the keys from before the first setup

#### Scenario: Unbound key
- **WHEN** T was unbound before setup and the player restores the keybinds
- **THEN** T is unbound again
