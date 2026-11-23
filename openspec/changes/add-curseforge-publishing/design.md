# Design: CurseForge publishing

## 1. Packaging
`.pkgmeta` gains:
```yaml
required-dependencies:
  - libeditmode
```
and `docs` in its ignore list. The packager sends the dependency with each upload, so the CurseForge app installs LibEditMode alongside WASDBars. Check the slug on LibEditMode's CurseForge page.

## 2. Release workflow
`.github/workflows/release.yml` passes `CF_API_KEY: ${{ secrets.CF_API_KEY }}` to the packager. With the key and `## X-Curse-Project-ID` in the TOC, the packager uploads the zip to that project as well as creating the GitHub Release.

## 3. CurseForge project (manual, once)
- Create a World of Warcraft addon project named **WASDBars** (slug `wasdbars` if free)
- Summary (one line): "Shows your form action bar in the shape of the keys around WASD."
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

## 5. Listing content (`docs/curseforge/`)
- `description.md`: what it does, a screenshot, feature list, slash commands, how keybind setup works (and that it always asks first, and that binding Q and E replaces the default strafe keys), the known limitation that settings are saved per computer, a link to GitHub issues
- `icon.png` (square, CurseForge's current size requirement)
- `screenshots/`: the cluster in Bear and Cat form, the options panel, the keybind confirmation (the player takes them in game; Claude Code picks them up from `_forever_/Screenshots/`)

## 6. Versioning
The first CurseForge upload is a beta of the next version (for example `v1.1.0-beta.1`), installed through the CurseForge app on both machines; then the release.
