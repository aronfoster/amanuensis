Reviewed-draft: draft-v02.md

<!-- ILLUSTRATIVE EXAMPLE — NOT REAL PROJECT CANON OR STATE. See examples/relational-review/README.md.
     The compliance report `compliance_report` produced for chapter03/scene02, draft-v02.md. Five
     relational findings (blocks 002–006), each a per-block review unit carrying a cited referent and
     a `[defect: <type>]` label; four are prose defects and one (block 006) is a state defect. The
     `Decision:` fields are shown FILLED (a human reviewed the report) so the compliance_fix routing
     can be demonstrated; the reveal-timing failure is a separate `storyboard_review` finding, in
     ../../storyboards/storyboard-review.md. Validates `proceed` (exit 0). -->

## Compliance Report — Scene scene02, 2026-08-11

### Block 001 — CLEAN

### Block 002
<!-- review-id: compliance:book1:chapter03:scene02:block-002-v01 -->
- INCONSISTENT (chronology): elapsed time — "the better part of a month at sea" contradicts the maintained day-count. co-02 fixes Day 1 at the Kettle Cove departure and co-05 fixes Day 12 at chapter 2's close, so this scene stands near Day 14 — roughly a fortnight, not a month. Prose: "the better part of a month at sea". [defect: prose] [ref: continuity/book-1.md#co-05]
  - Decision: FIX: change "the better part of a month at sea" to "near a fortnight at sea"
  - Decision-note:
### Block 003
<!-- review-id: compliance:book1:chapter03:scene02:block-003-v01 -->
- INCONSISTENT (character-knowledge): Wick — the prose has Wick accuse Fenn of deliberately altering the manifest, knowledge he is concealed from at this position. kn-02 holds him believing the short count an honest clerical error, and the storyboard block conceals the forgery from him; only the prose diverges. Prose: "You altered the tally yourself, and you knew it". [defect: prose] [ref: characters/wick/knowledge/book-1.md#kn-02]
  - Decision: FIX: have Wick press only on the short count as an error, not accuse Fenn of deliberate forgery
  - Decision-note:
### Block 004
<!-- review-id: compliance:book1:chapter03:scene02:block-004-v01 -->
- INCONSISTENT (event-staging): the lost longboat — Sable recalls the reef-squall as though the longboat was hauled back aboard and the water saved. co-03 fixes that Pell cut the towed longboat loose and it was lost, the spare water breaker gone with it, not recovered. Prose: "we got the boat back aboard before she took her — the water with it". [defect: prose] [ref: continuity/book-1.md#co-03]
  - Decision: FIX
  - Decision-note:
### Block 005
<!-- review-id: compliance:book1:chapter03:scene02:block-005-v01 -->
- INCONSISTENT (recap-fidelity): the Saltford log line — Fenn's dictated log summarizes the Saltford victualling as paid in silver, the account closed. co-04 fixes that Saltford victualled the ship on credit against the summer cargo, no coin down, the account still open. Prose: "provisioned at Saltford, paid in silver, the account closed". [defect: prose] [ref: continuity/book-1.md#co-04]
  - Decision: FIX
  - Decision-note:
### Block 006
<!-- review-id: compliance:book1:chapter03:scene02:block-006-v01 -->
- INCONSISTENT (role): the night helm — the prose stands Teague at the night helm as officer of the watch, against the maintained roster (co-06: Sable stands the night helm). But co-06's provenance resolves to chapter02/attempt01/draft-v03.md, a superseded attempt — chapter02's latest attempt is attempt02 — so the maintained role entry cannot be trusted as fresh: the entry itself is the problem, not the prose. Prose: "Teague took the night helm as officer of the watch". [defect: state] [ref: continuity/book-1.md#co-06]
  - Decision: ESCALATE
  - Decision-note: re-derive the night-helm role from chapter02/attempt02 (via continuity_update or revise) before judging the prose; do not edit prose on this unit.
### Block 007 — CLEAN

### Summary

- Must-Contain violations: 0
- Must-Not-Contain violations: 0
- Canon violations: 0
- Relational violations: 5
- Blocks fully clean: 2 of 7
- Review units emitted: 5

All five findings are relational. Four are prose defects (blocks 002–005); one (block 006) is a state defect whose maintained referent is stamped in a superseded attempt. No local (Must-Contain / Must-Not-Contain / Canon-as-stated) violations were found. The reveal-timing failure for this chapter is a separate `storyboard_review` finding, not a compliance unit.

## Context consulted

- continuity/book-1.md#co-02 (chronology — Day 1 departure anchor)
- continuity/book-1.md#co-05 (chronology — Day 12 anchor at chapter 2's close)
- continuity/book-1.md#co-03 (event staging — the longboat cut loose and lost)
- continuity/book-1.md#co-04 (event staging — the Saltford victualling terms)
- continuity/book-1.md#co-06 (role — night-helm assignment; provenance resolves to chapter02/attempt01, a superseded attempt)
- characters/wick/knowledge/book-1.md#kn-02 (concealment — what Wick believes about the short manifest at chapter03/scene02)
- plot/book1/chapter02/drafts/attempt02/draft-manifest.md (latest-attempt check that resolves co-06 as non-latest / superseded)
