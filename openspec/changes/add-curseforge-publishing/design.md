# Design: CurseForge publishing

## 1. Packaging
`.pkgmeta` gains `docs` in its ignore list. Its `required-dependencies` (`libeditmode`, `libeditmodeoverride`) come from `add-layout-setup`; the packager sends them with each upload, so the CurseForge app installs both alongside WASDBars. Check the slugs on their CurseForge pages.

## 2. Release workflow
`.github/workflows/release.yml` passes `CF_API_KEY: ${{ secrets.CF_API_KEY }}` to the packager. With the key and `## X-Curse-Project-ID` in the TOC, the packager uploads the zip to that project as well as creating the GitHub Release.

## 3. CurseForge project (manual, once)
- Create a World of Warcraft addon project named **WASDBars** (slug `wasdbars` if free)
- Summary (one line): "Arranges action bar 1's buttons in the shape of the keys around WASD."
- Category: Action Bars; licence: MIT
- Description, icon and screenshots come from `docs/curseforge/` (section 5)
- Create an API token in CurseForge account settings and store it as the GitHub repo secret `CF_API_KEY`
- Add `## X-Curse-Project-ID: <id>` to the TOC. The packager reads it and uploads to that project (the ID isn't secret).

## 4. Game version
CurseForge tags every file with game versions, and the CurseForge app uses that to decide which game flavour a file is for. The packager works this out from the TOC's `## Interface` number (`16001`). **This is the main unknown; check it first, before any manual CurseForge work beyond an account:**
1. Do a dry run with `CF_API_KEY` set and check which game version the packager would use (it's printed in the log).
2. Confirm CurseForge has a matching WoW Forever entry. If the packager doesn't pick it automatically, pass it explicitly with the packager's `-g` option.
3. If CurseForge has no WoW Forever entry at all, stop: GitHub Releases stay the way to install.
Record the finding in this file.

**Found so far (2026-11-23, `add-github-releases` dry run):** the packager recognises the TOC as WoW Forever ("Build type: non-retail version-forever", "Game version: 1.60.1") and names the zip `...-forever.zip`. Still to check: that CurseForge accepts uploads for that game version.

## 5. Listing content (`docs/curseforge/`)
- `description.md`: what it does, a screenshot, feature list, slash commands, how setup works (one window lists every change first; it makes its own WASDBars Edit Mode layout, puts action bar 2 in action bar 1's place, and binding Q and E replaces the default strafe keys), how to undo it (`/wasd restore`), the known limitation that settings are saved per computer, a link to GitHub issues
- `icon.png` (square, CurseForge's current size requirement)
- `screenshots/`: the cluster in Bear and Cat form, action bar 2 with action bar 1's art, the options panel, the setup window (the player takes them in game; Claude Code picks them up from `_forever_/Screenshots/`)

## 6. Versioning
The first CurseForge upload is a beta of the next version after v1.1.1 (for example `v1.2.0-beta.1`), installed through the CurseForge app on both machines; then the release.
