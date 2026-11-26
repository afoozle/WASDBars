## ADDED Requirements

### Requirement: Buttons follow the WASDBars layout
Action bar 1's buttons SHALL be in the cluster exactly while the active Edit Mode layout is "WASDBars", and on the game's action bar 1 on any other layout. When the active layout changes, the addon SHALL move them straight away out of combat, or as soon as combat ends. On any other layout the cluster, its movement keys and its Edit Mode element SHALL be hidden, and the buttons SHALL be back in the game's own holders at the game's own size and hotkey style, as if the addon had never moved them.

#### Scenario: Fresh character
- **WHEN** a character logs in with WASDBars for the first time and isn't on the "WASDBars" layout
- **THEN** action bar 1 is the game's normal bar, and no cluster, movement keys or WASDBars Edit Mode element are shown

#### Scenario: Switching away
- **WHEN** a set-up character switches from "WASDBars" to Modern in Edit Mode
- **THEN** the buttons are back on action bar 1 and the cluster is gone, with no reload

#### Scenario: Switching back
- **WHEN** the character switches back to "WASDBars"
- **THEN** the buttons are in the cluster again, where the cluster was last placed in that layout

#### Scenario: Picking the layout by hand
- **WHEN** a character that never ran setup picks "WASDBars" in Edit Mode
- **THEN** the buttons move into the cluster

#### Scenario: Layout change in combat
- **WHEN** the active layout changes during combat
- **THEN** the buttons move when combat ends, with no errors

## MODIFIED Requirements

### Requirement: Keyboard-shaped layout using the game's own buttons
The addon SHALL move the game's own action buttons 1–12 into a cluster shaped like the keys around WASD: Q, E, R, T on the top row; F, G on the middle row; Z, X, C, V on the bottom row, with rows staggered like a standard keyboard. Buttons 1–10 SHALL sit at Q, E, R, T, F, G, Z, X, C, V in that order, and buttons 11 and 12 in a column just right of the keyboard shape, 11 above 12. Positions, button mapping and size tiers SHALL be defined in one editable data table. The addon SHALL NOT create its own action buttons, and SHALL NOT draw the number row or change action bar 2.

#### Scenario: Default layout
- **WHEN** a character is on the "WASDBars" layout and the cluster hasn't been moved in it
- **THEN** the cluster is shown at its default position (see `display-positioning`)
- **AND** Q, E, R, T, F, G, Z, X, C and V sit in their keyboard positions around W, A, S and D, with buttons 11 and 12 in a column to the right

#### Scenario: Following action bar 2
- **WHEN** the player moves action bar 2 in Edit Mode
- **THEN** the cluster does not move; it has its own Edit Mode position

#### Scenario: Editing the layout table
- **WHEN** the player changes a key's button, position or size tier in the layout table and reloads
- **THEN** that button appears at the new position and size

### Requirement: Layout holds
While the "WASDBars" layout is active, the layout SHALL stay in place through form changes, combat, reloads, zoning, bar page changes and Edit Mode changes. When Edit Mode layouts change, "WASDBars" is still active and a button has left the cluster, the addon SHALL re-apply the layout straight away out of combat, or as soon as combat ends. The addon SHALL never move or change the buttons during combat, and SHALL cause no "Interface action blocked" errors.

#### Scenario: Reload
- **WHEN** the player reloads the UI on the "WASDBars" layout
- **THEN** the buttons are back in the cluster

#### Scenario: Edit Mode layout change
- **WHEN** the player edits the "WASDBars" layout and a button has left the cluster
- **THEN** the addon puts it back (after combat if in combat), with no errors
