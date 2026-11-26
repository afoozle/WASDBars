# Design: Replace action bar 1 with action bar 2

Decided in the grill (2026-11-26); facts and game code references in `research.md` (Forever UI source, `Gethe/wow-ui-source` branch `forever`, commit `d9c22e3`).

## 1. One switch: on the WASDBars layout
`UI/EditMode.lua`'s layout callback already calls `Cluster.follow` and `Setup.mouseFix` (`ask-before-moving-buttons`). It also calls `BarArt.follow(onLayout)`, which does everything below, and its reverse on any other layout.

## 2. Action bar 1 see-through (`UI/BarArt.lua`)
`MainActionBar:SetAlpha(0)` on the layout, `SetAlpha(1)` off it. Not `Hide()`: Edit Mode's `UpdateBottomActionBarPositions` stacks every default-positioned bottom bar on action bar 1 and skips hidden ones (`Blizzard_EditMode/Shared/EditModeManager.lua:641`; the list in `Blizzard_EditMode/Camelot/EditModeUtil.lua:5-24`), so hiding it would drop the stack into its spot. Its Edit Mode selection is a child, so it goes transparent too. The game itself only shows or hides `MainActionBar` (gamepad mode), never changes its alpha. Alpha isn't expected to be blocked in combat; it goes through the combat queue anyway, like everything on the layout switch, until check 8 says otherwise.

## 3. The art on action bar 2 (`UI/BarArt.lua`)
- **Holder:** a frame inside `MultiBarBottomLeft`, `SetAllPoints`, frame level below the button holders, `ignoreInLayout = true` (the bar is a `ResizeLayoutFrame`; without it the holder would change the bar's size). Being a child, it follows action bar 2's position, scale and visibility for free.
- **Border:** one texture on the holder, `SetAtlas("UI-HUD-ActionBar-Frame")`, `BACKGROUND` sublevel -3, `TOPLEFT -6,6` and `BOTTOMRIGHT 4,-5` to the bar, `SetScale` of the icon size (read from button 1's holder scale, which is what Edit Mode sets). As `MainActionBar.BorderArt` (`Mainline/MainActionBar.xml:53-61`).
- **Dividers:** two `CreateFramePool`s on the holder with the game's `HorizontalDividerTemplate` / `VerticalDividerTemplate`, placed as `MainActionBarMixin:UpdateDividers` places them (`Shared/MainActionBar.lua:117-156`). Which buttons get one is `Logic/Dividers.lua` (section 4).
- **Button style:** for `MultiBarBottomLeftButton1`–`12`, the two branches of the game's `UpdateButtonArt` (`Mainline/ActionButtonOverrides.lua:1-30`): art on shows `SlotArt`, hides `SlotBackground`, Normal `UI-HUD-ActionBar-IconFrame` and Pushed `...-Down` at 46×45; art off is action bar 2's own look, `SlotBackground` and the `-AddRow` atlases at 51×51. The game sets these once at load and never again on action bar 2.
- **Redraw** on `hooksecurefunc` of `MultiBarBottomLeft`'s own `UpdateSystem`, `UpdateSystemSetting` and `UpdateShownButtons` (the instance, not the mixin), on the layout switch, and on the checkbox. Out of combat right away; in combat it marks the art dirty and redraws on `PLAYER_REGEN_ENABLED`. Off the layout, or with Hide Bar Art on, the border and dividers are hidden and the buttons get action bar 2's own style back.

## 4. Divider rule (`Logic/Dividers.lua`, pure)
`Dividers.between(shown, rows, padding, minPadding, hideArt)`: `shown` is a list of booleans in button order. Returns the indices of buttons that get a divider before them: none if `hideArt`, `rows > 1` or `padding > minPadding`; otherwise every shown button whose previous button is shown. Busted tests cover each case.

## 5. Hide Bar Art checkbox
`LibEditMode:AddSystemSettings(Enum.EditModeSystem.ActionBar, { checkbox }, Enum.EditModeActionBarSystemIndices.Bar2)`, named "Hide Bar Art", default false (art shown), `hidden` when the active layout isn't WASDBars. `get` and `set` use `WASDBarsDB.bar2HideArt` (one value: the art only exists on one layout), and `set` redraws. LibEditMode's box may still show, empty, under action bar 2 on other layouts (it shows for any system with settings); an in-game check looks at that.

## 6. Starting value (`UI/Setup.lua`)
When setup creates the layout, before `LayoutPlan.edit` turns action bar 1's art off, `bar2HideArt` is set from the source layout's action bar 1 Hide Bar Art (`readings.layout.bar1.hideBarArt == 1`). `Logic/Settings.lua` default `bar2HideArt = false`, so an existing layout starts with the art shown.

## 7. Setup window
`Logic/LayoutPlan.lua`: a "replace" action, "Replace action bar 1 with action bar 2", right after "buttons", on create or switch. Like "buttons", it needs no applying: being on the layout does it.
