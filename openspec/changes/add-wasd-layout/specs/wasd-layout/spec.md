# wasd-layout

## ADDED Requirements

### Requirement: Keyboard-shaped layout using the game's own buttons
The addon SHALL move the game's own action buttons 1–12 into a cluster shaped like the keys around WASD: Q, E, R, T on the top row; F, G on the middle row; Z, X, C, V on the bottom row, with rows staggered like a standard keyboard. Buttons 1–10 SHALL sit at Q, E, R, T, F, G, Z, X, C, V in that order, and buttons 11 and 12 at the front and back mouse side buttons. Positions, button mapping and size tiers SHALL be defined in one editable data table. The addon SHALL NOT create its own action buttons, and SHALL NOT draw the number row or touch action bar 2.

#### Scenario: Default layout
- **WHEN** the addon loads for the first time on a character
- **THEN** the cluster is shown near the bottom centre of the screen
- **AND** Q, E, R, T, F, G, Z, X, C and V sit in their keyboard positions around W, A, S and D

#### Scenario: Editing the layout table
- **WHEN** the player changes a key's button, position or size tier in the layout table and reloads
- **THEN** that button appears at the new position and size

### Requirement: Relative key sizes
Keys SHALL use three relative size tiers: keys touching W, A, S or D (Q, E, R, F, Z, X, C) largest; further-out keys (T, G, V) and both mouse side buttons slightly smaller; movement keys (W, A, S, D) smallest. Each key SHALL be centred on its keyboard position so size never changes the keyboard shape.

#### Scenario: Size order
- **WHEN** the cluster is shown
- **THEN** Q, E, R, F, Z, X and C are larger than T, G, V and the mouse side buttons
- **AND** those are larger than W, A, S and D

### Requirement: Movement keys with direction arrows
W, A, S and D SHALL be shown as small, dimmed, non-clickable keys showing only a direction arrow (W up, A left, S down, D right).

#### Scenario: Arrows
- **WHEN** the cluster is shown
- **THEN** W shows an up arrow, A left, S down and D right, and clicking them does nothing

### Requirement: Mouse side buttons on a mouse outline
The addon SHALL draw a simple, non-interactive mouse outline to the right of the keyboard cluster, with action buttons 11 (front) and 12 (back) on its left edge, front above back, labelled "Fwd" and "Back".

#### Scenario: Mouse cluster
- **WHEN** the cluster is shown
- **THEN** a mouse outline appears to the right with the front-button action above the back-button action, labelled "Fwd" and "Back"

### Requirement: Game behaviour kept
Moved buttons SHALL keep everything the game's action buttons do: icons, cooldowns, usable/rage/range colours, queued and active highlights, item counts, tooltips, keybind labels, keybinds, following shapeshift forms in and out of combat, and drag and drop out of combat. The addon SHALL NOT replace any of the game's functions; it SHALL only add to them.

#### Scenario: Form change in combat
- **WHEN** the player shifts from caster to Bear Form in combat
- **THEN** the cluster immediately shows the Bear Form abilities, with their cooldowns and colours

#### Scenario: Setting up a Bear key
- **WHEN** the player is in Bear Form out of combat and drags Swipe from the spellbook onto the E button
- **THEN** Swipe is placed on the Bear bar's E slot, and the caster and Cat bars are unchanged

#### Scenario: Keys
- **WHEN** the player presses F in Bear Form
- **THEN** the ability on the Bear bar's F button is used

### Requirement: Layout holds
The layout SHALL stay in place through form changes, combat, reloads, zoning, bar page changes and Edit Mode changes. When Edit Mode layouts change and a button has left the cluster, the addon SHALL re-apply the layout straight away out of combat, or as soon as combat ends. The addon SHALL never move or change the buttons during combat, and SHALL cause no "Interface action blocked" errors.

#### Scenario: Reload
- **WHEN** the player reloads the UI
- **THEN** the buttons are back in the cluster

#### Scenario: Edit Mode layout change
- **WHEN** the player switches or edits an Edit Mode layout and a button has left the cluster
- **THEN** the addon puts it back (after combat if in combat), with no errors

### Requirement: Other bars left alone
This change SHALL NOT hide, move or change the main bar's art, action bar 2, the micro menu or the bags. (Hiding the main bar art and moving action bar 2 belong to `add-edit-mode-setup`.)

#### Scenario: After loading
- **WHEN** the cluster is shown
- **THEN** action bar 2, the micro menu and bags are where they were
