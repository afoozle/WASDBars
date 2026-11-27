-- Loads an addon file the way the game does: as a chunk called with
-- the addon name and the shared namespace table as `...`.
-- Usage: local ns = {}; load_addon_file("Core/SavedSettings.lua", ns)
return function(path, ns)
  ns = ns or {}
  local chunk = assert(loadfile(path))
  chunk("WASDBars", ns)
  return ns
end
