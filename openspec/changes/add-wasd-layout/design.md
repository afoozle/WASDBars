# Design: Arrange action bar 1 in the WASD shape

## 1. Spike findings
From `archive/2026-11-22-spike-button-takeover` (full detail there):
- Forever runs the modern UI. The main bar is `MainActionBar`, managed by Edit Mode; each `ActionButtonN` sits in its own `MainActionBarButtonContainerN`.
- Buttons are protected and 45×45 (`baseSize` = `ActionButton1:GetWidth()`), with `useparent-actionpage = true`. Re-parented to a plain frame, form paging still works in and out of combat.
- Nothing in the game moved the buttons back: 157 hooked bar and Edit Mode functions and 5 events, 0 times out of place. One apply at login was enough.
- Action bar 2 (`MultiBarBottomLeft`) is parented to `UIParent`, so it isn't affected by anything done to the main bar.
- The main bar art is unnamed textures; Edit Mode's own "Hide Bar Art" and "Hide Bar Scrolling" settings cover it.
- The spike only moved buttons 1–10; this change's in-game checks confirm 11 and 12 behave the same.

## 2. Layout data (`Data/Layout.lua`)
Positions are in key units (1 unit = one primary key plus a gap). Each key is **centred** on its grid point, so smaller keys shrink towards their centre and rows still line up. `button` is the action button number (1–12).

| Size tier | Weight | Keys |
|---|---|---|
| `primary` | 1.0 | Keys touching W, A, S or D: Q, E, R, F, Z, X, C |
| `secondary` | about 0.85 | T, G, V and both mouse side buttons |
| `movement` | about 0.7 | W, A, S, D |

```lua
ns.Layout = {
  sizes = { primary = 1.0, secondary = 0.85, movement = 0.7 },
  keys = {
    { label = "Q", button = 1,  x = 0.5,  y = 0, size = "primary" },
    { label = "W", movement = "up",    x = 1.5,  y = 0 },
    { label = "E", button = 2,  x = 2.5,  y = 0, size = "primary" },
    { label = "R", button = 3,  x = 3.5,  y = 0, size = "primary" },
    { label = "T", button = 4,  x = 4.5,  y = 0, size = "secondary" },
    { label = "A", movement = "left",  x = 0.75, y = 1 },
    { label = "S", movement = "down",  x = 1.75, y = 1 },
    { label = "D", movement = "right", x = 2.75, y = 1 },
    { label = "F", button = 5,  x = 3.75, y = 1, size = "primary" },
    { label = "G", button = 6,  x = 4.75, y = 1, size = "secondary" },
    { label = "Z", button = 7,  x = 1.25, y = 2, size = "primary" },
    { label = "X", button = 8,  x = 2.25, y = 2, size = "primary" },
    { label = "C", button = 9,  x = 3.25, y = 2, size = "primary" },
    { label = "V", button = 10, x = 4.25, y = 2, size = "secondary" },
  },
  mouse = {
    offsetX = 6.2, offsetY = 0,   -- outline position relative to the cluster, in key units
    keys = {
      { label = "Fwd",  button = 11, position = "front", size = "secondary" },
      { label = "Back", button = 12, position = "back",  size = "secondary" },
    },
  },
}
```

## 3. Layout maths (`Logic/LayoutGeometry.lua`)
`LayoutGeometry.compute(layout, baseSize, gap)` returns, for each key, its centre point and scale relative to the cluster's top-left, plus the cluster's total size and the mouse outline's rectangle.
- Grid point: `(x * (baseSize + gap) + baseSize/2, y * (baseSize + gap) + baseSize/2)`
- Scale: `sizes[tier]`. The game's buttons keep their own size and are shrunk with `SetScale`, so positions are given as centre points; the UI divides the offset by the button's scale when anchoring (a scaled frame's offsets are in its own scaled units).
- Mouse outline: about 1.5 primary keys wide and 2.5 tall; side buttons centred on its left edge at about 30% (front) and 70% (back) of its height.
`baseSize` is the game's action button size. Pure and unit tested.

## 4. Taking over the buttons (`UI/Cluster.lua`)
- A plain frame `WASDBarsCluster`, anchored bottom centre above the default bars. Because it will hold protected buttons, it is only moved or resized out of combat (`add-position-and-scale` handles that).
- `applyLayout()`, out of combat only: for each layout entry, `ActionButtonN:SetParent(cluster)`, `ClearAllPoints()`, `SetPoint("CENTER", cluster, "TOPLEFT", cx / scale, -cy / scale)`, `SetScale(scale)`.
- **Mouse button labels:** the game labels thumb buttons with its own short names. After the game updates a button's hotkey text, a `hooksecurefunc` on the button's hotkey update (the mixin's `UpdateHotkeys`; `ActionButton_UpdateHotkeys` doesn't exist on Forever; exact hook decided when this change is grilled) replaces it with "Fwd" or "Back" for `BUTTON5` and `BUTTON4`. Only the label text changes.
- **Staying in place:** `applyLayout` runs once at `PLAYER_LOGIN` through `ns.queue:run("layout", applyLayout)`. On `EDIT_MODE_LAYOUTS_UPDATED` the addon checks whether any button's parent is no longer the cluster and, if so, queues the same job. No hooks into the game's bar or Edit Mode code.
- **Main bar art and action bar 2:** not touched by this change (see proposal). `MainActionBar`, action bar 2, the micro menu and bags are never modified here.
- Nothing here runs per frame, and nothing touches the buttons in combat.

## 5. Decorations
- `UI/MovementKeys.lua`: plain frames in the cluster, no mouse interaction, dashed dimmed border, arrow texture rotated per direction (the game's own arrow art if suitable, otherwise `Media/arrow.tga`).
- `UI/MouseOutline.lua`: plain non-interactive frame drawn with line textures for the body, button split and wheel, placed behind the two side-button actions.

## 6. What comes free from the game
Icons, cooldowns, rage/usable/range colours, the queued Maul highlight, item counts, tooltips, keybind labels, following Bear/Cat/Prowl in and out of combat, and drag and drop (drop on, drag off, swap, Shift-drag when bars are locked, nothing in combat). The addon adds no code for any of these. In-game checks confirm each still works after moving.
