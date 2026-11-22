#!/usr/bin/env bash
# One-time MacBook dev setup: StyLua via Homebrew, plus a project-local
# Lua 5.1 with luacheck and busted (the game runs Lua 5.1; Homebrew doesn't ship it).
set -euo pipefail

cd "$(dirname "$0")/.."

if ! command -v brew >/dev/null 2>&1; then
  echo "setup: Homebrew is missing. Install it from https://brew.sh and run make setup again." >&2
  exit 1
fi
if ! command -v python3 >/dev/null 2>&1; then
  echo "setup: Python 3 is missing. Install it with 'brew install python' and run make setup again." >&2
  exit 1
fi
if ! command -v cc >/dev/null 2>&1; then
  echo "setup: no C compiler. Install the Xcode Command Line Tools with 'xcode-select --install'." >&2
  exit 1
fi

if command -v stylua >/dev/null 2>&1; then
  echo "setup: StyLua already installed"
else
  brew install stylua
fi

# Homebrew's Python refuses system-wide pip installs, so hererocks gets its own venv.
if [ ! -x .tools/venv/bin/hererocks ]; then
  python3 -m venv .tools/venv
  .tools/venv/bin/pip install --quiet hererocks
fi

if [ ! -x .lua/bin/lua ]; then
  .tools/venv/bin/hererocks .lua -l 5.1 -r latest
fi

for rock in luacheck busted; do
  if ! .lua/bin/luarocks show "$rock" >/dev/null 2>&1; then
    .lua/bin/luarocks install "$rock"
  fi
done

echo "setup: done. Run make check."
