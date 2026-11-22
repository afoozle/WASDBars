# Proposal: Polish the look and the messages

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

## What Changes
- **One keybind window** (a standard game panel with title bar and close button, left-aligned text) replaces the two chained popups. It lists the steps still needed, "1. Action bar 1 on the keys around WASD" and "2. Action bar 2 on the number row", each with one line of detail; then "These will no longer have a key:" with only the actions left with no key at all (for example "Chat Reply (R)"); then Confirm / Cancel. Steps already done are left out; if both are done, chat says "Keybinds are already set up."
- Form binds show the form's name (or "Stance bar button n" on a class without that form), never "Form n".
- **Chat style:** "WASDBars: " plus one capitalised sentence ending in a full stop; one line per action ("Keybinds set up.", "Your Edit Mode layout is ready.", "Your Edit Mode layout needs 2 changes:" with "  - ..." lines). `/wasd setup status` is one line: "Keybinds set up (WASD keys and number row). Edit Mode layout ready."
- **Key sizes:** two sizes, big 1.0 and small 0.8; W/A/S/D move from 0.6 to 0.8.
- **Spacing:** every key takes the same square cell, small keys centred in theirs; the gap between cells shrinks from 4 to 2 pixels; rows keep a real keyboard's offsets so E, D and C run on a slant.
- **W/A/S/D:** fully opaque (no 60% fade), no letters, bigger arrows.
- **Hotkey text** on the 12 cluster buttons: the game's own text, larger (18) with a thick outline, at bottom centre, with mouse buttons shortened to M4/M5. The game still sets the text, its range colour and when it shows.

## Decided when grilled (2026-11-22)
- The window describes what the setup does, not each key's new action ("Cluster Q" said nothing); warnings are what matters.
- A standard panel (title bar, close button) over a popup look-alike, made to look tidy.
- Two sizes only (the player's own pick over growing W/A/S/D alone). Packing rows was tried first and dropped after the in-game look: equal cells, the real keyboard slant and a smaller gap instead; W/A/S/D letters dropped in favour of bigger arrows.
- Hotkey text bottom centre rather than centred, so it doesn't cover the icon or the cooldown numbers; to be judged in game.

## Depends on
`add-edit-mode-setup`
