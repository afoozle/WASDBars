## REMOVED Requirements

### Requirement: Running setup again
**Reason:** Replaced by "Setup commands": the Run setup button it described was replaced by the options panel's own setup buttons (`options-panel`).
**Migration:** Use `/wasd setup`, or the options panel's Set up keybinds and Check layout buttons.

## ADDED Requirements

### Requirement: Setup commands
`/wasd setup` SHALL run the whole setup; `/wasd setup keys` and `/wasd setup layout` SHALL run one part; `/wasd setup status` SHALL report the keybinds and the layout in one line. (The options page's setup buttons are in the `options-panel` capability.)

#### Scenario: Status
- **WHEN** the keys are set up, Hide Bar Art is off, and the player types `/wasd setup status`
- **THEN** chat shows "WASDBars: Keybinds set up (WASD keys and number row). Edit Mode layout needs 1 change (/wasd setup layout)."

#### Scenario: Nothing to do
- **WHEN** everything is set up and the player types `/wasd setup`
- **THEN** chat shows two lines: keybinds already set up, and the Edit Mode layout is ready

#### Scenario: In combat
- **WHEN** the player types `/wasd setup` during combat
- **THEN** chat shows "WASDBars: Will apply after combat." and the setup runs, keybinds then layout check, when combat ends
