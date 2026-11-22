local load_addon_file = require("helpers.load_addon_file")
local stubs = require("helpers.wow_stubs")

describe("CombatQueue", function()
  local combat, notify, queue, ran

  local function job(name)
    return function()
      table.insert(ran, name)
    end
  end

  before_each(function()
    local CombatQueue = load_addon_file("Logic/CombatQueue.lua").CombatQueue
    combat = stubs.combat(false)
    notify = stubs.recorder()
    queue = CombatQueue.new(combat.fn, notify.fn)
    ran = {}
  end)

  it("runs immediately out of combat without a message", function()
    assert.is_true(queue:run("a", job("a")))
    assert.same({ "a" }, ran)
    assert.equal(0, #notify.calls)
  end)

  it("defers work in combat", function()
    combat:set(true)
    assert.is_false(queue:run("a", job("a")))
    assert.same({}, ran)
  end)

  it("notifies once per combat", function()
    combat:set(true)
    queue:run("a", job("a"))
    queue:run("b", job("b"))
    queue:run("c", job("c"))
    assert.equal(1, #notify.calls)
  end)

  it("replaces a waiting job with a newer one of the same key, keeping its place", function()
    combat:set(true)
    queue:run("scale", job("scale 1.2"))
    queue:run("other", job("other"))
    queue:run("scale", job("scale 1.3"))
    combat:set(false)
    queue:flush()
    assert.same({ "scale 1.3", "other" }, ran)
  end)

  it("flushes in order and empties the queue", function()
    combat:set(true)
    queue:run("a", job("a"))
    queue:run("b", job("b"))
    queue:run("c", job("c"))
    combat:set(false)
    queue:flush()
    assert.same({ "a", "b", "c" }, ran)
    queue:flush()
    assert.same({ "a", "b", "c" }, ran)
  end)

  it("notifies again in a second combat", function()
    combat:set(true)
    queue:run("a", job("a"))
    combat:set(false)
    queue:flush()
    combat:set(true)
    queue:run("b", job("b"))
    assert.equal(2, #notify.calls)
  end)
end)
