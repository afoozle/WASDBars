# wasd-layout Specification

## Purpose

Shows the game's own action bar 1 buttons in the shape of the keys around WASD, with relative key sizes and movement keys, while keeping all of the game's button behaviour.

## Requirements

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

### Requirement: Relative key sizes
Keys SHALL use two relative sizes: big (1.0) for the keys touching W, A, S or D (Q, E, R, F, Z, X, C) and small (0.8) for W, A, S, D, the further-out keys (T, G, V) and buttons 11 and 12. Every key SHALL take the same square cell, centred on its keyboard position, with smaller keys centred in theirs and no gap between cells. Buttons 11 and 12 SHALL sit in a column next to G, centred on the three rows. Rows SHALL be offset like a real keyboard (the A row a quarter key right of the Q row, the Z row half a key further).

#### Scenario: Size order
- **WHEN** the cluster is shown
- **THEN** Q, E, R, F, Z, X and C are larger than W, A, S, D, T, G, V and buttons 11 and 12

#### Scenario: Keyboard slant
- **WHEN** the cluster is shown
- **THEN** D sits a quarter key right of E and C half a key right of D, like a keyboard

### Requirement: Movement keys with direction arrows
W, A, S and D SHALL be shown as small, non-clickable keys drawn with the game's own empty action slot art, each showing a large direction arrow from the game's own art and no letter (W up, A left, S down, D right). The addon SHALL NOT ship its own textures for this.

#### Scenario: Arrows
- **WHEN** the cluster is shown
- **THEN** W shows an up arrow, A left, S down and D right, and clicking them does nothing

### Requirement: Game behaviour kept
Moved buttons SHALL keep everything the game's action buttons do: icons, cooldowns, usable/rage/range colours, queued and active highlights, item counts, tooltips, the game's own keybind labels, keybinds, following shapeshift forms in and out of combat, and drag and drop out of combat. The addon SHALL NOT replace any of the game's functions. It MAY restyle the game's own hotkey text on the cluster buttons (larger, outlined, at the bottom centre, mouse buttons shortened to M4/M5), but the game SHALL still set its text, colour and visibility.

#### Scenario: Form change in combat
- **WHEN** the player shifts from caster to Bear Form in combat
- **THEN** the cluster immediately shows the Bear Form abilities, with their cooldowns and colours

#### Scenario: Setting up a Bear key
- **WHEN** the player is in Bear Form out of combat and drags Swipe from the spellbook onto the E button
- **THEN** Swipe is placed on the Bear bar's E slot, and the caster and Cat bars are unchanged

#### Scenario: Thumb buttons
- **WHEN** the player presses the mouse side button bound to action button 11 (or 12)
- **THEN** the action on button 11 (or 12) in the cluster is used

#### Scenario: Hotkey text
- **WHEN** a cluster button's spell is out of range
- **THEN** its large bottom-centre hotkey text turns the game's out-of-range colour

### Requirement: Layout holds
The layout SHALL stay in place through form changes, combat, reloads, zoning, bar page changes and Edit Mode changes. When Edit Mode layouts change and a button has left the cluster, the addon SHALL re-apply the layout straight away out of combat, or as soon as combat ends. The addon SHALL never move or change the buttons during combat, and SHALL cause no "Interface action blocked" errors.

#### Scenario: Reload
- **WHEN** the player reloads the UI
- **THEN** the buttons are back in the cluster

#### Scenario: Edit Mode layout change
- **WHEN** the player switches or edits an Edit Mode layout and a button has left the cluster
- **THEN** the addon puts it back (after combat if in combat), with no errors

### Requirement: Other bars left alone
The cluster SHALL NOT hide, move or change the main bar's art or settings, action bar 2, the micro menu or the bags. (The `edit-mode-setup` layout check lists the Edit Mode settings the player changes by hand.)

#### Scenario: After loading
- **WHEN** the cluster is shown
- **THEN** action bar 2, the micro menu and bags are where they were
