# Design: Options panel

## 1. Use the game's settings system, not a custom window
WoW Forever runs on a modern client, which has the `Settings` API used by the game's own options. An addon registers a category and its settings, and the game draws standard controls in a scrolling list, handles their layout and look, and shows them under AddOns. WASDBars builds its whole panel this way.

**Verify first (task 1.1):** check that `Settings.RegisterVerticalLayoutCategory`, `Settings.RegisterAddOnSetting`, `Settings.CreateCheckbox`, `Settings.CreateSlider` and `CreateSettingsButtonInitializer` exist on Forever, and note their exact signatures. If the vertical-layout API isn't there, stop and revisit this design rather than hand-building a panel.

## 2. Registration (`UI/Options.lua`)
```lua
local category, layout = Settings.RegisterVerticalLayoutCategory("WASDBars")

-- each setting is bound straight to a key in WASDBarsDB
local function checkbox(key, name, tooltip, onChange)
  local setting = Settings.RegisterAddOnSetting(category, "WASDBars_" .. key, key, WASDBarsDB,
    "boolean", name, ns.Settings.defaults[key])
  setting:SetValueChangedCallback(onChange)
  Settings.CreateCheckbox(category, setting, tooltip)
end
```
- Section headers: `layout:AddInitializer(CreateSettingsListSectionHeaderInitializer("Display"))`, and the same for Appearance and Key bindings.
- Buttons: `layout:AddInitializer(CreateSettingsButtonInitializer(name, buttonText, onClick, tooltip, true))`.
- `Settings.RegisterAddOnCategory(category)`; `/wasd` and `/wasd options` call `Settings.OpenToCategory(category:GetID())`.
- Registered at `PLAYER_LOGIN`, after `WASDBarsDB` has been merged with defaults.

## 3. Controls
| Section | Control | Setting / action |
|---|---|---|
| Display | Checkbox "Unlock to move" | inverse of `locked`; calls `ns.Display.setLocked`. In combat the change is refused, the checkbox flips back and chat explains why. |
| Display | Slider "Scale", 0.5–2.0, step 0.05, shown as a percentage | `scale`; calls `ns.Display.setScale` (combat queue keeps only the latest value) |
| Display | Button "Reset position and scale" | `ns.Display.reset()`; the slider then shows 100% |
| Appearance | Checkbox "Show movement keys (W, A, S, D)" | `showMovementKeys` (default on); shows/hides the movement key frames |
| Appearance | Checkbox "Show mouse outline" | `showMouseOutline` (default on); shows/hides the outline only, the two side-button actions stay |
| Key bindings | Button "Set up WASD keys…" | `ns.Bindings.request("wasd")` |
| Key bindings | Button "Set up number row…" | `ns.Bindings.request("numbers")` |
| Key bindings | Button "Set up action bar layout…" | `ns.EditModeSetup.request()` (from `add-edit-mode-setup`) |

The movement keys and mouse outline are plain decorative frames, so showing and hiding them works at any time, including in combat. Settings changed by slash command (`/wasd scale`, `/wasd lock`) update `WASDBarsDB` directly, so the panel shows them the next time it opens.
