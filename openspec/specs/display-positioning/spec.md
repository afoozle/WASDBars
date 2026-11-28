# display-positioning Specification

## Purpose

Where the WASD cluster sits on screen and how big it is: its own Edit Mode element on the "WASDBars" layout, moved, scaled and reset through LibEditMode, saved account-wide per machine and never changed during combat.

## Requirements

### Requirement: Move the display in Edit Mode
The display SHALL be its own element in the game's Edit Mode, named "WASDBars", independent of the game's action bars, shown on the "WASDBars" layout only. With Edit Mode open the player SHALL be able to select and drag it anywhere on screen; it SHALL NOT go off screen. Its position SHALL be saved account-wide, per machine.

#### Scenario: Moving
- **WHEN** the player opens Edit Mode on "WASDBars", drags the display, closes Edit Mode and reloads
- **THEN** the display stays where it was dropped

#### Scenario: Independent of the bars
- **WHEN** the player moves action bar 2 in Edit Mode
- **THEN** the display does not move

### Requirement: Scale the display
The display's Edit Mode settings SHALL include a Scale slider from 0.5 to 2.0. Every key SHALL scale by the same factor, keeping the layout and size order. The scale SHALL be saved with the position.

#### Scenario: Scaling
- **WHEN** the player sets Scale to 1.5 in the display's Edit Mode settings and reloads
- **THEN** the display is 1.5 times its default size

### Requirement: Combat safety
The display SHALL never be moved or scaled during combat. Position and scale applied outside Edit Mode, such as at login or on a layout change, SHALL go through the combat queue.

#### Scenario: Layout change in combat
- **WHEN** the active Edit Mode layout changes to "WASDBars" during combat
- **THEN** the display appears at its saved position when combat ends, with no errors

### Requirement: Default position and reset
When setup creates the "WASDBars" layout it SHALL place the display at the bottom left (see `edit-mode-setup`); otherwise the display SHALL start at a default position and scale 1.0. The player SHALL be able to restore the default position and scale from its Edit Mode settings.

#### Scenario: Reset
- **WHEN** the player uses "Reset To Default Position" and resets the settings in the display's Edit Mode settings
- **THEN** the display returns to the default position at scale 1.0

#### Scenario: Scale before moving
- **WHEN** the player changes the display's scale on a layout where it was never dragged
- **THEN** the display keeps the default position at the new scale
