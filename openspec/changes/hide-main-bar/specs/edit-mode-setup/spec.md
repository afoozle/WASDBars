## MODIFIED Requirements

### Requirement: One setup window
Setup SHALL show one window listing, under a Layout heading, the layout actions still needed and, under a Keys heading, the keybind steps and the actions that would lose their key. Set up SHALL apply all of them; Not now, the close button and Escape SHALL change nothing. Headings with nothing to do SHALL be left out. Setup SHALL change nothing while Edit Mode is open or in combat.

#### Scenario: Back out
- **WHEN** the player reads the window and clicks Not now
- **THEN** no layout, setting, keybind or button changes

#### Scenario: Buttons listed
- **WHEN** a character not on "WASDBars" opens the window
- **THEN** the Layout heading lists "Move action bar 1's buttons into the WASD shape" followed by "Replace action bar 1 with action bar 2", and Set up does both

#### Scenario: Keys already set up
- **WHEN** the keys are already set up and the layout isn't
- **THEN** the window shows only the Layout heading

#### Scenario: Edit Mode open
- **WHEN** Edit Mode is open and the player runs `/wasd setup`
- **THEN** chat says to close Edit Mode and run `/wasd setup layout`, and nothing changes

#### Scenario: In combat
- **WHEN** the player runs setup, or clicks Set up, during combat
- **THEN** chat says setup can't be done in combat, and nothing changes
