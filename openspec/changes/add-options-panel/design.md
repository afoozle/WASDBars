# Design: Options panel

## 1. Settings API
Checked against TomTom, which is installed and builds its pages from the same rows on this client: `Settings.RegisterVerticalLayoutCategory(name)` returns `category, layout`; `Settings.RegisterProxySetting(category, variable, Settings.VarType.Boolean, name, default, get, set)`; `Settings.CreateCheckbox(category, setting, tooltip)`; `layout:AddInitializer(CreateSettingsListSectionHeaderInitializer(title))`; `layout:AddInitializer(CreateSettingsButtonInitializer(name, buttonText, onClick, tooltip, addSearchTags))`; `Settings.RegisterAddOnCategory(category)`; `Settings.OpenToCategory(category:GetID())`.

Proxy settings read and write `WASDBarsDB` directly, so the page always shows the saved value. Registered at `PLAYER_LOGIN`, after the cluster and movement keys exist.

## 2. Controls (`UI/Options.lua`)
| Section | Row | Does |
|---|---|---|
| Display | Move and resize: **Open Edit Mode** | Out of combat: hides the options window and shows `EditModeManagerFrame`. In combat: "Edit Mode can't be opened in combat." |
| Appearance | **Show movement keys (W, A, S, D)** | `showMovementKeys`; `MovementKeys.setShown` shows or hides the decorative frames (safe in combat) |
| Appearance | **Large hotkey text** | `largeHotkeys`; `Cluster.refreshHotkeys` restyles every cluster button's hotkey text |
| Setup | Keybinds: **Set up keybinds** | `ns.Bindings.request()` |
| Setup | Edit Mode layout: **Check layout** | `ns.Setup.checkLayout()` |

## 3. Large hotkey text off
The first time a button's hotkey text is styled, its original font, anchors, size and justification are remembered. With the option off, they're put back and the game's `UpdateHotkeys` is called to restore its own text (so "M5" goes back to the game's text).
