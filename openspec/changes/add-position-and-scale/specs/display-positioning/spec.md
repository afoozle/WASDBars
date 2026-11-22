# display-positioning

## ADDED Requirements

### Requirement: Move the display
The player SHALL be able to unlock the display, drag it anywhere on screen, and lock it again. The position SHALL be saved (account-wide, per machine) and the display SHALL NOT be draggable off screen. Unlocking SHALL be refused in combat.

#### Scenario: Moving
- **WHEN** the player types `/wasd unlock`, drags the display, types `/wasd lock` and reloads
- **THEN** the display stays where it was dropped

#### Scenario: Unlock in combat
- **WHEN** the player types `/wasd unlock` in combat
- **THEN** chat says it can't be moved in combat and nothing changes

### Requirement: Scale the display
The player SHALL be able to scale the whole display between 0.5 and 2.0. Every key SHALL scale by the same factor, keeping the layout and size order. Values outside the range SHALL be limited with a message, and non-numbers SHALL be rejected.

#### Scenario: Scaling
- **WHEN** the player types `/wasd scale 1.5`
- **THEN** the display is 1.5 times its default size, and the setting is saved

#### Scenario: Too large
- **WHEN** the player types `/wasd scale 5`
- **THEN** the scale is set to 2.0 and chat says it was limited

#### Scenario: In combat
- **WHEN** the player changes the scale twice during combat
- **THEN** chat shows "WASDBars: will apply after combat." once and the latest value applies when combat ends

### Requirement: Reset
The player SHALL be able to restore the default position and scale, and a missing or damaged saved position SHALL fall back to the default.

#### Scenario: Reset
- **WHEN** the player types `/wasd reset`
- **THEN** the display returns to bottom centre at scale 1.0

#### Scenario: Damaged saved position
- **WHEN** the saved position is invalid at login
- **THEN** the display uses the default position and no error occurs
