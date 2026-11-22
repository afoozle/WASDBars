# Installing WASDBars

Written so that a person, or an AI agent such as Claude Code given only "install this addon: https://github.com/afoozle/WASDBars", can install it on Windows or macOS.

WASDBars is an addon for **World of Warcraft: Forever** only (interface `16001`). It has no release builds yet: you install it straight from this repository.

## Summary
1. Find the Forever AddOns folder.
2. Install the required library, **LibEditMode**, through CurseForge.
3. Put this repository in the AddOns folder as a folder named exactly `WASDBars`.
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

If `AddOns\WASDBars` already exists, don't overwrite it: if it's a git clone, update it instead (see Updating); otherwise ask the player.

**With git (preferred, makes updating easy).** On Windows (PowerShell), with the AddOns folder from step 1:
```powershell
git clone https://github.com/afoozle/WASDBars.git "C:\Program Files (x86)\World of Warcraft\_forever_\Interface\AddOns\WASDBars"
```
On macOS:
```sh
git clone https://github.com/afoozle/WASDBars.git "/Applications/World of Warcraft/_forever_/Interface/AddOns/WASDBars"
```
Writing under `C:\Program Files (x86)` can need an administrator prompt; if the clone fails with "Permission denied", run it from an elevated terminal or ask the player.

**Without git.** Download https://github.com/afoozle/WASDBars/archive/refs/heads/main.zip, extract it, rename the extracted `WASDBars-main` folder to `WASDBars`, and move it into the AddOns folder.

The repository also holds development files (`openspec/`, `tests/`, `.agents/` and so on). They're harmless: the game only loads the files `WASDBars.toc` lists.

## 4. Check it in game
1. Start the game (or `/reload` if it's running) and open **AddOns** on the character select screen: **WASDBars** and **Lib: EditMode** are listed and ticked. If WASDBars shows "Dependency missing", step 2 isn't done.
2. Log in: action bar 1's buttons appear as a cluster shaped like the keys around WASD.
3. On a character whose keys aren't set up, WASDBars offers to set them up. It always shows what will change before changing any keybind.
4. `/wasd` lists the commands; `/wasd options` opens its options; move and scale the cluster in the game's Edit Mode (select "WASDBars").

`/wasd version` says "Dev build." for installs from this repository; that's expected.

## Updating
With git: `git pull` in the `WASDBars` folder, then `/reload` in game. Without git: delete the `WASDBars` folder and repeat step 3.

## Uninstalling
Delete `AddOns\WASDBars`. Its settings are in `_forever_\WTF\Account\<ACCOUNT>\SavedVariables\WASDBars.lua` (delete that too for a clean slate). Keybinds it set stay until changed in the game's Key Bindings.
