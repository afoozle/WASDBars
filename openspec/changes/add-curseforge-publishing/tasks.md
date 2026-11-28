# Tasks: CurseForge publishing

## 1. Game version (first: decides whether the rest is worth doing)
- [ ] 1.1 Create a CurseForge account and API token; add it to the GitHub repo as secret `CF_API_KEY`
- [ ] 1.2 Dry run with the key; check which game version the packager would use and whether CurseForge has a WoW Forever entry (design.md section 4); record the finding

## 2. CurseForge project (manual)
- [ ] 2.1 Create the CurseForge project (design.md section 3); note the project ID
- [ ] 2.2 Add `## X-Curse-Project-ID` to the TOC

## 3. Packaging and workflow
- [x] 3.1 `.pkgmeta`: `docs` ignored (design.md section 1; the dependencies are declared by `add-layout-setup`)
- [ ] 3.2 `release.yml` passes `CF_API_KEY` (design.md section 2)

## 4. Listing content
- [ ] 4.1 `docs/curseforge/description.md` (design.md section 5)
- [ ] 4.2 Icon
- [ ] 4.3 Screenshots: Bear form, Cat form, action bar 2 with its art, options panel, setup window (taken on the Mac)
- [ ] 4.4 Paste description, icon and screenshots into the CurseForge project page

## 5. First beta
- [ ] 5.1 Add a beta CHANGELOG section, merge, tag the beta
- [ ] 5.2 CurseForge shows the file as **beta**, tagged with the WoW Forever game version, with the CHANGELOG and LibEditMode and LibEditModeOverride as required dependencies
- [ ] 5.3 Install through the CurseForge app on the Mac (remove the dev symlink first, put it back after) and on the Windows PC; the addon loads with no errors and the app doesn't warn about the wrong game flavour
- [ ] 5.4 On the installed beta, record `bear-pull` and ask Claude Code to check performance

## 6. Public release
- [ ] 6.1 Fix anything from the beta, add the release's CHANGELOG section, merge, tag
- [ ] 6.2 CurseForge shows it as a **release**; the CurseForge app offers it as an update over the beta
- [ ] 6.3 `INSTALL.md`: CurseForge as the first way to install
- [ ] 6.4 Archive this change
