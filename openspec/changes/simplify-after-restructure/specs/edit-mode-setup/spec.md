## REMOVED Requirements

### Requirement: Setup commands and status
**Reason**: `/wasd setup status` is removed; running `/wasd setup` already says when everything is set up.
**Migration**: Use `/wasd setup`.

## ADDED Requirements

### Requirement: Setup command
`/wasd setup` SHALL open the setup window, or say everything is set up.

#### Scenario: Nothing to do
- **WHEN** everything is set up and the player types `/wasd setup`
- **THEN** chat says everything is set up and no window opens
