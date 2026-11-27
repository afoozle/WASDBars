local ADDON, ns = ...
local KeybindCopies = {}
ns.KeybindCopies = KeybindCopies

-- The setup keys' actions from before setup first changed them, one copy per
-- binding set, in the saved table it's given: copy owner -> { [key] = action | false }.

-- "account" while the character is on the account's keybinds (shared by every
-- such character), otherwise its own GUID.
-- bindingSet: the game's GetCurrentBindingSet(); characterBindingSet: CHARACTER_BINDINGS.
function KeybindCopies.findCopyOwner(bindingSet, characterBindingSet, playerGuid)
  if bindingSet == characterBindingSet then
    return playerGuid
  end
  return "account"
end

-- Only the first copy is kept: later setups must not overwrite the keys from before WASDBars.
function KeybindCopies.saveKeybindCopyOnce(savedCopies, copyOwner, keybindCopy)
  savedCopies[copyOwner] = savedCopies[copyOwner] or keybindCopy
end

function KeybindCopies.findKeybindCopy(savedCopies, copyOwner)
  return savedCopies[copyOwner]
end

function KeybindCopies.forgetKeybindCopy(savedCopies, copyOwner)
  savedCopies[copyOwner] = nil
end
