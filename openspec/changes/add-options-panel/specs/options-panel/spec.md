# options-panel

## ADDED Requirements

### Requirement: Options in the game's settings
The addon SHALL list its options under AddOns in the game's own options window, built only from the game's standard settings controls, with no custom-drawn window. `/wasd` with no arguments or `/wasd options` SHALL open it.

#### Scenario: From slash command
- **WHEN** the player types `/wasd`
- **THEN** the game's options window opens at the WASDBars page

#### Scenario: From game options
- **WHEN** the player opens the game's options and goes to AddOns
- **THEN** WASDBars is listed and shows its controls

### Requirement: Display controls
The panel SHALL have an "Unlock to move" checkbox, a scale slider from 50% to 200% that applies as it moves, and a "Reset position and scale" button. Unlocking SHALL be refused in combat.

#### Scenario: Scale slider
- **WHEN** the player drags the scale slider to 125%
- **THEN** the display resizes to 125% and the value is saved

#### Scenario: Unlock in combat
- **WHEN** the player ticks "Unlock to move" in combat
- **THEN** the box flips back and chat explains it can't be moved in combat

#### Scenario: Reset
- **WHEN** the player clicks "Reset position and scale"
- **THEN** the display returns to bottom centre at 100% and the slider shows 100%

### Requirement: Appearance controls
The panel SHALL have checkboxes to show or hide the movement keys and the mouse outline, both on by default. Hiding the outline SHALL leave the two side-button actions in place.

#### Scenario: Hide the outline
- **WHEN** the player unticks "Show mouse outline"
- **THEN** the outline disappears, the side-button actions stay, and the choice is kept after `/reload`

### Requirement: Key binding buttons
The panel SHALL have "Set up WASD keys…" and "Set up number row…" buttons that open the same confirmation as `/wasd setup keys`, and a "Set up action bar layout…" button that runs `/wasd setup layout`.

#### Scenario: Set up from the panel
- **WHEN** the player clicks "Set up WASD keys…" and confirms
- **THEN** the keys are bound exactly as with `/wasd setup keys`

### Requirement: Panel shows current values
Every control SHALL show the current saved value when the panel opens, including changes made by slash command.

#### Scenario: Changed elsewhere
- **WHEN** the player types `/wasd scale 1.5` and then opens the panel
- **THEN** the slider shows 150%
