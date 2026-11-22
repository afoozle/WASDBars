# Proposal: Polish the look and the messages

Draft: notes collected during earlier changes. Grill this at the start of work on it.

## Why
The addon works, but several things look rough or read badly in game. This change makes them feel finished.

## Notes to address
- **Key spacing** (from `add-wasd-layout`): the gap between full-size and smaller (0.8 / 0.6) keys is too wide; the gap is measured as if every key were full size.
- **Key labels** (from `add-position-and-scale`): the W/A/S/D letters and the buttons' hotkey text aren't obvious enough; larger and/or heavier outline.
- **Messages are rubbish** (from `add-edit-mode-setup`, the player's words: "still super shit", "make this non rubbish"). Seen in game:
  - The binding popups are a centred wall of "key: old bind" lines ("Q: Turn Left", "3: Action bar 1 button 3", ...) that is hard to scan. Consider a proper frame with aligned columns (key, what it does now, what it will do) instead of a StaticPopup.
  - Form binds on non-druids show "Form 1" / "Form 3" (the rogue's stealth); the form name lookup (`GetShapeshiftFormInfo` → spell name) found nothing there.
  - Chat output is inconsistent and repetitive: "WASD keys: set up" vs "WASD keys: already set up." vs "action bar layout is set up." (lower case, full stop on some lines only); running setup prints three separate "already set up" lines; status and setup say the same thing differently.
- **Edit Mode layout check:** only seen reporting "OK"; check the problem lines read well when something is actually off.

## Depends on
`add-edit-mode-setup`
