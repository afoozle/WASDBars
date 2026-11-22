# curseforge-publishing

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

### Requirement: Windows PC install
The addon SHALL be installable on the Windows PC from the release zip, and a clone SHALL be linkable into the game with a script that makes a directory junction named `WASDBars` without admin rights, remembers the game path after asking once, and never overwrites a real `WASDBars` folder.

#### Scenario: Clone and link
- **WHEN** `scripts/link-addon.ps1` is run in a clone on the Windows PC
- **THEN** AddOns contains a junction named `WASDBars` pointing at the clone, and the addon loads

#### Scenario: Existing folder
- **WHEN** the script finds a real (non-link) `WASDBars` folder already in AddOns
- **THEN** it stops with a message and changes nothing

### Requirement: Publish on version tag
Pushing a version tag SHALL, after all checks pass, upload the packager's zip to the WASDBars CurseForge project, tagged with the WoW Forever game version and with the CHANGELOG attached, and create a GitHub Release with the same zip.

#### Scenario: Release tag
- **WHEN** tag `v1.0.0` is pushed
- **THEN** CurseForge has a new `1.0.0` file marked as a release, for WoW Forever, with the CHANGELOG showing the `1.0.0` section first
- **AND** GitHub Release `v1.0.0` has the same zip attached

#### Scenario: Checks fail
- **WHEN** a tag is pushed and lint or unit tests fail
- **THEN** nothing is uploaded to CurseForge and no GitHub Release is created

### Requirement: Release type from tag
The CurseForge release type SHALL follow the tag name: tags containing "alpha" are alpha, tags containing "beta" are beta, and all other version tags are releases.

#### Scenario: Beta
- **WHEN** tag `v1.0.0-beta.1` is pushed
- **THEN** the CurseForge file is marked beta

### Requirement: Package contents
The published zip SHALL contain only a single `WASDBars/` folder with the addon's files, and SHALL match what `make package` produces.

#### Scenario: Inspecting the download
- **WHEN** the CurseForge download is unzipped
- **THEN** it contains one `WASDBars/` folder with the TOC, Lua files, LICENSE and CHANGELOG, and no development files

### Requirement: Dry run
The release workflow SHALL support a manual dry run that runs every step except uploading, and makes the built zip available to download from the workflow run.

#### Scenario: Dry run
- **WHEN** the workflow is started by hand with dry run on
- **THEN** the zip is built and attached to the workflow run
- **AND** nothing is uploaded to CurseForge or GitHub Releases

### Requirement: Credentials kept out of the repo
The CurseForge API token SHALL only be stored as a GitHub repository secret and SHALL never appear in the repo, workflow logs or the package.

#### Scenario: Secret use
- **WHEN** the workflow uploads to CurseForge
- **THEN** it reads the token from the `CF_API_KEY` secret and the token is masked in logs

### Requirement: Installs cleanly from CurseForge
A file published to CurseForge SHALL install through the CurseForge app into WoW Forever on both macOS and Windows and load without errors or wrong-flavour warnings.

#### Scenario: CurseForge app
- **WHEN** the player installs WASDBars through the CurseForge app for WoW Forever
- **THEN** the addon appears in the game's AddOns list, loads with no errors, and the app shows no flavour mismatch warning
