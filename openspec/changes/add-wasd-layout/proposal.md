# Proposal: Arrange action bar 1 in the WASD shape

## Why
This is the core of the addon: showing action bar 1's buttons in the shape of the keys around WASD, so the player can see which key does what at a glance, in whatever form they're in.

The simplest way is to move **the game's own action bar 1 buttons** into that shape rather than building new ones. The game's buttons already do everything an action button needs: icons, cooldowns, rage/range/usable colours, the queued Maul highlight, counts, tooltips, keybind labels, following Bear/Cat forms in combat, and drag and drop. The addon only arranges, sizes and decorates them. Established bar addons (for example Dominos) take over the game's buttons the same way.

## What Changes
- Builds on the findings of `spike-button-takeover`, which proved the game's action buttons can be moved into the cluster and stay there (buttons 1–10; this change adds 11 and 12 for the mouse side buttons)
- An editable layout table (`Data/Layout.lua`) mapping action buttons 1–12 to Q, E, R, T, F, G, Z, X, C, V and the front/back mouse side buttons, with keyboard positions and size tiers
- Pure layout maths (`Logic/LayoutGeometry.lua`)
- A container frame at a fixed default position (bottom centre) holding:
  - The game's action buttons 1–12, positioned like the keys and sized in three tiers (keys touching WASD largest, further-out keys and mouse buttons slightly smaller)
  - W, A, S, D as small dimmed keys with direction arrows only
  - A simple mouse outline with the two side-button actions on its left edge, front above back, labelled "Fwd" and "Back"
- Layout is applied once at login. As a cheap safety check, when Edit Mode layouts change (`EDIT_MODE_LAYOUTS_UPDATED`) the addon checks whether any button has left the cluster and re-applies through the combat queue if so. The spike found nothing else ever moves them, so there are no hooks into the game's bar code.
- The main bar's leftover art and action bar 2 are **not** touched here. While testing this change the player sets them up by hand in Edit Mode (Action Bar 1: "Hide Bar Art" and "Hide Bar Scrolling"; drag Action Bar 2 into Action Bar 1's old spot). `add-edit-mode-setup` later does this for the player.

Everything an action button does (feedback, form following, drag and drop) comes from the game; this change adds none of it.

## Depends on
`setup-addon-foundation` (and the spike's findings)

## Impact
- New capability spec: `wasd-layout`
- New files: `Data/Layout.lua`, `Logic/LayoutGeometry.lua`, `UI/Cluster.lua`, `UI/MovementKeys.lua`, `UI/MouseOutline.lua`

## Out of Scope
- Moving and scaling the cluster (`add-position-and-scale`), hiding the movement keys or mouse outline (`add-options-panel`), hiding the main bar art and moving action bar 2 (`add-edit-mode-setup`)

## Open question for this change's grilling
The "Fwd"/"Back" relabel: `ActionButton_UpdateHotkeys` doesn't exist on Forever, so the hook has to go on the button mixin's `UpdateHotkeys` method (or similar). Decide the exact hook, or whether the relabel is worth it at all.
