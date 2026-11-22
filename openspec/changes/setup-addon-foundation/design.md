# Design: Addon foundation

## 1. Repository layout
Standard WoW addon layout: the repo root **is** the addon folder. The game only loads files listed in the TOC, so development files sitting alongside are harmless. Folders are created when first needed, so there are no empty placeholders.

```
WASDBars/                      repo root (linked into AddOns as "WASDBars")
  WASDBars.toc
  Core/
    Init.lua
    Events.lua
    Slash.lua
  Logic/
    Settings.lua
    CombatQueue.lua
  tests/
    helpers/
      wow_stubs.lua
      load_addon_file.lua
    logic/
      settings_spec.lua
      combat_queue_spec.lua
  scripts/
    setup-dev.sh
  openspec/
  .agents/  .claude/  skills-lock.json     Claude Code skills (committed)
  .busted
  .editorconfig
  .gitattributes
  .gitignore
  .luacheckrc
  .stylua.toml
  CLAUDE.md
  Makefile
  README.md
```

## 2. TOC
```
## Interface: 16001
## Title: WASDBars
## Notes: Shows your form action bar in the shape of the keys around WASD.
## Author: Matt
## Version: @project-version@
## SavedVariables: WASDBarsDB

Core/Init.lua
Core/Events.lua
Logic/Settings.lua
Logic/CombatQueue.lua
Core/Slash.lua
```
Settings are account-wide (per machine). Later changes append their files in the load order `Core` → `Logic` → `Data` → `UI`, with `Core/Slash.lua` and any wiring file last. `@project-version@` stays as-is until a packager exists (`add-curseforge-publishing`), so `/wasd version` shows "dev build".

## 3. Logic modules are pure and injectable
Each `Logic/` file attaches a table to `ns` and only defines functions. It never calls a WoW API function when the file loads, and functions that need the game receive it as an argument. Example:

```lua
local ADDON, ns = ...
local CombatQueue = {}
ns.CombatQueue = CombatQueue

-- isLocked: function returning true while in combat (InCombatLockdown in game)
function CombatQueue.new(isLocked, notify)
  local q = { order = {}, jobs = {}, notified = false }
  -- key: a name for the job, e.g. "scale". A newer job with the same key
  -- replaces the waiting one, so dragging a slider in combat applies once.
  function q:run(key, fn)
    if not isLocked() then fn(); return true end
    if not self.jobs[key] then table.insert(self.order, key) end
    self.jobs[key] = fn
    if not self.notified then notify(); self.notified = true end
    return false
  end
  function q:flush()
    local order, jobs = self.order, self.jobs
    self.order, self.jobs, self.notified = {}, {}, false
    for _, key in ipairs(order) do jobs[key]() end
  end
  return q
end
```
`Core/Init.lua` creates the real queue with `InCombatLockdown` and a print function, and `Core/Events.lua` calls `flush()` on `PLAYER_REGEN_ENABLED`.

`Settings.lua` holds `Settings.defaults` and `Settings.merge(saved, defaults)`, which fills missing keys (recursively for nested tables) without overwriting saved values. Later changes add their own defaults.

## 4. Unit test harness
- `tests/helpers/load_addon_file.lua` loads an addon file with `loadfile(path)` and calls it with `("WASDBars", ns)`, the same two values the game passes as `...`. Tests share one `ns` per test file.
- `tests/helpers/wow_stubs.lua` provides fake versions of the WoW functions that Logic modules receive (a controllable `InCombatLockdown`, table-backed `GetBindingKey` / `GetBindingAction`, and so on). Stubs are passed in as arguments, never installed as globals.
- `.busted`: `ROOT = {"tests"}`, `pattern = "_spec"`, `lpath = "./?.lua;./tests/?.lua"`.

## 5. Linting and formatting
`.luacheckrc`:
```lua
std = "lua51"
max_line_length = 120
exclude_files = { "tests/helpers/**", ".lua/**", ".tools/**", "openspec/**", ".agents/**", ".claude/**" }
globals = { "WASDBarsDB", "SLASH_WASDBARS1", "StaticPopupDialogs" }
read_globals = {
  -- grows with each change; only list what is actually used
  "CreateFrame", "UIParent", "InCombatLockdown",
  "SlashCmdList", "DEFAULT_CHAT_FRAME", "C_AddOns", "GetAddOnMetadata",
}
files["tests/**"] = { std = "+busted" }
```
`.stylua.toml`: `column_width = 120`, `indent_type = "Spaces"`, `indent_width = 2`, `quote_style = "AutoPreferDouble"`. StyLua runs on `Core Logic Data UI tests` (whichever exist).

## 6. MacBook development setup
**`scripts/setup-dev.sh` (`make setup`, run once):**
1. Check for Homebrew and Python 3; stop with a clear message if missing.
2. `brew install stylua` (skip if installed).
3. Create a project-local Lua 5.1 with LuaRocks using hererocks in its own virtual environment (Homebrew's Python refuses system-wide pip installs): `python3 -m venv .tools/venv`, `.tools/venv/bin/pip install hererocks`, then `.tools/venv/bin/hererocks .lua -l 5.1 -r latest`. Homebrew doesn't ship Lua 5.1, which is what the game uses.
4. `.lua/bin/luarocks install luacheck` and `.lua/bin/luarocks install busted`.

**Makefile:**
```
LUA_BIN := $(if $(wildcard .lua/bin),.lua/bin/,)
SRC := $(wildcard Core Logic Data UI tests)

setup:         scripts/setup-dev.sh
lint:          $(LUA_BIN)luacheck .
format:        stylua $(SRC)
format-check:  stylua --check $(SRC)
test:          $(LUA_BIN)busted
check:         lint format-check test
```

**Installing in game:** Claude Code creates a symlink named `WASDBars` in `/Applications/World of Warcraft/_forever_/Interface/AddOns/` pointing at the repo root, and never overwrites a real `WASDBars` folder.

## 7. Git files
- `.gitignore`: `.claude/settings.local.json`, `.tools/`, `.lua/`, `.luarocks/`, `lua_modules/`, `luacov.*`, `.DS_Store`, `Thumbs.db`, `*.zip`
- `.gitattributes`: `* text=auto eol=lf`, `*.tga binary`, `*.blp binary`, `*.png binary`
- `.editorconfig`: UTF-8, LF, 2-space indent, trim trailing whitespace, final newline

## 8. CLAUDE.md
Short and practical: what the addon is, "read `openspec/project.md` first", the roadmap and how to pick up the next change (grill it first), the make targets, the Logic/UI split, the no-per-frame-work rule, the combat queue rule, "add to the game's functions with hooksecurefunc, never replace them", "never change keybind or action-button code without updating the in-game checklist", and where to read in-game results (game folder, BugGrabber's SavedVariables, `Logs/taint.log`).

## 9. Slash command registry
`Core/Slash.lua` registers `/wasd`. It keeps `ns.Slash.commands`, a table of `name -> { help = "...", run = function(args) }`. Built-in commands:
- `help`: lists every registered command
- `version`: prints the TOC version (via `C_AddOns.GetAddOnMetadata` if present, else `GetAddOnMetadata`) without a leading `v`, or "dev build" if it still reads `@project-version@`
- `debug`: turns extra chat output (`ns.debug(...)`) on or off for this session; not saved

Later changes add commands by inserting into the table.

## Risks
- Settings don't sync between the Mac and the PC; that's how WoW saves addon data.
