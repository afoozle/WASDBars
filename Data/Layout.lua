local ADDON, ns = ...

-- The WASD cluster. Positions are in key units (one primary key plus a gap);
-- each key is centred on its grid point. `button` is the action button number.
-- `label` is drawn only on movement keys; on action buttons it is documentation.
ns.Layout = {
  sizes = { primary = 1.0, secondary = 0.8, movement = 0.6 },
  gap = 4, -- pixels between primary keys
  -- default Edit Mode position (relative to the screen) and scale, for layouts where it hasn't been moved
  position = { point = "BOTTOM", x = -250, y = 150 },
  scale = 1.0,
  keys = {
    { label = "Q", button = 1, x = 0.5, y = 0, size = "primary" },
    { label = "W", movement = "up", x = 1.5, y = 0 },
    { label = "E", button = 2, x = 2.5, y = 0, size = "primary" },
    { label = "R", button = 3, x = 3.5, y = 0, size = "primary" },
    { label = "T", button = 4, x = 4.5, y = 0, size = "secondary" },
    { label = "A", movement = "left", x = 0.75, y = 1 },
    { label = "S", movement = "down", x = 1.75, y = 1 },
    { label = "D", movement = "right", x = 2.75, y = 1 },
    { label = "F", button = 5, x = 3.75, y = 1, size = "primary" },
    { label = "G", button = 6, x = 4.75, y = 1, size = "secondary" },
    { label = "Z", button = 7, x = 1.25, y = 2, size = "primary" },
    { label = "X", button = 8, x = 2.25, y = 2, size = "primary" },
    { label = "C", button = 9, x = 3.25, y = 2, size = "primary" },
    { label = "V", button = 10, x = 4.25, y = 2, size = "secondary" },
    -- mouse side buttons: a column right of the shape, half a key further out, front above back
    { label = "Mouse front", button = 11, x = 6.25, y = 0, size = "secondary" },
    { label = "Mouse back", button = 12, x = 6.25, y = 1, size = "secondary" },
  },
}
