## MODIFIED Requirements

### Requirement: Slash command
The addon SHALL register `/wasd` with `help` and `version` subcommands, alongside the commands of the other capabilities.

#### Scenario: Help
- **WHEN** the player types `/wasd help`
- **THEN** chat lists every available subcommand with a one-line description

#### Scenario: Unknown subcommand
- **WHEN** the player types `/wasd nonsense`
- **THEN** chat says the command wasn't recognised and shows the help list
