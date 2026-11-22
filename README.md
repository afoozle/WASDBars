# WASDBars

A small World of Warcraft: Forever addon that arranges the game's own action bar 1 buttons (the bar that changes with form) into the shape of the keys around WASD: Q, E, R, T, F, G, Z, X, C, V and two mouse side buttons. The buttons keep all their normal behaviour; the addon only arranges, sizes and decorates them.

It's a personal tool, built for a feral druid who plays with WASD movement.

**Requires [LibEditMode](https://www.curseforge.com/wow/addons/libeditmode)**, installed from CurseForge. Move and scale the cluster in the game's Edit Mode.

## Development (Mac)

Needs Homebrew and Python 3. Then, once:

```sh
make setup
```

This installs StyLua with Homebrew, and a project-local Lua 5.1 with luacheck and busted in `.lua/` (via hererocks in `.tools/venv`).

| Target | What it does |
|---|---|
| `make setup` | Install the dev tools (run once) |
| `make lint` | luacheck, zero warnings allowed |
| `make format` | Format the Lua files with StyLua |
| `make format-check` | Check formatting without changing anything |
| `make test` | Run the busted unit tests |
| `make check` | lint + format-check + test |

To try it in game, symlink the repo root into `/Applications/World of Warcraft/_forever_/Interface/AddOns/` as `WASDBars` and `/reload`.

Specs and the roadmap live in `openspec/`; start with `openspec/project.md`.

## License

MIT; see [LICENSE](LICENSE).
