# Design: Restructure into features

Behaviour stays exactly as it is after `fix-what-is-wrong`. Only the structure, the names and the tests change. Dead code and leftover guards stay for `simplify-after-restructure`, so every change here is a move or a rename that the tests can confirm.

## 1. Rules

1. **Folders by feature.** `tests/` mirrors them.
2. **Each feature is an object**, built by `new(dependencies)` with every game part it uses: game functions *and* game frames. Nothing inside a feature reaches for a WoW global. Tests build it with fakes.
3. **One wiring file** (`Core/Wiring.lua`) builds every object with the real game parts and connects game events to methods. It holds no decisions of its own.
4. **Objects are nouns** naming what they own. **Methods start with the verb** and name the purpose, not details that may change.
5. **No boolean parameters** that switch what a function does: two functions instead.
6. **Full-word names** for variables, parameters and data fields, saying what the thing is. Loop indices (`i`) are fine. Saved-setting keys keep their names, so nothing saved moves.
7. **No functions declared inside functions.** Helpers are file-level local functions taking the object as their first argument (`findCommandOnKey(keybinds, key)`), or methods. **One exception:** the game's callbacks (events, hooks, timers, popup buttons, LibEditMode getters and setters, combat-queue jobs) take a function, so a short anonymous function passed straight as an argument is allowed when its body is one method call:
   ```lua
   combatQueue:runOutOfCombat("buttons", function()
     moveActionButtonsIntoCluster(actionBarCluster)
   end)
   ```
8. **No tables holding rules.** Each rule is a small named function, called in order in plain code. Plain data tables (the key shape, the keybind groups, step texts, help lines) are fine.
9. **Pure helpers with no game parts are plain functions** on their module (`ClusterGeometry.measureClusterKeys(...)`). Anything built with dependencies is an object with `new`.

Unchanged from today: every file starts with `local ADDON, ns = ...`; the same globals; everything that moves or shows the action buttons, or changes keybinds, goes through the combat queue; `hooksecurefunc`, never replacing game functions; setup and restore refuse in combat.

## 2. The object pattern

`new` always takes one table of named dependencies.

```lua
local ADDON, ns = ...
local Keybinds = {}
Keybinds.__index = Keybinds
ns.Keybinds = Keybinds

-- dependencies: { getBindingAction, getBindingKey, getBindingName, setBinding,
--   saveBindings, getCurrentBindingSet, getShapeshiftFormInfo, getSpellName, keybindGroups }
function Keybinds.new(dependencies)
  return setmetatable({ dependencies = dependencies }, Keybinds)
end

-- The action on a key now, or nil when it's unbound.
local function findActionOnKey(keybinds, key)
  local action = keybinds.dependencies.getBindingAction(key)
  if action == "" then
    return nil
  end
  return action
end

-- What every setup key is bound to now: { [key] = action | false }.
function Keybinds:copyCurrentKeybinds()
  local keybindCopy = {}
  for _, group in ipairs(self.dependencies.keybindGroups) do
    for _, keybind in ipairs(group.keybinds) do
      keybindCopy[keybind.key] = findActionOnKey(self, keybind.key) or false
    end
  end
  return keybindCopy
end
```

The wiring builds it once:

```lua
local keybinds = ns.Keybinds.new({
  getBindingAction = GetBindingAction,
  getBindingKey = GetBindingKey,
  ...
  keybindGroups = ns.KeybindGroups,
})
```

A test builds it with a fake:

```lua
local keybindApi = fakes.fakeKeybindApi({ Q = "STRAFELEFT" })
local keybinds = Keybinds.new(keybindApi:withKeybindGroups(keybindGroups))
keybinds:restoreKeybinds({ Q = "ACTIONBUTTON1" })
assert.equal("ACTIONBUTTON1", keybindApi.boundActions.Q)
```

## 3. Folders and load order

```
Core/
  ChatMessages.lua            ChatMessages
  GameEvents.lua              GameEvents
  CombatQueue.lua             CombatQueue
  SavedSettings.lua           SavedSettings (plain functions)
  AddonVersion.lua            AddonVersion (plain functions)
  SlashCommands.lua           SlashCommands
ActionBarCluster/
  ClusterKeys.lua             ns.ClusterKeys (data)
  ClusterGeometry.lua         ClusterGeometry (plain functions)
  HotkeyText.lua              HotkeyText (plain functions)
  ActionBarCluster.lua        ActionBarCluster
  MovementKeys.lua            MovementKeys
  ClusterPosition.lua         ClusterPosition
MainBarReplacement/
  BarDividers.lua             BarDividers (plain functions)
  MainBarReplacement.lua      MainBarReplacement
WasdLayoutMode/
  WasdLayoutMode.lua          WasdLayoutMode
Keybinds/
  KeybindGroups.lua           ns.KeybindGroups (data)
  Keybinds.lua                Keybinds
  KeybindCopies.lua           KeybindCopies
EditModeLayouts/
  EditModeIds.lua             EditModeIds (plain functions)
  EditModeLayouts.lua         EditModeLayouts
  WasdLayoutSettings.lua      WasdLayoutSettings
Setup/
  SetupGuards.lua             SetupGuards
  RestorePoints.lua           RestorePoints
  ChatWindow.lua              ChatWindow
  SetupSteps.lua              SetupSteps
  SetupWindow.lua             SetupWindow
  ReloadPrompt.lua            ReloadPrompt
  Setup.lua                   Setup
  SetupOffer.lua              SetupOffer
  Restore.lua                 Restore
Options/
  OptionsPage.lua             OptionsPage
Performance/
  PerformanceRecorder.lua     PerformanceRecorder
Core/Wiring.lua               (last: builds everything)
```

Every file except `Core/Wiring.lua` only defines its object or data when it loads, so the order only matters for `Wiring.lua`, which the TOC loads last.

## 4. Data shapes

Field names inside the tables the objects pass around:

- **Measured cluster key** (`ClusterGeometry`): `{ clusterKey, centreX, centreY, scale }`; the measured cluster is `{ measuredKeys, width, height }`
- **Cluster position** (`ClusterPosition`): `{ point, x, y, scale }`
- **Cluster key** (`ClusterKeys`): `{ label, actionButtonNumber | movementDirection, column, row, size }`
- **Keybind** (`KeybindGroups`): `{ key, keyLabel, action }`, in groups `{ name, heading, detail, keybinds }`
- **Keybind change** (`Keybinds`): `{ key, keyLabel, wantedAction, currentAction }`; per group `{ group, keybindChanges, correctCount, totalCount, status }`
- **Action losing its key**: `{ action, actionName, keyLabels }`
- **All layouts** (`EditModeLayouts`): `{ layouts, activeLayoutIndex }`
- **Layout settings** (`WasdLayoutSettings`): `{ actionBar1 = { settingName = value }, actionBar2 = { … }, gryphonsHidden = { left, right } }`
- **Current layout state** (`Setup`, replacing today's `readings`): `{ wasdLayout = "active" | "inactive" | "missing", activeLayoutName, layoutSettings, isActionBar2On, isActionBar2OnActionBar1 }`
- **Restore point** (`RestorePoints`): `{ layout, bar2 }` (saved keys unchanged)

## 5. The objects

"Built with" lists every dependency passed to `new`. Methods are public unless marked *(local)*.

### Core

**`ChatMessages`**: the addon's lines in chat.
- Built with: `messageFrame` (`DEFAULT_CHAT_FRAME`)
- `:printMessage(...)`: one line, prefixed `WASDBars:`
- `:printDebugMessage(...)`: only while debug output is on
- `:turnDebugOutputOn()`, `:turnDebugOutputOff()`, `:isDebugOutputOn()`

**`GameEvents`**: game events to handlers.
- Built with: `createFrame`
- `:listenFor(eventName, handler)`: several handlers per event run in the order added

**`CombatQueue`**: runs jobs now, or after combat.
- Built with: `isInCombat` (`InCombatLockdown`), `chatMessages`
- `:runOutOfCombat(jobName, job)`: runs now out of combat; in combat, waits, and a newer job with the same name replaces the waiting one. Says "Will apply after combat." once per combat
- `:runWaitingJobs()`: when combat ends
- `:isInCombat()`

**`SavedSettings`** (plain functions): `WASDBarsDB`.
- `SavedSettings.DEFAULTS` (data)
- `SavedSettings.fillMissingSettings(savedSettings)`: fills missing keys with copies of the defaults, never overwrites
- `SavedSettings.moveV110KeybindCopyToAccount(savedSettings)`: from `fix-what-is-wrong`
- `SavedSettings.forgetV100SetUpFlag(savedSettings)`: today's `setUp = nil` (removal is for `simplify-after-restructure`)
- `SavedSettings.createRecordingsList(savedRecordings)`: today's `WASDBarsPerfDB.sessions` default

**`AddonVersion`** (plain functions).
- `AddonVersion.readReleaseVersion(versionMetadata)`: "1.1.1", or nil for a dev build (`@project-version@`)

**`SlashCommands`**: `/wasd`.
- Built with: `chatMessages`, `setup`, `restore`, `optionsPage`, `performanceRecorder`, `releaseVersion`
- `SlashCommands.HELP_LINES` (data): command name → help text, for `help` only
- `:runSlashCommand(text)`: an `if`/`elseif` on the command name, each calling one local
- *(local)* `showHelp`, `showVersion`, `switchDebugOutput`, `runPerformanceCommand`, `runSetupCommand`
- The wiring sets `SLASH_WASDBARS1` and `SlashCmdList.WASDBARS`, which calls `runSlashCommand`

### ActionBarCluster

**`ClusterKeys`** (data, was `Data/Layout.lua`): the WASD key shape, key sizes, the default position and scale. Renamed because an Edit Mode layout is a different thing.

**`ClusterGeometry`** (plain functions).
- `ClusterGeometry.measureClusterKeys(clusterKeys, buttonSize)`: each key's centre and scale, and the cluster's size

**`HotkeyText`** (plain functions).
- `HotkeyText.shortenMouseButtonNames(hotkeyText)`: "Mouse Button 5" → "M5"

**`ActionBarCluster`**: the cluster frame and action bar 1's buttons in it.
- Built with: `createFrame`, `uiParent`, `actionButtons` (`ActionButton1`–`12`), `hookFunction` (`hooksecurefunc`), `combatQueue`, `chatMessages`, `savedSettings`, `clusterKeys`
- `:buildActionBarCluster()`: at login; measures the keys from the first action button, makes the hidden `WASDBarsCluster` frame, keeps the hotkey style up to date after the game redraws it
- `:moveActionButtonsIntoCluster()`, `:moveActionButtonsBackToActionBar1()`: through the combat queue, sharing one job name so the last one asked for runs
- `:areActionButtonsInCluster()`
- `:moveStrayActionButtonsIntoCluster()`: today's safety check on Edit Mode updates
- `:repositionActionBarCluster(clusterPosition)`: through the combat queue
- `:showLargeHotkeys()`, `:showGameHotkeys()`: the "Large hotkey text" option
- `:restyleHotkeysAfterKeybindChange()`
- `:findClusterFrame()`, `:findMeasuredKeys()`, `:findButtonSize()`, `:measureClusterHeight()`
- *(local)* `applyLargeHotkeyStyle`, `applyGameHotkeyStyle`, `saveGameHotkeyStyle`

**`MovementKeys`**: the W, A, S, D arrow keys.
- Built with: `createFrame`, `templateButton` (`ActionButton1`), `getAtlasInfo` (`C_Texture.GetAtlasInfo`), `actionBarCluster`, `savedSettings`
- `:drawMovementKeys()`: at login, after the cluster is built
- `:showMovementKeys()`, `:hideMovementKeys()`

**`ClusterPosition`**: where the cluster sits on each layout, and its Edit Mode element.
- Built with: `libEditMode`, `actionBarCluster`, `savedSettings`, `clusterKeys`
- `ClusterPosition.MIN_SCALE`, `MAX_SCALE`
- `:addClusterToEditMode()`: the "WASDBars" element (movable, kept on screen), dragging saves the position, the Scale slider saves and repositions
- `:findClusterPosition(layoutName)`: saved, or the defaults; a damaged entry never errors
- `:saveClusterPosition(layoutName, point, x, y)`, `:saveClusterScale(layoutName, scale)`
- *(local)* `limitScale`, `isValidPoint`

### MainBarReplacement

**`BarDividers`** (plain functions).
- `BarDividers.findButtonsNeedingDivider(isButtonShown, rowCount, padding, minimumPadding)`: the game's rule for action bar 1, applied to action bar 2 (today's unused `hideArt` parameter goes: it's never passed, so nothing changes)

**`MainBarReplacement`**: action bar 2 taking action bar 1's place, and action bar 2 itself.
- Built with: `actionBar1` (`MainActionBar`), `actionBar1FirstButtonHolder` (`MainActionBarButtonContainer1`), `actionBar2` (`MultiBarBottomLeft`), `actionBar2FirstButton` (`MultiBarBottomLeftButton1`), `getActionBarToggles`, `setOptionValue` (`Settings.SetValue`), `createFrame`, `createFramePool`, `hookFunction`, `libEditMode`, `editModeIds`, `combatQueue`, `savedSettings`
- `:replaceActionBar1()`: action bar 1 see-through and not catching the mouse; action bar 2's art drawn unless Hide Bar Art is ticked
- `:restoreActionBar1()`: action bar 1 visible and catching the mouse as before; action bar 2's own look
- `:keepActionBar2ArtUpToDate()`: at login; redraws after the game updates action bar 2
- `:redrawActionBar2ArtIfWaiting()`: when combat ends, if a redraw waited
- `:addHideBarArtCheckbox()`: action bar 2's checkbox, on the WASDBars layout only
- `:matchActionBar2ArtToActionBar1(layoutSettings)`: on a new layout, Hide Bar Art starts as action bar 1's was
- `:isActionBar2On()`, `:turnOnActionBar2()`, `:turnOffActionBar2()`
- `:isActionBar2OnActionBar1()`, `:findActionBar2AnchorOnActionBar1()`
- *(local)* `disableMouseOnActionBar1`, `restoreMouseOnActionBar1`, `redrawActionBar2Art`, `drawActionBar2Border`, `drawActionBar2Dividers`, `styleButtonsLikeActionBar1`, `styleButtonsLikeActionBar2`, `measureOffsetToActionBar1`

### WasdLayoutMode

**`WasdLayoutMode`**: being on the WASDBars layout is the player's consent to moving the buttons and replacing action bar 1.
- Built with: `actionBarCluster`, `mainBarReplacement`, `clusterPosition`, `wasdLayoutName`
- `:followActiveLayout(layoutName)`: repositions the cluster for that layout, then enters or leaves WASD layout mode
- *(local)* `enterWasdLayoutMode` (buttons into the cluster, action bar 1 replaced), `leaveWasdLayoutMode` (both undone)

### Keybinds

**`KeybindGroups`** (data, was `Data/BindingGroups.lua`): the WASD keys and the number row.

**`Keybinds`**: the setup keys and the game's keybinds. "Action" is used throughout for what a key does (the game calls it a command).
- Built with: `getBindingAction`, `getBindingKey`, `getBindingName`, `setBinding`, `saveBindings`, `getCurrentBindingSet`, `getShapeshiftFormInfo`, `getSpellName`, `keybindGroups`
- `:findKeybindChanges()`: per group, the keys not yet bound as setup wants
- `:findActionsLosingTheirKey(keybindChanges)`: with each action's name for the window
- `:applyKeybindChanges(keybindChanges)`: saves to the binding set the character already uses
- `:copyCurrentKeybinds()`, `:restoreKeybinds(keybindCopy)`
- `:isEveryKeybindSetUp()`, `:describeKeybindStatus()`
- `:nameAction(action)`: "Action bar 1 button 3", a form name, or the game's name
- Apply and restore are out of combat only; their callers refuse in combat (`SetupGuards`)
- *(local)* `findActionOnKey`, `doesActionKeepAKey(keybinds, action, keysSetupWillChange, actionsSetupWillBind)`, `groupChangesByCurrentAction`, `findFormName`

**`KeybindCopies`**: the keys from before setup, one copy per binding set.
- Built with: `getCurrentBindingSet`, `characterBindingSet` (`CHARACTER_BINDINGS`), `getPlayerGuid`, `savedSettings`
- `:saveKeybindCopyOnce(keybindCopy)`, `:findKeybindCopy()`, `:forgetKeybindCopy()`
- *(local)* `findCopyOwner`: "account", or the character's GUID on character keybinds

### EditModeLayouts

**`EditModeIds`** (plain functions).
- `EditModeIds.readEditModeIds(enum)`: the game's Edit Mode enum values, or nil if one setup needs is missing (today's check, kept until `simplify-after-restructure`)

**`EditModeLayouts`**: reading, writing and opening the game's Edit Mode layouts.
- Built with: `editModeApi` (`C_EditMode`), `presetLayouts` (`EditModePresetLayoutManager`), `editModeManager` (`EditModeManagerFrame`), `libEditModeOverride`, `libEditMode`, `optionsPanel` (`SettingsPanel`), `showPanel`, `hidePanel`, `layoutTypes` (`Enum.EditModeLayoutType`), `maxLayoutsPerType`
- `:isEditModeReady()`, `:isEditModeOpen()`, `:openEditMode()`
- `:loadAllLayouts()`: presets first, then saved layouts brought up to date with the game's systems
- `:saveAllLayouts(allLayouts)`: saves and makes the game apply them
- `:findActiveLayout(allLayouts)`, `:findActiveLayoutName()`, `:findLayoutIndex(allLayouts, layoutName)`, `:findFirstPresetLayoutName(allLayouts)`
- `:copyActiveLayout(allLayouts, newLayoutName)`: where Edit Mode puts new layouts, and made active
- `:makeLayoutActive(allLayouts, layoutName)`: in the table, saved by `saveAllLayouts`
- `:switchToLayout(layoutName)`: straight away
- `:hasRoomForAnotherLayout(allLayouts)`

**`WasdLayoutSettings`**: the settings the WASDBars layout needs, on layout tables. Pure apart from `editModeIds`.
- Built with: `editModeIds`
- `WasdLayoutSettings.WASD_LAYOUT_NAME` = "WASDBars"
- `:readLayoutSettings(layout)`
- `:isActionBar1SetUp(layoutSettings)`, `:doesActionBar2MatchActionBar1(layoutSettings)`, `:areGryphonsHidden(layoutSettings)`
- `:applyActionBar1Settings(layout)`, `:copyActionBar1ShapeToActionBar2(layout)`, `:hideGryphons(layout)`
- `:moveActionBar2(layout, anchor)`, `:moveChatWindow(layout, anchor)`
- *(local)* `findSystem`, `readSetting`, `writeSetting`

### Setup

**`SetupGuards`**: the two refusals setup and restore share.
- Built with: `combatQueue`, `editModeLayouts`, `chatMessages`
- `:refuseInCombat(whatPlayerTried)`: says "Can't … in combat." and returns true
- `:refuseInEditMode(commandToRunAgain)`: says "Close Edit Mode, then run /wasd …." and returns true

**`RestorePoints`**: per character, the layout and action bar 2 from before setup.
- Built with: `getPlayerGuid`, `savedSettings`
- `:saveRestorePointOnce(layoutName, wasActionBar2On)`, `:findRestorePoint()`, `:forgetRestorePoint()`

**`ChatWindow`**: the game's chat window, moved up on a new layout.
- Built with: `chatWindow` (`ChatFrame1`), `uiParent`
- `:findAnchorAboveCluster(clusterTop)`: the chat window's anchor above the cluster, leaving room for its edit box
- `:findLeftEdge()`: where the cluster goes, in screen units

**`SetupSteps`**: which layout steps setup still needs. Pure apart from `wasdLayoutSettings`.
- Built with: `wasdLayoutSettings`
- `:findNeededLayoutSteps(currentLayoutState)`: straight-line code, one `if` per step, in window order:
  ```lua
  if isWasdLayoutMissing(currentLayoutState) then
    table.insert(neededLayoutSteps, "createWasdLayout")
  end
  if isWasdLayoutInactive(currentLayoutState) then
    table.insert(neededLayoutSteps, "switchToWasdLayout")
  end
  ...
  ```
- `:describeLayoutStep(stepName, currentLayoutState)`: the window text, including the source layout's name for `createWasdLayout`
- `:describeLayoutStatus(currentLayoutState, neededLayoutSteps)`: the layout half of `/wasd setup status`
- Steps, in order: `createWasdLayout`, `switchToWasdLayout`, `moveActionButtons` and `replaceActionBar1` (listed with create or switch; switching is what does them), `positionClusterAndChatWindow` (with create), `setUpActionBar1`, `matchActionBar2ToActionBar1` (with create), `placeActionBar2OnActionBar1`, `hideGryphons`, `turnOnActionBar2`
- *(local, one each)* `isWasdLayoutMissing`, `isWasdLayoutInactive`, `isActionBar1Wrong`, `isActionBar2ShapeWrong`, `isActionBar2AwayFromActionBar1`, `areGryphonsShowing`, `isActionBar2TurnedOff`

**`SetupWindow`**: the window listing every change.
- Built with: `createFrame`, `uiParent`, `specialFrames` (`UISpecialFrames`, so Escape closes it)
- `:showSetupChanges(neededLayoutStepTexts, keybindChanges, actionsLosingTheirKey, onSetUpClicked)`
- `:isSetupWindowShown()`
- *(local)* `addHeading`, `addLine`, `arrangeLines`

**`ReloadPrompt`**: the "Reload to finish" window with its own secure button.
- Built with: `createFrame`, `uiParent`, `combatQueue`
- `:askForReloadAfterSetup()`, `:askForReloadAfterRestore()`

**`Setup`**: the setup flow.
- Built with: `editModeLayouts`, `wasdLayoutSettings`, `setupSteps`, `setupGuards`, `restorePoints`, `keybinds`, `keybindCopies`, `actionBarCluster`, `clusterPosition`, `mainBarReplacement`, `wasdLayoutMode`, `chatWindow`, `setupWindow`, `reloadPrompt`, `runNextFrame` (`C_Timer.After`), `combatQueue`, `chatMessages`
- `:openSetupWindow()`: `/wasd setup` and the Run setup button
- `:isAnythingLeftToSetUp()`, `:isOnWasdLayout()`: for the offer
- `:describeSetupStatus()`: `/wasd setup status`
- *(local, in the order setup runs them)* `readCurrentLayoutState`, `saveRestorePoint`, `saveKeybindCopy`, `createWasdLayout`, `switchToWasdLayout`, `applyWasdLayoutSettings`, `placeActionBar2OnActionBar1`, `positionClusterAndChatWindowOnNewLayout` (saves the cluster's position, then `wasdLayoutMode:followActiveLayout` applies it straight away, as `EditMode.refresh` does today), `turnOnActionBar2IfOff`, `confirmSetupOrAskForReload`

**`SetupOffer`**: the first-time offer and the login reminder.
- Built with: `setup`, `showPopup` (`StaticPopup_Show`), `popupDialogs` (`StaticPopupDialogs`), `getPlayerGuid`, `runNextFrame`, `combatQueue`, `chatMessages`, `savedSettings`
- `:offerSetupOrRemindOncePerLogin()`: on every Edit Mode update; only the first one per login does anything

**`Restore`**: `/wasd restore`.
- Built with: `editModeLayouts`, `setupGuards`, `restorePoints`, `keybinds`, `keybindCopies`, `mainBarReplacement`, `reloadPrompt`, `showPopup`, `popupDialogs`, `chatMessages`
- `:askToRestore()`: `/wasd restore` and the Restore button
- *(local)* `findLayoutToRestore`, `describeRestore`, `restoreLayout`, `askToRestoreKeybinds`, `finishRestore`

### Options and Performance

**`OptionsPage`**: the page under AddOns in the game's options.
- Built with: `optionsApi` (`Settings`), `createButtonInitializer`, `createHeaderInitializer`, `editModeLayouts`, `setupGuards`, `movementKeys`, `actionBarCluster`, `setup`, `restore`, `savedSettings`, `defaultSettings`
- `:addOptionsPage()`: at login
- `:openOptionsPage()`: `/wasd options`

**`PerformanceRecorder`**: `/wasd perf`.
- Built with: `addonName`, `profiler` (`C_AddOnProfiler`), `profilerMetrics` (`Enum.AddOnProfilerMetric`), `newTicker` (`C_Timer.NewTicker`), `getTime`, `getFramerate`, `isInCombat`, `getShapeshiftForm`, `doesUnitExist`, `formatDate` (`date`), `getBuildInfo`, `releaseVersion`, `chatMessages`, `savedRecordings` (`WASDBarsPerfDB`)
- `PerformanceRecorder.MAX_ROWS`, `MAX_RECORDINGS`
- `:startRecording(label)`, `:stopRecording()`, `:clearRecordings()`
- *(local)* `recordOneSecond`, `keepNewestRows`, `keepNewestRecordings`, `readAllMetrics`

## 6. Wiring (`Core/Wiring.lua`)

The one place that knows every object. It builds them and connects events; every handler is one method call.

**At `ADDON_LOADED`** (saved settings exist from here):
1. `SavedSettings.fillMissingSettings`, `forgetV100SetUpFlag`, `moveV110KeybindCopyToAccount`, `createRecordingsList`
2. `chatMessages`, `combatQueue`
3. `editModeLayouts`, `wasdLayoutSettings`
4. `keybinds`, `keybindCopies`
5. `actionBarCluster`, `movementKeys`, `clusterPosition`, `mainBarReplacement`, `wasdLayoutMode`
6. `setupGuards`, `restorePoints`, `chatWindow`, `setupSteps`, `setupWindow`, `reloadPrompt`, `setup`, `setupOffer`, `restore`
7. `optionsPage`, `performanceRecorder`, `slashCommands`; `SLASH_WASDBARS1` and `SlashCmdList.WASDBARS`

**At `PLAYER_LOGIN`**: `actionBarCluster:buildActionBarCluster()`, `movementKeys:drawMovementKeys()`, `clusterPosition:addClusterToEditMode()`, `mainBarReplacement:keepActionBar2ArtUpToDate()`, `mainBarReplacement:addHideBarArtCheckbox()`, `optionsPage:addOptionsPage()`, then `wasdLayoutMode:followActiveLayout(editModeLayouts:findActiveLayoutName())`.

**Events to methods**:
- `PLAYER_REGEN_ENABLED` → `combatQueue:runWaitingJobs()`, `mainBarReplacement:redrawActionBar2ArtIfWaiting()`
- `UPDATE_BINDINGS` → `actionBarCluster:restyleHotkeysAfterKeybindChange()`
- `EDIT_MODE_LAYOUTS_UPDATED` → `actionBarCluster:moveStrayActionButtonsIntoCluster()`, `setupOffer:offerSetupOrRemindOncePerLogin()`
- LibEditMode's `layout` callback → `wasdLayoutMode:followActiveLayout(layoutName)`

## 7. Tests

`tests/` mirrors the folders, one spec per object or module (`tests/Keybinds/keybinds_spec.lua`, …). Today's specs move into them, unedited where the behaviour is the same, apart from new names. `tests/helpers/load_addon_file.lua` stays.

**Fakes** in `tests/fakes/`, each with only the methods the objects call:
- `fakeKeybindApi`: keybinds in a table; records what was bound and which binding set was saved
- `fakeFrame`: records points, parent, scale, shown and mouse; `createFrame` makes these
- `fakeEditModeApi`: layouts in a table; records saves and the active layout
- `fakeCombat`, `fakeChatMessages`, `fakeTimers` (runs `runNextFrame` and ticker callbacks on demand)
- `fakePopups`: records shown popups and lets a test press their buttons
- `fakeLibEditMode`: records registered frames, settings and callbacks
- `fakeOptionsApi`, `fakeProfiler`

**New tests, for code that has none today:**
- `Setup`: a new character's full setup (layout copied, restore point and keybind copy saved once, action bar 2's art matched, reload asked for); switching to an existing layout; keys only (no reload); the layout limit; refusing in combat and in Edit Mode
- `SetupOffer`: the offer once per character, then the reminder; nothing on the second Edit Mode update
- `Restore`: back to the saved layout; the first preset when it's gone; keybinds restored from the right copy and that copy forgotten; nothing to restore
- `Keybinds`: losing a key across both groups (a new player's key 1); applying and restoring to the character's binding set
- `KeybindCopies`: one copy for account keybinds, one per character on character keybinds
- `WasdLayoutMode`: on "WASDBars" the buttons go into the cluster and action bar 1 is replaced; off it, both are undone
- `ActionBarCluster`: buttons in and out, the last request winning in combat, stray buttons put back
- `SetupSteps`: every step on its own, action bar 2 already matching on create, one gryphon showing
- `SlashCommands`: each command reaches its object

## 8. Where today's code ends up

| Today | Goes to |
|---|---|
| `Core/Init.lua` `ns.print`, `ns.debug`, `ns.debugEnabled` | `ChatMessages` |
| `Core/Init.lua` `ns.addonVersion` | `AddonVersion.readReleaseVersion`; the wiring passes the result on |
| `Core/Events.lua` | `GameEvents`; its `ADDON_LOADED` work → `Wiring.lua` and `SavedSettings` |
| `Logic/CombatQueue.lua` | `CombatQueue` (`run` → `runOutOfCombat`, `flush` → `runWaitingJobs`) |
| `Logic/Settings.lua` | `SavedSettings` |
| `Data/Layout.lua` | `ClusterKeys` |
| `Logic/LayoutGeometry.lua` | `ClusterGeometry.measureClusterKeys` |
| `Logic/HotkeyText.lua` | `HotkeyText.shortenMouseButtonNames` |
| `Logic/Placement.lua` (`forLayout`, `save`, `clampScale`, scale limits, valid points) | `ClusterPosition` |
| `UI/Cluster.lua` | `ActionBarCluster` (`follow(wanted)` → `moveActionButtonsIntoCluster` / `moveActionButtonsBackToActionBar1`) |
| `UI/MovementKeys.lua` | `MovementKeys` (`setShown(shown)` → `showMovementKeys` / `hideMovementKeys`) |
| `UI/EditMode.lua` (element, movable, kept on screen, Scale slider) | `ClusterPosition` |
| `UI/EditMode.lua` `apply` | `WasdLayoutMode:followActiveLayout` |
| `UI/EditMode.lua` `refresh` | `Setup` calls `wasdLayoutMode:followActiveLayout` after saving the position |
| `UI/BarArt.lua` | `MainBarReplacement` (`follow(on)` → `replaceActionBar1` / `restoreActionBar1`) |
| `UI/Setup.lua` `mouseFix(on)` | `MainBarReplacement` locals `disableMouseOnActionBar1` / `restoreMouseOnActionBar1` |
| `UI/Setup.lua` `bar2On`, `bar2Offset`, `bottomLeft`, turning action bar 2 on | `MainBarReplacement` |
| `UI/Setup.lua` `bar2HideArt` on create | `MainBarReplacement:matchActionBar2ArtToActionBar1` |
| `Logic/Dividers.lua` | `BarDividers.findButtonsNeedingDivider` |
| `Data/BindingGroups.lua` | `KeybindGroups` |
| `Logic/BindingPlan.lua` | `Keybinds` (`build` → `findKeybindChanges`, `lostActions` → `findActionsLosingTheirKey`, `commandName` → `nameAction`, `statusSentence` → `describeKeybindStatus`) |
| `UI/Bindings.lua` | `Keybinds` |
| `Logic/Restore.lua` `keyCopy`, `keyChanges` | `Keybinds:copyCurrentKeybinds`, `Keybinds:restoreKeybinds` |
| `Logic/Restore.lua` `keyCopyOwner`; `ns.db.keyCopies` use in Setup | `KeybindCopies` |
| `Logic/Restore.lua` `target`, `lines` | `Restore` locals, with `EditModeLayouts:findFirstPresetLayoutName` |
| `ns.db.restore[guid]` use in Setup and Restore | `RestorePoints` |
| `Logic/LayoutCopy.lua` | `EditModeLayouts` (`combine` → inside `loadAllLayouts`, `add` → `copyActiveLayout`, `find` → `findLayoutIndex`, `count` → `hasRoomForAnotherLayout`) |
| `Logic/LayoutPlan.lua` `read`, `edit`, `BAR1`, `SHAPE`, `anchor`, `NAME` | `WasdLayoutSettings` (`edit(withShape)` → three methods, `anchor` → `moveActionBar2` / `moveChatWindow`) |
| `Logic/LayoutPlan.lua` `actions`, `has`, `statusSentence` | `SetupSteps` |
| `UI/Setup.lua` enum ids and their check | `EditModeIds.readEditModeIds` |
| `UI/Setup.lua` `ready`, `loadData`, `save` | `EditModeLayouts` |
| `UI/Setup.lua` `CLUSTER_Y`, `CHAT_GAP`, the chat window maths | `ChatWindow` (`CHAT_GAP`) and `Setup` (`CLUSTER_Y`) |
| `UI/Setup.lua` `refuseInCombat`, the Edit Mode refusals | `SetupGuards` |
| `UI/Setup.lua` `readings`, `plan`, `place`, `apply`, `open`, `layoutStatusSentence` | `Setup` |
| `UI/Setup.lua` the offer popup and its event | `SetupOffer` |
| `UI/Setup.lua` restore popups, `Setup.restore` | `Restore` |
| `UI/SetupWindow.lua` | `SetupWindow` and `ReloadPrompt` |
| `UI/Options.lua` | `OptionsPage`; `openEditMode` → `EditModeLayouts:openEditMode` |
| `Logic/PerfLog.lua`, `Core/Perf.lua` | `PerformanceRecorder`; the recordings default → `SavedSettings.createRecordingsList` |
| `Core/Slash.lua` | `SlashCommands`, and the two globals in the wiring |
| `tests/helpers/wow_stubs.lua` | `tests/fakes/` |

## 9. Docs

- `CLAUDE.md` "Code rules": section 1 replaces the Logic/UI split and the load-order line
- `openspec/project.md` "Folder Layout" and "Architecture": sections 3 and 6
- Spec deltas where a spec names a file or folder (`addon-foundation` names `Logic/`)

## 10. Order of work

One feature at a time, `make check` passing after each, with old files removed as their code moves:
1. Fakes, the `Core` objects, and `Wiring.lua` alongside the old files
2. `Keybinds`, `KeybindCopies` (tests first: losing a key across both groups, restore to the right binding set)
3. `EditModeLayouts`, `WasdLayoutSettings`
4. `ActionBarCluster`, `ClusterPosition`, `MovementKeys`, `MainBarReplacement`, `WasdLayoutMode`
5. `SetupGuards`, `RestorePoints`, `ChatWindow`, `SetupSteps`, `SetupWindow`, `ReloadPrompt`, `Setup`, `SetupOffer`, `Restore` (tests first: the setup and restore flows)
6. `OptionsPage`, `PerformanceRecorder`, `SlashCommands`
7. Remove `Logic/`, `Data/`, `UI/`; TOC, `.luacheckrc`, `CLAUDE.md`, `project.md`
