# key-binding-setup

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

### Requirement: Binding status
`/wasd setup status` SHALL report the keybinds in one sentence: set up, or per group set up, partly set up (with how many keys are correct) or not set up.

#### Scenario: Partial
- **WHEN** the WASD keys are set up, 7 of the 12 number row keys are bound to action bar 2, and the player types `/wasd setup status`
- **THEN** chat starts "WASDBars: Keybinds: WASD keys set up, number row 7 of 12 set up."
