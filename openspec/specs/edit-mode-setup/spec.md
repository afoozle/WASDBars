# edit-mode-setup Specification

## Purpose

Getting a character ready for WASDBars: the setup offered once per character (keybinds, then a read-only check of the Edit Mode layout that lists manual fixes), re-run with `/wasd setup` or the Run setup button. The addon never writes Edit Mode layouts.

## Requirements

### Requirement: Edit Mode layout check
`/wasd setup layout` SHALL read the active Edit Mode layout and list, as manual Edit Mode steps, each of these that is off: Action Bar 1 "# of Icons" is 12, "Always Show Buttons" on, "Hide Bar Art" on, "Hide Bar Scrolling" on, Action Bar 2 turned on, and Action Bar 1 not overlapping Action Bar 2. The addon SHALL NOT change any Edit Mode layout, frame or table.

#### Scenario: Something to fix
- **WHEN** Action Bar 1 has 8 icons and the player types `/wasd setup layout`
- **THEN** chat says to set Action Bar 1's "# of Icons" to 12
- **AND** nothing in Edit Mode changes

#### Scenario: All set
- **WHEN** every checked setting is right
- **THEN** chat says the action bar layout is set up

#### Scenario: Setting can't be read
- **WHEN** the game doesn't report one of the settings
- **THEN** that check is skipped without errors

### Requirement: First-time setup offered once per character
At a character's first login with WASDBars, if its keys aren't all set up, the addon SHALL offer the setup once. "Set up" SHALL run the WASD keys popup, then the number row popup, then the layout check, each after the previous one closes. Either answer SHALL be remembered for that character.

#### Scenario: New character
- **WHEN** a character whose keys aren't set up logs in with WASDBars for the first time and the player clicks "Set up"
- **THEN** the WASD keys popup appears, then the number row popup, then the layout check in chat

#### Scenario: Not now
- **WHEN** the player clicks "Not now"
- **THEN** nothing changes and that character isn't offered the setup again

#### Scenario: Keys already set up
- **WHEN** a character whose keys are all set up logs in
- **THEN** no offer is shown

### Requirement: Running setup again
`/wasd setup` and the Run setup button on the WASDBars page in the game's AddOns settings SHALL run the whole setup; `/wasd setup keys` and `/wasd setup layout` SHALL run one part; `/wasd setup status` SHALL report each key group and the layout.

#### Scenario: Status
- **WHEN** the keys are set up, Hide Bar Art is off, and the player types `/wasd setup status`
- **THEN** chat shows both key groups as set up and "Action bar layout: 1 thing to fix (/wasd setup layout)"

#### Scenario: Options button
- **WHEN** the player clicks Run setup on the WASDBars options page
- **THEN** the setup runs as with `/wasd setup`
