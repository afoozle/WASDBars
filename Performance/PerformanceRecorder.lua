local ADDON, ns = ...
local AddonVersion = ns.AddonVersion
local PerformanceLog = ns.PerformanceLog
local PerformanceRecorder = {}
ns.PerformanceRecorder = PerformanceRecorder

-- Saves the game's built-in addon profiler numbers once a second while the
-- player records, for Claude Code to read from WASDBarsPerfDB after /reload.
-- Nothing runs until a recording starts.
local ticker, recording, startTime

-- Every metric the profiler lists, by name.
local function readAddonMetrics()
  local metricValues = {}
  for metricName, metric in pairs(Enum.AddOnProfilerMetric) do
    metricValues[metricName] = C_AddOnProfiler.GetAddOnMetric(ADDON, metric)
  end
  return metricValues
end

local function readOverallMetrics()
  local metricValues = {}
  for metricName, metric in pairs(Enum.AddOnProfilerMetric) do
    metricValues[metricName] = C_AddOnProfiler.GetOverallMetric(metric)
  end
  return metricValues
end

local function measureSecondsRecorded()
  return math.floor(GetTime() - startTime + 0.5)
end

local function recordOneSecond()
  PerformanceLog.addRow(recording, {
    t = measureSecondsRecorded(),
    wasdbars = readAddonMetrics(),
    allRecentAverage = C_AddOnProfiler.GetOverallMetric(Enum.AddOnProfilerMetric.RecentAverageTime),
    fps = math.floor(GetFramerate() + 0.5),
    combat = InCombatLockdown(),
    form = GetShapeshiftForm(),
    target = UnitExists("target"),
  })
end

function PerformanceRecorder.startRecording(label)
  if ticker then
    ns.ChatMessages.printMessage("Already recording '" .. recording.label .. "'. Use /wasd perf stop first.")
    return
  end
  label = (label and label ~= "") and label or "unnamed"
  startTime = GetTime()
  recording = {
    label = label,
    started = date("%Y-%m-%d %H:%M"),
    addonVersion = AddonVersion.readReleaseVersion(C_AddOns.GetAddOnMetadata(ADDON, "Version")),
    interface = select(4, GetBuildInfo()),
    samples = {},
  }
  ticker = C_Timer.NewTicker(1, recordOneSecond)
  ns.ChatMessages.printMessage("Recording '" .. label .. "'. Use /wasd perf stop when done.")
end

function PerformanceRecorder.stopRecording()
  if not ticker then
    ns.ChatMessages.printMessage("Not recording.")
    return
  end
  ticker:Cancel()
  ticker = nil
  recording.seconds = measureSecondsRecorded()
  recording.summary = { wasdbars = readAddonMetrics(), allAddons = readOverallMetrics() }
  PerformanceLog.addRecording(WASDBarsPerfDB, recording)
  ns.ChatMessages.printMessage("Recording '" .. recording.label .. "' saved. Type /reload to write it to disk.")
  recording = nil
end

function PerformanceRecorder.clearRecordings()
  WASDBarsPerfDB.sessions = {}
  ns.ChatMessages.printMessage("Recordings cleared.")
end
