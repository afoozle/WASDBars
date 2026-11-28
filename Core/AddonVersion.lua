local ADDON, ns = ...
local AddonVersion = {}
ns.AddonVersion = AddonVersion

-- The TOC's Version, e.g. "1.1.1", or nil for a dev build (the packager
-- hasn't replaced @project-version@).
function AddonVersion.readReleaseVersion(versionMetadata)
  if not versionMetadata or versionMetadata == "@project-version@" then
    return nil
  end
  return (versionMetadata:gsub("^v", ""))
end
