# Design: CurseForge publishing

## 1. Packaging
`.pkgmeta` gains `docs` in its ignore list. Its `required-dependencies` (`libeditmode`, `libeditmodeoverride`) come from `add-layout-setup`; the packager sends them with each upload, so the CurseForge app installs both alongside WASDBars. Check the slugs on their CurseForge pages.

## 2. Release workflow
`.github/workflows/release.yml` passes `CF_API_KEY: ${{ secrets.CF_API_KEY }}` to the packager. With the key and `## X-Curse-Project-ID` in the TOC, the packager uploads the zip to that project as well as creating the GitHub Release.

## 3. CurseForge project (manual, once)
- Create a World of Warcraft addon project named **WASDBars** (slug `wasdbars` if free)
- Summary (one line): "Arranges action bar 1's buttons in the shape of the keys around WASD."
- Category: Action Bars; licence: MIT
- Description from `README.md`, icon and screenshots from `docs/images/` (section 5)
- Create an API token in CurseForge account settings and store it as the GitHub repo secret `CF_API_KEY`
- Add `## X-Curse-Project-ID: <id>` to the TOC. The packager reads it and uploads to that project (the ID isn't secret).

## 4. Game version
CurseForge tags every file with game versions, and the CurseForge app uses that to decide which game flavour a file is for. The packager works this out from the TOC's `## Interface` number (`16001`). **This is the main unknown; check it first, before any manual CurseForge work beyond an account:**
1. Do a dry run with `CF_API_KEY` set and check which game version the packager would use (it's printed in the log).
2. Confirm CurseForge has a matching WoW Forever entry. If the packager doesn't pick it automatically, pass it explicitly with the packager's `-g` option.
3. If CurseForge has no WoW Forever entry at all, stop: GitHub Releases stay the way to install.
Record the finding in this file.

**Found so far (2026-11-23, `add-github-releases` dry run):** the packager recognises the TOC as WoW Forever ("Build type: non-retail version-forever", "Game version: 1.60.1") and names the zip `...-forever.zip`. Still to check: that CurseForge accepts uploads for that game version.

## 5. Listing content
- `README.md` is the description (the player's pitch and FAQ; development notes are in `CONTRIBUTING.md`). Paste it without the centred icon and title at the top (CurseForge shows its own icon and name) and without its Installing and Developing sections. It covers what it does, a screenshot, feature list, slash commands, how setup works (one window lists every change first; it makes its own WASDBars Edit Mode layout, puts action bar 2 in action bar 1's place, and binding Q and E replaces the default strafe keys), how to undo it (`/wasd restore`), the known limitation that the cluster's position is saved per computer, a link to GitHub issues; the player wrote the final text
- `docs/images/icon.png` (square, CurseForge's current size requirement): keycaps drawn in code, the player picks from a few versions
- `docs/images/screenshots/`: before setup, the setup window, after setup (the cluster, and action bar 2 with action bar 1's art), 1280×720, with the character name and other addons' chat lines removed; plus `cluster.png`, the cluster cropped at full resolution from the after-setup shot, shown in the description

## 6. Versioning and the beta
Grilled 2026-11-28. v1.2.0 is already on GitHub, so the first CurseForge upload is `v1.2.1-beta.1`: the same code plus the project ID and the API key. It is installed through the CurseForge app on the Mac and the Windows PC and checked for both libraries, the WoW Forever flavour and a clean load (no performance recording: `/wasd perf` was removed, and nothing here runs in combat). On the Mac, Claude Code removes only the dev symlink before the install, checks the installed folder afterwards, and asks before deleting it and putting the link back. Then `v1.2.1` is the public release.
