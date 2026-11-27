local ADDON, ns = ...

-- The WASD cluster. Columns and rows are in key units (one big key plus a
-- gap), offset like a real keyboard; each key is centred on its grid point.
-- `label` is drawn only on movement keys; on action buttons it is documentation.
ns.ClusterKeys = {
  keySizes = { big = 1.0, small = 0.8 },
  gap = 0, -- pixels between key cells
  -- default Edit Mode position (relative to the screen) and scale, for layouts where it hasn't been moved
  defaultPosition = { point = "BOTTOMLEFT", x = 200, y = 81 },
  defaultScale = 1.0,
  keys = {
    { label = "Q", actionButtonNumber = 1, column = 0.5, row = 0, size = "big" },
    { label = "W", movementDirection = "up", column = 1.5, row = 0, size = "small" },
    { label = "E", actionButtonNumber = 2, column = 2.5, row = 0, size = "big" },
    { label = "R", actionButtonNumber = 3, column = 3.5, row = 0, size = "big" },
    { label = "T", actionButtonNumber = 4, column = 4.5, row = 0, size = "small" },
    { label = "A", movementDirection = "left", column = 0.75, row = 1, size = "small" },
    { label = "S", movementDirection = "down", column = 1.75, row = 1, size = "small" },
    { label = "D", movementDirection = "right", column = 2.75, row = 1, size = "small" },
    { label = "F", actionButtonNumber = 5, column = 3.75, row = 1, size = "big" },
    { label = "G", actionButtonNumber = 6, column = 4.75, row = 1, size = "small" },
    { label = "Z", actionButtonNumber = 7, column = 1.25, row = 2, size = "big" },
    { label = "X", actionButtonNumber = 8, column = 2.25, row = 2, size = "big" },
    { label = "C", actionButtonNumber = 9, column = 3.25, row = 2, size = "big" },
    { label = "V", actionButtonNumber = 10, column = 4.25, row = 2, size = "small" },
    -- mouse side buttons: a column next to G, front above back, centred on the three rows
    { label = "Mouse front", actionButtonNumber = 11, column = 5.75, row = 0.5, size = "small" },
    { label = "Mouse back", actionButtonNumber = 12, column = 5.75, row = 1.5, size = "small" },
  },
}
