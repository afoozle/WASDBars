# key-binding-setup Specification

## Purpose

The keybinds that match the WASD cluster and action bar 2: two confirmed groups (WASD keys and the number row), set up with `/wasd setup keys`, checked with `/wasd setup status`, and never changed without the player confirming.

## Requirements

### Requirement: Binding groups
The addon SHALL define two binding groups: "WASD keys" (Q, E, R, T, F, G, Z, X, C, V to Action Buttons 1–10, front mouse side button to Action Button 11, back to Action Button 12) and "Number row" (1–9, 0, - and = to action bar 2 buttons 1–12). These SHALL be the only keybinds the addon ever changes.

#### Scenario: Groups don't overlap
- **WHEN** both groups are applied
- **THEN** no key is bound by both, and every listed command has exactly one of the listed keys

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

### Requirement: Spells are never moved
The keybind setup SHALL NOT pick up, place or swap anything on the action bars.

#### Scenario: Spells stay in their slots
- **WHEN** the player confirms the WASD keys
- **THEN** every action slot holds what it held before

### Requirement: Binding status
`/wasd setup status` SHALL report the keybinds in one sentence: set up, or per group set up, partly set up (with how many keys are correct) or not set up.

#### Scenario: Partial
- **WHEN** the WASD keys are set up, 7 of the 12 number row keys are bound to action bar 2, and the player types `/wasd setup status`
- **THEN** chat starts "WASDBars: Keybinds: WASD keys set up, number row 7 of 12 set up."

### Requirement: Action bar 2 not changed by keybind setup
The keybind setup SHALL NOT draw, move, show or hide action bar 2 (arranging it belongs to `add-edit-mode-setup`). If the number row is set up while action bar 2 is turned off, the addon SHALL remind the player to turn it on in Edit Mode.

#### Scenario: Bar turned off
- **WHEN** the number row is confirmed while action bar 2 is turned off
- **THEN** chat shows a reminder to turn on action bar 2
- **AND** the addon does not turn it on
