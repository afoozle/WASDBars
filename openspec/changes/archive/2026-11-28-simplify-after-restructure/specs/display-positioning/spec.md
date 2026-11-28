## REMOVED Requirements

### Requirement: Reset and defaults
**Reason:** Only the addon and LibEditMode's scale slider write the saved positions, so the defences against a damaged saved position are gone.
**Migration:** Replaced by "Default position and reset", without the damaged-position scenario.

## ADDED Requirements

### Requirement: Default position and reset
When setup creates the "WASDBars" layout it SHALL place the display at the bottom left (see `edit-mode-setup`); otherwise the display SHALL start at a default position and scale 1.0. The player SHALL be able to restore the default position and scale from its Edit Mode settings.

#### Scenario: Reset
- **WHEN** the player uses "Reset To Default Position" and resets the settings in the display's Edit Mode settings
- **THEN** the display returns to the default position at scale 1.0

#### Scenario: Scale before moving
- **WHEN** the player changes the display's scale on a layout where it was never dragged
- **THEN** the display keeps the default position at the new scale
