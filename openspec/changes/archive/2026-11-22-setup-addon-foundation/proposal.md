# Proposal: Set up the addon foundation

## Why
Every later feature needs the same groundwork: a repo laid out the way WoW addons normally are, an addon that loads cleanly, saved settings, a safe way to defer work until combat ends, and checks that catch mistakes before they reach the game. It's kept lean so the tool can be iterated on quickly; release machinery waits until the addon goes public (`add-curseforge-publishing`).

## What Changes
- `git init` in this folder, in the **standard WoW addon layout** (repo root = addon folder, TOC at the root). No GitHub remote yet.
- Tooling:
  - **luacheck** with a WoW-aware `.luacheckrc`
  - **StyLua** formatting
  - **busted** unit tests in `tests/`, with WoW API stubs and a helper that loads addon files the way the game does
  - `Makefile` targets: `setup`, `lint`, `format`, `format-check`, `test`, `check`
  - One-step MacBook setup (`make setup`)
- `CLAUDE.md` describing the project, the roadmap and the make targets for Claude Code
- Core skeleton inside the addon: TOC, init, events, settings merge, combat queue, `/wasd` with `help`, `version` and `debug`
- Unit tests for Settings and CombatQueue
- The repo is symlinked into the Mac's AddOns folder by Claude Code when asked

## Not in this change
Packager, `.pkgmeta`, CI, release workflow, GitHub Releases, link scripts, LICENSE and CHANGELOG all move to `add-curseforge-publishing`.

## Depends on
`spike-button-takeover` (passed)

## Impact
- New capability spec: `addon-foundation`
- The addon loads and does nothing visible except respond to `/wasd help`, `/wasd version` and `/wasd debug`
