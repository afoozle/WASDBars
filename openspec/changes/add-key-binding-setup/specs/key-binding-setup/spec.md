# key-binding-setup

## ADDED Requirements

### Requirement: Binding groups
The addon SHALL define two binding groups: "WASD keys" (Q, E, R, T, F, G, Z, X, C, V to Action Buttons 1–10, front mouse side button to Action Button 11, back to Action Button 12) and "Number row" (1–9 and 0 to action bar 2 buttons 1–10). These SHALL be the only keybinds the addon ever changes.

#### Scenario: Groups don't overlap
- **WHEN** both groups are applied
- **THEN** no key is bound by both, and every listed command has exactly one of the listed keys

### Requirement: Confirmed setup
Applying a group SHALL first show the player every key in the group and what it is currently bound to, and SHALL change nothing unless the player confirms. Confirmed binds SHALL be saved so they persist across reloads and logins.

#### Scenario: Confirm
- **WHEN** the player types `/wasd setup keys` and clicks Confirm on the WASD keys popup
- **THEN** Q, E, R, T, F, G, Z, X, C, V and both mouse side buttons use action bar 1
- **AND** they still do after `/reload` and after logging out and back in

#### Scenario: Cancel
- **WHEN** the player clicks Cancel on the number row popup
- **THEN** no keybinds change

#### Scenario: Showing what gets replaced
- **WHEN** Q is bound to strafe left and the player requests the WASD group
- **THEN** the confirmation shows Q's current binding and its new one before anything changes

#### Scenario: Already set up
- **WHEN** the player requests a group whose keys are all already correct
- **THEN** chat says it's already set up and no popup is shown

#### Scenario: In combat
- **WHEN** the player requests a group during combat
- **THEN** chat shows "WASDBars: will apply after combat." and the confirmation appears when combat ends

### Requirement: Binding status
The addon SHALL report, per group, whether it is fully set up, partly set up (with how many keys are correct), or not set up.

#### Scenario: Partial
- **WHEN** 7 of the 10 number keys are bound to action bar 2 and the player types `/wasd setup status`
- **THEN** chat shows "Number row: 7 of 10 set up"

### Requirement: Action bar 2 not changed by keybind setup
The keybind setup SHALL NOT draw, move, show or hide action bar 2 (arranging it belongs to `add-edit-mode-setup`). If the number row is set up while action bar 2 is turned off, the addon SHALL remind the player to turn it on in the game's interface options.

#### Scenario: Bar turned off
- **WHEN** the number row is confirmed while action bar 2 is turned off
- **THEN** chat shows a reminder to turn on action bar 2
- **AND** the addon does not turn it on
