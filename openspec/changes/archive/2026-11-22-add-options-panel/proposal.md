# Proposal: Options panel

## Why
One place in the game's own options to reach everything WASDBars offers, for the player and for anyone else if it goes public.

## What Changes
WASDBars options under AddOns in the game's options window, built from the game's standard settings rows. It replaces the Run setup page from `add-edit-mode-setup`.
- **Display:** "Move and resize" with an **Open Edit Mode** button (moving and scaling live in Edit Mode through LibEditMode).
- **Appearance:** **Show movement keys** and **Large hotkey text** checkboxes, both on by default. Large hotkey text off puts the game's own small corner text back.
- **Setup:** **Set up keybinds** (the keybind window) and **Check layout** (the Edit Mode layout check).
- `/wasd options` opens it; plain `/wasd` still shows help.

## Decided when grilled (2026-11-22)
- The earlier plan's lock, scale and reset controls are gone: Edit Mode covers them (`add-position-and-scale`). The mouse outline was never built, so no checkbox for it.
- The two setup buttons replace "Set up WASD keys…" / "Set up number row…": the keybind window already handles both groups in one go.

## Depends on
`polish-look-and-messages`

## Impact
- New capability spec: `options-panel`
- `UI/Options.lua` rewritten; `Cluster.refreshHotkeys`, `MovementKeys.setShown`
- New settings: `showMovementKeys`, `largeHotkeys`
