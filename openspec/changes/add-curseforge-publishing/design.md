# Design: Publish (releases, Windows PC and CurseForge)

## 1. Packaging
**`.pkgmeta`** at the root:
```yaml
package-as: WASDBars

manual-changelog:
  filename: CHANGELOG.md
  markup-type: markdown

ignore:
  - tests
  - scripts
  - docs
  - openspec
  - Makefile
  - CLAUDE.md
  - README.md
  - skills-lock.json
```
The packager leaves out dot-files and dot-folders (`.github`, `.agents`, `.claude`, `.luacheckrc`, `.lua/` and so on) by itself; the package check confirms it. LICENSE and CHANGELOG.md stay in the package. CurseForge will show the whole CHANGELOG.md, newest section first.

- `make setup` also installs a newer bash (`brew install bash`; macOS's built-in one is too old for the packager) and downloads a pinned copy of the packager's `release.sh` into `.tools/`.
- `make package` runs `scripts/package.sh`: the packager with `-d` (no upload); the zip lands in `.release/` (git-ignored). Local and CI zips are identical.
- Version: the packager replaces `@project-version@` with the tag exactly as written (for example `v1.0.0`); `/wasd version` strips the leading `v`.
- Add `LICENSE` (MIT) and `CHANGELOG.md` (Keep a Changelog format). From here on, each finished change adds a CHANGELOG section and is tagged.

## 2. GitHub, CI and releases
- Create the GitHub repo and push `main`.
- `.github/workflows/ci.yml` on push and pull request: install Lua 5.1 and LuaRocks (`leafo/gh-actions-lua`, `leafo/gh-actions-luarocks`), `luarocks install luacheck busted`, StyLua check (`JohnnyMorganz/stylua-action`), then `make lint test`.
- `.github/workflows/release.yml` on tags matching `v*`: check out with full history, run the same checks, then `BigWigsMods/packager@v2` with `GITHUB_OAUTH: ${{ secrets.GITHUB_TOKEN }}` and `CF_API_KEY: ${{ secrets.CF_API_KEY }}`. The packager builds `WASDBars-<tag>.zip`, creates the GitHub Release with it attached, and uploads to CurseForge.
- A `workflow_dispatch` trigger with a `dry_run` input (default true). Dry runs pass `-d` (skip uploads) and attach the built zip to the workflow run as an artifact.

## 3. Windows PC
1. **Release zip (default):** download `WASDBars-<version>.zip` from the GitHub Release (or install through the CurseForge app) and unzip into `_forever_\Interface\AddOns\`.
2. **Clone + link (unreleased work):** clone the repo, run `scripts/link-addon.ps1`, which creates a directory junction named `WASDBars` in AddOns pointing at the clone (no admin rights needed). Default path `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns`, otherwise ask once and remember it in git-ignored `scripts/.gamepath`. Refuse to overwrite a real `WASDBars` folder. Update with `git pull`, then `/reload`.
- `.gitattributes` gains `*.ps1 text eol=crlf`.

## 4. CurseForge project (manual, once)
- Create a World of Warcraft addon project named **WASDBars** (slug `wasdbars` if free)
- Summary (one line): "Shows your form action bar in the shape of the keys around WASD."
- Category: Action Bars; licence: MIT
- Description, icon and screenshots come from `docs/curseforge/` (section 6)
- Create an API token in CurseForge account settings and store it as the GitHub repo secret `CF_API_KEY`
- Add `## X-Curse-Project-ID: <id>` to the TOC. The packager reads it and uploads to that project (the ID isn't secret).

## 5. Game version
CurseForge tags every file with game versions, and the CurseForge app uses that to decide which game flavour a file is for. The packager works this out from the TOC's `## Interface` number (`16001`). Before the first real upload:
1. Do a dry run and check which game version the packager would use (it's printed in the log).
2. Confirm CurseForge has a matching WoW Forever entry. If the packager doesn't pick it automatically, pass it explicitly with the packager's `-g` option.
Record the finding in this file before the first beta.

## 6. Listing content (`docs/curseforge/`)
- `description.md`: what it does, a screenshot, feature list, slash commands, how keybind setup works (and that it always asks first, and that binding Q and E replaces the default strafe keys), the known limitation that settings are saved per computer, a link to GitHub issues
- `icon.png` (square, CurseForge's current size requirement)
- `screenshots/`: the cluster in Bear and Cat form, the options panel, the keybind confirmation

## 7. Versioning
- First public release is `1.0.0`. Before it, upload `1.0.0-beta.1` and install it through the CurseForge app on both machines.
- Later fixes bump the patch number, features the minor number. CHANGELOG gets a section per version.
