# Proposal: GitHub releases

## Why
WASDBars installs from a git clone on both machines, which works but has no version numbers, no automatic checks and nothing anyone else can simply download. This change adds packaged, versioned GitHub Releases and checks that run on every push. It is also the first half of publishing: `add-curseforge-publishing` adds the CurseForge upload on top without redoing any of it.

## What Changes
- **Packaging:** the BigWigs packager with `.pkgmeta` (ignoring every development file), the version taken from the git tag (`@project-version@` replaced; `/wasd version` already strips the `v`), and CHANGELOG.md
- **CI:** GitHub Actions runs lint, format check and tests on every push and pull request
- **Releases:** a workflow on version tags runs the checks, builds the zip and creates a GitHub Release with it attached; tags containing `alpha` or `beta` become pre-releases
- A manual dry-run option on the release workflow that builds the zip without releasing
- `INSTALL.md` offers the release zip alongside the git clone

Already done outside this change: the GitHub repo, LICENSE (MIT) and the Windows PC install (`INSTALL.md`, a git clone). The planned `scripts/link-addon.ps1` is dropped: cloning straight into AddOns worked first time on the PC.

## Depends on
`add-performance-recording`

## Impact
- New capability spec: `github-releases`
- New files: `.pkgmeta`, `.github/workflows/ci.yml`, `.github/workflows/release.yml`, `CHANGELOG.md`
- Changed: `INSTALL.md`, `README.md`, `openspec/project.md`, `CLAUDE.md` (releasing)
