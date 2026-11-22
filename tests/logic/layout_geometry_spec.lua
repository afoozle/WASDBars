local load_addon_file = require("helpers.load_addon_file")

describe("LayoutGeometry.compute", function()
  local ns, geometry
  local BASE = 45

  local function find(label)
    for _, k in ipairs(geometry.keys) do
      if k.key.label == label then
        return k
      end
    end
  end

  before_each(function()
    ns = {}
    load_addon_file("Data/Layout.lua", ns)
    load_addon_file("Logic/LayoutGeometry.lua", ns)
    geometry = ns.LayoutGeometry.compute(ns.Layout, BASE)
  end)

  it("centres keys on their grid points", function()
    local layout = {
      sizes = { primary = 1 },
      gap = 5,
      keys = {
        { label = "a", button = 1, x = 0, y = 0, size = "primary" },
        { label = "b", button = 2, x = 2, y = 1, size = "primary" },
      },
    }
    local g = ns.LayoutGeometry.compute(layout, 40)
    assert.same({ 20, 20 }, { g.keys[1].cx, g.keys[1].cy })
    assert.same({ 2 * 45 + 20, 45 + 20 }, { g.keys[2].cx, g.keys[2].cy })
  end)

  it("starts the cluster at the leftmost and topmost key", function()
    local layout = {
      sizes = { primary = 1 },
      gap = 0,
      keys = { { label = "a", button = 1, x = 0.5, y = 1, size = "primary" } },
    }
    local g = ns.LayoutGeometry.compute(layout, 40)
    assert.same({ 20, 20, 40, 40 }, { g.keys[1].cx, g.keys[1].cy, g.width, g.height })
  end)

  it("scales keys by their size tier", function()
    assert.equal(1.0, find("Q").scale)
    assert.equal(0.8, find("T").scale)
    assert.equal(0.8, find("Mouse front").scale)
    assert.equal(0.6, find("W").scale)
  end)

  it("keeps the keyboard stagger", function()
    local step = BASE + ns.Layout.gap
    assert.equal(step / 4, find("A").cx - find("Q").cx)
    assert.equal(step / 2, find("Z").cx - find("A").cx)
    assert.equal(find("Q").cy, find("W").cy)
    assert.equal(step, find("A").cy - find("Q").cy)
  end)

  it("covers every key with the cluster box", function()
    for _, k in ipairs(geometry.keys) do
      assert.is_true(k.cx - BASE / 2 >= 0 and k.cx + BASE / 2 <= geometry.width, k.key.label)
      assert.is_true(k.cy - BASE / 2 >= 0 and k.cy + BASE / 2 <= geometry.height, k.key.label)
    end
  end)

  it("puts button 11 above button 12, right of the keyboard keys", function()
    local front, back = find("Mouse front"), find("Mouse back")
    assert.equal(front.cx, back.cx)
    assert.is_true(front.cy < back.cy)
    for _, label in ipairs({ "T", "G", "V" }) do
      assert.is_true(front.cx > find(label).cx, label)
    end
  end)
end)
