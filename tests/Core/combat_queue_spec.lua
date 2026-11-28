local load_addon_file = require("helpers.load_addon_file")

-- CombatQueue is a game file, but its job-replacing rule is the addon's main
-- combat safety net, so it is tested with the game's combat check stood in for.
describe("CombatQueue", function()
  local CombatQueue, isInCombat, printedMessages, ranJobs

  local function job(jobLabel)
    return function()
      table.insert(ranJobs, jobLabel)
    end
  end

  before_each(function()
    isInCombat = false
    printedMessages = {}
    ranJobs = {}
    _G.InCombatLockdown = function()
      return isInCombat
    end
    local ns = {
      ChatMessages = {
        printMessage = function(message)
          table.insert(printedMessages, message)
        end,
      },
    }
    CombatQueue = load_addon_file("Core/CombatQueue.lua", ns).CombatQueue
  end)

  after_each(function()
    _G.InCombatLockdown = nil
  end)

  it("runs immediately out of combat without a message", function()
    CombatQueue.runOutOfCombat("a", job("a"))
    assert.same({ "a" }, ranJobs)
    assert.same({}, printedMessages)
  end)

  it("waits in combat", function()
    isInCombat = true
    CombatQueue.runOutOfCombat("a", job("a"))
    assert.same({}, ranJobs)
  end)

  it("says it will apply after combat once per combat", function()
    isInCombat = true
    CombatQueue.runOutOfCombat("a", job("a"))
    CombatQueue.runOutOfCombat("b", job("b"))
    CombatQueue.runOutOfCombat("c", job("c"))
    assert.same({ "Will apply after combat." }, printedMessages)
  end)

  it("replaces a waiting job with a newer one of the same name, keeping its place", function()
    isInCombat = true
    CombatQueue.runOutOfCombat("scale", job("scale 1.2"))
    CombatQueue.runOutOfCombat("other", job("other"))
    CombatQueue.runOutOfCombat("scale", job("scale 1.3"))
    isInCombat = false
    CombatQueue.runWaitingJobs()
    assert.same({ "scale 1.3", "other" }, ranJobs)
  end)

  it("runs waiting jobs in order and empties the queue", function()
    isInCombat = true
    CombatQueue.runOutOfCombat("a", job("a"))
    CombatQueue.runOutOfCombat("b", job("b"))
    CombatQueue.runOutOfCombat("c", job("c"))
    isInCombat = false
    CombatQueue.runWaitingJobs()
    assert.same({ "a", "b", "c" }, ranJobs)
    CombatQueue.runWaitingJobs()
    assert.same({ "a", "b", "c" }, ranJobs)
  end)

  it("says it again in a second combat", function()
    isInCombat = true
    CombatQueue.runOutOfCombat("a", job("a"))
    isInCombat = false
    CombatQueue.runWaitingJobs()
    isInCombat = true
    CombatQueue.runOutOfCombat("b", job("b"))
    assert.equal(2, #printedMessages)
  end)
end)
