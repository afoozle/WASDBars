# Proposal: Deep clean

## Why
Thirteen changes in, parts of the code, docs and specs describe how WASDBars used to work, and some code was built for cases that later changes removed. Clean it up before going public with `add-curseforge-publishing`, so other players (and later changes) start from an accurate, simple base.

## What Changes
A review of the repo, then fixes for the findings the player accepts.

**In scope:** addon code (`Core/`, `Logic/`, `UI/`, the TOC, `.luacheckrc`), `tests/`, living docs (`README.md`, `INSTALL.md`, `CHANGELOG.md`, `CLAUDE.md`, `openspec/project.md`), capability specs (`openspec/specs/`), tooling (`Makefile`, `scripts/`, `.pkgmeta`, `.github/workflows/`). **Out of scope:** `openspec/changes/archive/` (history; only live pointers into it are fixed), `.claude/`.

The code is the source of truth. Findings:
- **Out of date:** docs, specs, comments and messages that don't match the code
- **Overengineered:** guards for cases that can no longer happen, code more general than its only use, leftovers of ideas later changes replaced. Not findings: the project's own rules (Logic/UI split and its tests, combat queue, `hooksecurefunc`, anything in `CLAUDE.md`)
- **Dead:** unused functions, settings, migrations, test helpers (removal needs a search showing no callers)
- **Structure:** functions over cyclomatic complexity 10, dependency cycles between `ns` modules, and SOLID applied pragmatically: a finding only if fixing it makes the code easier to read or change
- **Gaps that matter before going public:** player-visible behaviour no spec describes, `Logic/` functions without tests, commands or settings missing from README or INSTALL

Any size of fix accepted by the player is done in this change.

`.luacheckrc` gets `max_cyclomatic_complexity = 10`, enforced by `make check` and CI from now on.

## Depends on
`hide-main-bar`

## Impact
- Any in-scope file; capability specs corrected where they describe old behaviour
- Released as v1.1.1 straight after merging; the CurseForge beta takes the next number
