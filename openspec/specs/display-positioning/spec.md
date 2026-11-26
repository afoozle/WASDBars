# display-positioning Specification

## Purpose

Where the WASD cluster sits on screen and how big it is: its own Edit Mode element, moved, scaled and reset through LibEditMode, saved per Edit Mode layout and never changed during combat.

## Requirements

### Requirement: Move the display in Edit Mode
The display SHALL be its own element in the game's Edit Mode, named "WASDBars", independent of the game's action bars. With Edit Mode open the player SHALL be able to select and drag it anywhere on screen; it SHALL NOT go off screen. Its position SHALL be saved per Edit Mode layout (account-wide, per machine).

#### Scenario: Moving
- **WHEN** the player opens Edit Mode, drags the display, closes Edit Mode and reloads
- **THEN** the display stays where it was dropped

#### Scenario: Independent of the bars
- **WHEN** the player moves action bar 2 in Edit Mode
- **THEN** the display does not move

### Requirement: Scale the display
The display's Edit Mode settings SHALL include a Scale slider from 0.5 to 2.0. Every key SHALL scale by the same factor, keeping the layout and size order. The scale SHALL be saved with the position.

#### Scenario: Scaling
- **WHEN** the player sets Scale to 1.5 in the display's Edit Mode settings and reloads
- **THEN** the display is 1.5 times its default size

### Requirement: Reset and defaults
The display SHALL start at a default position and scale 1.0 in any layout where it hasn't been moved. The player SHALL be able to restore the default position and scale from its Edit Mode settings. A missing or damaged saved position SHALL fall back to the default without errors.

#### Scenario: Reset
- **WHEN** the player uses "Reset To Default Position" and resets the settings in the display's Edit Mode settings
- **THEN** the display returns to the default position at scale 1.0

#### Scenario: Damaged saved position
- **WHEN** the saved position is invalid at login
- **THEN** the display uses the default position and no error occurs

### Requirement: Combat safety
The display SHALL never be moved or scaled during combat. Position and scale applied outside Edit Mode, such as at login or on a layout change, SHALL go through the combat queue.

#### Scenario: Layout change in combat
- **WHEN** the active Edit Mode layout changes during combat
- **THEN** the display moves to that layout's position when combat ends, with no errors
