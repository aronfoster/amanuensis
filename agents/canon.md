# Canon Rules

The `canon/` folder contains world-level truth.

## Purpose of canon files

Canon files store global setting facts that should remain consistent across books and chapters unless intentionally revised.

Use canon files for:
- supernatural rules
- institutions
- history
- secrecy rules
- threat models
- factions
- resource systems
- other world truths

## Canon priority

If a conflict exists, canon files usually outrank planning files.

Default priority order:

1. `canon/`
2. `characters/` stable files
3. book `overview.md`
4. book `outline.md`
5. chapter `summary.md`
6. chapter `storyboard.md`
7. chapter `draft.md`
8. chapter `aftermath.md`

## Canon handling rule

World facts are the highest-priority, settled tier (see the priority order above).
A settled or load-bearing world fact must never be silently invented.

Whether a *missing* world fact may be invented at all is governed by the single
bounded-invention rule — **Rule 1 in `agents/update-rules.md`** — not restated here.
In short: an agent may supply a missing world detail only in the bounded, non-load-
bearing, non-conflicting, register-appropriate case Rule 1 permits, and only when that
invention is captured rather than hidden. Anything settled, load-bearing, or in
conflict with existing canon is off-limits.

If a needed fact falls outside what Rule 1 permits:
- record an open question
- note the uncertainty
- avoid pretending canon is settled when it is not
