local ADDON, ns = ...
local Setup = {}
ns.Setup = Setup

-- Setup changes only the account-wide "WASDBars" Edit Mode layout. Layout
-- tables are edited here (as Edit Mode stores them), saved with
-- C_EditMode.SaveLayouts, and LibEditModeOverride (a TOC dependency) makes
-- the game apply them.
local LEMO = LibStub("LibEditModeOverride-1.0")
local NAME = ns.LayoutPlan.NAME
local OFFER = "WASDBARS_OFFER_SETUP"
local RESTORE = "WASDBARS_RESTORE"
local RESTORE_KEYS = "WASDBARS_RESTORE_KEYS"
-- cluster's bottom edge, and the space between its top and the chat window
-- (which leaves room for the chat's edit box)
local CLUSTER_Y, CHAT_GAP = 12, 40

local function enum(group, name)
  local t = Enum[group]
  return t and t[name]
end

-- The game's Edit Mode enum values (see Logic/LayoutPlan.lua), or nil if this
-- client is missing one the setup can't do without.
local function editModeIds()
  local bar = {}
  for name, key in pairs({
    numIcons = "NumIcons",
    alwaysShowButtons = "AlwaysShowButtons",
    hideBarArt = "HideBarArt",
    hideBarScrolling = "HideBarScrolling",
    orientation = "Orientation",
    numRows = "NumRows",
    iconSize = "IconSize",
    iconPadding = "IconPadding",
  }) do
    bar[name] = enum("EditModeActionBarSetting", key)
  end
  local ids = {
    actionBar = enum("EditModeSystem", "ActionBar"),
    bar1 = enum("EditModeActionBarSystemIndices", "MainBar"),
    bar2 = enum("EditModeActionBarSystemIndices", "Bar2"),
    endCap = enum("EditModeSystem", "MainActionBarEndCap"),
    capLeft = enum("EditModeMainActionBarEndCapSystemIndices", "EndCapLeft"),
    capRight = enum("EditModeMainActionBarEndCapSystemIndices", "EndCapRight"),
    capHidden = enum("EditModeMainActionBarEndCapSetting", "Hidden"),
    chat = enum("EditModeSystem", "ChatFrame"),
    bar = bar,
  }
  if ids.actionBar and ids.bar1 and ids.bar2 and enum("EditModeLayoutType", "Account") then
    return ids
  end
end

local function ready()
  return LEMO:IsReady() and C_EditMode and EditModePresetLayoutManager and editModeIds() ~= nil
end

-- Where this character's key copy is kept (Logic/Restore.lua).
local function keyCopyOwner()
  return ns.Restore.keyCopyOwner(GetCurrentBindingSet(), CHARACTER_BINDINGS, UnitGUID("player"))
end

-- Every layout, presets first (Logic/LayoutCopy.lua). Saved layouts are
-- brought up to date with the game's current systems first, as
-- LibEditModeOverride does.
local function loadData()
  local saved = C_EditMode.GetLayouts()
  for _, layout in ipairs(saved.layouts) do
    EditModeManagerFrame:ReconcileWithModern(layout)
  end
  return ns.LayoutCopy.combine(EditModePresetLayoutManager:GetCopyOfPresetLayouts(), saved)
end

local function save(data)
  C_EditMode.SaveLayouts(data)
  C_EditMode.SetActiveLayout(data.activeLayout)
  LEMO:LoadLayouts()
  LEMO:ApplyChanges()
end

local function bottomLeft(frame)
  local left, bottom = frame:GetLeft(), frame:GetBottom()
  if not left then
    return nil
  end
  local scale = frame:GetEffectiveScale()
  return left * scale, bottom * scale
end

-- Screen pixels from action bar 2's first button to action bar 1's first
-- button holder, or nil if either isn't laid out.
local function bar2Offset()
  local holder, button = _G.MainActionBarButtonContainer1, _G.MultiBarBottomLeftButton1
  if not (holder and button) then
    return nil
  end
  local hx, hy = bottomLeft(holder)
  local bx, by = bottomLeft(button)
  if not (hx and bx) then
    return nil
  end
  return hx - bx, hy - by
end

local function bar2On()
  return (GetActionBarToggles()) and true or false
end

local function readings(ids, data)
  local active = data.layouts[data.activeLayout]
  local index = ns.LayoutCopy.find(data, NAME)
  local step, target
  if active.layoutName == NAME then
    target = active
  elseif index then
    step, target = "switch", data.layouts[index]
  else
    step, target = "create", active
  end
  local onBar1
  if not step then
    local dx, dy = bar2Offset()
    if dx then
      onBar1 = math.abs(dx) <= 1 and math.abs(dy) <= 1
    end
  end
  return {
    step = step,
    source = active.layoutName,
    layout = ns.LayoutPlan.read(target, ids),
    bar2On = bar2On(),
    onBar1 = onBar1,
  }
end

-- What's still needed, or nil (with a reason) when it can't be worked out yet.
local function plan()
  if not ready() then
    return nil, "Edit Mode isn't ready yet. Try again in a moment."
  end
  local ids = editModeIds()
  local r = readings(ids, loadData())
  return { ids = ids, readings = r, actions = ns.LayoutPlan.actions(r) }
end

-- On the WASDBars layout action bar 1 is empty (the cluster has its buttons);
-- stop it and its Edit Mode selection catching the mouse so action bar 2 on
-- top of it works. On any other layout, give them back the game's mouse state.
-- Called from UI/EditMode.lua whenever the active layout changes.
local gameMouse
function Setup.mouseFix(on)
  ns.combatQueue:run("bar1-mouse", function()
    local selection = MainActionBar.Selection
    if not gameMouse then
      gameMouse = { bar = MainActionBar:IsMouseEnabled(), selection = selection and selection:IsMouseEnabled() }
    end
    MainActionBar:EnableMouse(not on and gameMouse.bar)
    if selection then
      selection:EnableMouse(not on and gameMouse.selection)
    end
  end)
end

-- Second pass, once the first save has been laid out: action bar 2 onto
-- action bar 1 and, for a new layout, the cluster and the chat window.
local function place(ids, withClusterAndChat)
  local data = loadData()
  local layout = data.layouts[data.activeLayout]
  local dx, dy = bar2Offset()
  if dx then
    local bar = MultiBarBottomLeft
    local scale = bar:GetEffectiveScale()
    ns.LayoutPlan.anchor(layout, ids.actionBar, ids.bar2, {
      point = "BOTTOMLEFT",
      relativeTo = "UIParent",
      relativePoint = "BOTTOMLEFT",
      offsetX = bar:GetLeft() + dx / scale,
      offsetY = bar:GetBottom() + dy / scale,
    })
  end
  if withClusterAndChat then
    local chat = ChatFrame1
    local chatScale = chat:GetEffectiveScale() / UIParent:GetEffectiveScale()
    local x = chat:GetLeft() * chatScale
    local scale = select(4, ns.Placement.forLayout(ns.db.layouts, NAME, ns.Layout.position, ns.Layout.scale))
    -- placement offsets are in the cluster's scaled units
    ns.Placement.save(ns.db.layouts, NAME, { point = "BOTTOMLEFT", x = x / scale, y = CLUSTER_Y / scale })
    local top = CLUSTER_Y + ns.Cluster.frame:GetHeight() * scale
    ns.LayoutPlan.anchor(layout, ids.chat, nil, {
      point = "BOTTOMLEFT",
      relativeTo = "UIParent",
      relativePoint = "BOTTOMLEFT",
      offsetX = chat:GetLeft(),
      offsetY = (top + CHAT_GAP) / chatScale,
    })
    ns.EditMode.refresh()
  end
  save(data)
end

-- Setup and restore refuse in combat rather than waiting for it to end.
local function refuseInCombat(what)
  if InCombatLockdown() then
    ns.print("Can't " .. what .. " in combat.")
    return true
  end
  return false
end

local function apply(p, steps)
  if refuseInCombat("set up") then
    return
  end
  if EditModeManagerFrame:IsEditModeActive() then
    ns.print("Close Edit Mode, then run /wasd setup.")
    return
  end
  local ids, actions, has = p.ids, p.actions, ns.LayoutPlan.has
  local guid = UnitGUID("player")
  local data = loadData()
  local creating = has(actions, "create")

  if creating then
    local max = Constants.EditModeConsts.EditModeMaxLayoutsPerType
    if ns.LayoutCopy.count(data, Enum.EditModeLayoutType.Account) >= max then
      ns.print("You have the most Edit Mode layouts the game allows. Delete one, then run /wasd setup.")
      return
    end
  end
  if creating or has(actions, "switch") then
    ns.db.restore[guid] = ns.db.restore[guid]
      or { layout = data.layouts[data.activeLayout].layoutName, bar2 = bar2On() }
  end
  local owner = keyCopyOwner()
  if #steps > 0 and not ns.db.keyCopies[owner] then
    ns.db.keyCopies[owner] = ns.Restore.keyCopy(ns.BindingGroups, GetBindingAction)
  end

  local layoutActions = 0
  for _, action in ipairs(actions) do
    if action.id ~= "bar2On" then
      layoutActions = layoutActions + 1
    end
  end
  if layoutActions > 0 then
    if creating then
      -- action bar 2's art starts as action bar 1's was in the source layout,
      -- read before LayoutPlan.edit turns action bar 1's art off
      ns.db.bar2HideArt = p.readings.layout.bar1.hideBarArt == 1
      ns.LayoutCopy.add(data, NAME, Enum.EditModeLayoutType.Account, Enum.EditModeLayoutType.Preset)
    elseif has(actions, "switch") then
      data.activeLayout = ns.LayoutCopy.find(data, NAME)
    end
    ns.LayoutPlan.edit(data.layouts[data.activeLayout], ids, creating)
    save(data)
  end
  if has(actions, "bar2On") then
    Settings.SetValue("PROXY_SHOW_ACTIONBAR_2", true)
  end
  if #steps > 0 then
    ns.Bindings.apply(steps)
  end

  -- Applying a layout from addon code taints the game's bar code (the stance
  -- bar is blocked in combat) until the UI reloads, so setup asks for a reload
  -- when it changed the layout or action bar 2's setting. Keybinds alone don't.
  local function finish()
    if layoutActions > 0 or has(actions, "bar2On") then
      ns.SetupWindow.showReload("Set up")
    else
      ns.print("Set up.")
    end
  end
  if creating or has(actions, "bar2Place") then
    -- action bar 2 is measured after the game has laid out the first save
    C_Timer.After(0, function()
      ns.combatQueue:run("setup-place", function()
        place(ids, creating)
        finish()
      end)
    end)
  else
    finish()
  end
end

-- /wasd setup and the Run setup button.
function Setup.open()
  if refuseInCombat("set up") or ns.SetupWindow.isShown() then
    return
  end
  if EditModeManagerFrame:IsEditModeActive() then
    ns.print("Close Edit Mode, then run /wasd setup.")
    return
  end
  local p, why = plan()
  if not p then
    ns.print(why)
    return
  end
  local steps, lost = ns.Bindings.steps()
  if #p.actions == 0 and #steps == 0 then
    ns.print("Everything is set up.")
    return
  end
  ns.SetupWindow.show(p.actions, steps, lost, function()
    apply(p, steps)
  end)
end

-- The layout half of /wasd setup status.
function Setup.layoutStatusSentence()
  local p, why = plan()
  if not p then
    return why
  end
  return ns.LayoutPlan.statusSentence(p.readings, p.actions)
end

StaticPopupDialogs[OFFER] = {
  text = "Set up WASDBars?\n\nIt moves action bar 1's buttons into the WASD shape, "
    .. "makes a WASDBars Edit Mode layout and binds your keys. "
    .. "You'll see every change before anything happens.",
  button1 = "Set up",
  button2 = "Not now",
  OnAccept = function()
    C_Timer.After(0, Setup.open)
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}

-- Offered once per character, when its keys or its layout aren't set up.
-- Otherwise, a character not on the WASDBars layout gets a one-line reminder
-- at every login. Layouts arrive after login, so this waits for the first
-- layout update.
local offerChecked = false
ns.Events.on("EDIT_MODE_LAYOUTS_UPDATED", function()
  if offerChecked then
    return
  end
  offerChecked = true
  C_Timer.After(0, function()
    -- the realm name isn't ready yet at PLAYER_LOGIN; the GUID is
    local guid = UnitGUID("player")
    local p = plan()
    if ns.db.setupOffered[guid] or not p or (#p.actions == 0 and ns.Bindings.isSetUp()) then
      if p and p.readings.step then
        ns.print("Not set up on this character. Type /wasd setup to set it up.")
      end
      return
    end
    ns.combatQueue:run("setup-offer", function()
      ns.db.setupOffered[guid] = true
      StaticPopup_Show(OFFER)
    end)
  end)
end)

-- Restore always switches the layout, so it asks for a reload like setup.
local function finishRestore()
  ns.print(
    "Restored. You can delete the WASDBars layout in Edit Mode whenever you like. "
      .. "Type /wasd setup to set it up again."
  )
  ns.SetupWindow.showReload("Restored")
end

StaticPopupDialogs[RESTORE_KEYS] = {
  text = "Restore your keybinds too?\n\nPuts the keys around WASD and the number row back to what they were "
    .. "before WASDBars set them up.",
  button1 = "Yes",
  button2 = "No",
  OnAccept = function()
    if refuseInCombat("restore keybinds") then
      return
    end
    local owner = keyCopyOwner()
    for _, change in ipairs(ns.Restore.keyChanges(ns.db.keyCopies[owner])) do
      if change.command then
        SetBinding(change.key, change.command)
      else
        SetBinding(change.key)
      end
    end
    SaveBindings(GetCurrentBindingSet())
    ns.db.keyCopies[owner] = nil
    finishRestore()
  end,
  OnCancel = finishRestore,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}

StaticPopupDialogs[RESTORE] = {
  text = "Restore WASDBars changes?\n\n%s",
  button1 = "Restore",
  button2 = "Cancel",
  OnAccept = function(_, data)
    if refuseInCombat("restore") then
      return
    end
    if EditModeManagerFrame:IsEditModeActive() then
      ns.print("Close Edit Mode, then run /wasd restore.")
      return
    end
    LEMO:LoadLayouts()
    LEMO:SetActiveLayout(data.layout)
    LEMO:ApplyChanges()
    Settings.SetValue("PROXY_SHOW_ACTIONBAR_2", data.bar2)
    local guid = UnitGUID("player")
    ns.db.restore[guid] = nil
    if ns.db.keyCopies[keyCopyOwner()] then
      StaticPopup_Show(RESTORE_KEYS)
    else
      finishRestore()
    end
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}

-- /wasd restore and the Restore button.
function Setup.restore()
  if refuseInCombat("restore") then
    return
  end
  local saved = ns.db.restore[UnitGUID("player")]
  if not saved then
    ns.print("Nothing to restore on this character.")
    return
  end
  if EditModeManagerFrame:IsEditModeActive() then
    ns.print("Close Edit Mode, then run /wasd restore.")
    return
  end
  if not ready() then
    ns.print("Edit Mode isn't ready yet. Try again in a moment.")
    return
  end
  local target, missing = ns.Restore.target(loadData(), saved.layout, Enum.EditModeLayoutType.Preset)
  local lines = ns.Restore.lines(target, missing, saved.layout, saved.bar2)
  StaticPopup_Show(RESTORE, table.concat(lines, "\n"), nil, { layout = target, bar2 = saved.bar2 })
end
