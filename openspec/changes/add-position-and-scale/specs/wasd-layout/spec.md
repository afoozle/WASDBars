# wasd-layout

## MODIFIED Requirements

### Requirement: Keyboard-shaped layout using the game's own buttons
The addon SHALL move the game's own action buttons 1–12 into a cluster shaped like the keys around WASD: Q, E, R, T on the top row; F, G on the middle row; Z, X, C, V on the bottom row, with rows staggered like a standard keyboard. Buttons 1–10 SHALL sit at Q, E, R, T, F, G, Z, X, C, V in that order, and buttons 11 and 12 in a column just right of the keyboard shape, 11 above 12. Positions, button mapping and size tiers SHALL be defined in one editable data table. The addon SHALL NOT create its own action buttons, and SHALL NOT draw the number row or change action bar 2.

#### Scenario: Default layout
- **WHEN** the addon loads for the first time on a character
- **THEN** the cluster is shown at its default position (see `display-positioning`)
- **AND** Q, E, R, T, F, G, Z, X, C and V sit in their keyboard positions around W, A, S and D, with buttons 11 and 12 in a column to the right

#### Scenario: Following action bar 2
- **WHEN** the player moves action bar 2 in Edit Mode
- **THEN** the cluster does not move; it has its own Edit Mode position

#### Scenario: Editing the layout table
- **WHEN** the player changes a key's button, position or size tier in the layout table and reloads
- **THEN** that button appears at the new position and size
