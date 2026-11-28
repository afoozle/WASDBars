# Changelog

All notable changes to WASDBars. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/).

## [1.1.0] - 2026-11-26

Now also requires LibEditModeOverride.

### Added
- Setup makes the Edit Mode changes itself, in its own **WASDBars** layout copied from the one you're using: action bar 2 placed exactly where action bar 1 was, the gryphons hidden, the cluster bottom left and the chat window moved up to make room. Your other layouts are never changed.
- Keys and layout are set up in one window that lists every change before anything happens.
- Action bar 2 takes action bar 1's place on the WASDBars layout: action bar 1 goes invisible (the bars above it stay where they are), and action bar 2 gets action bar 1's border, dividers and button frames. Turn them off by ticking **Hide Bar Art** in action bar 2's Edit Mode settings.
- `/wasd restore` switches you back to your old layout, puts action bar 1's buttons back, and asks whether to put your keybinds back too.
- A one-line reminder at login on characters that aren't set up.

### Changed
- Nothing moves until you agree: action bar 1's buttons go into the WASD shape only when you confirm setup, and only while the WASDBars layout is active. Switch to another layout and they're back on action bar 1.
- Setup and restore end with a **Reload to finish** button, so your action bars can't be blocked in your next fight.
- Setup and restore refuse to run in combat instead of waiting for it to end.

## [1.0.1] - 2026-11-23

### Fixed
- Confirming keybinds during combat and then running `/wasd setup` before combat ended could drop the confirmed keybinds.
- Running `/wasd setup` while the keybind window was already open skipped the Edit Mode layout check.

### Changed
- Removed fallback code for game clients other than WoW Forever.

## [1.0.0] - 2026-11-23

First release, for World of Warcraft: Forever. Requires LibEditMode.

### Added
- Action bar 1's buttons arranged in the shape of the keys around WASD: Q, E, R, T, F, G, Z, X, C, V and the two mouse side buttons, offset like a real keyboard. The buttons keep all their normal behaviour.
- W, A, S and D shown as empty keys with arrows (can be turned off).
- Large, centred hotkey text on the cluster (can be turned off).
- Move and scale the cluster in the game's Edit Mode.
- Keybind setup that shows what will change, and which keys lose their action, before changing anything: action bar 1 on the keys around WASD, action bar 2 on the number row (1–0, - and =).
- A check of the game's Edit Mode settings for action bar 1 that lists anything to fix by hand.
- Setup offered once per character; run it again any time with `/wasd setup`.
- Options in the game's settings window (`/wasd options`).
- Performance recording with the game's addon profiler (`/wasd perf`).
