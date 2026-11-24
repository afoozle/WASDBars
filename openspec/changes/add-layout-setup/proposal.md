# Proposal: Layout setup

## Why
First-time setup still leaves the player doing Edit Mode by hand: turn on action bar 2, set four action bar 1 settings, drag action bar 2 onto action bar 1's spot and find somewhere for action bar 1's empty box. It's a one-off, but too rough for a CurseForge addon. This change makes setup do all of it after one confirmation, inside a layout of its own, and adds a way to undo it.

## What Changes
- **A "WASDBars" Edit Mode layout** (account-wide). The first setup creates it as a copy of the layout the player is on and switches to it; later characters and later runs switch to it. WASDBars never changes any other layout, so rolling back is switching layouts.
- **Inside "WASDBars":** action bar 1 gets 12 icons, Always Show Buttons, Hide Bar Art and Hide Bar Scrolling; action bar 2 gets 12 icons and action bar 1's orientation, rows, icon size and padding, and sits exactly on action bar 1; both gryphons (end caps) are hidden; when the layout is created, the WASD cluster goes to the bottom left and the chat window moves up above it.
- **Action bar 1 stops catching the mouse** on characters that are set up, so action bar 2 on top of it works and can be grabbed in Edit Mode.
- **Action bar 2 is turned on** for the character.
- **One setup window** lists the layout actions and the keybinds together; one Set up applies everything, one Not now changes nothing. Keybinds are no longer a separate first step.
- **First-time offer** once per character when its keys or its layout aren't set up.
- **`/wasd restore`** and a Restore button: back to the previous layout and action bar 2 state, then a second question for the keybinds. "WASDBars" is kept.
- **New dependency:** LibEditModeOverride (CurseForge), next to LibEditMode; both declared in the TOC and `.pkgmeta`.
- The read-only layout checklist and the bar overlap check go.

## Decided when grilled (2026-11-23 and 24)
- **Approach:** write the layout with LibEditModeOverride (prior art: SpartanUI's setup wizard, DragonflightUI, GW2_UI, p3lim's UI) rather than better instructions or an import string. Hiding action bar 1 the Bartender4 way (`hide-main-bar`) is an optional extra; see design.md section 9 for why it's not needed now.
- **Keep the current takeover:** the buttons stay in the cluster, and LibEditMode still places it. Making action bar 1 itself the cluster fails because the game lays action bar 1 out again in combat (the spike counted thousands of calls).
- **Own layout only**, copied from the player's current one with our own copy step (LibEditModeOverride's `AddLayout` only copies Modern). The upstream patch is the optional `upstream-layout-copy`.
- **Action bar 1 stays put** and stops catching the mouse, instead of moving it away. On WoW Forever every bar left in its default position stacks on action bar 1, so moving it would drag the XP bar, stance bar and pet bar along or need them all pinned. Probed on the rogue 2026-11-24: `MainActionBar:EnableMouse(false)` makes action bar 2 on top clickable, `MainActionBar.Selection:EnableMouse(false)` lets action bar 2 be grabbed in Edit Mode, and both survive opening and closing Edit Mode.
- **Positions only when the layout is created** (cluster, chat, action bar 2), so later runs never undo the player's own moves; the exception is putting action bar 2 back on action bar 1 if it drifts off.
- **Mouse fix only on characters that are set up** (layout step finished with the layout ready).
- **Setup refuses while Edit Mode is open.** Switching to another layout doesn't bring up the offer.
- **Restore:** previous layout (Modern if it's gone) and action bar 2 state; then "Restore your keybinds too?" puts the 24 keys back to the account-wide copy saved the first time setup changed them. The layout is never deleted. It ends by telling the player to turn the addon off or uninstall it.
- **Design for a fresh install;** no special paths for existing characters.

- **`/wasd setup keys` goes:** `/wasd setup` lists only what's off, so it already covers fixing one key, and keys always come with the layout.
- **Options page:** Run setup and Restore replace Set up keybinds and Check layout.

## Depends on
`add-edit-mode-setup`, `add-key-binding-setup`, `add-options-panel`

## Impact
- Changed capabilities: `edit-mode-setup` (layout setup, mouse fix, restore), `key-binding-setup` (part of the one window; key copy for restore), `options-panel` (setup buttons)
- New files: `Logic/LayoutPlan.lua` (replaces `Logic/LayoutCheck.lua`), `Logic/LayoutCopy.lua`, `Logic/Restore.lua` and their tests
- Changed: `UI/Setup.lua`, `UI/Bindings.lua`, `UI/Options.lua`, `Core/Slash.lua`, `Logic/Settings.lua`, the TOC, `.pkgmeta`, `INSTALL.md`, `README.md`, `openspec/project.md`
- New runtime dependency: LibEditModeOverride
- `add-curseforge-publishing` no longer adds LibEditMode to `.pkgmeta`
