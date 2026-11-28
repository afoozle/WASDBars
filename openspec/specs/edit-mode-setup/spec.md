# edit-mode-setup Specification

## Purpose

Getting a character ready for WASDBars and undoing it: one setup window (offered once per character, re-run with `/wasd setup` or Run setup) that creates or switches to the account-wide "WASDBars" Edit Mode layout, sets it up and binds the keys, then asks for a reload; the login reminder; the action bar 1 mouse fix; and `/wasd restore`. Action bar 1's buttons and look follow the WASDBars layout. The addon only ever writes its own WASDBars layout.

## Requirements

### Requirement: WASDBars layout
Setup SHALL only ever change an account-wide Edit Mode layout named "WASDBars". If it doesn't exist, setup SHALL create it as a copy of the active layout (custom or preset) and switch to it; if it exists, setup SHALL switch to it. A layout already named "WASDBars" SHALL be treated as the addon's. No other layout SHALL be changed.

#### Scenario: First setup on a preset
- **WHEN** the player is on Modern and confirms setup
- **THEN** a "WASDBars" account layout exists, copied from Modern, and is active
- **AND** Modern is unchanged

#### Scenario: First setup on the player's own layout
- **WHEN** the player is on their layout "Raid" and confirms setup
- **THEN** "WASDBars" starts as a copy of "Raid", and "Raid" is unchanged

#### Scenario: Second character
- **WHEN** "WASDBars" exists and another character confirms setup
- **THEN** that character switches to "WASDBars" and no new layout is created

#### Scenario: Layout limit
- **WHEN** the account already has the most layouts the game allows and setup needs to create "WASDBars"
- **THEN** chat says to delete a layout first, and nothing changes

### Requirement: Layout settings
In "WASDBars", setup SHALL set Action Bar 1 to 12 icons with Always Show Buttons, Hide Bar Art and Hide Bar Scrolling on, and hide both end caps (gryphons); every run SHALL fix whichever of these is off. When it creates the layout, setup SHALL also give Action Bar 2 12 icons and Action Bar 1's orientation, rows, icon size and icon padding; later runs SHALL leave Action Bar 2's shape alone.

#### Scenario: Player resizes Action Bar 2
- **WHEN** the player changes Action Bar 2's icon size in "WASDBars" and runs `/wasd setup`
- **THEN** setup doesn't list Action Bar 2's shape and leaves its size as the player set it

#### Scenario: Fixing one setting later
- **WHEN** the player turns Hide Bar Art off in "WASDBars" and runs `/wasd setup`
- **THEN** the window lists only that action, and Set up turns it back on

### Requirement: Layout positions
When setup creates "WASDBars" it SHALL put Action Bar 2 exactly on Action Bar 1 (first button on first button), the WASD cluster at the bottom left, and the chat window just above the cluster. Later runs SHALL NOT move the cluster or the chat window, and SHALL only move Action Bar 2 if it no longer sits on Action Bar 1.

#### Scenario: Player moves the chat
- **WHEN** the player moves the chat window in "WASDBars" and runs setup again
- **THEN** the chat window stays where the player put it

#### Scenario: Action Bar 2 drifted
- **WHEN** Action Bar 2 has been dragged off Action Bar 1 and the player runs setup
- **THEN** the window lists "Put Action Bar 2 on Action Bar 1"

### Requirement: Action Bar 2 turned on
Setup SHALL turn on Action Bar 2 for the character (the game's per-character Action Bars setting) if it is off.

#### Scenario: Bar off
- **WHEN** Action Bar 2 is off and the player confirms setup
- **THEN** Action Bar 2 is on, and still on after `/reload`

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

### Requirement: Reload after setup and restore
When Set up has changed the Edit Mode layout or turned on Action Bar 2, and at the end of every restore, the addon SHALL show a small window saying "Set up. Reload the UI to finish." (or "Restored. …") with one "Reload to finish" button and no close button; clicking it reloads the UI. Setup that only changes keybinds SHALL NOT ask for a reload.

#### Scenario: Fight after setup
- **WHEN** the player clicks Set up on a character not on "WASDBars", and fights a mob after the UI has reloaded
- **THEN** clicking "Reload to finish" reloads the UI, and no action is blocked in the fight

#### Scenario: After a restore
- **WHEN** the player finishes `/wasd restore`
- **THEN** the window says "Restored. Reload the UI to finish.", and clicking the button reloads the UI

#### Scenario: Keys only
- **WHEN** only the keys needed setting up
- **THEN** chat says "WASDBars: Set up." and no reload window shows

### Requirement: Setup command
`/wasd setup` SHALL open the setup window, or say everything is set up.

#### Scenario: Nothing to do
- **WHEN** everything is set up and the player types `/wasd setup`
- **THEN** chat says everything is set up and no window opens
