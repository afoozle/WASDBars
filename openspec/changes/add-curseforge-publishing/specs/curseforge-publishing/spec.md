# curseforge-publishing

## ADDED Requirements

### Requirement: Publish to CurseForge on version tag
Pushing a version tag SHALL, after all checks pass, upload the same zip as the GitHub Release to the WASDBars CurseForge project, tagged with the WoW Forever game version and with the CHANGELOG attached.

#### Scenario: Release tag
- **WHEN** tag `v1.2.0` is pushed
- **THEN** CurseForge has a new `1.2.0` file for WoW Forever, with the CHANGELOG showing the `1.2.0` section first

#### Scenario: Checks fail
- **WHEN** a tag is pushed and lint or unit tests fail
- **THEN** nothing is uploaded to CurseForge

### Requirement: Release type from tag
The CurseForge release type SHALL follow the tag name: tags containing "alpha" are alpha, tags containing "beta" are beta, and all other version tags are releases.

#### Scenario: Beta
- **WHEN** tag `v1.2.0-beta.1` is pushed
- **THEN** the CurseForge file is marked beta

### Requirement: Libraries installed with it
Each CurseForge file SHALL declare LibEditMode and LibEditModeOverride as required dependencies.

#### Scenario: Installing through the app
- **WHEN** the player installs WASDBars through the CurseForge app without the libraries
- **THEN** the app installs LibEditMode and LibEditModeOverride too

### Requirement: Credentials kept out of the repo
The CurseForge API token SHALL only be stored as a GitHub repository secret and SHALL never appear in the repo, workflow logs or the package.

#### Scenario: Secret use
- **WHEN** the workflow uploads to CurseForge
- **THEN** it reads the token from the `CF_API_TOKEN` secret and the token is masked in logs

### Requirement: Installs cleanly from CurseForge
A file published to CurseForge SHALL install through the CurseForge app into WoW Forever on both macOS and Windows and load without errors or wrong-flavour warnings.

#### Scenario: CurseForge app
- **WHEN** the player installs WASDBars through the CurseForge app for WoW Forever
- **THEN** the addon appears in the game's AddOns list, loads with no errors, and the app shows no flavour mismatch warning
