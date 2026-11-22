# Design: Move and scale the display

## 1. Settings
- Defaults: `point = { "BOTTOM", "UIParent", "BOTTOM", 0, 180 }`, `scale = 1.0`, `locked = true`
- `Settings.clampScale(n)` in `Logic/Settings.lua`: returns `n` clamped to 0.5–2.0, or `nil` if `n` isn't a number. Unit tested.
- If the saved `point` isn't a table of the expected shape at login, the default is used.

## 2. Mover (`UI/Mover.lua`)
- Unlocked: a thin labelled bar above the cluster ("WASDBars: drag to move, /wasd lock when done"), drag with the left mouse button (`StartMoving` / `StopMovingOrSizing`), then save the point relative to `UIParent`.
- Locked: handle hidden, cluster not movable.
- The cluster is clamped to the screen.

## 3. Public API (`ns.Display`)
```lua
ns.Display.isLocked()          -- for the options panel
ns.Display.setLocked(bool)
ns.Display.getScale()
ns.Display.setScale(n)         -- uses Settings.clampScale
ns.Display.reset()
```
Each call saves the setting immediately and applies it through the combat queue with a fixed key (`"scale"`, `"point"`), so repeated requests in one combat apply once with the latest value. Unlocking in combat is refused with a message, because the cluster holds the game's action buttons and can't be moved mid-fight.

## 4. Commands
- `/wasd unlock`, `/wasd lock`, `/wasd reset`
- `/wasd scale <number>`: for example `/wasd scale 1.25`. Values outside 0.5–2.0 are limited with a message; anything that isn't a number shows the allowed range.
