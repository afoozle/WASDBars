# Proposal: CurseForge publishing

## Why
Optional, for going public. `add-github-releases` already builds versioned zips and GitHub Releases from tags. This change uploads the same zips to CurseForge so other players can find WASDBars, get the libraries installed automatically and be told about updates.

## What Changes
- **CurseForge project:** created and filled in once by hand
- **Uploads:** the release workflow also uploads each version tag's zip to CurseForge, with the CHANGELOG and the WoW Forever game version
- **Dependencies:** `.pkgmeta` already declares LibEditMode and LibEditModeOverride (from `add-layout-setup`), so the CurseForge app installs them with WASDBars
- Release type follows the tag: `v1.2.0` → release, `v1.2.0-beta.1` → beta, `v1.2.0-alpha.1` → alpha (the packager's standard behaviour)
- Listing content kept in `docs/curseforge/` (ignored by the packager)
- First CurseForge upload is a beta, installed through the CurseForge app on both machines before the first public release

## Depends on
`add-github-releases`, `simplify-after-restructure`

## Impact
- New capability spec: `curseforge-publishing`
- Changed: `.pkgmeta` (`docs` ignored), `.github/workflows/release.yml` (`CF_API_KEY`), the TOC (`## X-Curse-Project-ID`), `INSTALL.md` (CurseForge as the first choice)
- New files: `docs/curseforge/`
- New GitHub secret: `CF_API_KEY` (never stored in the repo)
