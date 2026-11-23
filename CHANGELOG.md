# Changelog

All notable changes to WASDBars. The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and versions follow [Semantic Versioning](https://semver.org/).

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
