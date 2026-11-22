local ADDON, ns = ...
local CombatQueue = {}
ns.CombatQueue = CombatQueue

-- isLocked: function returning true while in combat (InCombatLockdown in game)
-- notify: called once per combat when the first job is deferred
function CombatQueue.new(isLocked, notify)
  local q = { order = {}, jobs = {}, notified = false }

  -- key: a name for the job, e.g. "scale". A newer job with the same key
  -- replaces the waiting one, so dragging a slider in combat applies once.
  function q:run(key, fn)
    if not isLocked() then
      fn()
      return true
    end
    if not self.jobs[key] then
      table.insert(self.order, key)
    end
    self.jobs[key] = fn
    if not self.notified then
      notify()
      self.notified = true
    end
    return false
  end

  function q:flush()
    local order, jobs = self.order, self.jobs
    self.order, self.jobs, self.notified = {}, {}, false
    for _, key in ipairs(order) do
      jobs[key]()
    end
  end

  return q
end
