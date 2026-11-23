## MODIFIED Requirements

### Requirement: Confirmed setup
Setting up keybinds SHALL first show one window describing each group still to be set up ("Action bar 1 on the keys around WASD", "Action bar 2 on the number row") and listing every action that would be left with no key at all, with the keys that did it. It SHALL change nothing unless the player confirms. Confirmed binds SHALL be saved to the binding set the character already uses (account-wide or character-specific), so they persist across reloads and logins.

#### Scenario: Confirm
- **WHEN** the player types `/wasd setup keys` and clicks Confirm in the keybind window
- **THEN** Q, E, R, T, F, G, Z, X, C, V and both mouse side buttons use action bar 1, and 1–0, - and = use action bar 2
- **AND** they still do after `/reload` and after logging out and back in

#### Scenario: Cancel
- **WHEN** the player clicks Cancel, the close button, or presses Escape
- **THEN** no keybinds change

#### Scenario: Showing what gets replaced
- **WHEN** R is bound to Chat Reply, no other key is, and the player opens the keybind window
- **THEN** the window lists "Chat Reply (R)" under the actions that will no longer have a key

#### Scenario: Not warning about actions still bound
- **WHEN** Q is bound to Turn Left and A is too
- **THEN** Turn Left isn't listed as losing its key

#### Scenario: Already set up
- **WHEN** every key in both groups is already correct
- **THEN** chat says "WASDBars: Keybinds are already set up." and no window is shown

#### Scenario: In combat
- **WHEN** the player requests the keybinds during combat
- **THEN** chat shows "WASDBars: Will apply after combat." and the window appears when combat ends

#### Scenario: Replacing another addon's or the game's bind
- **WHEN** 1 is bound to a shapeshift form and the player confirms
- **THEN** 1 fires action bar 2's first button and the form bind is gone

#### Scenario: Confirming in combat
- **WHEN** the player clicks Confirm during combat and then types `/wasd setup` before combat ends
- **THEN** the confirmed binds are applied when combat ends, and the setup then reports the keybinds already set up

#### Scenario: Window already open
- **WHEN** the keybind window is open and the player types `/wasd setup`
- **THEN** no second window opens, and the layout check runs once the window closes


### Requirement: Action bar 2 not changed by keybind setup
The keybind setup SHALL NOT draw, move, show or hide action bar 2 (the `edit-mode-setup` layout check lists any manual Edit Mode fixes). If the number row is set up while action bar 2 is turned off, the addon SHALL remind the player to turn it on in Edit Mode.

#### Scenario: Bar turned off
- **WHEN** the number row is confirmed while action bar 2 is turned off
- **THEN** chat shows a reminder to turn on action bar 2
- **AND** the addon does not turn it on
