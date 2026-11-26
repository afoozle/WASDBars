local ADDON, ns = ...

-- The WASD cluster. Positions are in key units (one big key plus a gap), with
-- rows offset like a real keyboard; each key is centred on its grid point.
-- `button` is the action button number.
-- `label` is drawn only on movement keys; on action buttons it is documentation.
ns.Layout = {
  sizes = { big = 1.0, small = 0.8 },
  gap = 0, -- pixels between key cells
  -- default Edit Mode position (relative to the screen) and scale, for layouts where it hasn't been moved
  position = { point = "BOTTOMLEFT", x = 200, y = 81 },
  scale = 1.0,
  keys = {
    { label = "Q", button = 1, x = 0.5, y = 0, size = "big" },
    { label = "W", movement = "up", x = 1.5, y = 0, size = "small" },
    { label = "E", button = 2, x = 2.5, y = 0, size = "big" },
    { label = "R", button = 3, x = 3.5, y = 0, size = "big" },
    { label = "T", button = 4, x = 4.5, y = 0, size = "small" },
    { label = "A", movement = "left", x = 0.75, y = 1, size = "small" },
    { label = "S", movement = "down", x = 1.75, y = 1, size = "small" },
    { label = "D", movement = "right", x = 2.75, y = 1, size = "small" },
    { label = "F", button = 5, x = 3.75, y = 1, size = "big" },
    { label = "G", button = 6, x = 4.75, y = 1, size = "small" },
    { label = "Z", button = 7, x = 1.25, y = 2, size = "big" },
    { label = "X", button = 8, x = 2.25, y = 2, size = "big" },
    { label = "C", button = 9, x = 3.25, y = 2, size = "big" },
    { label = "V", button = 10, x = 4.25, y = 2, size = "small" },
    -- mouse side buttons: a column next to G, front above back, centred on the three rows
    { label = "Mouse front", button = 11, x = 5.75, y = 0.5, size = "small" },
    { label = "Mouse back", button = 12, x = 5.75, y = 1.5, size = "small" },
  },
}
