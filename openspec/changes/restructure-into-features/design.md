# Design: Restructure into features

Behaviour stays exactly as it is after `fix-what-is-wrong`. Only the structure, the names and the tests change. Dead code and leftover guards stay for `simplify-after-restructure`, so every change here is a move or a rename that the tests or the in-game checks can confirm.

## 1. Rules

1. **Folders by feature.** `tests/` mirrors them.
2. **Two kinds of file in a feature:**
   - **Logic files** are plain functions: you give them data, they return data. They make no game calls, keep no state of their own, and take no game functions as arguments. busted tests every one of them.
   - **Game files** talk to the game. They call WoW functions directly, own the feature's frames and state, and are checked in-game, not by busted.
3. **Decisions go in logic files.** A game file reads the game into plain data, asks a logic function what to do, and does it. When a game file grows an `if` that decides something worth testing, that `if` moves into a logic function.
4. **Modules, not instances.** Each file is one table on `ns` (`ns.Keybinds`) with functions called with a dot (`Keybinds.applyKeybindChanges(keybindChanges)`). There is only ever one of each, so there are no constructors. A game file reaches another feature through `ns` (`ns.CombatQueue.runOutOfCombat(...)`), only from inside its functions, never while the file loads.
5. **One startup file** (`Core/Startup.lua`, loaded last) connects game events to functions and runs the login steps. Every handler there is one function call.
6. **Files and modules are nouns** naming what they own. **Functions start with the verb** and name the purpose, not details that may change.
7. **No boolean parameters** that switch what a function does: two functions instead.
8. **Full-word names** for variables, parameters and data fields, saying what the thing is. Loop indices (`i`) are fine. Saved-setting keys keep their names, so nothing saved moves.
9. **No functions declared inside functions.** Helpers are file-level local functions. **One exception:** the game's callbacks (events, hooks, timers, popup buttons, LibEditMode getters and setters, combat-queue jobs) take a function, so a short anonymous function passed straight as an argument is allowed when its body is one function call:
   ```lua
   ns.CombatQueue.runOutOfCombat("buttons", function()
     moveActionButtonsIntoCluster()
   end)
   ```
10. **No tables holding rules.** Each rule is a small named function, called in order in plain code. Plain data tables (the key shape, the keybind groups, step texts, help lines) are fine.

Unchanged from today: every file starts with `local ADDON, ns = ...`; the same globals; everything that moves or shows the action buttons, or changes keybinds, goes through the combat queue; `hooksecurefunc`, never replacing game functions; setup and restore refuse in combat.

## 2. The pattern

A logic file, `Keybinds/KeybindPlan.lua`:

```lua
local ADDON, ns = ...
local KeybindPlan = {}
ns.KeybindPlan = KeybindPlan

-- What every setup key is bound to now, ready to restore later:
-- { [key] = action | false }. currentActions: { [key] = action }.
function KeybindPlan.copyKeybinds(keybindGroups, currentActions)
  local keybindCopy = {}
  for _, group in ipairs(keybindGroups) do
    for _, keybind in ipairs(group.keybinds) do
      keybindCopy[keybind.key] = currentActions[keybind.key] or false
    end
  end
  return keybindCopy
end
```

The game file that uses it, `Keybinds/Keybinds.lua`:

```lua
local ADDON, ns = ...
local Keybinds = {}
ns.Keybinds = Keybinds

-- { [key] = action } for every setup key that has one.
local function readCurrentActions()
  local currentActions = {}
  for _, group in ipairs(ns.KeybindGroups) do
    for _, keybind in ipairs(group.keybinds) do
      local action = GetBindingAction(keybind.key)
      if action ~= "" then
        currentActions[keybind.key] = action
      end
    end
  end
  return currentActions
end

function Keybinds.copyCurrentKeybinds()
  return ns.KeybindPlan.copyKeybinds(ns.KeybindGroups, readCurrentActions())
end
```

A test needs no game at all:

```lua
local keybindCopy = KeybindPlan.copyKeybinds(keybindGroups, { Q = "STRAFELEFT" })
assert.equal("STRAFELEFT", keybindCopy.Q)
assert.is_false(keybindCopy.E)
```

## 3. Folders and load order

`(logic)` files are tested by busted; `(game)` files are checked in-game; `(data)` files are plain tables.

```
Core/
  ChatMessages.lua            (game)
  CombatQueue.lua             (game)
  SavedSettings.lua           (logic)
  AddonVersion.lua            (logic)
  SlashCommands.lua           (game)
ActionBarCluster/
  ClusterKeys.lua             (data)
  ClusterGeometry.lua         (logic)
  HotkeyText.lua              (logic)
  ClusterPositions.lua        (logic)
  ActionBarCluster.lua        (game)
  ClusterEditModeElement.lua  (game)
  MovementKeys.lua            (game)
MainBarReplacement/
  BarDividers.lua             (logic)
  MainBarReplacement.lua      (game)
WasdLayoutMode/
  WasdLayoutMode.lua          (game)
Keybinds/
  KeybindGroups.lua           (data)
  KeybindPlan.lua             (logic)
  KeybindCopies.lua           (logic)
  Keybinds.lua                (game)
EditModeLayouts/
  EditModeIds.lua             (logic)
  LayoutList.lua              (logic)
  WasdLayoutSettings.lua      (logic)
  EditModeLayouts.lua         (game)
Setup/
  SetupSteps.lua              (logic)
  RestorePoints.lua           (logic)
  RestoreSteps.lua            (logic)
  SetupGuards.lua             (game)
  ChatWindow.lua              (game)
  SetupWindow.lua             (game)
  ReloadPrompt.lua            (game)
  Setup.lua                   (game)
  SetupOffer.lua              (game)
  Restore.lua                 (game)
Options/
  OptionsPage.lua             (game)
Performance/
  PerformanceLog.lua          (logic)
  PerformanceRecorder.lua     (game)
Core/Startup.lua              (last: events and login steps)
```

Every file except `Core/Startup.lua` only defines its module when it loads, so the order only matters for `Startup.lua`, which the TOC loads last.

## 4. Data shapes

Field names inside the tables passed between files:

- **Measured cluster key** (`ClusterGeometry`): `{ clusterKey, centreX, centreY, scale }`; the measured cluster is `{ measuredKeys, width, height }`
- **Cluster position** (`ClusterPositions`): `{ point, x, y, scale }`
- **Cluster key** (`ClusterKeys`): `{ label, actionButtonNumber | movementDirection, column, row, size }`
- **Keybind** (`KeybindGroups`): `{ key, keyLabel, action }`, in groups `{ name, heading, detail, keybinds }`
- **Current actions** (read by `Keybinds`): `{ [key] = action }`; **keys of each action**: `{ [action] = { key, … } }`
- **Keybind change** (`KeybindPlan`): `{ key, keyLabel, wantedAction, currentAction }`; per group `{ group, keybindChanges, correctCount, totalCount, status }`
- **Action losing its key**: `{ action, keyLabels }`; `Keybinds` adds `actionName` for the window
- **All layouts** (`LayoutList`): `{ layouts, activeLayout }` (the game's own field names: `C_EditMode.SaveLayouts` takes this table)
- **Layout settings** (`WasdLayoutSettings`): `{ actionBar1 = { settingName = value }, actionBar2 = { … }, gryphonsHidden = { left, right } }`
- **Current layout state** (built by `Setup`, replacing today's `readings`): `{ wasdLayout = "active" | "inactive" | "missing", activeLayoutName, layoutSettings, isActionBar2On, isActionBar2OnActionBar1 }`
- **Restore point** (`RestorePoints`): `{ layout, bar2 }` (saved keys unchanged)

## 5. The files

Functions are public unless marked *(local)*.

### Core

**`ChatMessages`** (game): the addon's lines in chat.
- `printMessage(...)`: one line, prefixed `WASDBars:`
- `printDebugMessage(...)`: only while debug output is on
- `turnDebugOutputOn()`, `turnDebugOutputOff()`, `isDebugOutputOn()`

**`CombatQueue`** (game): runs jobs now, or after combat.
- `runOutOfCombat(jobName, job)`: runs now out of combat; in combat, waits, and a newer job with the same name replaces the waiting one. Says "Will apply after combat." once per combat
- `runWaitingJobs()`: when combat ends
- `isInCombat()`

**`SavedSettings`** (logic): works on the `WASDBarsDB` table it's given.
- `SavedSettings.DEFAULTS` (data)
- `fillMissingSettings(savedSettings)`: fills missing keys with copies of the defaults, never overwrites
- `moveV110KeybindCopyToAccount(savedSettings)`: from `fix-what-is-wrong`
- `forgetV100SetUpFlag(savedSettings)`: today's `setUp = nil` (removal is for `simplify-after-restructure`)
- `createRecordingsList(savedRecordings)`: today's `WASDBarsPerfDB.sessions` default

**`AddonVersion`** (logic)
- `readReleaseVersion(versionMetadata)`: "1.1.1", or nil for a dev build (`@project-version@`)

**`SlashCommands`** (game): `/wasd`.
- `SlashCommands.HELP_LINES` (data): command name → help text, for `help` only
- `runSlashCommand(text)`: an `if`/`elseif` on the command name, each calling one local
- *(local)* `showHelp`, `showVersion`, `switchDebugOutput`, `runPerformanceCommand`, `runSetupCommand`

### ActionBarCluster

**`ClusterKeys`** (data, was `Data/Layout.lua`): the WASD key shape, key sizes, the default position and scale. Renamed because an Edit Mode layout is a different thing.

**`ClusterGeometry`** (logic)
- `measureClusterKeys(clusterKeys, buttonSize)`: each key's centre and scale, and the cluster's size

**`HotkeyText`** (logic)
- `shortenMouseButtonNames(hotkeyText)`: "Mouse Button 5" → "M5"

**`ClusterPositions`** (logic, was `Logic/Placement.lua`): works on the saved positions table it's given.
- `MIN_SCALE`, `MAX_SCALE`
- `findClusterPosition(savedPositions, layoutName, defaultPosition, defaultScale)`: saved, or the defaults; a damaged entry never errors
- `saveClusterPosition(savedPositions, layoutName, point, x, y)`, `saveClusterScale(savedPositions, layoutName, scale)`
- `limitScale(scale)`
- *(local)* `isValidPoint`

**`ActionBarCluster`** (game): the cluster frame and action bar 1's buttons in it.
- `buildActionBarCluster()`: at login; measures the keys from the first action button, makes the hidden `WASDBarsCluster` frame, keeps the hotkey style up to date after the game redraws it
- `moveActionButtonsIntoCluster()`, `moveActionButtonsBackToActionBar1()`: through the combat queue, sharing one job name so the last one asked for runs
- `areActionButtonsInCluster()`
- `moveStrayActionButtonsIntoCluster()`: today's safety check on Edit Mode updates
- `repositionActionBarCluster(clusterPosition)`: through the combat queue
- `showLargeHotkeys()`, `showGameHotkeys()`: the "Large hotkey text" option
- `restyleHotkeysAfterKeybindChange()`
- `findClusterFrame()`, `findMeasuredKeys()`, `findButtonSize()`, `measureClusterHeight()`
- *(local)* `applyLargeHotkeyStyle`, `applyGameHotkeyStyle`, `saveGameHotkeyStyle`

**`ClusterEditModeElement`** (game, was the element half of `UI/EditMode.lua`): the "WASDBars" element in Edit Mode.
- `addClusterToEditMode()`: movable, kept on screen; dragging saves the position, the Scale slider saves and repositions
- `findClusterPosition(layoutName)`: `ClusterPositions.findClusterPosition` on the saved table and the `ClusterKeys` defaults
- `saveClusterPosition(layoutName, point, x, y)`: for setup's first position on a new layout

**`MovementKeys`** (game): the W, A, S, D arrow keys.
- `drawMovementKeys()`: at login, after the cluster is built
- `showMovementKeys()`, `hideMovementKeys()`

### MainBarReplacement

**`BarDividers`** (logic)
- `findButtonsNeedingDivider(isButtonShown, rowCount, padding, minimumPadding)`: the game's rule for action bar 1, applied to action bar 2 (today's unused `hideArt` parameter goes: it's never passed, so nothing changes)

**`MainBarReplacement`** (game): action bar 2 taking action bar 1's place, and action bar 2 itself.
- `replaceActionBar1()`: action bar 1 see-through and not catching the mouse; action bar 2's art drawn unless Hide Bar Art is ticked
- `restoreActionBar1()`: action bar 1 visible and catching the mouse as before; action bar 2's own look
- `keepActionBar2ArtUpToDate()`: at login; redraws after the game updates action bar 2
- `redrawActionBar2ArtIfWaiting()`: when combat ends, if a redraw waited
- `addHideBarArtCheckbox()`: action bar 2's checkbox, on the WASDBars layout only
- `matchActionBar2ArtToActionBar1(layoutSettings)`: on a new layout, Hide Bar Art starts as action bar 1's was
- `isActionBar2On()`, `turnOnActionBar2()`, `turnOffActionBar2()`
- `isActionBar2OnActionBar1()`, `findActionBar2AnchorOnActionBar1()`
- *(local)* `disableMouseOnActionBar1`, `restoreMouseOnActionBar1`, `redrawActionBar2Art`, `drawActionBar2Border`, `drawActionBar2Dividers`, `styleButtonsLikeActionBar1`, `styleButtonsLikeActionBar2`, `measureOffsetToActionBar1`

### WasdLayoutMode

**`WasdLayoutMode`** (game): being on the WASDBars layout is the player's consent to moving the buttons and replacing action bar 1.
- `followActiveLayout(layoutName)`: repositions the cluster for that layout, then enters or leaves WASD layout mode
- *(local)* `enterWasdLayoutMode` (buttons into the cluster, action bar 1 replaced), `leaveWasdLayoutMode` (both undone)

### Keybinds

**`KeybindGroups`** (data, was `Data/BindingGroups.lua`): the WASD keys and the number row.

**`KeybindPlan`** (logic, was `Logic/BindingPlan.lua` and the key half of `Logic/Restore.lua`). "Action" is used throughout for what a key does (the game calls it a command).
- `findKeybindChanges(keybindGroups, currentActions)`: per group, the keys not yet bound as setup wants
- `selectGroupsToChange(allGroupChanges)`: the groups with keys left to change
- `findActionsLosingTheirKey(groupsToChange, keysOfEachAction)`: actions setup takes the last key from, across both groups
- `isEveryKeybindSetUp(allGroupChanges)`, `describeKeybindStatus(allGroupChanges)`
- `copyKeybinds(keybindGroups, currentActions)`, `findRestoreChanges(keybindCopy)`
- `findStanceButtonNumber(action)`, `nameAction(action, formName, gameActionName)`: "Action bar 1 button 3", the form's name, or the game's name
- *(local)* `listKeybindChanges`, `collectKeysAndActionsSetupWillChange`, `doesActionKeepAKey`, `isActionLosingItsKey`

**`KeybindCopies`** (logic): the keys from before setup, one copy per binding set, in the saved table it's given.
- `findCopyOwner(bindingSet, characterBindingSet, playerGuid)`: "account", or the character's GUID on character keybinds
- `saveKeybindCopyOnce(savedCopies, copyOwner, keybindCopy)`, `findKeybindCopy(savedCopies, copyOwner)`, `forgetKeybindCopy(savedCopies, copyOwner)`

**`Keybinds`** (game): the game's keybinds.
- `findGroupsToChange()`, `findActionsLosingTheirKey(groupsToChange)`: read the game, ask `KeybindPlan`, add each action's name
- `applyKeybindChanges(keybindChanges)`: saves to the binding set the character already uses
- `copyCurrentKeybinds()`, `restoreKeybinds(keybindCopy)`
- `findCopyOwner()`: `KeybindCopies.findCopyOwner` with the current binding set and the player's GUID
- `nameAction(action)`: `KeybindPlan.nameAction` with the form's name and the game's name
- Apply and restore are out of combat only; their callers refuse in combat (`SetupGuards`)
- *(local)* `readCurrentActions`, `readKeysOfEachAction`, `findFormName`

### EditModeLayouts

**`EditModeIds`** (logic)
- `readEditModeIds(editModeEnum)`: the Edit Mode enum values setup needs, or nil if one is missing (today's check, kept until `simplify-after-restructure`)

**`LayoutList`** (logic, was `Logic/LayoutCopy.lua`): works on the all-layouts table it's given.
- `combinePresetAndSavedLayouts(presetLayouts, savedLayouts)`
- `findActiveLayout(allLayouts)`, `findLayoutIndex(allLayouts, layoutName)`, `findFirstPresetLayoutName(allLayouts, presetLayoutType)`
- `copyActiveLayout(allLayouts, newLayoutName, layoutType)`: where Edit Mode puts new layouts, and made active
- `makeLayoutActive(allLayouts, layoutName)`
- `hasRoomForAnotherLayout(allLayouts, layoutType, maxLayoutsPerType)`
- *(local)* `copyTable`

**`WasdLayoutSettings`** (logic, was most of `Logic/LayoutPlan.lua`): the settings the WASDBars layout needs, on the layout tables it's given.
- `WASD_LAYOUT_NAME` = "WASDBars"
- `readLayoutSettings(layout, editModeIds)`
- `isActionBar1SetUp(layoutSettings)`, `doesActionBar2MatchActionBar1(layoutSettings)`, `areGryphonsHidden(layoutSettings)`
- `applyActionBar1Settings(layout, editModeIds)`, `copyActionBar1ShapeToActionBar2(layout, editModeIds)`, `hideGryphons(layout, editModeIds)`
- `moveActionBar2(layout, editModeIds, anchor)`, `moveChatWindow(layout, editModeIds, anchor)`
- *(local)* `findSystem`, `readSetting`, `writeSetting`

**`EditModeLayouts`** (game): the game's Edit Mode layouts.
- `isEditModeReady()`, `isEditModeOpen()`, `openEditMode()`
- `findEditModeIds()`: `EditModeIds.readEditModeIds(Enum)`
- `loadAllLayouts()`: `LayoutList.combinePresetAndSavedLayouts`, with saved layouts brought up to date with the game's systems
- `saveAllLayouts(allLayouts)`: saves and makes the game apply them
- `findActiveLayoutName()`
- `switchToLayout(layoutName)`: straight away
- `hasRoomForAnotherLayout(allLayouts)`, `copyActiveLayout(allLayouts, newLayoutName)`, `findPresetLayoutType()`: `LayoutList` with the game's layout types and limit

### Setup

**`SetupSteps`** (logic, was `LayoutPlan.actions`, `has` and `statusSentence`): which layout steps setup still needs.
- `findNeededLayoutSteps(currentLayoutState)`: straight-line code, one `if` per step, in window order:
  ```lua
  if isWasdLayoutMissing(currentLayoutState) then
    table.insert(neededLayoutSteps, "createWasdLayout")
  end
  if isWasdLayoutInactive(currentLayoutState) then
    table.insert(neededLayoutSteps, "switchToWasdLayout")
  end
  ...
  ```
- `isStepNeeded(neededLayoutSteps, stepName)`
- `isLayoutChangeNeeded(neededLayoutSteps)`: any step but turning on action bar 2
- `describeLayoutStep(stepName, currentLayoutState)`: the window text, including the source layout's name for `createWasdLayout`
- `describeLayoutStatus(currentLayoutState, neededLayoutSteps)`: the layout half of `/wasd setup status`
- Steps, in order: `createWasdLayout`, `switchToWasdLayout`, `moveActionButtons` and `replaceActionBar1` (listed with create or switch; switching is what does them), `positionClusterAndChatWindow` (with create), `setUpActionBar1`, `matchActionBar2ToActionBar1` (with create), `placeActionBar2OnActionBar1`, `hideGryphons`, `turnOnActionBar2`
- *(local, one each)* `isWasdLayoutMissing`, `isWasdLayoutInactive`, `isActionBar1Wrong`, `isActionBar2ShapeWrong`, `isActionBar2AwayFromActionBar1`, `areGryphonsShowing`, `isActionBar2TurnedOff`

**`RestorePoints`** (logic): per character, the layout and action bar 2 from before setup, in the saved table it's given.
- `saveRestorePointOnce(savedRestorePoints, playerGuid, layoutName, wasActionBar2On)`, `findRestorePoint(savedRestorePoints, playerGuid)`, `forgetRestorePoint(savedRestorePoints, playerGuid)`

**`RestoreSteps`** (logic, was `Restore.target` and `Restore.lines`)
- `findLayoutToRestore(allLayouts, restorePoint, presetLayoutType)`: the saved layout, or the first preset when it's gone
- `describeRestore(layoutToRestore, isSavedLayoutMissing, restorePoint)`: the restore popup's lines

**`SetupGuards`** (game): the two refusals setup and restore share.
- `refuseInCombat(whatPlayerTried)`: says "Can't … in combat." and returns true
- `refuseInEditMode(commandToRunAgain)`: says "Close Edit Mode, then run /wasd …." and returns true

**`ChatWindow`** (game): the game's chat window, moved up on a new layout.
- `findAnchorAboveCluster(clusterTop)`: the chat window's anchor above the cluster, leaving room for its edit box
- `findLeftEdge()`: where the cluster goes, in screen units

**`SetupWindow`** (game): the window listing every change.
- `showSetupChanges(neededLayoutStepTexts, groupsToChange, actionsLosingTheirKey, runSetup)`
- `isSetupWindowShown()`
- *(local)* `createSetupWindow`, `addHeading`, `addLine`, `addLayoutLines`, `addKeybindLines`, `arrangeLines`

**`ReloadPrompt`** (game): the "Reload to finish" window with its own secure button.
- `askForReloadAfterSetup()`, `askForReloadAfterRestore()`

**`Setup`** (game): the setup flow.
- `openSetupWindow()`: `/wasd setup` and the Run setup button
- `isAnythingLeftToSetUp()`, `isOffWasdLayout()`: for the offer and the reminder
- `describeSetupStatus()`: `/wasd setup status`
- *(local, in the order setup runs them)* `findNeededSetup`, `readCurrentLayoutState`, `runSetup`, `refuseWithoutRoomForLayout`, `saveRestorePoint`, `saveKeybindCopy`, `changeLayout` (`createWasdLayout` or `switchToWasdLayout`, then `applyWasdLayoutSettings`), `turnOnActionBar2IfOff`, `applyKeybindChanges`, `finishSetup`, `placeActionBar2OnActionBar1`, `positionClusterAndChatWindowOnNewLayout` (saves the cluster's position, then `WasdLayoutMode.followActiveLayout` applies it straight away, as `EditMode.refresh` did), `confirmSetupOrAskForReload`

**`SetupOffer`** (game): the first-time offer and the login reminder.
- `offerSetupOrRemindOncePerLogin()`: on every Edit Mode update; only the first one per login does anything

**`Restore`** (game): `/wasd restore`.
- `askToRestore()`: `/wasd restore` and the Restore button
- *(local)* `restoreLayout`, `askToRestoreKeybinds`, `finishRestore`

### Options and Performance

**`OptionsPage`** (game): the page under AddOns in the game's options.
- `addOptionsPage()`: at login
- `openOptionsPage()`: `/wasd options`

**`PerformanceLog`** (logic, was `Logic/PerfLog.lua`): works on the recordings table it's given.
- `MAX_ROWS`, `MAX_RECORDINGS`
- `addRow(recording, row)`: keeps the newest rows
- `addRecording(savedRecordings, recording)`: keeps the newest recordings
- `readAllMetrics(metricNames, readMetric)`: today's `readMetrics`; `readMetric` is the profiler call, the one function a logic file still takes, left for `simplify-after-restructure` to judge

**`PerformanceRecorder`** (game): `/wasd perf`.
- `startRecording(label)`, `stopRecording()`, `clearRecordings()`
- *(local)* `recordOneSecond`

## 6. Startup (`Core/Startup.lua`)

The one place that connects game events. Every handler is one function call.

**At `ADDON_LOADED`** (saved settings exist from here): `SavedSettings.fillMissingSettings`, `forgetV100SetUpFlag`, `moveV110KeybindCopyToAccount`, `createRecordingsList`; then `SLASH_WASDBARS1` and `SlashCmdList.WASDBARS`, which calls `SlashCommands.runSlashCommand`.

**At `PLAYER_LOGIN`**: `ActionBarCluster.buildActionBarCluster()`, `MovementKeys.drawMovementKeys()`, `ClusterEditModeElement.addClusterToEditMode()`, `MainBarReplacement.keepActionBar2ArtUpToDate()`, `MainBarReplacement.addHideBarArtCheckbox()`, `OptionsPage.addOptionsPage()`, then `WasdLayoutMode.followActiveLayout(EditModeLayouts.findActiveLayoutName())`.

**Events to functions**:
- `PLAYER_REGEN_ENABLED` → `CombatQueue.runWaitingJobs()`, `MainBarReplacement.redrawActionBar2ArtIfWaiting()`
- `UPDATE_BINDINGS` → `ActionBarCluster.restyleHotkeysAfterKeybindChange()`
- `EDIT_MODE_LAYOUTS_UPDATED` → `ActionBarCluster.moveStrayActionButtonsIntoCluster()`, `SetupOffer.offerSetupOrRemindOncePerLogin()`
- LibEditMode's `layout` callback → `WasdLayoutMode.followActiveLayout(layoutName)`

## 7. Tests

`tests/` mirrors the folders, one spec per logic file (`tests/Keybinds/keybind_plan_spec.lua`, …). Game files have no busted tests; the in-game checks at the end of `simplify-after-restructure` cover them. Today's specs move into the new folders, unedited where the behaviour is the same, apart from new names and plain data in place of the stub game functions they pass today. `tests/helpers/load_addon_file.lua` stays; `tests/helpers/wow_stubs.lua` goes.

`CombatQueue` is a game file, but its job-replacing rule is the addon's main safety net and has a test today. Its spec keeps testing it by setting `InCombatLockdown` and `DEFAULT_CHAT_FRAME` before loading the file.

**New tests, for logic that has none today:**
- `KeybindPlan`: losing a key across both groups (a new player's key 1); the restore changes from a copy
- `KeybindCopies`: one copy for account keybinds, one per character on character keybinds; saved once, forgotten
- `SetupSteps`: every step on its own, action bar 2 already matching on create, one gryphon showing
- `RestorePoints`: saved once per character, found, forgotten
- `RestoreSteps`: the saved layout; the first preset when it's gone
- `LayoutList`: the active layout, making a layout active
- `EditModeIds`: nil when an enum value is missing

## 8. Where today's code ends up

| Today | Goes to |
|---|---|
| `Core/Init.lua` `ns.print`, `ns.debug`, `ns.debugEnabled` | `ChatMessages` |
| `Core/Init.lua` `ns.addonVersion` | `AddonVersion.readReleaseVersion` |
| `Core/Events.lua` | `Startup.lua`; its `ADDON_LOADED` settings work → `SavedSettings` |
| `Logic/CombatQueue.lua` | `CombatQueue` (`run` → `runOutOfCombat`, `flush` → `runWaitingJobs`) |
| `Logic/Settings.lua` | `SavedSettings` |
| `Data/Layout.lua` | `ClusterKeys` |
| `Logic/LayoutGeometry.lua` | `ClusterGeometry.measureClusterKeys` |
| `Logic/HotkeyText.lua` | `HotkeyText.shortenMouseButtonNames` |
| `Logic/Placement.lua` (`forLayout`, `save`, `clampScale`, scale limits, valid points) | `ClusterPositions` |
| `UI/Cluster.lua` | `ActionBarCluster` (`follow(wanted)` → `moveActionButtonsIntoCluster` / `moveActionButtonsBackToActionBar1`) |
| `UI/MovementKeys.lua` | `MovementKeys` (`setShown(shown)` → `showMovementKeys` / `hideMovementKeys`) |
| `UI/EditMode.lua` (element, movable, kept on screen, Scale slider) | `ClusterEditModeElement` |
| `UI/EditMode.lua` `apply` | `WasdLayoutMode.followActiveLayout` |
| `UI/EditMode.lua` `refresh` | `Setup` calls `WasdLayoutMode.followActiveLayout` after saving the position |
| `UI/BarArt.lua` | `MainBarReplacement` (`follow(on)` → `replaceActionBar1` / `restoreActionBar1`) |
| `UI/Setup.lua` `mouseFix(on)` | `MainBarReplacement` locals `disableMouseOnActionBar1` / `restoreMouseOnActionBar1` |
| `UI/Setup.lua` `bar2On`, `bar2Offset`, `bottomLeft`, turning action bar 2 on | `MainBarReplacement` |
| `UI/Setup.lua` `bar2HideArt` on create | `MainBarReplacement.matchActionBar2ArtToActionBar1` |
| `Logic/Dividers.lua` | `BarDividers.findButtonsNeedingDivider` |
| `Data/BindingGroups.lua` | `KeybindGroups` |
| `Logic/BindingPlan.lua` | `KeybindPlan` (`build` → `findKeybindChanges`, `lostActions` → `findActionsLosingTheirKey`, `statusSentence` → `describeKeybindStatus`); `commandName` → `Keybinds.nameAction`, with `KeybindPlan.nameActionButton` |
| `UI/Bindings.lua` | `Keybinds` |
| `Logic/Restore.lua` `keyCopy`, `keyChanges` | `KeybindPlan.copyKeybinds`, `KeybindPlan.findRestoreChanges` |
| `Logic/Restore.lua` `keyCopyOwner`; `ns.db.keyCopies` use in Setup | `KeybindCopies` |
| `Logic/Restore.lua` `target`, `lines` | `RestoreSteps` |
| `ns.db.restore[guid]` use in Setup and Restore | `RestorePoints` |
| `Logic/LayoutCopy.lua` | `LayoutList` (`combine` → `combinePresetAndSavedLayouts`, `add` → `copyActiveLayout`, `find` → `findLayoutIndex`, `count` → `hasRoomForAnotherLayout`) |
| `Logic/LayoutPlan.lua` `read`, `edit`, `BAR1`, `SHAPE`, `anchor`, `NAME` | `WasdLayoutSettings` (`edit(withShape)` → three functions, `anchor` → `moveActionBar2` / `moveChatWindow`) |
| `Logic/LayoutPlan.lua` `actions`, `has`, `statusSentence` | `SetupSteps` |
| `UI/Setup.lua` enum ids and their check | `EditModeIds.readEditModeIds` |
| `UI/Setup.lua` `ready`, `loadData`, `save` | `EditModeLayouts` |
| `UI/Setup.lua` `CLUSTER_Y`, `CHAT_GAP`, the chat window maths | `ChatWindow` (`CHAT_GAP`) and `Setup` (`CLUSTER_Y`) |
| `UI/Setup.lua` `refuseInCombat`, the Edit Mode refusals | `SetupGuards` |
| `UI/Setup.lua` `readings`, `plan`, `place`, `apply`, `open`, `layoutStatusSentence` | `Setup` |
| `UI/Setup.lua` the offer popup and its event | `SetupOffer` |
| `UI/Setup.lua` restore popups, `Setup.restore` | `Restore` |
| `UI/SetupWindow.lua` | `SetupWindow` and `ReloadPrompt` |
| `UI/Options.lua` | `OptionsPage`; `openEditMode` → `EditModeLayouts.openEditMode` |
| `Logic/PerfLog.lua` | `PerformanceLog` |
| `Core/Perf.lua` | `PerformanceRecorder`; the recordings default → `SavedSettings.createRecordingsList` |
| `Core/Slash.lua` | `SlashCommands`, and the two globals in `Startup.lua` |
| `tests/helpers/wow_stubs.lua` | removed; tests pass plain data |

## 9. Docs

- `CLAUDE.md` "Code rules": section 1 replaces the Logic/UI split and the load-order line
- `openspec/project.md` "Folder Layout" and "Architecture": sections 3 and 6
- Spec deltas where a spec names a file or folder (`addon-foundation` names `Logic/`)

## 10. Order of work

Planned as one feature at a time alongside the old files. Built in one pass instead: old and new files would both have registered the same events and hooks, so they couldn't run side by side. The order below is the order the files were written in:
1. `Core` files and `Startup.lua` alongside the old files
2. `Keybinds` (tests first: losing a key across both groups, restore from the right copy)
3. `EditModeLayouts`
4. `ActionBarCluster`, `MainBarReplacement`, `WasdLayoutMode`
5. `Setup` (tests first: `SetupSteps`, `RestorePoints`, `RestoreSteps`)
6. `Options`, `Performance`, `SlashCommands`
7. Remove `Logic/`, `Data/`, `UI/`; TOC, `.luacheckrc`, `CLAUDE.md`, `project.md`
