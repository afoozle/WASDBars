# Design: GitHub releases

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
  - openspec
  - Makefile
  - CLAUDE.md
  - INSTALL.md
  - README.md
  - skills-lock.json
```
The packager leaves out dot-files and dot-folders (`.github`, `.agents`, `.claude`, `.luacheckrc`, `.lua/` and so on) by itself; the dry run's zip confirms it. LICENSE and CHANGELOG.md stay in the package.

- Version: the packager replaces `@project-version@` with the tag exactly as written (for example `v1.0.0`); `/wasd version` already strips the leading `v`.
- `CHANGELOG.md` in Keep a Changelog format. From here on, each release adds a section.

## 2. CI
`.github/workflows/ci.yml` on push and pull request: install Lua 5.1 and LuaRocks (`leafo/gh-actions-lua`, `leafo/gh-actions-luarocks`), `luarocks install luacheck busted`, StyLua check (`JohnnyMorganz/stylua-action`), then `make lint test`.

## 3. Releases
`.github/workflows/release.yml` on tags matching `v*`: check out with full history, run the same checks, then `BigWigsMods/packager@v2` with `GITHUB_OAUTH: ${{ secrets.GITHUB_TOKEN }}` (the workflow needs `contents: write`). The packager builds `WASDBars-<tag>-forever.zip` (it adds the game flavour it reads from the TOC's interface number) and creates the GitHub Release with it attached, using the CHANGELOG as the release notes. With no `CF_API_KEY` and no `X-Curse-Project-ID` it uploads nowhere else.

- Tags containing `alpha` or `beta` become GitHub pre-releases (the packager's standard behaviour).
- A `workflow_dispatch` trigger with a `dry_run` input (default true). Dry runs pass `-d` (skip uploads) and attach the built zip to the workflow run as an artifact.
- Claude Code watches runs with `gh run watch` and reads failures with `gh run view --log-failed`.

## 4. Installing from a release
`INSTALL.md` step 3 offers two ways: the release zip (download `WASDBars-<version>-forever.zip` from the latest GitHub Release and unzip it into AddOns; it already holds a `WASDBars/` folder) or the git clone (for unreleased work). Updating a zip install means replacing the folder.

## 5. Versioning
- Fixes bump the patch number, features the minor number.
- Releasing: add the CHANGELOG section on `main`, commit, tag `vX.Y.Z`, push the tag. Claude Code does this when the player says to release.
