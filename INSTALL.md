# Installing WASDBars

Written so that a person, or an AI agent such as Claude Code given only "install this addon: https://github.com/afoozle/WASDBars", can install it on Windows or macOS.

WASDBars is an addon for **World of Warcraft: Forever** only (interface `16001`). Install a release (recommended) or a git clone of this repository (for unreleased work).

## Summary
1. Find the Forever AddOns folder.
2. Install the required library, **LibEditMode**, through CurseForge.
3. Put WASDBars (a release zip or a git clone) in the AddOns folder as a folder named exactly `WASDBars`.
4. Check it in game.

## 1. Find the Forever AddOns folder
The game folder contains one subfolder per game version. WASDBars goes in **`_forever_`**, never `_retail_`, `_classic_` or `_classic_era_`.

| System | Usual AddOns folder |
|---|---|
| Windows | `C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns` |
| macOS | `/Applications/World of Warcraft/_forever_/Interface/AddOns` |

If it isn't there:
- On Windows, also look on other drives (`D:\World of Warcraft\...`, `D:\Games\World of Warcraft\...`), or open the Battle.net app → World of Warcraft → the gear icon → **Show in Explorer**.
- If `_forever_` exists but `Interface\AddOns` doesn't, create both folders.
- If there's no `_forever_` folder at all, the Forever client isn't installed: stop and tell the player.

Agents: confirm the folder with the player before writing to it.

## 2. Install LibEditMode (required)
WASDBars won't load without it. The player installs it through CurseForge, like their other addons:
- **CurseForge app:** World of Warcraft → make sure the **Forever** version is selected → search **"LibEditMode"** (listed as "Lib: EditMode") → Install.
- **Or the website:** https://www.curseforge.com/wow/addons/libeditmode → download the latest file and extract it into the AddOns folder, so it holds `LibEditMode\LibEditMode.toc`.

Use the CurseForge package rather than the library's own source repository: the package includes LibStub, which the source doesn't.

Agents: ask the player to do this step (or to confirm it's done), then check that `AddOns\LibEditMode\LibEditMode.toc` exists.

## 3. Install WASDBars
The folder must be named exactly `WASDBars`, with `WASDBars.toc` directly inside it: `AddOns\WASDBars\WASDBars.toc`. Any other name or extra nesting (such as `WASDBars-main\WASDBars-main\...`) means the game won't load it.

If `AddOns\WASDBars` already exists, don't overwrite it: update it instead (see Updating), or ask the player.

Writing under `C:\Program Files (x86)` can need an administrator prompt; if extracting or cloning fails with "Permission denied" or "Access denied", run it from an elevated terminal or ask the player.

**From a release (recommended).** Open https://github.com/afoozle/WASDBars/releases/latest and download `WASDBars-v<version>-forever.zip` (not GitHub's "Source code" archives). It already holds a `WASDBars` folder: extract it straight into the AddOns folder from step 1. On Windows (PowerShell):
```powershell
$zip = "$env:TEMP\WASDBars.zip"
$url = (Invoke-RestMethod https://api.github.com/repos/afoozle/WASDBars/releases/latest).assets | Where-Object name -like 'WASDBars-*.zip' | Select-Object -First 1 -ExpandProperty browser_download_url
Invoke-WebRequest $url -OutFile $zip
Expand-Archive $zip "C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns"
```
On macOS:
```sh
url=$(curl -s https://api.github.com/repos/afoozle/WASDBars/releases/latest | grep -o 'https://[^"]*/WASDBars-[^"]*\.zip' | head -1)
curl -L -o /tmp/WASDBars.zip "$url"
unzip /tmp/WASDBars.zip -d "/Applications/World of Warcraft/_forever_/Interface/AddOns"
```

**With git (for unreleased work, or if the player prefers it).** On Windows (PowerShell), with the AddOns folder from step 1:
```powershell
git clone https://github.com/afoozle/WASDBars.git "C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\WASDBars"
```
On macOS:
```sh
git clone https://github.com/afoozle/WASDBars.git "/Applications/World of Warcraft/_forever_/Interface/AddOns/WASDBars"
```
A clone also holds development files (`openspec/`, `tests/`, `.agents/` and so on). They're harmless: the game only loads the files `WASDBars.toc` lists. Release zips leave them out.

## 4. Check it in game
1. Start the game (or `/reload` if it's running) and open **AddOns** on the character select screen: **WASDBars** and **Lib: EditMode** are listed and ticked. If WASDBars shows "Dependency missing", step 2 isn't done.
2. Log in: action bar 1's buttons appear as a cluster shaped like the keys around WASD.
3. On a character whose keys aren't set up, WASDBars offers to set them up. It always shows what will change before changing any keybind.
4. `/wasd` lists the commands; `/wasd options` opens its options; move and scale the cluster in the game's Edit Mode (select "WASDBars").

`/wasd version` shows the release's version, or "Dev build." for a git clone; both are expected.

## Updating
- **Release install:** delete the `WASDBars` folder (keep everything else in AddOns), install the latest release as in step 3, then `/reload` in game. Settings and keybinds are kept.
- **Git clone:** `git pull` in the `WASDBars` folder, then `/reload` in game.

To tell which one it is: a git clone has a `.git` folder inside `WASDBars`.

## Uninstalling
Delete `AddOns\WASDBars`. Its settings are in `_forever_\WTF\Account\<ACCOUNT>\SavedVariables\WASDBars.lua` (delete that too for a clean slate). Keybinds it set stay until changed in the game's Key Bindings.
