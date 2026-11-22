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

  local function edges(k)
    local half = k.scale * BASE / 2
    return k.cx - half, k.cx + half
  end

  before_each(function()
    ns = {}
    load_addon_file("Data/Layout.lua", ns)
    load_addon_file("Logic/LayoutGeometry.lua", ns)
    geometry = ns.LayoutGeometry.compute(ns.Layout, BASE)
  end)

  local tiny = {
    sizes = { big = 1, small = 0.5 },
    gap = 5,
    keys = {
      { label = "a", x = 0, y = 0, size = "big" },
      { label = "b", x = 1, y = 0, size = "small" },
      { label = "c", x = 3, y = 0, size = "big" },
      { label = "d", x = 0, y = 1, size = "small" },
    },
  }

  it("packs neighbouring keys with the gap between them", function()
    local g = ns.LayoutGeometry.compute(tiny, 40)
    assert.equal((1 + 0.5) / 2 * 40 + 5, g.keys[2].cx - g.keys[1].cx)
  end)

  it("puts a key after a jump on its grid point", function()
    local g = ns.LayoutGeometry.compute(tiny, 40)
    assert.equal(3 * 45, g.keys[3].cx - g.keys[1].cx)
  end)

  it("keeps rows one grid step apart", function()
    local g = ns.LayoutGeometry.compute(tiny, 40)
    assert.equal(45, g.keys[4].cy - g.keys[1].cy)
  end)

  it("fits the cluster box tightly around the keys", function()
    local g = ns.LayoutGeometry.compute({
      sizes = { small = 0.5 },
      gap = 0,
      keys = { { label = "a", x = 0.5, y = 1, size = "small" } },
    }, 40)
    assert.same({ 10, 10, 20, 20 }, { g.keys[1].cx, g.keys[1].cy, g.width, g.height })
  end)

  it("uses two sizes: big and small", function()
    assert.equal(1.0, find("Q").scale)
    assert.equal(0.8, find("T").scale)
    assert.equal(0.8, find("W").scale)
    assert.equal(0.8, find("Mouse front").scale)
  end)

  it("leaves the same gap between every pair of neighbours in a row", function()
    local row = { "Q", "W", "E", "R", "T" }
    for i = 2, #row do
      local _, right = edges(find(row[i - 1]))
      local left = edges(find(row[i]))
      assert.is_true(math.abs(left - right - ns.Layout.gap) < 1e-9, row[i - 1] .. "-" .. row[i])
    end
  end)

  it("keeps the keyboard stagger at the start of each row", function()
    local step = BASE + ns.Layout.gap
    assert.equal(step / 4, find("A").cx - find("Q").cx)
    assert.equal(step / 2, find("Z").cx - find("A").cx)
    assert.equal(find("Q").cy, find("W").cy)
    assert.equal(step, find("A").cy - find("Q").cy)
  end)

  it("covers every key with the cluster box", function()
    for _, k in ipairs(geometry.keys) do
      local left, right = edges(k)
      local half = k.scale * BASE / 2
      assert.is_true(left >= -1e-9 and right <= geometry.width + 1e-9, k.key.label)
      assert.is_true(k.cy - half >= -1e-9 and k.cy + half <= geometry.height + 1e-9, k.key.label)
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
