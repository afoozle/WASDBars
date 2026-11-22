# Proposal: Options panel

## Why
Optional, for going public: the personal version is driven by slash commands. Slash commands work but are hard to remember for other players. The player needs one place to see and change every setting, set up keybinds, and move or scale the display.

## What Changes
- WASDBars options under AddOns in the game's own options window, built entirely from the game's **standard settings controls** (checkboxes, a slider, buttons and section headers). No custom window is drawn; the game lays out, styles and saves the controls the same way as its own options.
- `/wasd` (no arguments) or `/wasd options` opens it
- Controls:
  1. **Display:** "Unlock to move" checkbox, scale slider (50%–200%), "Reset position and scale" button
  2. **Appearance:** "Show movement keys (W, A, S, D)" and "Show mouse outline" checkboxes (new settings, both on by default)
  3. **Key bindings:** "Set up WASD keys…" and "Set up number row…" buttons, which open the confirmation from `add-key-binding-setup`, and "Set up action bar layout…" from `add-edit-mode-setup`
- All controls reuse existing functions (`ns.Display`, `ns.Bindings`, settings plus the combat queue)

## Depends on
`add-edit-mode-setup`

## Impact
- New capability spec: `options-panel`
- New file: `UI/Options.lua`
- New settings: `showMovementKeys`, `showMouseOutline`
