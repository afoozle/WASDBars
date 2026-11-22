# wasd-layout

## MODIFIED Requirements

### Requirement: Relative key sizes
Keys SHALL use two relative sizes: big (1.0) for the keys touching W, A, S or D (Q, E, R, F, Z, X, C) and small (0.8) for W, A, S, D, the further-out keys (T, G, V) and buttons 11 and 12. Within a row, neighbouring keys SHALL be packed with the same gap between them whatever their sizes; the first key of each row (and of the mouse column) SHALL sit on its keyboard position, so rows keep their keyboard stagger.

#### Scenario: Size order
- **WHEN** the cluster is shown
- **THEN** Q, E, R, F, Z, X and C are larger than W, A, S, D, T, G, V and buttons 11 and 12

#### Scenario: Even gaps
- **WHEN** the cluster is shown
- **THEN** the gap between Q and W is the same as between W and E

### Requirement: Movement keys with letters and direction arrows
W, A, S and D SHALL be shown as small, non-clickable keys drawn with the game's own empty action slot art, each showing its letter in a large outlined font and a direction arrow from the game's own art (W up, A left, S down, D right). The addon SHALL NOT ship its own textures for this.

#### Scenario: Arrows
- **WHEN** the cluster is shown
- **THEN** W shows "W" and an up arrow, A "A" and left, S "S" and down, D "D" and right, and clicking them does nothing

### Requirement: Game behaviour kept
Moved buttons SHALL keep everything the game's action buttons do: icons, cooldowns, usable/rage/range colours, queued and active highlights, item counts, tooltips, the game's own keybind labels, keybinds, following shapeshift forms in and out of combat, and drag and drop out of combat. The addon SHALL NOT replace any of the game's functions. It MAY restyle the game's own hotkey text on the cluster buttons (larger, outlined, at the bottom centre), but the game SHALL still set its text, colour and visibility.

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
