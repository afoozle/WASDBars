local ADDON, ns = ...
local PerfLog = {}
ns.PerfLog = PerfLog

PerfLog.MAX_SAMPLES = 600 -- 10 minutes at one row a second
PerfLog.MAX_SESSIONS = 5

-- Adds a row, dropping the oldest once the session holds MAX_SAMPLES.
function PerfLog.addSample(session, row)
  table.insert(session.samples, row)
  while #session.samples > PerfLog.MAX_SAMPLES do
    table.remove(session.samples, 1)
  end
end

-- Adds a finished session, dropping the oldest once there are MAX_SESSIONS.
function PerfLog.addSession(db, session)
  db.sessions = db.sessions or {}
  table.insert(db.sessions, session)
  while #db.sessions > PerfLog.MAX_SESSIONS do
    table.remove(db.sessions, 1)
  end
end

-- Every metric the profiler lists, read for one addon (or all addons when
-- read is GetOverallMetric). metrics: name -> enum value.
function PerfLog.readMetrics(metrics, read)
  local values = {}
  for name, value in pairs(metrics) do
    values[name] = read(value)
  end
  return values
end
