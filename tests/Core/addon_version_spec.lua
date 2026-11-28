local load_addon_file = require("helpers.load_addon_file")

describe("AddonVersion.readReleaseVersion", function()
  local readReleaseVersion

  before_each(function()
    readReleaseVersion = load_addon_file("Core/AddonVersion.lua").AddonVersion.readReleaseVersion
  end)

  it("drops the tag's v", function()
    assert.equal("1.1.1", readReleaseVersion("v1.1.1"))
    assert.equal("1.1.1", readReleaseVersion("1.1.1"))
  end)

  it("is nil for a dev build", function()
    assert.is_nil(readReleaseVersion("@project-version@"))
    assert.is_nil(readReleaseVersion(nil))
  end)
end)
