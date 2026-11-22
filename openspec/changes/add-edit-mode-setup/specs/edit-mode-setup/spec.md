# edit-mode-setup

## ADDED Requirements

### Requirement: Confirmed Edit Mode arrangement
`/wasd setup layout` SHALL show what it will change and, only after the player confirms, switch to an Edit Mode layout named "WASDBars" (created from the player's current layout if it doesn't exist) in which Action Bar 1's art and page arrows are hidden, its empty slots always show, it has 12 icons, and Action Bar 2 sits where Action Bar 1 was. The addon SHALL NOT edit the game's preset layouts or any layout other than "WASDBars".

#### Scenario: Confirm
- **WHEN** the player types `/wasd setup layout` and clicks Confirm
- **THEN** the active Edit Mode layout is "WASDBars", the main bar art and page arrows are gone, empty cluster slots still show, action bar 2 is where action bar 1 was, and the WASD cluster is unchanged
- **AND** it stays that way after `/reload` and relogging

#### Scenario: Cancel
- **WHEN** the player clicks Cancel
- **THEN** no Edit Mode layout changes

#### Scenario: Already set up
- **WHEN** the "WASDBars" layout is active with the expected settings and the player runs `/wasd setup layout`
- **THEN** chat says it's already set up and no popup is shown

#### Scenario: Not possible on this client
- **WHEN** the feasibility check failed and the player runs `/wasd setup layout`
- **THEN** chat lists the manual Edit Mode steps and nothing is changed

### Requirement: First-time setup offered once
At the first login with WASDBars, the addon SHALL offer the first-time setup once. Choosing "Set up" SHALL run the keybind setup and then the Edit Mode arrangement, each with its own confirmation. Either answer SHALL be remembered so the offer isn't shown again.

#### Scenario: First login
- **WHEN** the player logs in with WASDBars for the first time and clicks "Set up"
- **THEN** the WASD keys popup appears, then the number row popup, then the Edit Mode popup, each only after the previous one closes

#### Scenario: Not now
- **WHEN** the player clicks "Not now"
- **THEN** nothing changes and the offer isn't shown at later logins

### Requirement: Each part can be re-run on its own
`/wasd setup` SHALL run the whole setup again; `/wasd setup keys` and `/wasd setup layout` SHALL run just that part; `/wasd setup status` SHALL report the state of each part.

#### Scenario: Status
- **WHEN** the keybinds are set up but the Edit Mode arrangement isn't, and the player types `/wasd setup status`
- **THEN** chat shows the keybind groups as set up and "Action bar layout: not set up"

### Requirement: No taint from Edit Mode changes
The addon SHALL change Edit Mode only through `C_EditMode` functions, out of combat, and SHALL NOT write to the game's Edit Mode frames or tables. Changing the layout SHALL cause no "Interface action blocked" errors, including when entering combat or opening Edit Mode afterwards.

#### Scenario: Requested in combat
- **WHEN** the player runs `/wasd setup layout` in combat
- **THEN** chat shows "WASDBars: will apply after combat." and the confirmation appears when combat ends
