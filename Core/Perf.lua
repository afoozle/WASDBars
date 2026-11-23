local ADDON, ns = ...
local Perf = {}
ns.Perf = Perf

-- Saves the game's built-in addon profiler numbers once a second while the
-- player records, for Claude Code to read from WASDBarsPerfDB after /reload.
-- Nothing runs until a recording starts.
local ticker, session, started

local function addonMetrics()
  return ns.PerfLog.readMetrics(Enum.AddOnProfilerMetric, function(metric)
    return C_AddOnProfiler.GetAddOnMetric(ADDON, metric)
  end)
end

local function overallMetrics()
  return ns.PerfLog.readMetrics(Enum.AddOnProfilerMetric, function(metric)
    return C_AddOnProfiler.GetOverallMetric(metric)
  end)
end

local function sample()
  ns.PerfLog.addSample(session, {
    t = math.floor(GetTime() - started + 0.5),
    wasdbars = addonMetrics(),
    allRecentAverage = C_AddOnProfiler.GetOverallMetric(Enum.AddOnProfilerMetric.RecentAverageTime),
    fps = math.floor(GetFramerate() + 0.5),
    combat = InCombatLockdown(),
    form = GetShapeshiftForm(),
    target = UnitExists("target"),
  })
end

function Perf.start(label)
  if ticker then
    ns.print("Already recording '" .. session.label .. "'. Use /wasd perf stop first.")
    return
  end
  label = (label and label ~= "") and label or "unnamed"
  started = GetTime()
  session = {
    label = label,
    started = date("%Y-%m-%d %H:%M"),
    addonVersion = ns.addonVersion(),
    interface = select(4, GetBuildInfo()),
    samples = {},
  }
  ticker = C_Timer.NewTicker(1, sample)
  ns.print("Recording '" .. label .. "'. Use /wasd perf stop when done.")
end

function Perf.stop()
  if not ticker then
    ns.print("Not recording.")
    return
  end
  ticker:Cancel()
  ticker = nil
  session.seconds = math.floor(GetTime() - started + 0.5)
  session.summary = { wasdbars = addonMetrics(), allAddons = overallMetrics() }
  ns.PerfLog.addSession(WASDBarsPerfDB, session)
  ns.print("Recording '" .. session.label .. "' saved. Type /reload to write it to disk.")
  session = nil
end

function Perf.clear()
  WASDBarsPerfDB.sessions = {}
  ns.print("Recordings cleared.")
end

ns.Events.on("ADDON_LOADED", function(name)
  if name == ADDON then
    WASDBarsPerfDB = WASDBarsPerfDB or {}
    WASDBarsPerfDB.sessions = WASDBarsPerfDB.sessions or {}
  end
end)
