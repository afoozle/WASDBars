# Research: drawing action bar 1's bar art around action bar 2

Question: once action bar 1 is hidden, can WASDBars make action bar 2 (`MultiBarBottomLeft`) look like action bar 1 with bar art on, by drawing its own copies of the same textures? And can it offer a "Hide Bar Art" checkbox for action bar 2 in Edit Mode?

## Short answer

**Feasible, with caveats.** "Bar art" is three things, and each one can be copied:

1. **One border texture** (`UI-HUD-ActionBar-Frame`, a sliced atlas) stretched around the bar. An addon texture with `SetAtlas` anchored to `MultiBarBottomLeft` with the same offsets and scale does the same job.
2. **Dividers** between buttons. These are small frames that use the game's own virtual templates (`HorizontalDividerTemplate` / `VerticalDividerTemplate`), and an addon can create those too. They only show with 1 row, minimum padding and no hidden gaps.
3. **The style of each button.** With bar art on, a button shows `SlotArt` and uses the 46x45 `UI-HUD-ActionBar-IconFrame` border. Without it, the button shows `SlotBackground` and the larger 51x51 `...-IconFrame-AddRow` border. Action bar 2's buttons always use the "no art" style. **This part can't be done with copies alone.** Those textures belong to action bar 2's own buttons, so an addon copy would sit under or over the button's own 51x51 border instead of replacing it. Getting a true match means changing textures on action bar 2's buttons, through the same calls Blizzard uses (`SetNormalAtlas`, `SlotArt:Show()`, and so on). Without that, the border and dividers will look right but the button frames will look like a multi bar.

Other caveats:
- The page arrows and page number (`HideBarScrolling`) are working buttons, not just art. Copying them means copying their behaviour too. I'd suggest leaving them out.
- Re-laying out the art means hooking action bar 2's own methods (`UpdateSystem`, `UpdateSystemSetting`, `UpdateShownButtons`) with `hooksecurefunc`.
- Edit Mode can't change settings in combat, but buttons can still show or hide in combat (grid shown while dragging, empty slots). Whether WASDBars can re-anchor its own regions in combat has to be checked in game (see the checks list).

**Checkbox (Q6): yes, but not inside the game's own dialog.** The native dialog only lists settings that are stored in that bar's saved Edit Mode settings. Action bar 2 has no `HideBarArt` there, and the game strips unknown settings from saved layouts. `LibEditMode:AddSystemSettings` (already a WASDBars dependency) adds a checkbox in its own small panel attached under the game's dialog when action bar 2 is selected. WASDBars would store the value per layout in `WASDBarsDB.layouts`.

## Sources used

- Blizzard UI source, **Forever branch** of the mirror: `Gethe/wow-ui-source`, branch `forever`, commit `d9c22e32cb240afb82bb2ecefbb78ef935333f59` ("1.60.1 (71139)", 2026-11-25). Below, `SRC/<path>` means `https://github.com/Gethe/wow-ui-source/blob/d9c22e32cb240afb82bb2ecefbb78ef935333f59/Interface/AddOns/<path>`. The game install has no extracted FrameXML (only `Interface/AddOns`), so this mirror is the best source.
- On Forever the action bar addon loads the `Shared`, `Mainline` ("[Family]") and `Camelot` ("[Game]") files. `SRC/Blizzard_ActionBar/Blizzard_ActionBar.toc:24-25` loads both `[Game]\ActionButtonOverrides.lua [AllowLoadGameType camelot]` and `[Family]\ActionButtonOverrides.lua [AllowLoadGameType mainline]`. `mainline` includes camelot: elsewhere Blizzard has to write `[AllowLoadGameType mainline] [ExcludeLoadGameType camelot]` to keep a file off Forever (e.g. `SRC/Blizzard_ChatFrame/Blizzard_ChatFrame.toc:26`). So the Mainline override of `UpdateButtonArt` is active on Forever (check 1 below confirms it).
- Atlas sizes: wago.tools DB2 exports `UiTextureAtlasMember`, `UiTextureAtlasElement`, `UiTextureAtlasElementSliceData` (`https://wago.tools/db2/<table>/csv`, default build = **live retail 12.1.5.70961**, not Forever). Forever may differ; check in game.
- LibEditMode version 19, read from the installed copy `_forever_/Interface/AddOns/LibEditMode/` (evidence of what runs on this client), plus upstream `p3lim-wow/LibEditMode` master `adfa353` (2026-11-08; only a later atlas fix in `widgets/coords.lua`, nothing relevant).

## 1. What makes up action bar 1's bar art

All on `MainActionBar` (`SRC/Blizzard_ActionBar/Mainline/MainActionBar.xml`):

| Piece | Definition | Notes |
|---|---|---|
| **BorderArt** | `Texture parentKey="BorderArt" atlas="UI-HUD-ActionBar-Frame"`, layer `BACKGROUND`, sublevel `-3`, anchors `TOPLEFT -6,6` and `BOTTOMRIGHT 4,-5` to the bar (`:52-62`) | One texture around the whole bar. Retail atlas data: element 26258, 110x110 in a 128x128 file, **slice margins L20 T20 R25 B25, SliceMode 1** (`UiTextureAtlasElementSliceData` row 76), so it stretches like a nine-slice from a single `SetAtlas`. |
| **Dividers** | `HorizontalDividerTemplate` (width 12) and `VerticalDividerTemplate` (height 12), both `NineSliceCodeTemplate` with `layoutTextureKit="ui-hud-actionbar-frame-divider"`, layouts `ThreeSliceVerticalLayout` / `ThreeSliceHorizontalLayout` (`:10-27`) | Made from a pool in Lua (section 2). Pieces (`SRC/Blizzard_SharedXML/Mainline/NineSliceLayouts.lua:450-464`): `%s-ThreeSlice-EdgeTop`, `%s-ThreeSlice-EdgeBottom`, `!%s-ThreeSlice-Center` (horizontal bar), and `%s-ThreeSlice-EdgeLeft`, `%s-ThreeSlice-EdgeRight`, `_%s-ThreeSlice-Center` (vertical bar). Retail sizes: top 12x14, bottom 12x15, centre 12x16 (tiled vertically); left/right 12x14, centre 16x14. |
| **Button style** (per button) | Template has both `SlotBackground` (`UI-HUD-ActionBar-IconFrame-Background`) and `SlotArt` (`ui-hud-actionbar-iconframe-slot`), `BACKGROUND`, `setAllPoints` (`SRC/Blizzard_ActionBar/Mainline/ActionButtonTemplate.xml:32-33`) | `UpdateButtonArt` (`SRC/Blizzard_ActionBar/Mainline/ActionButtonOverrides.lua:2-30`). **Art on:** `SlotArt` shown, `SlotBackground` hidden, Normal `UI-HUD-ActionBar-IconFrame` 46x45, Pushed `UI-HUD-ActionBar-IconFrame-Down` 46x45, OVERLAY. **Art off:** `SlotBackground` shown, `SlotArt` hidden, Normal `UI-HUD-ActionBar-IconFrame-AddRow` 51x51, Pushed `...-AddRow-Down` 51x51. Retail sizes: slot 64x62 drawn at 45x45 (override size), AddRow 51x51, IconFrame 46x45. |
| End caps | `EndCaps` frame (`:92`) | Out of scope. |

`HideBarScrolling` toggles only `ActionBarPageNumber` (`MainActionBar.xml:93-146`). That is a `ResizeLayoutFrame` anchored `BOTTOMRIGHT` to the bar's `BOTTOMLEFT` at `-4, 9`, with a `GameFontNormal` text (17x10) and two 17x14 buttons, `UpButton` / `DownButton`. The buttons use the atlases `ui-hud-actionbar-page{up,down}arrow-{up,down,disabled,mouseover}` and run `ActionBar_PageUp/PageDown` (`SRC/Blizzard_ActionBar/Shared/MainActionBar.lua:164-186`). The text updates on `ACTIONBAR_PAGE_CHANGED` (`MainActionBar.lua:56-57`).

Other main-bar-only things that aren't bar art: the QuickKeybind shadow and glow textures (`MainActionBar.xml:63-88`, shown by `SetQuickKeybindModeEffectsShown`).

## 2. The code that shows, hides and lays them out

Edit Mode setting handlers (`SRC/Blizzard_EditMode/Shared/EditModeSystemTemplates.lua`):
- `UpdateSystemSettingHideBarArt` (`:1112-1126`): `self.hideBarArt = ...; if self.BorderArt then self.BorderArt:SetShown(not self.hideBarArt) end; for ... actionButton:UpdateButtonArt() end; MarkDividersDirty(); MarkBarArtDirty()`.
- `UpdateSystemSettingHideBarScrolling` (`:1128-1135`): `self.ActionBarPageNumber:SetShown(not ...HideBarScrolling)`.
- Orientation (`:1027-1046`), NumRows (`:1048-1059`), NumIcons (`:1061-1075`, calls `UpdateShownButtons`) and IconPadding (`:1099-1110`) each set fields and mark the grid, dividers and art dirty.
- IconSize (`:1077-1097`): `iconScale = setting/100`, calls `self:EditModeSetScale(iconScale)` if it exists, then `actionButton.container:SetScale(iconScale)` for each button, then `self:Layout()`.
- `UpdateSystemSetting` (`:1158-1195`) dispatches each setting, then runs `RefreshGridLayout`, `RefreshDividers` and `RefreshBarArt` unless the whole system is updating. `UpdateSystem` (`:930-935`) applies a whole layout and then runs the same three refreshes.

Main bar functions (`SRC/Blizzard_ActionBar/Shared/MainActionBar.lua`):
- `EditModeSetScale` (`:107-115`): `self.BorderArt:SetScale(newScale)`. The end caps and page number scale down only, never up.
- `UpdateDividers` (`:117-156`): returns early unless `enableDividers` is set (only `MainActionBar`, `MainActionBar.xml:47`). It releases both pools, then **draws nothing if `hideBarArt or numRows > 1 or buttonPadding > minButtonPadding`** (`:129`, `minButtonPadding = 2` from `SRC/Blizzard_ActionBar/Shared/ActionBar.lua:5`). Otherwise, for each shown button that follows another shown button, it places a divider:
  - horizontal bar: `TOP`/`BOTTOM` to the button's top and bottom, `RIGHT` to the button's `LEFT` at `+5,0`
  - vertical bar: `LEFT`/`RIGHT` to the button, `BOTTOM` to the button's `TOP` at `0,-5`

  The pool is parented to the bar (`:123-124`), so dividers aren't scaled by the container scale. They follow the scaled button through their anchors, and their width (12) stays the same.
- `UpdateShownButtons` (`ActionBar.lua:202-223`) calls `UpdateDividers` every time the shown buttons change. That includes grid show/hide while dragging (`SetShowGrid`, `:144-175`), which can happen in combat.
- `UpdateGridLayout` (`ActionBar.lua:93-142`) places the button containers with `GridLayoutUtil` and calls `self:Layout()`. The bar is a `ResizeLayoutFrame` (`SRC/Blizzard_ActionBar/Shared/ActionBarTemplate.xml:7`), so the bar's size follows its containers, including empty "spacer" containers up to NumIcons (`ActionBar.lua:212`). The BorderArt therefore always wraps the bar's laid-out size.

## 3. Multi bars: what they have and lack

- `MultiBarBottomLeft` (`SRC/Blizzard_ActionBar/Shared/MultiActionBars.xml:45-73`) uses the same `EditModeActionBarTemplate` as action bar 1. It has **no `BorderArt`, no `enableDividers`, no `ActionBarPageNumber`, no `EditModeSetScale`, no `UpdateDividers`**. Its only texture is the `QuickKeybindGlow`.
- Its buttons (`MultiBar1ButtonTemplate` → `ActionBarButtonTemplate`, `:3-7`) use the same button template as the main bar's (`MainBarActionBarButtonTemplate` adds only a `showButtonArt` key, which no code reads: `MainActionBar.xml:3-7`; a search of the action bar code finds no use). So they have their own `SlotArt` and `SlotBackground`.
- **Why multi bar buttons get the "no art" style:** `UpdateButtonArt` runs at button `OnLoad` (`SRC/Blizzard_ActionBar/Shared/ActionButton.lua:1607-1615`). The button is still being created at that point, before `actionButton.bar = self` is set (`ActionBar.lua:31-33`), so `self.bar` is nil and the "else" (no art) branch runs. After that, `UpdateButtonArt` runs only from `UpdateSystemSettingHideBarArt`, which only bars with a `HideBarArt` setting reach. If something did call it on a multi bar button, `bar.hideBarArt` is nil, so it would pick the **art on** style.
- **No setting or flag turns bar art on for a multi bar.** The preset layout gives `HideBarArt`/`HideBarScrolling` only to `MainBar` (`SRC/Blizzard_EditMode/Mainline/EditModePresetLayouts.lua:21-40` vs Bar2 `:42-50`). The dialog shows only settings the system has (section 6). Saved layouts are reconciled against the preset, which removes extra settings (`SRC/Blizzard_EditMode/Shared/EditModeManager.lua:872-875`, `893-911`).

## 4. Can an addon make the copies, and keep them right?

- **Textures:** `SetAtlas("UI-HUD-ActionBar-Frame")` on an addon texture uses the atlas's slice data, the same as the XML `atlas=` does. Two anchors with Blizzard's offsets and `SetScale(iconScale)` copy `BorderArt` exactly. The divider templates are global virtual templates, so `CreateFramePool("FRAME", parent, "HorizontalDividerTemplate")` works from an addon and builds the three-slice pieces itself (`SRC/Blizzard_SharedXML/NineSlice.lua:105-123`).
- **Parenting:** a holder frame that is a child of `MultiBarBottomLeft` (low frame level, so it sits under the button containers) inherits bar 2's visibility (its VisibleSetting, the bar 2 toggle, Edit Mode showing it). It also inherits position and parent scale for free, so WASDBars never shows or hides it itself.
- **When to re-lay out** (all `hooksecurefunc` on the bar instance; the mixin functions are copied onto the frame, so hook `MultiBarBottomLeft`, not the global mixin):
  - `MultiBarBottomLeft:UpdateSystem` covers layout applied or switched, login, and LibEditModeOverride's `ApplyChanges`.
  - `MultiBarBottomLeft:UpdateSystemSetting(setting, entire)` covers each change in the dialog (count, padding, size, orientation, rows).
  - `MultiBarBottomLeft:UpdateShownButtons` covers buttons shown or hidden, which changes the dividers (runs on grid show/hide, which can be in combat).
  - Read the bar's own fields after the call: `isHorizontal`, `numRows`, `buttonPadding`, `minButtonPadding`, `actionButtons[i]:IsShown()`, plus `GetSettingValue(Enum.EditModeActionBarSetting.IconSize)` for the scale. All of these are events, with no per-frame work.
- **Taint and combat:** a `hooksecurefunc` post-hook doesn't taint Blizzard's code path. Addon textures are not protected. Two things are unconfirmed and need an in-game check:
  - whether anchoring an addon *frame* (the divider frames) to secure action buttons makes it protected, which would block `SetPoint`/`Show` in combat
  - whether setting points on addon *textures* relative to protected buttons is allowed in combat

  The safe pattern: re-lay out right away out of combat. In combat, just mark the art dirty and redo it on `PLAYER_REGEN_ENABLED`. That fits the "combat queue" rule (it isn't moving the buttons, but it's the same timing). Dividers being briefly wrong while dragging spells in combat is acceptable.
- **Button style:** the only way to get the art-on button style is to set it on bar 2's own buttons (`SlotArt:Show()`, `SlotBackground:Hide()`, `SetNormalAtlas("UI-HUD-ActionBar-IconFrame")` + `NormalTexture:SetSize(46,45)`, the same for Pushed). These are texture calls, not position, size or visibility calls on the secure button, and Blizzard's code doesn't touch them again after load (search for `SetNormalAtlas|SlotArt|SlotBackground` in `Blizzard_ActionBar`: only `ActionButtonOverrides.lua`). It goes beyond "copies", so the player should decide. An alternative that keeps to copies: draw addon textures over each button using `ui-hud-actionbar-iconframe-slot` (under the icon isn't possible from another frame) plus the 46x45 frame. But the button's own 51x51 AddRow border would still show around it, so I don't recommend it.

## 5. Things that look wrong off the main bar

- **Dividers** only appear with 1 row and padding at the 2 px minimum, and never across hidden-button gaps (`MainActionBar.lua:129`, `134-155`). On action bar 1 with padding > 2 or more than one row, the game itself shows no dividers, so copies should follow the same rule. Nothing assumes 12 buttons. Dividers sit at a fixed +5 px into the gap left of each button, so they are tuned to the 2 px padding.
- **BorderArt** wraps the bar's laid-out size in any orientation or row count. It's a sliced atlas, so multi-row and vertical bars just get a bigger frame, as action bar 1 does natively. It scales with IconSize through `SetScale`, so the -6/+6/4/-5 offsets scale too.
- **Page number** is placed for a horizontal bar (left side, `y=9`) and never moves for vertical. The game only scales it down (`MainActionBar.lua:114`).
- **Gamepad UI:** the main bar hides `BorderArt` when gamepad UI is on (`MainActionBar.lua:31-40`). The copies would need the same rule only if gamepad mode matters (probably not).
- With bar 2 placed exactly on bar 1 (as WASDBars sets it up), the copied art lands where bar 1's art was.

## 6. A "Hide Bar Art" checkbox for action bar 2

- **The game's own dialog can't show it.** `EditModeSystemSettingsDialogMixin:UpdateSettings` loops over `EditModeSettingDisplayInfoManager:GetSystemSettingDisplayInfo(system)` and shows an entry only `if self.attachedToSystem:ShouldShowSetting(displayInfo.setting)` (`SRC/Blizzard_EditMode/Shared/EditModeDialogs.lua:598-643`, esp. `605-607`). That calls `HasSetting`, which looks the setting up in `settingMap`. `settingMap` is built from the saved layout's `systemInfo.settings` (`EditModeSystemTemplates.lua:461-468`, `529-531`, `206-213`). The ActionBar system's display info already contains `HideBarArt` (`SRC/Blizzard_EditMode/Shared/EditModeSettingDisplayInfo.lua:112-117`); it's hidden for bar 2 only because bar 2's layout doesn't have the setting.
  - Adding the setting to bar 2's saved layout gets removed by reconcile (section 3).
  - Writing into `EditModeSettingDisplayInfoManager` tables or the dialog's pools from addon code would taint Edit Mode, and it still wouldn't help.
  - Placing custom widgets inside `EditModeSystemSettingsDialog.Settings` means insecure code changing a Blizzard layout frame that Blizzard rebuilds on every update. That's fragile and a taint risk.
- **LibEditMode does this safely, beside the dialog.**
  - `lib:AddSystemSettings(systemID, settings, subSystemID)` (installed `LibEditMode.lua:541-580`) stores the settings in the library's own tables.
  - On `hooksecurefunc(EditModeManagerFrame, 'SelectSystem', ...)` (`:362-379`) it checks `systemFrame.system` / `systemFrame.systemIndex` and shows its own "extension" panel for known systems.
  - That panel is an addon frame anchored `TOP` to `EditModeSystemSettingsDialog`'s `BOTTOM`, strata DIALOG, with a `DialogBorderTranslucentTemplate` border, the settings, and a "Reset to default" button (`widgets/extension.lua:113-143`). It hides when the dialog hides (`LibEditMode.lua:355-359`).
  - Checkbox entries are `{ kind = LibEditMode.SettingType.Checkbox, name, default, get(layoutName), set(layoutName, value) }` (`widgets/checkbox.lua:26-59`; `SettingType` copies `Enum.EditModeSettingDisplayType`, `LibEditMode.lua:924`).
  - For bar 2: `AddSystemSettings(Enum.EditModeSystem.ActionBar, {...}, Enum.EditModeActionBarSystemIndices.Bar2)`.
  - It's the same library and pattern WASDBars already uses for the cluster's frame settings (`UI/EditMode.lua:31-54`).
- **Look:** the checkbox uses the same widget style, but in a separate box *under* the game's dialog, not in the dialog's own list. It can't be in the same position as action bar 1's native checkbox.
- **Storage:** WASDBars keeps the value itself, per layout name, beside the cluster placement in `WASDBarsDB.layouts[layoutName]` (`Logic/Placement.lua:31-55`, `save` merges fields).
  - LibEditMode callbacks (`LibEditMode.lua:661-720`): `layout(layoutName, index)` fires on any active-layout change and at login, and right away on register if a layout is known. Apply the art there.
  - `create(name, index, sourceName)`, `rename(old, new, index)` and `delete(name)` exist too. WASDBars doesn't handle rename or delete today (`UI/EditMode.lua` registers only `layout`), so a renamed layout would lose its stored value and the cluster position. That's worth fixing at the same time.
- **Fallback:** a checkbox in WASDBars' own settings panel (`UI/Options.lua` already has a `checkbox` helper over `Settings.RegisterProxySetting`), applying to the active layout or to all layouts.

## Differences from Forever to verify in game

Run each with action bar 1 still visible and bar art on, unless the check says otherwise.

1. `/dump ActionButton1.SlotArt:IsShown(), ActionButton1.SlotBackground:IsShown(), ActionButton1:GetNormalTexture():GetAtlas()`: with bar art on, expect `true, false, "UI-HUD-ActionBar-IconFrame"`. With HideBarArt on, expect `false, true, "UI-HUD-ActionBar-IconFrame-AddRow"`. This confirms the Mainline `UpdateButtonArt` runs on Forever.
2. `/dump MultiBarBottomLeftButton1.SlotArt:IsShown(), MultiBarBottomLeftButton1.SlotBackground:IsShown(), MultiBarBottomLeftButton1:GetNormalTexture():GetAtlas(), MultiBarBottomLeftButton1:GetNormalTexture():GetSize()`: expect `false, true, "...-AddRow", 51, 51`.
3. `/dump MainActionBar.BorderArt:GetAtlas(), MainActionBar.BorderArt:GetDrawLayer(), MainActionBar.BorderArt:GetNumPoints()`: expect `UI-HUD-ActionBar-Frame`, `BACKGROUND -3`, `2`.
4. `/dump C_Texture.GetAtlasInfo("UI-HUD-ActionBar-Frame")` and `/dump C_Texture.GetAtlasInfo("UI-HUD-ActionBar-IconFrame-Slot")`: these atlas sizes and slice margins come from retail data.
5. `/dump MultiBarBottomLeft.BorderArt, MultiBarBottomLeft.enableDividers, MultiBarBottomLeft.UpdateDividers, MultiBarBottomLeft.hideBarArt`: expect all `nil`.
6. `/dump MainActionBar.HorizontalDividersPool:GetNumActive()` with 1 row and padding 2: expect 11. Set padding to 3 in Edit Mode and run it again: expect 0.
7. `/run local f=CreateFrame("Frame",nil,MultiBarBottomLeft,"HorizontalDividerTemplate") print(f.TopEdge and f.TopEdge:GetAtlas())`: confirms an addon can use the divider template on Forever.
8. Combat anchoring: `/run WASDT=CreateFrame("Frame",nil,MultiBarBottomLeft) WASDT:SetPoint("CENTER",MultiBarBottomLeftButton1) print(WASDT:IsProtected())`. Then attack a training dummy and run `/run WASDT:ClearAllPoints() WASDT:SetPoint("CENTER",MultiBarBottomLeftButton2) print("ok")`. Then look in `!BugGrabber.lua` for a blocked action. Repeat with a texture instead of a frame.
9. LibEditMode panel: after WASDBars registers an `AddSystemSettings` checkbox for Bar2, open Edit Mode, click action bar 2, and check that a box appears under the dialog. Click action bar 1 and check that it goes away. Switch layouts and check that the value follows the layout.
10. Edit Mode taint: after toggling the new checkbox, leave Edit Mode, enter combat, and use action bar 2. `!BugGrabber.lua` should show no `ADDON_ACTION_BLOCKED`.

## Sketch: how WASDBars would do it

- One holder frame, a child of `MultiBarBottomLeft` at a low frame level, holding:
  - one texture `SetAtlas("UI-HUD-ActionBar-Frame")`, `BACKGROUND`, anchored `TOPLEFT -6,6` / `BOTTOMRIGHT 4,-5` to the bar, `SetScale(IconSize/100)`
  - a pool of `HorizontalDividerTemplate`/`VerticalDividerTemplate` frames placed by the same rule as `MainActionBarMixin:UpdateDividers`
- The per-button style, if the player accepts touching bar 2's own button textures: the `UpdateButtonArt` "art on" branch applied to `MultiBarBottomLeftButton1-12`, and put back when the art is off or WASDBars is restored.
- Re-lay out from `hooksecurefunc` on `MultiBarBottomLeft` `UpdateSystem`, `UpdateSystemSetting` and `UpdateShownButtons`, and from LibEditMode's `layout` callback. In combat, mark the art dirty and redo it on `PLAYER_REGEN_ENABLED`. The divider rule, in `Logic/`, is a pure function of (shown flags, horizontal, rows, padding).
- A "Hide Bar Art" checkbox via `LibEditMode:AddSystemSettings(ActionBar, …, Bar2)`, stored in `WASDBarsDB.layouts[layoutName]`, with an `Options.lua` checkbox as the fallback.
