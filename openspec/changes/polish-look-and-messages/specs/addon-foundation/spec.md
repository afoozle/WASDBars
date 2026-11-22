# addon-foundation

## ADDED Requirements

### Requirement: Chat message style
Every chat message SHALL start with "WASDBars: " (the prefix in light blue) followed by plain-language sentences that start with a capital letter and end with a full stop (or a colon before indented list lines). An action SHALL produce one line, not one per part.

#### Scenario: Combat message
- **WHEN** work is deferred during combat
- **THEN** chat shows "WASDBars: Will apply after combat."
