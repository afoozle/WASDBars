local ADDON, ns = ...
local PerformanceLog = {}
ns.PerformanceLog = PerformanceLog

-- Recordings as Claude Code reads them from WASDBarsPerfDB: { sessions = {
-- { label, …, samples = { one row a second } } } }. The saved names stay as
-- they are, so older recordings still read the same.

PerformanceLog.MAX_ROWS = 600 -- 10 minutes at one row a second
PerformanceLog.MAX_RECORDINGS = 5

-- Adds a row, dropping the oldest once the recording holds MAX_ROWS.
function PerformanceLog.addRow(recording, row)
  table.insert(recording.samples, row)
  while #recording.samples > PerformanceLog.MAX_ROWS do
    table.remove(recording.samples, 1)
  end
end

-- Adds a finished recording, dropping the oldest once there are MAX_RECORDINGS.
function PerformanceLog.addRecording(savedRecordings, recording)
  savedRecordings.sessions = savedRecordings.sessions or {}
  table.insert(savedRecordings.sessions, recording)
  while #savedRecordings.sessions > PerformanceLog.MAX_RECORDINGS do
    table.remove(savedRecordings.sessions, 1)
  end
end

-- Every metric the profiler lists: metricNames is name -> enum value, and
-- readMetric the profiler call for one addon or all of them.
function PerformanceLog.readAllMetrics(metricNames, readMetric)
  local metricValues = {}
  for metricName, metric in pairs(metricNames) do
    metricValues[metricName] = readMetric(metric)
  end
  return metricValues
end
