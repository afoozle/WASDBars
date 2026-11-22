# Design: First-time setup and Edit Mode layout check

## 1. Layout check (`Logic/LayoutCheck.lua`, pure, unit tested)
- `LayoutCheck.problems(readings)`: `readings` has `numIcons`, `alwaysShowButtons`, `hideBarArt`, `hideBarScrolling`, `bar2Shown`, `bar1OverlapsBar2`. Returns the manual fix for each failing check, in that order. A `nil` reading (the game couldn't tell) skips its check.
- `LayoutCheck.overlaps(a, b)`: rects `{ left, bottom, width, height }`; touching edges don't overlap.
- `LayoutCheck.statusLine(fixes)`: "Action bar layout: OK" or "Action bar layout: 2 things to fix (/wasd setup layout)".

## 2. Readings (`UI/Setup.lua`)
- Action bar 1 settings come from the bar itself: `MainActionBar:GetSettingValue(Enum.EditModeActionBarSetting.<name>)` for `NumIcons`, `AlwaysShowButtons`, `HideBarArt`, `HideBarScrolling` (booleans may come back as 0/1). Missing enum entries or methods give `nil`, so the check is skipped rather than erroring.
- `bar2Shown` is `MultiBarBottomLeft:IsShown()`; the overlap compares both bars' `GetRect()` scaled by `GetEffectiveScale()`.
- Read only: nothing is written to Edit Mode, its frames or its tables.

## 3. Setup chain and offer (`UI/Setup.lua`)
- `ns.Setup.run()`: `ns.Bindings.requestAll(ns.Setup.checkLayout)`, so WASD keys → number row → layout check, each after the previous popup closes.
- `ns.Setup.checkLayout()` prints "action bar layout is set up." or "in Edit Mode, in your '<layout>' layout:" followed by one line per fix.
- At `PLAYER_LOGIN`: if `setupOffered["Name-Realm"]` isn't set and the character's keys aren't all set up, show the `WASDBARS_OFFER_SETUP` popup through the combat queue (`"setup-offer"`) and record the offer. Set up runs `ns.Setup.run()`; Not now does nothing.

## 4. Options page (`UI/Options.lua`)
A canvas page registered with `Settings.RegisterCanvasLayoutCategory` / `RegisterAddOnCategory`: title, one line of text, and a Run setup button calling `ns.Setup.run`.

## 5. Commands (`Core/Slash.lua`)
`Slash.setup` gains `""` (whole setup) and `layout`; `status` adds the layout line.
