## ADDED Requirements

### Requirement: Action bar 1 see-through
While the active layout is "WASDBars", action bar 1 and its Edit Mode box SHALL be fully transparent but not hidden, so the game's bottom bars (XP and reputation bars, action bar 3, stance, pet, possess, vehicle and totem bars) keep their places. On any other layout action bar 1 SHALL look as the game has it.

#### Scenario: Bottom bars stay put
- **WHEN** a character on "WASDBars" logs in, opens Edit Mode and closes it
- **THEN** the XP bar and stance bar stay where they were, in and out of Edit Mode

#### Scenario: Edit Mode box gone
- **WHEN** a character on "WASDBars" opens Edit Mode
- **THEN** no box shows for action bar 1

#### Scenario: Other layout
- **WHEN** the character switches to Modern
- **THEN** action bar 1 shows normally, with its buttons

### Requirement: Action bar 1's art on action bar 2
While the active layout is "WASDBars" and its Hide Bar Art for action bar 2 is off, the addon SHALL draw the game's action bar border around action bar 2, the game's dividers between its buttons by the game's own rule, and give action bar 2's buttons the main bar's button frame. It SHALL follow action bar 2's Edit Mode settings and shown buttons, and SHALL NOT draw page arrows or end caps. Otherwise action bar 2 SHALL look as the game has it. Changes in combat SHALL wait until combat ends.

#### Scenario: Art shown
- **WHEN** a character on "WASDBars" has Hide Bar Art off for action bar 2
- **THEN** action bar 2 has action bar 1's border, dividers and button frames

#### Scenario: Padding raised
- **WHEN** the player raises action bar 2's icon padding above the minimum
- **THEN** the dividers go and the border still wraps the bar, as action bar 1 does

#### Scenario: Leaving the layout
- **WHEN** the character switches to Modern
- **THEN** action bar 2 has no added art and its own button frames

### Requirement: Hide Bar Art for action bar 2
On the "WASDBars" layout, action bar 2's Edit Mode settings SHALL include a "Hide Bar Art" checkbox (in LibEditMode's box under the game's settings) that turns the art off and on straight away. When setup creates "WASDBars", the checkbox SHALL start as action bar 1's Hide Bar Art was in the layout it was copied from; on a layout made before this, it SHALL start off (art shown).

#### Scenario: Turning it off
- **WHEN** the player ticks Hide Bar Art for action bar 2 and reloads
- **THEN** action bar 2 has no added art, and the box is still ticked

#### Scenario: Copied from a layout without art
- **WHEN** setup creates "WASDBars" from a layout whose action bar 1 has Hide Bar Art on
- **THEN** action bar 2's Hide Bar Art starts ticked

#### Scenario: Other layout
- **WHEN** the player selects action bar 2 in Edit Mode on Modern
- **THEN** there is no Hide Bar Art checkbox for it
