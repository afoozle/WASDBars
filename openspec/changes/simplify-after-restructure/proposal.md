# Proposal: Simplify after restructure

## Why
Once `restructure-into-features` is done, simplify the new code rather than the old: remove what's dead or overengineered, and keep functions small from then on.

## What Changes
- A fresh review of the restructured code against the naming and structure rules in `CLAUDE.md`, for out-of-date, overengineered and dead code (guards for other game clients, unused parameters, duplicate work, nil checks that can't fail, leftover upgrade code), plus duplicated docs and tooling tidying
- `.luacheckrc` gets `max_cyclomatic_complexity = 10`, enforced by `make check` and CI
- Then the one in-game session for all three changes on branch `deep-clean`, merge, archive each, and release v1.1.1

How the review is run and decided gets grilled at the start of this change.

## Depends on
`restructure-into-features`

## Impact
Any file; released as v1.1.1 with `fix-what-is-wrong` and `restructure-into-features`.
