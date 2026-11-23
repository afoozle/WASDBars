# Tasks: GitHub releases

## 1. Packaging
- [x] 1.1 `.pkgmeta` (design.md section 1); add `.release/` to `.gitignore`
- [x] 1.2 CHANGELOG.md with a first section

## 2. CI and releases
- [x] 2.1 `.github/workflows/ci.yml` (design.md section 2); lint, format check and tests pass in CI
- [x] 2.2 `.github/workflows/release.yml` with the `workflow_dispatch` dry run (design.md section 3)
- [x] 2.3 Dry run: the workflow passes, the zip is attached as an artifact, no release is created
- [x] 2.4 Download the dry run's zip and unzip it: one `WASDBars/` folder with the TOC, the addon's Lua files, LICENSE and CHANGELOG, and no dot-files, `skills-lock.json` or ignored files; the TOC's version line holds the build's version

## 3. Docs
- [x] 3.1 `INSTALL.md`: the release zip as an option in step 3, and updating a zip install (design.md section 4)
- [x] 3.2 README, `openspec/project.md` and CLAUDE.md: releases, and how to release

## 4. First release
- [ ] 4.1 Merge to `main`, tag and push; CI passes on `main`
- [ ] 4.2 The GitHub Release exists with the zip attached and the CHANGELOG as notes
- [ ] 4.3 In game (Mac, dev symlink): `/wasd version` still says "Dev build."; the addon loads with no errors
- [ ] 4.4 Optional, on the Windows PC: replace the clone with the release zip; the addon loads and `/wasd version` shows the release's version
- [ ] 4.5 Archive this change
