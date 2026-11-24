## REMOVED Requirements

### Requirement: Setup buttons
**Reason:** Set up keybinds and Check layout belonged to the old two-step setup; keys and layout are now one setup window, and restore is new.
**Migration:** See "Setup and restore buttons".

## ADDED Requirements

### Requirement: Setup and restore buttons
The page's Setup section SHALL have a Run setup button that does what `/wasd setup` does, and a Restore button that does what `/wasd restore` does, each with a one-line description.

#### Scenario: Run setup from the page
- **WHEN** the player clicks Run setup and then Set up in the window
- **THEN** the layout and keys are set up exactly as with `/wasd setup`

#### Scenario: Restore from the page
- **WHEN** the player clicks Restore
- **THEN** the same restore popups appear as with `/wasd restore`
