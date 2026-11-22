# Design: Move and scale the display in Edit Mode

## 1. LibEditMode
- Installed by the player from CurseForge ("Lib: EditMode", folder `LibEditMode`, v19 at the time of writing; its TOC lists interface `16001` and game type `camelot`, so it supports Forever). It bundles LibStub.
- `WASDBars.toc` gets `## Dependencies: LibEditMode`, so the game loads it first and refuses to load WASDBars without it.
- Used through `LibStub("LibEditMode")`:
  - `AddFrame(frame, callback, default)`: makes the cluster a selectable Edit Mode element. `callback(frame, layoutName, point, x, y)` fires after every drag or position reset; the library stores nothing itself.
  - `AddFrameSettings(frame, settings)`: the Scale slider (`kind = SettingType.Slider`, `get(layoutName)`, `set(layoutName, value, fromReset)`, `default`, `minValue`, `maxValue`, `valueStep`).
  - `RegisterCallback("layout", fn(layoutName))`: fires when the active layout changes, including at login. The library doesn't reposition frames; the addon does.
- The library drags with `StartMoving`, so the cluster is `SetMovable(true)`; it is also `SetClampedToScreen(true)`.
- Positions from the library are `point, x, y` relative to `UIParent` (same point on both), with offsets in the frame's own scaled units.

## 2. Settings
- `Settings.defaults.layouts = {}`; saved as `WASDBarsDB.layouts[layoutName] = { point = "BOTTOMLEFT", x = 200, y = 81, scale = 1.0 }`.
- The default position and scale live in `Data/Layout.lua` as `ns.Layout.position = { point = ..., x = ..., y = ... }` and `ns.Layout.scale = 1.0`; the numbers are set from the player's placement during the in-game checks. `ns.Layout.anchor` (relative to action bar 2) is removed.

## 3. `Logic/Placement.lua` (pure, unit tested)
- `Placement.clampScale(n)`: `n` limited to 0.5–2.0; `nil` if `n` isn't a number.
- `Placement.forLayout(layouts, layoutName, defaultPosition, defaultScale)`: returns `point, x, y, scale` for a layout. Uses the saved values when they are valid (point is one of the nine anchor names, x and y are numbers, scale a number, clamped), otherwise the defaults; a damaged entry never errors.
- `Placement.save(layouts, layoutName, fields)`: creates the layout's entry if needed and merges `fields` (`point`, `x`, `y` and/or `scale`) into it.

## 4. `UI/EditMode.lua`
- At `PLAYER_LOGIN`, after `UI/Cluster.lua` has built the cluster:
  - Movable and clamped to screen; registered with `AddFrame` using the default position, and the Scale slider with `AddFrameSettings`.
  - `apply(layoutName)`: reads `Placement.forLayout`, then through `ns.combatQueue:run("placement", ...)`: `SetScale(scale)`, `ClearAllPoints()`, `SetPoint(point, UIParent, point, x, y)`.
  - Applies the active layout straight away (`GetActiveLayoutName()`, or the defaults if it isn't known yet), and again on the `layout` callback.
- Drag callback: `Placement.save` the new point; the library has already moved the frame.
- Scale setter: `Placement.save` the clamped scale, then `apply(layoutName)` (scale first, then the saved point, because offsets are in scaled units).
- Edit Mode can't be opened in combat and the library ignores drags in combat, so dragging and the slider only ever run out of combat; layout changes and login go through the combat queue.

## 5. Cluster changes (`UI/Cluster.lua`)
- `WASDBarsCluster` is created without a point; `UI/EditMode.lua` positions it. The anchor to `MultiBarBottomLeft` is removed, and `MultiBarBottomLeft` leaves `.luacheckrc`'s read globals.
