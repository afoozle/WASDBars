local ADDON, ns = ...
local CombatQueue = {}
ns.CombatQueue = CombatQueue

-- Anything that moves the action buttons or changes keybinds runs through
-- here: now when out of combat, otherwise once combat ends.
local waitingJobNames = {}
local waitingJobs = {}
local hasSaidWillApply = false

-- jobName: a name for the job, e.g. "scale". A newer job with the same name
-- replaces the waiting one, so dragging a slider in combat applies once.
function CombatQueue.runOutOfCombat(jobName, job)
  if not InCombatLockdown() then
    job()
    return
  end
  if not waitingJobs[jobName] then
    table.insert(waitingJobNames, jobName)
  end
  waitingJobs[jobName] = job
  if not hasSaidWillApply then
    ns.ChatMessages.printMessage("Will apply after combat.")
    hasSaidWillApply = true
  end
end

-- When combat ends.
function CombatQueue.runWaitingJobs()
  local jobNames, jobs = waitingJobNames, waitingJobs
  waitingJobNames, waitingJobs, hasSaidWillApply = {}, {}, false
  for _, jobName in ipairs(jobNames) do
    jobs[jobName]()
  end
end
