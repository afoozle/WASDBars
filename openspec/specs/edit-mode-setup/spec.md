# edit-mode-setup Specification

## Purpose

Getting a character ready for WASDBars: the setup offered once per character (keybinds, then a read-only check of the Edit Mode layout that lists manual fixes), re-run with `/wasd setup` or the options panel's setup buttons. The addon never writes Edit Mode layouts.

## Requirements

### Requirement: Edit Mode layout check
`/wasd setup layout` SHALL read the active Edit Mode layout and list, as manual Edit Mode steps, each of these that is off: Action Bar 1 "# of Icons" is 12, "Always Show Buttons" on, "Hide Bar Art" on, "Hide Bar Scrolling" on, Action Bar 2 turned on, and Action Bar 1 not overlapping Action Bar 2. The addon SHALL NOT change any Edit Mode layout, frame or table.

#### Scenario: Something to fix
- **WHEN** Action Bar 1 has 8 icons and the player types `/wasd setup layout`
- **THEN** chat says "WASDBars: Your Edit Mode layout needs 1 change:" followed by a line saying to set Action Bar 1's "# of Icons" to 12
- **AND** nothing in Edit Mode changes

#### Scenario: All set
- **WHEN** every checked setting is right
- **THEN** chat says "WASDBars: Your Edit Mode layout is ready."

#### Scenario: Setting can't be read
- **WHEN** the game doesn't report one of the settings
- **THEN** that check is skipped without errors

### Requirement: First-time setup offered once per character
At a character's first login with WASDBars, if its keys aren't all set up, the addon SHALL offer the setup once. "Set up" SHALL show the keybind window and then, once it closes, run the layout check. Either answer SHALL be remembered for that character.

#### Scenario: New character
- **WHEN** a character whose keys aren't set up logs in with WASDBars for the first time and the player clicks "Set up"
- **THEN** the keybind window appears, and the layout check shows in chat once it closes

#### Scenario: Not now
- **WHEN** the player clicks "Not now"
- **THEN** nothing changes and that character isn't offered the setup again

#### Scenario: Keys already set up
- **WHEN** a character whose keys are all set up logs in
- **THEN** no offer is shown

### Requirement: Running setup again
`/wasd setup` and the Run setup button on the WASDBars page in the game's AddOns settings SHALL run the whole setup; `/wasd setup keys` and `/wasd setup layout` SHALL run one part; `/wasd setup status` SHALL report the keybinds and the layout in one line.

#### Scenario: Status
- **WHEN** the keys are set up, Hide Bar Art is off, and the player types `/wasd setup status`
- **THEN** chat shows "WASDBars: Keybinds set up (WASD keys and number row). Edit Mode layout needs 1 change (/wasd setup layout)."

#### Scenario: Nothing to do
- **WHEN** everything is set up and the player types `/wasd setup`
- **THEN** chat shows two lines: keybinds already set up, and the Edit Mode layout is ready

#### Scenario: Options button
- **WHEN** the player clicks Run setup on the WASDBars options page
- **THEN** the setup runs as with `/wasd setup`
