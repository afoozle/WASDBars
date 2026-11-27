local load_addon_file = require("helpers.load_addon_file")

describe("PerformanceLog", function()
  local PerformanceLog

  before_each(function()
    PerformanceLog = load_addon_file("Performance/PerformanceLog.lua").PerformanceLog
  end)

  it("keeps the newest 600 rows of a recording", function()
    local recording = { samples = {} }
    for t = 1, 720 do
      PerformanceLog.addRow(recording, { t = t })
    end
    assert.equal(600, #recording.samples)
    assert.equal(121, recording.samples[1].t)
    assert.equal(720, recording.samples[600].t)
  end)

  it("keeps the newest 5 recordings", function()
    local savedRecordings = { sessions = {} }
    for i = 1, 6 do
      PerformanceLog.addRecording(savedRecordings, { label = "s" .. i })
    end
    assert.equal(5, #savedRecordings.sessions)
    assert.equal("s2", savedRecordings.sessions[1].label)
    assert.equal("s6", savedRecordings.sessions[5].label)
  end)
end)
