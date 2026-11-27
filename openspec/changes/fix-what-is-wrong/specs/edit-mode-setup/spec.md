## MODIFIED Requirements

### Requirement: Layout settings
In "WASDBars", setup SHALL set Action Bar 1 to 12 icons with Always Show Buttons, Hide Bar Art and Hide Bar Scrolling on, and hide both end caps (gryphons); every run SHALL fix whichever of these is off. When it creates the layout, setup SHALL also give Action Bar 2 12 icons and Action Bar 1's orientation, rows, icon size and icon padding; later runs SHALL leave Action Bar 2's shape alone.

#### Scenario: Player resizes Action Bar 2
- **WHEN** the player changes Action Bar 2's icon size in "WASDBars" and runs `/wasd setup`
- **THEN** setup doesn't list Action Bar 2's shape and leaves its size as the player set it

#### Scenario: Fixing one setting later
- **WHEN** the player turns Hide Bar Art off in "WASDBars" and runs `/wasd setup`
- **THEN** the window lists only that action, and Set up turns it back on

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
- **THEN** chat says to close Edit Mode and run `/wasd setup`, and nothing changes

#### Scenario: In combat
- **WHEN** the player runs setup, or clicks Set up, during combat
- **THEN** chat says setup can't be done in combat, and nothing changes

### Requirement: Setup commands and status
`/wasd setup` SHALL open the setup window, or say everything is set up. `/wasd setup status` SHALL report the keybinds and the layout in one line: layout ready, not on the WASDBars layout, or how many changes it needs.

#### Scenario: Not on WASDBars
- **WHEN** the keys are set up, the player has switched to Modern and types `/wasd setup status`
- **THEN** chat shows "WASDBars: Keybinds set up (WASD keys and number row). Not on the WASDBars layout (/wasd setup)."

#### Scenario: Nothing to do
- **WHEN** everything is set up and the player types `/wasd setup`
- **THEN** chat says everything is set up and no window opens

