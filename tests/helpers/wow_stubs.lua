-- Fake versions of the WoW functions that Logic modules receive as arguments.
-- Never installed as globals: tests pass them in explicitly.
local stubs = {}

-- A controllable InCombatLockdown. stub.fn is what you pass in;
-- stub:set(true/false) enters or leaves combat.
function stubs.combat(inCombat)
  local s = { inCombat = inCombat or false }
  s.fn = function()
    return s.inCombat
  end
  function s:set(value)
    self.inCombat = value
  end
  return s
end

-- Records every call, e.g. as a notify or print function.
function stubs.recorder()
  local r = { calls = {} }
  r.fn = function(...)
    table.insert(r.calls, { ... })
  end
  return r
end

-- Table-backed keybinds: keys = { Q = "ACTIONBUTTON1", ... }.
function stubs.bindings(keys)
  local b = { keys = keys or {} }
  b.GetBindingAction = function(key)
    return b.keys[key] or ""
  end
  b.GetBindingKey = function(command)
    local found = {}
    for key, action in pairs(b.keys) do
      if action == command then
        table.insert(found, key)
      end
    end
    table.sort(found)
    return unpack(found)
  end
  b.SetBinding = function(key, command)
    b.keys[key] = command
    return true
  end
  return b
end

return stubs
