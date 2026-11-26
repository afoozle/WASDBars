## RENAMED Requirements

- FROM: `### Requirement: Movement keys with letters and direction arrows`
- TO: `### Requirement: Movement keys with direction arrows`

## MODIFIED Requirements

### Requirement: Movement keys with direction arrows
W, A, S and D SHALL be shown as small, non-clickable keys drawn with the game's own empty action slot art, each showing a large direction arrow from the game's own art and no letter (W up, A left, S down, D right). The addon SHALL NOT ship its own textures for this.

#### Scenario: Arrows
- **WHEN** the cluster is shown
- **THEN** W shows an up arrow, A left, S down and D right, and clicking them does nothing

### Requirement: Other bars left alone
The cluster SHALL NOT hide, move or change the main bar's art or settings, action bar 2, the micro menu or the bags. (The `edit-mode-setup` layout check lists the Edit Mode settings the player changes by hand.)

#### Scenario: After loading
- **WHEN** the cluster is shown
- **THEN** action bar 2, the micro menu and bags are where they were
