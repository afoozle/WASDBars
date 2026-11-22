local load_addon_file = require("helpers.load_addon_file")

describe("Data/Layout", function()
  local layout

  before_each(function()
    layout = load_addon_file("Data/Layout.lua").Layout
  end)

  it("uses action buttons 1-12 exactly once each", function()
    local seen = {}
    for _, key in ipairs(layout.keys) do
      if key.button then
        assert.is_nil(seen[key.button], "button " .. key.button .. " used twice")
        seen[key.button] = true
      end
    end
    for n = 1, 12 do
      assert.is_true(seen[n], "button " .. n .. " missing")
    end
  end)

  it("gives every action button key a known size tier", function()
    for _, key in ipairs(layout.keys) do
      if key.button then
        assert.is_number(layout.sizes[key.size], key.label .. " has no size tier")
      end
    end
  end)

  it("gives every movement key a direction", function()
    local directions = {}
    for _, key in ipairs(layout.keys) do
      if not key.button then
        assert.is_truthy(key.movement, key.label .. " is neither a button nor a movement key")
        directions[key.label] = key.movement
      end
    end
    assert.same({ W = "up", A = "left", S = "down", D = "right" }, directions)
  end)

  it("puts buttons 1-10 on Q E R T F G Z X C V", function()
    local labels = {}
    for _, key in ipairs(layout.keys) do
      if key.button and key.button <= 10 then
        labels[key.button] = key.label
      end
    end
    assert.same({ "Q", "E", "R", "T", "F", "G", "Z", "X", "C", "V" }, labels)
  end)
end)
