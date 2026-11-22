# Proposal: Arrange action bar 1 in the WASD shape

## Why
This is the core of the addon: showing action bar 1's buttons in the shape of the keys around WASD, so the player can see which key does what at a glance, in whatever form they're in.

The simplest way is to move **the game's own action bar 1 buttons** into that shape rather than building new ones. The game's buttons already do everything an action button needs: icons, cooldowns, rage/range/usable colours, the queued Maul highlight, counts, tooltips, keybind labels, following Bear/Cat forms in combat, and drag and drop. The addon only arranges, sizes and decorates them. Established bar addons (for example Dominos) take over the game's buttons the same way.

## What Changes
- Builds on the findings of `spike-button-takeover`, which proved the game's action buttons can be moved into the cluster and stay there (buttons 1–10; this change adds 11 and 12, the buttons the mouse side buttons are bound to)
- An editable layout table (`Data/Layout.lua`) mapping action buttons 1–10 to Q, E, R, T, F, G, Z, X, C, V and buttons 11 and 12 to a column just right of the keyboard shape, with keyboard positions and size tiers
- Pure layout maths (`Logic/LayoutGeometry.lua`)
- A container frame anchored to the top-left of action bar 2 (`MultiBarBottomLeft`), so it follows that bar until `add-position-and-scale` makes the cluster movable on its own, holding:
  - The game's action buttons 1–12, positioned like the keys and sized in three tiers (1.0 for keys touching WASD, 0.8 for further-out keys and buttons 11–12, 0.6 for W/A/S/D)
  - W, A, S, D as small dimmed keys drawn with the game's own empty-slot art, with the key letter and a direction arrow (the game's own arrow art) on top
- Layout is applied once at login. As a cheap safety check, when Edit Mode layouts change (`EDIT_MODE_LAYOUTS_UPDATED`) the addon checks whether any button has left the cluster and re-applies through the combat queue if so. The spike found nothing else ever moves them, so there are no hooks into the game's bar code.
- Game art only: no custom textures in this change.
- The main bar's leftover art, empty-slot visibility and action bar 2 are **not** touched by the addon. While testing this change the player sets them up by hand in Edit Mode (Action Bar 1: "Hide Bar Art", "Hide Bar Scrolling", "Always Show Buttons" and "# of Icons" 12; drag Action Bar 2 into Action Bar 1's old spot and move the now-empty Action Bar 1 out of the way, since it still catches the mouse). `add-edit-mode-setup` later does this for the player.

Everything an action button does (feedback, form following, drag and drop, keybind labels) comes from the game; this change adds none of it.

## Decided when grilled (2026-11-22)
- Action buttons keep the game's own hotkey text, even though it won't match the WASD positions until `add-key-binding-setup` sets the binds. Letters are drawn only on W, A, S, D.
- No "Fwd"/"Back" relabel and no mouse outline. Buttons 11 and 12 are two ordinary keys in the cluster. A mouse outline may come in a later change if it seems worth it.
- Size tiers 1.0 / 0.8 / 0.6 for a clearer visual difference.

## Depends on
`setup-addon-foundation` (and the spike's findings)

## Impact
- New capability spec: `wasd-layout`
- New files: `Data/Layout.lua`, `Logic/LayoutGeometry.lua`, `UI/Cluster.lua`, `UI/MovementKeys.lua`

## Out of Scope
- Moving and scaling the cluster (`add-position-and-scale`), hiding the movement keys (`add-options-panel`), hiding the main bar art, showing empty slots and moving action bar 2 (`add-edit-mode-setup`), a mouse outline and thumb-button labels (a possible later change)
