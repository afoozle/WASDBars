local load_addon_file = require("helpers.load_addon_file")

describe("ClusterGeometry.measureClusterKeys", function()
  local ns, measuredCluster
  local BUTTON_SIZE = 45

  local function findMeasuredKey(label)
    for _, measuredKey in ipairs(measuredCluster.measuredKeys) do
      if measuredKey.clusterKey.label == label then
        return measuredKey
      end
    end
  end

  before_each(function()
    ns = {}
    load_addon_file("ActionBarCluster/ClusterKeys.lua", ns)
    load_addon_file("ActionBarCluster/ClusterGeometry.lua", ns)
    measuredCluster = ns.ClusterGeometry.measureClusterKeys(ns.ClusterKeys, BUTTON_SIZE)
  end)

  it("centres keys on their grid points", function()
    local clusterKeys = {
      keySizes = { big = 1, small = 0.5 },
      keys = {
        { label = "a", column = 0, row = 0, size = "big" },
        { label = "b", column = 2, row = 1, size = "small" },
      },
    }
    local measured = ns.ClusterGeometry.measureClusterKeys(clusterKeys, 40)
    assert.same({ 20, 20 }, { measured.measuredKeys[1].centreX, measured.measuredKeys[1].centreY })
    assert.same({ 2 * 40 + 20, 40 + 20 }, { measured.measuredKeys[2].centreX, measured.measuredKeys[2].centreY })
  end)

  it("gives a small key a full-size cell", function()
    local measured = ns.ClusterGeometry.measureClusterKeys({
      keySizes = { small = 0.5 },
      keys = { { label = "a", column = 0.5, row = 1, size = "small" } },
    }, 40)
    local measuredKey = measured.measuredKeys[1]
    assert.same({ 20, 20, 40, 40 }, { measuredKey.centreX, measuredKey.centreY, measured.width, measured.height })
  end)

  it("spaces neighbours one step apart whatever their size", function()
    local step = BUTTON_SIZE
    assert.equal(step, findMeasuredKey("W").centreX - findMeasuredKey("Q").centreX)
    assert.equal(step, findMeasuredKey("T").centreX - findMeasuredKey("R").centreX)
  end)

  it("offsets the rows like a keyboard, so E, D and C run on a slant", function()
    local step = BUTTON_SIZE
    assert.equal(step / 4, findMeasuredKey("A").centreX - findMeasuredKey("Q").centreX)
    assert.equal(step / 2, findMeasuredKey("Z").centreX - findMeasuredKey("A").centreX)
    assert.equal(step / 4, findMeasuredKey("D").centreX - findMeasuredKey("E").centreX)
    assert.equal(step / 2, findMeasuredKey("C").centreX - findMeasuredKey("D").centreX)
    assert.equal(findMeasuredKey("Q").centreY, findMeasuredKey("W").centreY)
    assert.equal(step, findMeasuredKey("A").centreY - findMeasuredKey("Q").centreY)
  end)

  it("covers every key's cell with the cluster box", function()
    for _, measuredKey in ipairs(measuredCluster.measuredKeys) do
      local label = measuredKey.clusterKey.label
      local halfButton = BUTTON_SIZE / 2
      assert.is_true(
        measuredKey.centreX - halfButton >= 0 and measuredKey.centreX + halfButton <= measuredCluster.width,
        label
      )
      assert.is_true(
        measuredKey.centreY - halfButton >= 0 and measuredKey.centreY + halfButton <= measuredCluster.height,
        label
      )
    end
  end)

  it("puts button 11 above button 12, right of the keyboard keys and centred on the rows", function()
    local front, back = findMeasuredKey("Mouse front"), findMeasuredKey("Mouse back")
    assert.equal(front.centreX, back.centreX)
    assert.is_true(front.centreY < back.centreY)
    assert.equal(findMeasuredKey("S").centreY, (front.centreY + back.centreY) / 2)
    for _, label in ipairs({ "T", "G", "V" }) do
      assert.is_true(front.centreX > findMeasuredKey(label).centreX, label)
    end
  end)
end)
