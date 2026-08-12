Reviewed-draft: draft-v01.md

<!-- ILLUSTRATIVE EXAMPLE — NOT REAL PROJECT CANON OR STATE. See
     examples/unreviewed-confirmation/README.md.

     compliance_report's output for scene01 against draft-v01.md: two findings. Block
     002 took Check 3's Canon-check escalation path (canon_active was insufficient, so
     it opened canon/generated/frost-wards.md) and carries no [defect:] tag, per
     agents/steps/compliance-report.md ("Check 3 carries no [defect: <type>] tag
     today"). Block 003 is an ordinary Check 4 relational finding, resolved against
     continuity/story.md. Both resolved entries' per-entry markers read `unreviewed` at
     report time, so both violation lines carry `[premise: unreviewed]`. Both units are
     shown decided `Decision: FIX` by a human reviewer, and this file is shown already
     carried through compliance_fix: because `[premise: unreviewed]` is checked before
     the defect-label rule (agents/steps/compliance-fix.md), both `FIX` decisions route
     upstream via `Escalated:` blocks instead of a prose edit — the core safety property
     this fixture demonstrates. No FIX decision reaches prose, but compliance_fix still
     mints draft-v02.md (an unedited copy of draft-v01.md) and repoints Active-head: to
     it, per its completion contract — see draft-manifest.md. That leaves this file's
     `Reviewed-draft: draft-v01.md` stamp above STALE against the new active head, which
     is why the closing-step compliance_report re-run in the README is a regenerated
     (fresh-stamp, full-overwrite) run rather than an appended one. See the README for
     the confirm/correct-and-confirm `/revise` passes each Escalated: block's target
     routes to, and for the actual `validate-review-artifact.sh` output captured against
     this file. -->

## Compliance Report — Scene scene01, 2026-08-12

### Block 001 — CLEAN

### Block 002
<!-- review-id: compliance:scene01:block-002-v01 -->
- INCONSISTENT (canon): Frost-ward duration — "every two days, same as always" violates rule: "a chalked frost-ward holds a sealed crate for three days before it must be recast; past that, the verglass begins to sweat and crack" [premise: unreviewed] [ref: canon/generated/frost-wards.md#scene01-beat01-attempt01 "holds a sealed crate for three days before it must be recast"]
  - Decision: FIX
  - Decision-note:

### Block 003
<!-- review-id: compliance:scene01:block-003-v01 -->
- INCONSISTENT (chronology): elapsed time — "nine days out of Last Well" contradicts the maintained day-count. co-01 fixes the caravan at Day 6 out of Last Well at this position. Prose: "nine days out of Last Well". [defect: prose] [ref: continuity/story.md#co-01] [premise: unreviewed]
  - Decision: FIX
  - Decision-note:

### Block 004 — CLEAN

### Summary

- Must-Contain violations: 0
- Must-Not-Contain violations: 0
- Canon violations: 1
- Relational violations: 1
- Blocks fully clean: 2 of 4
- Review units emitted: 2

Both findings cite a per-entry marker that read `unreviewed` at report time — block 002
via Check 3's canon-escalation path, block 003 via Check 4's continuity resolution — and
both carry `[premise: unreviewed]`. See `## Context consulted` below and the
`Escalated:` blocks appended after this run's `compliance_fix` pass.

## Context consulted

- canon/generated/frost-wards.md#scene01-beat01-attempt01 (canon escalation — frost-ward recast duration; block 002's `canon_active` states the rule only generically)
- continuity/story.md#co-01 (chronology — day-count anchor out of Last Well)

#### Escalated: Frost-ward duration (review-id: compliance:scene01:block-002-v01)
- Reason: the violation line carries [premise: unreviewed] — the cited entry (canon/generated/frost-wards.md#scene01-beat01-attempt01) is itself unconfirmed, so a FIX cannot be applied to prose against an unconfirmed guess, regardless of the unit's (absent) defect label.
- Suggested upstream target: /revise against canon/generated/frost-wards.md#scene01-beat01-attempt01 — the self-contained locator, copied verbatim from the violation line's [ref:] tag.

#### Escalated: elapsed time (review-id: compliance:scene01:block-003-v01)
- Reason: the violation line carries [premise: unreviewed] — the cited entry (continuity/story.md#co-01) is itself unconfirmed, so a FIX cannot be applied to prose against an unconfirmed guess, even though its defect label reads prose.
- Suggested upstream target: /revise against continuity/story.md#co-01 — the minted id, copied verbatim from the violation line's [ref:] tag.
