## REMOVED Requirements

### Requirement: Edit Mode layout check
**Reason:** Setup now makes the Edit Mode changes itself, inside its own layout, after the player confirms; the read-only list of manual fixes and the bar overlap check go.
**Migration:** `/wasd setup layout` shows the setup window (see "One setup window").

### Requirement: First-time setup offered once per character
**Reason:** The offer now also appears when the layout isn't set up, and opens the one setup window instead of chaining keybinds and a layout check.
**Migration:** See "First-time offer".

### Requirement: Setup commands
**Reason:** Replaced by the one setup window, a new status sentence and `/wasd restore`.
**Migration:** See "Setup commands and status".

## ADDED Requirements

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
- **WHEN** the player changes Action Bar 2's icon size in "WASDBars" and runs `/wasd setup layout`
- **THEN** setup doesn't list Action Bar 2's shape and leaves its size as the player set it

#### Scenario: Fixing one setting later
- **WHEN** the player turns Hide Bar Art off in "WASDBars" and runs `/wasd setup layout`
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

### Requirement: Action Bar 1 mouse fix
On a character whose layout step has finished with the layout ready, the addon SHALL at every login stop Action Bar 1's empty frame and its Edit Mode selection from catching the mouse, so Action Bar 2 on top of it can be used and selected in Edit Mode.

#### Scenario: Using Action Bar 2
- **WHEN** a set-up character hovers over and clicks Action Bar 2's buttons
- **THEN** their tooltips show and the clicks work, also after `/reload`

#### Scenario: Edit Mode
- **WHEN** a set-up character opens Edit Mode and clicks where Action Bar 2 is
- **THEN** Action Bar 2 is selected, and still is after closing and reopening Edit Mode

#### Scenario: Not set up
- **WHEN** a character has never finished the layout step
- **THEN** Action Bar 1's mouse handling is left as the game has it

### Requirement: One setup window
Setup SHALL show one window listing, under a Layout heading, the layout actions still needed and, under a Keys heading, the keybind steps and the actions that would lose their key. Set up SHALL apply all of them; Not now, the close button and Escape SHALL change nothing. Headings with nothing to do SHALL be left out. Setup SHALL change nothing while Edit Mode is open or in combat.

#### Scenario: Back out
- **WHEN** the player reads the window and clicks Not now
- **THEN** no layout, setting or keybind changes

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
At login, if the character hasn't been offered setup and either its keys or its layout aren't set up, the addon SHALL offer setup once for that character. Set up SHALL open the setup window; Not now SHALL change nothing. Switching to another layout later SHALL NOT bring the offer back.

#### Scenario: Second character on shared keybinds
- **WHEN** a character whose keys are already set up, but who isn't on "WASDBars", logs in for the first time
- **THEN** the offer appears, and the window lists only the layout actions

#### Scenario: Not now
- **WHEN** the player clicks Not now
- **THEN** that character isn't offered setup again

#### Scenario: Everything set up
- **WHEN** a character's keys and layout are set up
- **THEN** no offer is shown

### Requirement: Setup commands and status
`/wasd setup` and `/wasd setup layout` SHALL open the setup window, or say everything is set up. `/wasd setup status` SHALL report the keybinds and the layout in one line: layout ready, not on the WASDBars layout, or how many changes it needs.

#### Scenario: Not on WASDBars
- **WHEN** the keys are set up, the player has switched to Modern and types `/wasd setup status`
- **THEN** chat shows "WASDBars: Keybinds set up (WASD keys and number row). Not on the WASDBars layout (/wasd setup layout)."

#### Scenario: Nothing to do
- **WHEN** everything is set up and the player types `/wasd setup`
- **THEN** chat says everything is set up and no window opens

### Requirement: Restore
`/wasd restore` SHALL ask to switch the character back to the layout it was on before setup (Modern if that layout is gone) and set Action Bar 2 back to how it was, then, if keys were changed by setup, ask separately whether to put the 24 keys back to what they were before. It SHALL refuse in combat, SHALL never delete "WASDBars", and SHALL end by telling the player how to turn the addon off.

#### Scenario: Full restore
- **WHEN** the player types `/wasd restore`, confirms, and answers Yes to the keybinds
- **THEN** the previous layout is active, Action Bar 2 is as before setup, the 24 keys are bound as before setup, and "WASDBars" still exists
- **AND** chat says the WASDBars layout can be deleted whenever they like and to turn the addon off or uninstall it, then reload

#### Scenario: Keep the keys
- **WHEN** the player confirms the restore and answers No (or presses Escape) to the keybinds
- **THEN** the layout and Action Bar 2 are restored and the keys stay as they are

#### Scenario: Old layout deleted
- **WHEN** the layout the character was on before setup no longer exists
- **THEN** the restore switches to Modern and says so

#### Scenario: Nothing to restore
- **WHEN** the character never ran setup and the player types `/wasd restore`
- **THEN** chat says there is nothing to restore on this character
