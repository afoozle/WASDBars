# wasd-layout

## ADDED Requirements

### Requirement: Keyboard-shaped layout using the game's own buttons
The addon SHALL move the game's own action buttons 1–12 into a cluster shaped like the keys around WASD: Q, E, R, T on the top row; F, G on the middle row; Z, X, C, V on the bottom row, with rows staggered like a standard keyboard. Buttons 1–10 SHALL sit at Q, E, R, T, F, G, Z, X, C, V in that order, and buttons 11 and 12 in a column just right of the keyboard shape, 11 above 12. Positions, button mapping and size tiers SHALL be defined in one editable data table. The addon SHALL NOT create its own action buttons, and SHALL NOT draw the number row or change action bar 2.

#### Scenario: Default layout
- **WHEN** the addon loads for the first time on a character
- **THEN** the cluster is shown just above action bar 2, aligned with its left edge
- **AND** Q, E, R, T, F, G, Z, X, C and V sit in their keyboard positions around W, A, S and D, with buttons 11 and 12 in a column to the right

#### Scenario: Following action bar 2
- **WHEN** the player moves action bar 2 in Edit Mode
- **THEN** the cluster moves with it

#### Scenario: Editing the layout table
- **WHEN** the player changes a key's button, position or size tier in the layout table and reloads
- **THEN** that button appears at the new position and size

### Requirement: Relative key sizes
Keys SHALL use three relative size tiers: keys touching W, A, S or D (Q, E, R, F, Z, X, C) at full size; further-out keys (T, G, V) and buttons 11 and 12 at 0.8; movement keys (W, A, S, D) at 0.6. Each key SHALL be centred on its keyboard position so size never changes the keyboard shape.

#### Scenario: Size order
- **WHEN** the cluster is shown
- **THEN** Q, E, R, F, Z, X and C are larger than T, G, V and buttons 11 and 12
- **AND** those are larger than W, A, S and D

### Requirement: Movement keys with letters and direction arrows
W, A, S and D SHALL be shown as small, dimmed, non-clickable keys drawn with the game's own empty action slot art, each showing its letter and a direction arrow from the game's own art (W up, A left, S down, D right). The addon SHALL NOT ship its own textures for this.

#### Scenario: Arrows
- **WHEN** the cluster is shown
- **THEN** W shows "W" and an up arrow, A "A" and left, S "S" and down, D "D" and right, and clicking them does nothing

### Requirement: Game behaviour kept
Moved buttons SHALL keep everything the game's action buttons do: icons, cooldowns, usable/rage/range colours, queued and active highlights, item counts, tooltips, the game's own keybind labels, keybinds, following shapeshift forms in and out of combat, and drag and drop out of combat. The addon SHALL NOT replace any of the game's functions or change the buttons' hotkey text.

#### Scenario: Form change in combat
- **WHEN** the player shifts from caster to Bear Form in combat
- **THEN** the cluster immediately shows the Bear Form abilities, with their cooldowns and colours

#### Scenario: Setting up a Bear key
- **WHEN** the player is in Bear Form out of combat and drags Swipe from the spellbook onto the E button
- **THEN** Swipe is placed on the Bear bar's E slot, and the caster and Cat bars are unchanged

#### Scenario: Thumb buttons
- **WHEN** the player presses the mouse side button bound to action button 11 (or 12)
- **THEN** the action on button 11 (or 12) in the cluster is used

### Requirement: Layout holds
The layout SHALL stay in place through form changes, combat, reloads, zoning, bar page changes and Edit Mode changes. When Edit Mode layouts change and a button has left the cluster, the addon SHALL re-apply the layout straight away out of combat, or as soon as combat ends. The addon SHALL never move or change the buttons during combat, and SHALL cause no "Interface action blocked" errors.

#### Scenario: Reload
- **WHEN** the player reloads the UI
- **THEN** the buttons are back in the cluster

#### Scenario: Edit Mode layout change
- **WHEN** the player switches or edits an Edit Mode layout and a button has left the cluster
- **THEN** the addon puts it back (after combat if in combat), with no errors

### Requirement: Other bars left alone
This change SHALL NOT hide, move or change the main bar's art or settings, action bar 2, the micro menu or the bags. (Hiding the main bar art, showing empty slots and moving action bar 2 belong to `add-edit-mode-setup`.)

#### Scenario: After loading
- **WHEN** the cluster is shown
- **THEN** action bar 2, the micro menu and bags are where they were
