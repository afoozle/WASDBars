local load_addon_file = require("helpers.load_addon_file")

describe("PerfLog", function()
  local PerfLog

  before_each(function()
    PerfLog = load_addon_file("Logic/PerfLog.lua").PerfLog
  end)

  it("keeps the newest 600 rows of a session", function()
    local session = { samples = {} }
    for t = 1, 720 do
      PerfLog.addSample(session, { t = t })
    end
    assert.equal(600, #session.samples)
    assert.equal(121, session.samples[1].t)
    assert.equal(720, session.samples[600].t)
  end)

  it("keeps the newest 5 sessions", function()
    local db = {}
    for i = 1, 6 do
      PerfLog.addSession(db, { label = "s" .. i })
    end
    assert.equal(5, #db.sessions)
    assert.equal("s2", db.sessions[1].label)
    assert.equal("s6", db.sessions[5].label)
  end)

  it("reads every listed metric", function()
    local values = PerfLog.readMetrics({ RecentAverageTime = 1, PeakTime = 2 }, function(metric)
      return metric * 10
    end)
    assert.same({ RecentAverageTime = 10, PeakTime = 20 }, values)
  end)
end)
