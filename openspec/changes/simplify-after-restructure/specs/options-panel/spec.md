## MODIFIED Requirements

### Requirement: Options in the game's settings
The addon SHALL list its options under AddOns in the game's own options window, built from the game's standard settings rows. `/wasd options` SHALL open it; in combat, when the game blocks addons from opening it, it SHALL say the options can't be opened instead.

#### Scenario: From slash command
- **WHEN** the player types `/wasd options`
- **THEN** the game's options window opens at the WASDBars page

#### Scenario: In combat
- **WHEN** the player types `/wasd options` in combat
- **THEN** chat says the options can't be opened in combat, and nothing is blocked

#### Scenario: From game options
- **WHEN** the player opens the game's options and goes to AddOns
- **THEN** WASDBars is listed with Display, Appearance and Setup sections
