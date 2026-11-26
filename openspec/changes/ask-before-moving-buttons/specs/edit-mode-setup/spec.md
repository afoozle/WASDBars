## REMOVED Requirements

### Requirement: Action Bar 1 mouse fix
**Reason:** The mouse fix now follows the active layout instead of a per-character set-up flag.
**Migration:** See "Action Bar 1 mouse fix follows the layout".

## ADDED Requirements

### Requirement: Login reminder
At every login (and reload) on a character whose active layout isn't "WASDBars", the addon SHALL print one chat line: "WASDBars: Not set up on this character. Type /wasd setup to set it up." It SHALL NOT print it on a login where the setup offer appears.

#### Scenario: After Not now
- **WHEN** the player clicked Not now on the offer and later logs in again
- **THEN** chat shows the reminder once

#### Scenario: First login
- **WHEN** the setup offer appears at login
- **THEN** the reminder isn't printed on that login

#### Scenario: After a restore
- **WHEN** a character has been restored and logs in
- **THEN** chat shows the reminder once

#### Scenario: Set up
- **WHEN** a character on the "WASDBars" layout logs in
- **THEN** no reminder is printed

### Requirement: Action Bar 1 mouse fix follows the layout
While the active layout is "WASDBars", the addon SHALL stop Action Bar 1's empty frame and its Edit Mode selection from catching the mouse, so Action Bar 2 on top of it can be used and selected in Edit Mode. On any other layout it SHALL give them back the mouse handling the game had. Changes SHALL go through the combat queue.

#### Scenario: Using Action Bar 2
- **WHEN** a character on "WASDBars" hovers over and clicks Action Bar 2's buttons
- **THEN** their tooltips show and the clicks work, also after `/reload`

#### Scenario: Edit Mode
- **WHEN** a character on "WASDBars" opens Edit Mode and clicks where Action Bar 2 is
- **THEN** Action Bar 2 is selected, and still is after closing and reopening Edit Mode

#### Scenario: Other layout
- **WHEN** a character is on any layout other than "WASDBars"
- **THEN** Action Bar 1's mouse handling is as the game has it

## MODIFIED Requirements

### Requirement: One setup window
Setup SHALL show one window listing, under a Layout heading, the layout actions still needed and, under a Keys heading, the keybind steps and the actions that would lose their key. Set up SHALL apply all of them; Not now, the close button and Escape SHALL change nothing. Headings with nothing to do SHALL be left out. Setup SHALL change nothing while Edit Mode is open or in combat.

#### Scenario: Back out
- **WHEN** the player reads the window and clicks Not now
- **THEN** no layout, setting, keybind or button changes

#### Scenario: Buttons listed
- **WHEN** a character not on "WASDBars" opens the window
- **THEN** the Layout heading lists "Move action bar 1's buttons into the WASD shape", and Set up moves them

#### Scenario: Keys already set up
- **WHEN** the keys are already set up and the layout isn't
- **THEN** the window shows only the Layout heading

#### Scenario: Edit Mode open
- **WHEN** Edit Mode is open and the player runs `/wasd setup`
- **THEN** chat says to close Edit Mode and run `/wasd setup layout`, and nothing changes

#### Scenario: In combat
- **WHEN** the player runs setup, or clicks Set up, during combat
- **THEN** chat says setup can't be done in combat, and nothing changes

### Requirement: First-time offer
At login, if the character hasn't been offered setup and either its keys or its layout aren't set up, the addon SHALL offer setup once for that character, saying that it moves action bar 1's buttons into the WASD shape, makes a WASDBars Edit Mode layout and binds the keys. Set up SHALL open the setup window; Not now SHALL change nothing. Switching to another layout later SHALL NOT bring the offer back.

#### Scenario: Second character on shared keybinds
- **WHEN** a character whose keys are already set up, but who isn't on "WASDBars", logs in for the first time
- **THEN** the offer appears, and the window lists only the layout actions, including moving the buttons

#### Scenario: Not now
- **WHEN** the player clicks Not now
- **THEN** that character isn't offered setup again, and its action bar 1 is unchanged

#### Scenario: Everything set up
- **WHEN** a character's keys and layout are set up
- **THEN** no offer is shown

### Requirement: Restore
`/wasd restore` SHALL ask to switch the character back to the layout it was on before setup (Modern if that layout is gone) and set Action Bar 2 back to how it was, then, if keys were changed by setup, ask separately whether to put the 24 keys back to what they were before. Leaving "WASDBars" SHALL put action bar 1's buttons back straight away, with no reload. It SHALL refuse in combat, SHALL never delete "WASDBars", and SHALL end by saying how to set it up again.

#### Scenario: Full restore
- **WHEN** the player types `/wasd restore`, confirms, and answers Yes to the keybinds
- **THEN** the previous layout is active, action bar 1's buttons are back on it, Action Bar 2 is as before setup, the 24 keys are bound as before setup, and "WASDBars" still exists
- **AND** chat shows "WASDBars: Restored. You can delete the WASDBars layout in Edit Mode whenever you like. Type /wasd setup to set it up again."

#### Scenario: Keep the keys
- **WHEN** the player confirms the restore and answers No (or presses Escape) to the keybinds
- **THEN** the layout, action bar 1's buttons and Action Bar 2 are restored and the keys stay as they are

#### Scenario: Old layout deleted
- **WHEN** the layout the character was on before setup no longer exists
- **THEN** the restore switches to Modern and says so

#### Scenario: Nothing to restore
- **WHEN** the character never ran setup and the player types `/wasd restore`
- **THEN** chat says there is nothing to restore on this character
