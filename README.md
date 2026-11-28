# WASDBars

A small World of Warcraft: Forever addon that arranges the game's own action bar 1 buttons (the bar that changes with form) into the shape of the keys around WASD: Q, E, R, T, F, G, Z, X, C, V and two mouse side buttons. The buttons keep all their normal behaviour; the addon only arranges, sizes and decorates them.

It's a personal tool, built for a feral druid who plays with WASD movement.

**Requires [LibEditMode](https://www.curseforge.com/wow/addons/libeditmode) and [LibEditModeOverride](https://www.curseforge.com/wow/addons/libeditmodeoverride)**, installed from CurseForge. Move and scale the cluster in the game's Edit Mode.

## Setup and undoing it

Nothing moves until you agree. On first login WASDBars offers to set up (or type `/wasd setup`). One window lists every change before anything happens: it moves action bar 1's buttons into the WASD shape, creates a **WASDBars** Edit Mode layout as a copy of the one you're using, puts action bar 2 exactly where action bar 1 was, moves the chat window up to make room for the cluster, and binds the keys around WASD to the cluster and the number row to action bar 2. Your other layouts are never changed. On the WASDBars layout action bar 2 also takes action bar 1's place and look: action bar 1 goes invisible, and action bar 2 gets its border and button frames (tick Hide Bar Art in action bar 2's Edit Mode settings to turn them off). The buttons are in the cluster only while the WASDBars layout is active; switch to another layout and they're back on action bar 1.

To undo it, type `/wasd restore` (or use Restore in the options) on each character you set up: you're switched back to your old layout, action bar 1's buttons go back where they were, and you're asked whether to put your keybinds back too. Then delete the WASDBars layout in Edit Mode if you like, and turn the addon off or uninstall it.

## Installing

Download the latest zip from [Releases](https://github.com/afoozle/WASDBars/releases/latest), or see **[INSTALL.md](INSTALL.md)** (Windows and macOS). It's written so that a person, or an AI agent told "install this addon: https://github.com/afoozle/WASDBars", can follow it.

## Development (Mac)

Needs Homebrew and Python 3. Then, once:

```sh
make setup
```

This downloads StyLua (the version in `.stylua-version`, which CI uses too) into `.tools/`, and installs a project-local Lua 5.1 with luacheck and busted in `.lua/` (via hererocks in `.tools/venv`).

| Target | What it does |
|---|---|
| `make setup` | Install the dev tools (run once) |
| `make lint` | luacheck, zero warnings allowed |
| `make format` | Format the Lua files with StyLua |
| `make format-check` | Check formatting without changing anything |
| `make test` | Run the busted unit tests |
| `make check` | lint + format-check + test |

To try it in game, symlink the repo root into `/Applications/World of Warcraft/_forever_/Interface/AddOns/` as `WASDBars` and `/reload`.

GitHub Actions runs lint, format check and tests on every push.

## Releasing

Add a section to `CHANGELOG.md` on `main`, commit, then tag and push:

```sh
git tag v1.0.1 && git push origin v1.0.1
```

The Release workflow runs the checks, builds `WASDBars-v1.0.1-forever.zip` with the [BigWigs packager](https://github.com/BigWigsMods/packager) (using `.pkgmeta`) and creates the GitHub Release. Tags containing `alpha` or `beta` become pre-releases. To build a zip without releasing, run the Release workflow by hand (dry run is on by default) and download the zip from the run.

Specs and the roadmap live in `openspec/`; start with `openspec/project.md`.

## License

MIT; see [LICENSE](LICENSE).
