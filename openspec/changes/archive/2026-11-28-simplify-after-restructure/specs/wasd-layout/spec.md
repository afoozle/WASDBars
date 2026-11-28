## REMOVED Requirements

### Requirement: Layout holds
**Reason:** The spike found nothing moves the buttons out of the cluster, so the check that put stray buttons back on Edit Mode updates is gone.
**Migration:** Replaced by "Layout stays in place", without the Edit Mode re-apply.

## ADDED Requirements

### Requirement: Layout stays in place
While the "WASDBars" layout is active, the layout SHALL stay in place through form changes, combat, reloads, zoning, bar page changes and Edit Mode changes. The addon SHALL never move or change the buttons during combat, and SHALL cause no "Interface action blocked" errors.

#### Scenario: Reload
- **WHEN** the player reloads the UI on the "WASDBars" layout
- **THEN** the buttons are back in the cluster

#### Scenario: Edit Mode changes
- **WHEN** the player edits the "WASDBars" layout in Edit Mode
- **THEN** the buttons stay in the cluster
