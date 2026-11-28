local load_addon_file = require("helpers.load_addon_file")

describe("ClusterKeys", function()
  local clusterKeys

  before_each(function()
    clusterKeys = load_addon_file("ActionBarCluster/ClusterKeys.lua").ClusterKeys
  end)

  it("uses action buttons 1-12 exactly once each", function()
    local seen = {}
    for _, clusterKey in ipairs(clusterKeys.keys) do
      local number = clusterKey.actionButtonNumber
      if number then
        assert.is_nil(seen[number], "button " .. number .. " used twice")
        seen[number] = true
      end
    end
    for number = 1, 12 do
      assert.is_true(seen[number], "button " .. number .. " missing")
    end
  end)

  it("gives every key a known size", function()
    for _, clusterKey in ipairs(clusterKeys.keys) do
      assert.is_number(clusterKeys.keySizes[clusterKey.size], clusterKey.label .. " has no size")
    end
  end)

  it("gives every movement key a direction", function()
    local directions = {}
    for _, clusterKey in ipairs(clusterKeys.keys) do
      if not clusterKey.actionButtonNumber then
        assert.is_truthy(clusterKey.movementDirection, clusterKey.label .. " is neither a button nor a movement key")
        directions[clusterKey.label] = clusterKey.movementDirection
      end
    end
    assert.same({ W = "up", A = "left", S = "down", D = "right" }, directions)
  end)
end)
