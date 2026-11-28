# Contributing to WASDBars

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

## How the code is laid out

[CLAUDE.md](CLAUDE.md) has the code rules (feature folders, logic files tested with busted, thin game files), and `openspec/project.md` has the goals and the roadmap. Specs and planned changes live in `openspec/`.

## Releasing

See **Releasing** in [CLAUDE.md](CLAUDE.md): tag `vX.Y.Z` on `main` and the Release workflow builds the zip with the [BigWigs packager](https://github.com/BigWigsMods/packager) and publishes it.
