# github-releases

## ADDED Requirements

### Requirement: Version from git tag
The TOC version SHALL be a packager token replaced with the git tag when packaging, and `/wasd version` SHALL show it without the leading `v`.

#### Scenario: Tagged build
- **WHEN** the release for tag `v1.0.0` is installed and the player types `/wasd version`
- **THEN** chat shows `1.0.0`

### Requirement: Checks in CI
CI SHALL run lint, format check and unit tests on every push and pull request.

#### Scenario: CI
- **WHEN** a commit is pushed
- **THEN** CI runs lint, format check and tests, and marks the commit failed if any fail

### Requirement: Release on version tag
Pushing a version tag SHALL, after all checks pass, create a GitHub Release with the packager's zip attached and the CHANGELOG as its notes.

#### Scenario: Release tag
- **WHEN** tag `v1.0.0` is pushed
- **THEN** GitHub Release `v1.0.0` exists with `WASDBars-v1.0.0.zip` attached

#### Scenario: Checks fail
- **WHEN** a tag is pushed and lint, format check or unit tests fail
- **THEN** no GitHub Release is created

### Requirement: Pre-release from tag
Tags containing "alpha" or "beta" SHALL create GitHub pre-releases; all other version tags SHALL create normal releases.

#### Scenario: Beta
- **WHEN** tag `v1.1.0-beta.1` is pushed
- **THEN** the GitHub Release is marked as a pre-release

### Requirement: Package contents
The release zip SHALL contain only a single `WASDBars/` folder with the addon's files.

#### Scenario: Inspecting the download
- **WHEN** the release zip is unzipped
- **THEN** it contains one `WASDBars/` folder with the TOC, Lua files, LICENSE and CHANGELOG, and no development files

### Requirement: Dry run
The release workflow SHALL support a manual dry run that runs every step except releasing, and makes the built zip available to download from the workflow run.

#### Scenario: Dry run
- **WHEN** the workflow is started by hand with dry run on
- **THEN** the zip is built and attached to the workflow run
- **AND** no GitHub Release is created
