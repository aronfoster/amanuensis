<!-- ILLUSTRATIVE EXAMPLE — NOT REAL PROJECT CANON OR STATE. See examples/relational-review/README.md.
     Excerpt of the advisory report `storyboard_review` produced for chapter 3, reviewing the
     storyboards PRE-DRAFT against `reveals.md`. It is report-only: no `<!-- review-id: -->` anchors,
     no `Decision:` fields, no draft-version stamp (there is no draft yet). This excerpt shows the
     reveal-timing failure — the fifth of the five demonstrated failures — as a PREMATURE (reveal)
     finding. Blocks with no finding are shown CLEAN; unrelated scene-2 blocks are elided. -->

## Storyboard Review — book1/chapter03, 2026-08-11

### Block 001 — CLEAN

### Block 002 — CLEAN

### Block 003
- PREMATURE (reveal): scene 1, Wick's suspicion — the block discloses reveal rv-01 (Captain Fenn forged the *Cormorant*'s manifest) before its `concealed-until:` book1/chapter04/scene02:block-005. The block's `## Reader takeaway` names the forgery outright at book1/chapter03/scene01:block-003 — a full book-position early — while the reader is meant to learn it only when the agent's letter arrives in chapter 4. [defect: storyboard] [ref: reveals.md#rv-01]

### Block 004 — CLEAN

### Summary

- Unsupported takeaways: 0
- Reveals without setup: 0
- Premature disclosures: 1
- Takeaway/concealment contradictions: 0
- Blocks fully clean: 3 of 4

The single premature disclosure is the reveal-timing failure. By the reveal-timing carve-out (canon > `reveals.md` > storyboard > prose), the leaking *storyboard* is the defect — the ledger is not relaxed to accommodate it — so the label is `[defect: storyboard]`, routed to the human revising the storyboard, not a "ledger is wrong" defect.

## Context consulted

- reveals.md#rv-01 (lands book1/chapter04/scene02:block-005; setup book1/chapter02/scene03:block-002, book1/chapter03/scene01:block-002; concealed-until book1/chapter04/scene02:block-005)
