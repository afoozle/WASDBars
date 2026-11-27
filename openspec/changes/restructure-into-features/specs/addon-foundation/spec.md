## MODIFIED Requirements

### Requirement: Testable logic modules
Decisions SHALL live in logic files: plain functions that take data and return data, make no game calls and take no game functions as arguments. Code that talks to the game SHALL live in separate game files in the same feature folder. The test harness SHALL load logic files the same way the game does (with the addon name and a shared namespace table).

#### Scenario: Loading a logic file in tests
- **WHEN** a test loads `Core/SavedSettings.lua` through the test helper
- **THEN** `ns.SavedSettings` is available and no WoW globals were needed
