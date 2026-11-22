# Tasks: Publish (releases, Windows PC and CurseForge)

## 1. Packaging
- [ ] 1.1 `.pkgmeta` (design.md section 1); add `.release/` and `scripts/.gamepath` to `.gitignore`
- [ ] 1.2 Extend `make setup` with bash and the pinned packager; add `scripts/package.sh` and `make package`
- [ ] 1.3 Add LICENSE (MIT) and CHANGELOG.md
- [ ] 1.4 `make package`: unzip the result; it contains one `WASDBars/` folder with the TOC, the addon's Lua files, LICENSE and CHANGELOG, and no dot-files, `skills-lock.json` or ignored folders

## 2. GitHub, CI and releases
- [ ] 2.1 Create the GitHub repo and push
- [ ] 2.2 `.github/workflows/ci.yml` (design.md section 2); lint and tests pass in CI
- [ ] 2.3 `.github/workflows/release.yml` with the `workflow_dispatch` dry run
- [ ] 2.4 Dry run: workflow passes, zip is attached as an artifact, nothing is uploaded anywhere

## 3. Windows PC
- [ ] 3.1 `scripts/link-addon.ps1` (design.md section 3)
- [ ] 3.2 On the PC: clone, run the script, the junction works and the addon loads with no errors
- [ ] 3.3 Update README with installing on Mac and Windows, and that settings don't carry between machines

## 4. CurseForge setup (manual)
- [ ] 4.1 Create the CurseForge project (design.md section 4); note the project ID
- [ ] 4.2 Create a CurseForge API token and add it to the GitHub repo as secret `CF_API_KEY`
- [ ] 4.3 Add `## X-Curse-Project-ID` to the TOC
- [ ] 4.4 Check the game version the packager would use and record it (design.md section 5)

## 5. Listing content
- [ ] 5.1 `docs/curseforge/description.md` (design.md section 6)
- [ ] 5.2 Icon
- [ ] 5.3 Screenshots: Bear form, Cat form, options panel, keybind confirmation (take on the Mac)
- [ ] 5.4 Paste description, icon and screenshots into the CurseForge project page

## 6. First beta
- [ ] 6.1 Add a `1.0.0-beta.1` CHANGELOG section, merge, tag `v1.0.0-beta.1`
- [ ] 6.2 CurseForge shows the file as **beta**, tagged with the WoW Forever game version, with the CHANGELOG (newest section first)
- [ ] 6.3 GitHub Release `v1.0.0-beta.1` exists with the same zip; `/wasd version` in game shows `1.0.0-beta.1`
- [ ] 6.4 Install through the CurseForge app on the Mac (remove the dev symlink first, put it back after) and on the Windows PC; the addon loads with no errors and the app doesn't warn about the wrong game flavour
- [ ] 6.5 Unzip the downloaded file: it contains only the `WASDBars/` folder with no development files
- [ ] 6.6 On the installed beta, record `bear-pull` and ask Claude Code to check performance

## 7. Public release
- [ ] 7.1 Fix anything from the beta, add the `1.0.0` CHANGELOG section, merge, tag `v1.0.0`
- [ ] 7.2 CurseForge shows `1.0.0` as a **release**; the CurseForge app offers it as an update over the beta
- [ ] 7.3 Archive this change
