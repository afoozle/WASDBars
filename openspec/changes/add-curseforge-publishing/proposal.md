# Proposal: Publish (releases, Windows PC and CurseForge)

## Why
Optional, for going public. Until now the addon is a dev checkout symlinked into the Mac's game folder. Publishing adds everything needed to install it anywhere else: a packaged zip, versions from git tags, GitHub Releases, a clean install path for the Windows PC, and uploads to CurseForge so other players can use it. All of this was kept out of the foundation to keep the personal version lean.

## What Changes
- **Packaging:** the BigWigs packager with `.pkgmeta` (ignoring every development file), `make package` for a local zip, the version taken from the git tag (`@project-version@` replaced, `/wasd version` shows it without the `v`), LICENSE (MIT) and CHANGELOG.md
- **CI:** GitHub Actions runs lint, format check and tests on every push and pull request
- **GitHub:** create the remote; a release workflow on version tags runs the checks, builds the zip and creates a GitHub Release with it attached
- **Windows PC:** install from the release zip, or clone and run `scripts/link-addon.ps1` (a directory junction, no admin rights) to test unreleased work
- **CurseForge:** a project for WASDBars, created and filled in once by hand; the release workflow uploads each version tag's zip with the CHANGELOG entry and the WoW Forever game version
- Release type follows the tag: `v1.2.0` → release, `v1.2.0-beta.1` → beta, `v1.2.0-alpha.1` → alpha (the packager's standard behaviour)
- A manual dry-run option on the release workflow
- Listing content kept in `docs/curseforge/`
- First public version `1.0.0`, preceded by a `1.0.0-beta.1` test upload

## Depends on
`add-performance-recording`

## Impact
- New capability spec: `curseforge-publishing`
- New files: `.pkgmeta`, `scripts/package.sh`, `scripts/link-addon.ps1`, `.github/workflows/ci.yml`, `.github/workflows/release.yml`, `LICENSE`, `CHANGELOG.md`, `docs/curseforge/`; `## X-Curse-Project-ID` in the TOC
- New GitHub secret: `CF_API_KEY` (never stored in the repo)
