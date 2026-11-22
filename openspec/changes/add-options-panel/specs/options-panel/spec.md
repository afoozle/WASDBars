# options-panel

## ADDED Requirements

### Requirement: Options in the game's settings
The addon SHALL list its options under AddOns in the game's own options window, built from the game's standard settings rows. `/wasd options` SHALL open it.

#### Scenario: From slash command
- **WHEN** the player types `/wasd options`
- **THEN** the game's options window opens at the WASDBars page

#### Scenario: From game options
- **WHEN** the player opens the game's options and goes to AddOns
- **THEN** WASDBars is listed with Display, Appearance and Setup sections

### Requirement: Display row
The page SHALL have an Open Edit Mode button, because the cluster is moved and scaled in Edit Mode. In combat it SHALL say Edit Mode can't be opened instead.

#### Scenario: Opening Edit Mode
- **WHEN** the player clicks Open Edit Mode out of combat
- **THEN** the options window closes and Edit Mode opens, where WASDBars can be selected

### Requirement: Appearance options
The page SHALL have "Show movement keys (W, A, S, D)" and "Large hotkey text" checkboxes, both on by default, applied straight away and kept after reloading. With large hotkey text off, the cluster's buttons SHALL show the game's own hotkey text style.

#### Scenario: Hide movement keys
- **WHEN** the player unticks "Show movement keys"
- **THEN** W, A, S and D disappear and stay hidden after `/reload`

#### Scenario: Game's hotkey text
- **WHEN** the player unticks "Large hotkey text"
- **THEN** the cluster's buttons show the game's small corner hotkey text

### Requirement: Setup buttons
The page SHALL have a Set up keybinds button that opens the keybind window and a Check layout button that runs the Edit Mode layout check.

#### Scenario: Keybinds from the page
- **WHEN** the player clicks Set up keybinds and confirms
- **THEN** the keys are bound exactly as with `/wasd setup keys`

### Requirement: Page shows current values
Every checkbox SHALL show the current saved value when the page opens.

#### Scenario: After reload
- **WHEN** the player unticks a checkbox, reloads and opens the page
- **THEN** that checkbox is still unticked
